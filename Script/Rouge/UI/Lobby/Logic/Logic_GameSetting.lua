local M = {IsInit = false}
_G.LogicGameSetting = _G.LogicGameSetting or M
local GammaValueTagName = "Settings.Screen.Common.Lightness"
function LogicGameSetting.Init()
  if LogicGameSetting.IsInit then
    return
  end
  LogicGameSetting.IsInit = true
  LogicGameSetting.GameSettingsTreeStruct = {}
  LogicGameSetting.AllGameSettingsRowInfo = {}
  LogicGameSetting.AllGameSettingsLabelRowInfo = {}
  LogicGameSetting.GameSettingsParentChildTreeStruct = {}
  LogicGameSetting.TempGameSettingsValueList = {}
  LogicGameSetting.PreCustomKeyList = {}
  LogicGameSetting.GamepadCustomKeyRowNameToTableRowName = {}
  LogicGameSetting.GamepadCanNotChangeKeyNameList = {}
  LogicGameSetting.VisEffectByParentOptionTagList = {}
  LogicGameSetting.DealWithTable()
end
function LogicGameSetting.DealWithTable()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local GameSettingTreeStruct = {}
  local AllGameSettingInfo = DTSubsystem:GetAllGameSettings(nil):ToTable()
  for i, SingleGameSettingInfo in ipairs(AllGameSettingInfo) do
    if not UE.URGBlueprintLibrary.IsEmptyTag(SingleGameSettingInfo.Tag) then
      LogicGameSetting.InitGameSettingValue(SingleGameSettingInfo)
      local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(SingleGameSettingInfo.Tag)
      LogicGameSetting.AllGameSettingsRowInfo[TagName] = SingleGameSettingInfo
      local ParentTag = SingleGameSettingInfo.LabelTag
      if UE.URGBlueprintLibrary.IsEmptyTag(ParentTag) then
        ParentTag = UE.URGBlueprintLibrary.GetGameplayTagDirectParentTag(SingleGameSettingInfo.Tag)
      end
      local GameSettingsTagTable = LogicGameSetting.GameSettingsParentChildTreeStruct[UE.UBlueprintGameplayTagLibrary.GetTagName(ParentTag)]
      if UE.UBlueprintGameplayTagLibrary.IsGameplayTagValid(SingleGameSettingInfo.EffectByParentTagOption.ParentOptionTag) then
        if GameSettingsTagTable then
          local ParentTagName = UE.UBlueprintGameplayTagLibrary.GetTagName(SingleGameSettingInfo.EffectByParentTagOption.ParentOptionTag)
          local Index = table.IndexOf(GameSettingsTagTable, ParentTagName)
          if not Index then
            table.insert(GameSettingsTagTable, ParentTagName)
            table.insert(GameSettingsTagTable, TagName)
          else
            table.insert(GameSettingsTagTable, Index + 1, TagName)
          end
        else
          local ParentTagName = UE.UBlueprintGameplayTagLibrary.GetTagName(SingleGameSettingInfo.EffectByParentTagOption.ParentOptionTag)
          local Table = {ParentTagName, TagName}
          LogicGameSetting.GameSettingsParentChildTreeStruct[UE.UBlueprintGameplayTagLibrary.GetTagName(ParentTag)] = Table
        end
      elseif GameSettingsTagTable then
        table.insert(GameSettingsTagTable, UE.UBlueprintGameplayTagLibrary.GetTagName(SingleGameSettingInfo.Tag))
      else
        local Table = {
          UE.UBlueprintGameplayTagLibrary.GetTagName(SingleGameSettingInfo.Tag)
        }
        LogicGameSetting.GameSettingsParentChildTreeStruct[UE.UBlueprintGameplayTagLibrary.GetTagName(ParentTag)] = Table
      end
    else
      print("GameSettingRowInfo Tag is nil", SingleGameSettingInfo.Name)
    end
  end
  LogicGameSetting.InitScreenSettingsValue()
  LogicGameSetting.InitGammaValue()
  local AudioSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGAudioSubsystem:StaticClass())
  if AudioSubsystem then
    AudioSubsystem:UpdateAudioVolume()
  end
  local AllGameSettingLabels = DTSubsystem:GetAllGameSettingLabel(nil):ToTable()
  local FirstLabelsTag = {}
  local SecondLabelsTag = {}
  for i, SingleGameSettingLabelInfo in ipairs(AllGameSettingLabels) do
    if SingleGameSettingLabelInfo.LabelType == UE.ELabelType.FirstLabel then
      table.insert(FirstLabelsTag, SingleGameSettingLabelInfo.Tag)
      LogicGameSetting.GameSettingsTreeStruct[UE.UBlueprintGameplayTagLibrary.GetTagName(SingleGameSettingLabelInfo.Tag)] = {}
    elseif SingleGameSettingLabelInfo.LabelType == UE.ELabelType.SecondLabel then
      table.insert(SecondLabelsTag, SingleGameSettingLabelInfo.Tag)
    end
    LogicGameSetting.AllGameSettingsLabelRowInfo[UE.UBlueprintGameplayTagLibrary.GetTagName(SingleGameSettingLabelInfo.Tag)] = SingleGameSettingLabelInfo
  end
  for i, SingleTag in ipairs(SecondLabelsTag) do
    local ParentTag = UE.URGBlueprintLibrary.GetGameplayTagDirectParentTag(SingleTag)
    if table.Contain(FirstLabelsTag, ParentTag) then
      local TargetSecondLabelTags = LogicGameSetting.GameSettingsTreeStruct[UE.UBlueprintGameplayTagLibrary.GetTagName(ParentTag)]
      table.insert(TargetSecondLabelTags, UE.UBlueprintGameplayTagLibrary.GetTagName(SingleTag))
    end
  end
  local UserSetting = UE.UGameUserSettings.GetGameUserSettings()
  if UserSetting then
    UserSetting:SaveSettings()
  end
  local LocalizationModule = ModuleManager:Get("LocalizationModule")
  LocalizationModule:BindOnSettingsSaved()
  local AllRowNames = GetAllRowNames(DT.DT_CustomKey_Gamepad)
  for i, SingleRowName in ipairs(AllRowNames) do
    local Result, RowInfo = GetRowData(DT.DT_CustomKey_Gamepad, SingleRowName)
    if 1 == RowInfo.RowNames:Length() then
      LogicGameSetting.GamepadCustomKeyRowNameToTableRowName[RowInfo.RowNames[1]] = SingleRowName
      if not RowInfo.CanChange then
        local Key = LogicGameSetting.GetCurPlayerMappableKey(RowInfo.RowNames[1], UE.ECommonInputType.Gamepad)
        if Key then
          table.insert(LogicGameSetting.GamepadCanNotChangeKeyNameList, Key.KeyName)
        end
      end
    end
  end
end
function LogicGameSetting.InitGameSettingValue(RowInfo)
  local UserSetting = UE.UGameUserSettings.GetGameUserSettings()
  if not UserSetting then
    return
  end
  local Value = UserSetting:GetGameSettingByTag(RowInfo.Tag)
  if -1 == Value then
    if UE.UBlueprintGameplayTagLibrary.GetTagName(RowInfo.Tag) == "Settings.Language.Common.Interface" then
      local DefaultLanguage = UE.UKismetSystemLibrary.GetDefaultLanguage()
      local ISO6391Str = string.sub(DefaultLanguage, 1, 2)
      local TargetLocale
      local TargetSettingValue = 0
      for Number, CultureType in pairs(ECultureType) do
        local MatchStr = string.match(CultureType, ISO6391Str)
        if DefaultLanguage == CultureType or nil ~= MatchStr then
          TargetLocale = DefaultLanguage
          TargetSettingValue = Number
          break
        end
      end
      if not TargetLocale then
        TargetLocale = ECultureType[0]
        TargetSettingValue = 0
      end
      UserSetting:SetGameSettingByTag(RowInfo.Tag, TargetSettingValue)
      if not UE.RGUtil or not UE.RGUtil.IsEditor() then
        local LocalizationModule = ModuleManager:Get("LocalizationModule")
        if LocalizationModule then
          LocalizationModule:LuaCustomSetCurrentCulture(TargetLocale, false)
        else
          UE.URGBlueprintLibrary.CustomSetCurrentCulture(TargetLocale, false)
        end
      end
    else
      UserSetting:SetGameSettingByTag(RowInfo.Tag, RowInfo.DefaultValue)
    end
  end
end
local IsCurKeyType = function(Key, InputType)
  if UE.UKismetInputLibrary.Key_IsKeyboardKey(Key) then
    return UE.ECommonInputType.MouseAndKeyboard == InputType
  elseif UE.UKismetInputLibrary.Key_IsGamepadKey(Key) then
    return UE.ECommonInputType.Gamepad == InputType
  end
  return true
end
function LogicGameSetting.GetCurPlayerMappableKey(MappableKeyName, InputType)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local EnhancedInputLocalPlayerSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UEnhancedInputLocalPlayerSubsystem:StaticClass())
  local TargetKey
  local AllPlayerMappableKeyList = EnhancedInputLocalPlayerSystem:GetAllPlayerMappedKeyList()
  if AllPlayerMappableKeyList:Find(MappableKeyName) then
    TargetKey = EnhancedInputLocalPlayerSystem:GetPlayerMappedKey(MappableKeyName, nil)
    if not IsCurKeyType(TargetKey, InputType) then
      local InputSettings = UE.URGInputSettings.GetInputSettings()
      local AllDefaultMappableKeyByInputType = InputSettings:GetAllPlayerMappableKey()
      local AllDefaultMappableKey = AllDefaultMappableKeyByInputType:Find(InputType)
      TargetKey = AllDefaultMappableKey.MappableKeys:Find(MappableKeyName)
    end
  else
    local InputSettings = UE.URGInputSettings.GetInputSettings()
    local AllDefaultMappableKeyByInputType = InputSettings:GetAllPlayerMappableKey()
    local AllDefaultMappableKey = AllDefaultMappableKeyByInputType:Find(InputType)
    TargetKey = AllDefaultMappableKey.MappableKeys:Find(MappableKeyName)
  end
  return TargetKey
end
function LogicGameSetting.InitCustomKeySetting()
  local InputSettings = UE.UInputSettings.GetInputSettings()
  if not InputSettings then
    print("LogicGameSetting.InitCustomKeySetting InputSettings is nil")
    return
  end
  local GameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not GameUserSettings then
    return
  end
  local UserId = DataMgr.GetUserId()
  if UE.URGBlueprintLibrary.CheckWithEditor() and not LogicLobby.IsInLobbyLevel() then
    UserId = ""
  end
  local CustomKeyLocalConfigResult, CustomKeyLocalConfig = GameUserSettings:GetCustomKeyDatasByRoleId(UserId, nil)
  if not CustomKeyLocalConfigResult then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local EnhancedInputLocalPlayerSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UEnhancedInputLocalPlayerSubsystem:StaticClass())
  local Options = UE.FModifyContextOptions()
  for KeyRowName, CustomKeyData in pairs(CustomKeyLocalConfig.CustomKeyDataList) do
    EnhancedInputLocalPlayerSystem:AddPlayerMappedKey(KeyRowName, UE.URGBlueprintLibrary.MakeKey(CustomKeyData.KeyName, nil), Options)
  end
end
function LogicGameSetting.GetScreenSettingValueList()
  local ScreenSettingsList = {
    ["Settings.Screen.Quality.Overall"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      local Value = RGGameUserSettings:GetOverallQualityValue()
      if -1 == Value then
        Value = 4
      end
      return Value
    end,
    ["Settings.Screen.Common.FullscreenMode"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetRGFullscreenMode()
    end,
    ["Settings.Screen.Common.Resolution"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      local ResolutionName = RGGameUserSettings:Lua_GetCurrentResolutionByName(nil)
      return ResolutionName
    end,
    ["Settings.Screen.Common.MaxFPS"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      local FrameRateLimit = RGGameUserSettings:GetFrameRateLimit()
      if FrameRateLimit < 0 then
        FrameRateLimit = RGGameUserSettings:GetCurrentRefreshRate()
      end
      return FrameRateLimit
    end,
    ["Settings.Screen.Common.VSync"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:IsVSyncEnabled()
    end,
    ["Settings.Screen.Common.AntiAliasingQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetAntiAliasingQuality()
    end,
    ["Settings.Screen.Common.MotionBlur"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:IsMotionBlurEnabled()
    end,
    ["Settings.Screen.Quality.NiagaraParticleQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetNiagaraParticleQuality()
    end,
    ["Settings.Screen.Quality.MeshQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetViewDistanceQuality()
    end,
    ["Settings.Screen.Quality.TextureQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetTextureQuality()
    end,
    ["Settings.Screen.Quality.ShadowQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetShadowQuality()
    end,
    ["Settings.Screen.Quality.VolumetricEffectsQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetVolumetricEffectsQuality()
    end,
    ["Settings.Screen.Quality.ScreenSpaceReflectionQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetScreenSpaceReflectionQuality()
    end,
    ["Settings.Screen.Quality.AmbientOcclusionQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetAmbientOcclusionQuality()
    end,
    ["Settings.Screen.Quality.PostProcessingQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetPostProcessingQuality()
    end,
    ["Settings.Screen.Quality.LightingQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetLightingQuality()
    end,
    ["Settings.Screen.Quality.PhysicalSimulationQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetPhysicalSimulationQuality()
    end,
    ["Settings.Screen.Common.GraphicsRHI"] = function()
      return UE.URGGameUserSettings.GetDefaultGraphicsRHI() - 1
    end,
    ["Settings.Screen.Common.Monitor"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return ""
      end
      return RGGameUserSettings:Lua_GetCurrentMonitorName()
    end,
    ["Settings.Screen.Common.ResolutionRatio"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      if RGGameUserSettings:IsDLSSEnabled() then
        return 1
      end
      if RGGameUserSettings:IsFSR2Enabled() then
        return 2
      end
      return 0
    end,
    ["Settings.Screen.Common.DLSSQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetDLSSQuality()
    end,
    ["Settings.Screen.Common.FSRQuality"] = function()
      local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
      if not RGGameUserSettings then
        return 0
      end
      return RGGameUserSettings:GetFSR2Quality()
    end,
    ["Settings.Privacy.Common.BattleRecord"] = function()
      return DataMgr.GetPlayerInvisible(1)
    end,
    ["Settings.Privacy.Common.Rank"] = function()
      return DataMgr.GetPlayerInvisible(2)
    end
  }
  return ScreenSettingsList
end
function LogicGameSetting.GetScreenSettingValue(TagName)
  local ScreenSettingsList = LogicGameSetting.GetScreenSettingValueList()
  if not ScreenSettingsList[TagName] then
    return nil
  end
  local Value = ScreenSettingsList[TagName]()
  if "Settings.Screen.Common.MaxFPS" == TagName then
    Value = LogicGameSetting.GetFPSLimitDisplayOptionIndex(Value)
  elseif "Settings.Screen.Common.AntiAliasingQuality" == TagName then
    Value = LogicGameSetting.GetAntiAliasingValue(Value)
  end
  if type(Value) == "boolean" then
    if Value then
      Value = 0
    else
      Value = 1
    end
  end
  return Value
end
function LogicGameSetting.InitScreenSettingsValue()
  local ScreenSettingsList = LogicGameSetting.GetScreenSettingValueList()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  if RGGameUserSettings:GetIsFirstRunGame() then
    print("LogicGameSetting.InitScreenSettingsValue Execute First Run Game Recommend Settings")
  end
  for TagName, Func in pairs(ScreenSettingsList) do
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TagName, nil)
    local Value = Func()
    if "Settings.Screen.Common.MaxFPS" == TagName then
      Value = LogicGameSetting.GetFPSLimitDisplayOptionIndex(Value)
    end
    if "Settings.Screen.Common.AntiAliasingQuality" == TagName then
      Value = LogicGameSetting.GetAntiAliasingValue(Value)
    end
    if type(Value) == "boolean" then
      if Value then
        Value = 0
      else
        Value = 1
      end
    end
    if type(Value) == "number" then
      RGGameUserSettings:SetGameSettingByTag(Tag, Value)
    end
  end
end
function LogicGameSetting.ExecuteScreenSettingsRecommendLogic()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  RGGameUserSettings:RunHardwareBenchmark()
  RGGameUserSettings:ApplyHardwareBenchmarkResults()
end
function LogicGameSetting.InitGammaValue()
  local SettingGammaValue = LogicGameSetting.GetGameSettingValue(GammaValueTagName)
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local ConsoleVarGammaValue = math.floor(RGGameUserSettings:GetGammaValue() * 10)
  if ConsoleVarGammaValue ~= SettingGammaValue then
    LogicGameSetting.SetGammaValue(SettingGammaValue)
  end
end
function LogicGameSetting.SetGammaValue(Value)
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  RGGameUserSettings:SetGammaValue(Value / 10)
end
function LogicGameSetting.GetAllResolutions()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local AllResolutions = RGGameUserSettings:Lua_GetAllResolutionsByName(nil)
  return AllResolutions:ToTable()
end
function LogicGameSetting.GetAllMonitorNames()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return {}
  end
  local AllMonitors = RGGameUserSettings:Lua_GetAllMonitorNames(nil)
  return AllMonitors:ToTable()
end
function LogicGameSetting.GetDefaultResolution()
  local AllResolutions = LogicGameSetting.GetAllResolutions()
  if AllResolutions and AllResolutions[#AllResolutions] then
    return AllResolutions[#AllResolutions]
  end
  return ""
end
function LogicGameSetting.GetAntiAliasingValue(InScalabilityValue)
  if InScalabilityValue > 0 then
    return 0
  else
    return 1
  end
end
function LogicGameSetting.GetAntiAliasingScalabilityValue(SettingValue)
  if 0 == SettingValue then
    return 4
  else
    return 0
  end
end
function LogicGameSetting.GetFPSList()
  local RowInfo = LogicGameSetting.GetSettingsRowInfo("Settings.Screen.Common.MaxFPS")
  local FPSList = {}
  local TargetFPSList = {}
  local GameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if GameUserSettings then
    TargetFPSList = GameUserSettings:GetFrameRateLimitList()
  end
  if 0 == table.count(TargetFPSList) then
    for index, SingleOptionInfo in pairs(RowInfo.SettingOptionsList) do
      FPSList[tostring(SingleOptionInfo.OptionText)] = SingleOptionInfo.OptionValue
    end
  else
    for index, SingleOptionInfo in pairs(TargetFPSList) do
      FPSList[tostring(SingleOptionInfo.OptionText)] = SingleOptionInfo.OptionValue
    end
  end
  print("LogicGameSetting.GetFPSList", "FPSList", table.count(FPSList))
  return FPSList
end
function LogicGameSetting.GetFPSLimitDisplayOptionIndex(InValue)
  print("LogicGameSetting.GetFPSLimitDisplayOptionIndex", "InValue", InValue)
  local FPSList = LogicGameSetting.GetFPSList()
  local MaxOptionIndex = 0
  for Value, OptionIndex in pairs(FPSList) do
    if OptionIndex > MaxOptionIndex then
      MaxOptionIndex = OptionIndex
    end
  end
  return FPSList[tostring(math.ceil(InValue))] and FPSList[tostring(math.ceil(InValue))] or MaxOptionIndex
end
function LogicGameSetting.GetFPSLimitValue(Index)
  local FPSList = LogicGameSetting.GetFPSList()
  for Value, OptionIndex in pairs(FPSList) do
    if OptionIndex == Index then
      return tonumber(Value) or 0
    end
  end
  return 0
end
function LogicGameSetting.ShowGameSettingPanel()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.SETTINGS) then
    return
  end
  if LogicLobby.IsInLobbyLevel() then
    if UIMgr:IsShow(ViewID.UI_GameSettingsMain) then
      UIMgr:Hide(ViewID.UI_GameSettingsMain, true)
    else
      UIMgr:Show(ViewID.UI_GameSettingsMain, true)
      local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
      if UserClickStatisticsMgr then
        UserClickStatisticsMgr:AddClickStatistics("LobbySetting")
      end
    end
  else
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
    if not UIManager then
      return
    end
    local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/GameSettings/WBP_GameSettingsMain.WBP_GameSettingsMain_C")
    UIManager:Switch(WidgetClass, true)
    if RGUIMgr:IsShown(UIConfig.WBP_GameSettingsMain_C.UIName) then
      local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
      if UserClickStatisticsMgr then
        UserClickStatisticsMgr:AddClickStatistics("LobbySetting")
      end
    end
  end
end
function LogicGameSetting.GetLabelRowInfo(TagName)
  return LogicGameSetting.AllGameSettingsLabelRowInfo[TagName]
end
function LogicGameSetting.GetSettingsRowInfo(TagName)
  return LogicGameSetting.AllGameSettingsRowInfo[TagName]
end
function LogicGameSetting.GetTempOverallQualityValue()
  local TagName = "Settings.Screen.Quality.Overall"
  local TempValue = LogicGameSetting.GetTempGameSettingValue(TagName)
  if 4 == TempValue then
    TempValue = -1
  end
  return TempValue
end
function LogicGameSetting.SetTempGameSettingsValue(TagName, Value, IsNeedBroadcast)
  local CurrentSettingValue = LogicGameSetting.GetGameSettingValue(TagName)
  if CurrentSettingValue ~= Value then
    LogicGameSetting.TempGameSettingsValueList[TagName] = Value
    if type(Value) == "number" then
      UE.URGBlueprintLibrary.TriggerSetTempGameSettingsValue(TagName, Value)
    end
  elseif LogicGameSetting.TempGameSettingsValueList[TagName] then
    LogicGameSetting.TempGameSettingsValueList[TagName] = nil
    if type(Value) == "number" then
      UE.URGBlueprintLibrary.TriggerSetTempGameSettingsValue(TagName, Value)
    end
  end
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(TagName)
  if SettingRowInfo then
    local TargetEffectOtherSettingList
    for key, SingleEffectOtherSettingsOptionList in pairs(SettingRowInfo.EffectOtherSettingsOptionList) do
      if SingleEffectOtherSettingsOptionList.MainOptionValue == Value then
        TargetEffectOtherSettingList = SingleEffectOtherSettingsOptionList.EffectOtherSettingList:ToTable()
      end
    end
    if TargetEffectOtherSettingList then
      local OptionTagList = {}
      for SingleOptionTag, SingleOptionValue in pairs(TargetEffectOtherSettingList) do
        LogicGameSetting.SetTempGameSettingsValue(UE.UBlueprintGameplayTagLibrary.GetTagName(SingleOptionTag), SingleOptionValue, false)
        table.insert(OptionTagList, UE.UBlueprintGameplayTagLibrary.GetTagName(SingleOptionTag))
      end
      if table.count(OptionTagList) > 0 then
        EventSystem.Invoke(EventDef.GameSettings.OnGameSettingItemValueBeChanged, OptionTagList)
      end
    end
  end
  if nil == IsNeedBroadcast or IsNeedBroadcast then
    EventSystem.Invoke(EventDef.GameSettings.OnTempGameSettingListChanged, table.count(LogicGameSetting.TempGameSettingsValueList) > 0, TagName)
  end
end
function LogicGameSetting.GetTempGameSettingValue(TagName)
  return LogicGameSetting.TempGameSettingsValueList[TagName]
end
function LogicGameSetting.ClearTempGameSettingValueList()
  LogicGameSetting.TempGameSettingsValueList = {}
  UE.URGBlueprintLibrary.TriggerClearTempGameSettingValueList()
  EventSystem.Invoke(EventDef.GameSettings.OnTempGameSettingListChanged, table.count(LogicGameSetting.TempGameSettingsValueList) > 0)
end
function LogicGameSetting.SetPreCustomKeyList(KeyRowName, InKey, InKeyName, InOldKey)
  if InKey then
    local TempTable = {
      Key = UE.UKismetStringLibrary.Replace(InKey, " ", ""),
      KeyName = InKeyName,
      OldKey = UE.UKismetStringLibrary.Replace(InOldKey, " ", "")
    }
    LogicGameSetting.PreCustomKeyList[KeyRowName] = TempTable
  else
    LogicGameSetting.PreCustomKeyList[KeyRowName] = nil
  end
  EventSystem.Invoke(EventDef.GameSettings.OnTempGameSettingListChanged, table.count(LogicGameSetting.PreCustomKeyList) > 0)
end
function LogicGameSetting.GetPreCustomKeyList()
  return LogicGameSetting.PreCustomKeyList
end
function LogicGameSetting.ClearPreCustomKeyList()
  LogicGameSetting.PreCustomKeyList = {}
  EventSystem.Invoke(EventDef.GameSettings.OnTempGameSettingListChanged, table.count(LogicGameSetting.PreCustomKeyList) > 0)
end
function LogicGameSetting.GetGameSettingValue(TagName)
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return -1
  end
  local Value = LogicGameSetting.GetScreenSettingValue(TagName)
  if Value then
    return Value
  end
  local GameplayTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TagName, nil)
  return RGGameUserSettings:GetGameSettingByTag(GameplayTag)
end
function LogicGameSetting.GetSecondLabelsByFirstLabel(LabelName)
  return LogicGameSetting.GameSettingsTreeStruct[LabelName]
end
function LogicGameSetting.GetSettingsBySecondLabel(LabelName)
  return LogicGameSetting.GameSettingsParentChildTreeStruct[LabelName]
end
function LogicGameSetting.GetCurSelectedKeyNameByKeyRowName(KeyRowName, KeyIconUseType, TargetInputType)
  local KeyName = KeyRowName
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if not CommonInputSubsystem then
    print("LogicGameSetting.GetCurSelectedKeyNameByKeyRowName CommonInputSubsystem is nil")
    return KeyRowName, false
  end
  local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
  if TargetInputType then
    CurrentInputType = TargetInputType
  end
  local CurKey = LogicGameSetting.GetCurPlayerMappableKey(KeyRowName, CurrentInputType)
  if CurKey then
    KeyName = CurKey.KeyName
  end
  return LogicGameSetting.GetKeyDisplayInfoByKeyName(KeyName, KeyIconUseType)
end
function LogicGameSetting.GetKeyDisplayInfoByKeyName(KeyName, KeyIconUseType)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if not CommonInputSubsystem then
    print("LogicGameSetting.GetKeyDisplayInfoByKeyName CommonInputSubsystem is nil")
    return KeyName, false
  end
  local BResult, KeyIconRowInfo = GetRowData(DT.DT_KeyIcon, KeyName)
  if BResult then
    if KeyIconRowInfo.IsUseIcon then
      KeyIconUseType = KeyIconUseType or UE.EKeyIconUseType.UI
      local IconList
      if KeyIconRowInfo.IsGamepad then
        local CurGamepadName = CommonInputSubsystem:GetCurrentGamepadName()
        local TargetGamepadKeyIcon = KeyIconRowInfo.GamepadIconList:Find(tostring(CurGamepadName))
        if TargetGamepadKeyIcon then
          IconList = TargetGamepadKeyIcon.IconList
        end
      end
      IconList = IconList or KeyIconRowInfo.IconList
      local TargetIcon = IconList:Find(KeyIconUseType)
      TargetIcon = TargetIcon or KeyIconRowInfo.Icon
      return TargetIcon, true
    else
      return KeyIconRowInfo.DisplayName, false
    end
  end
  return KeyName, false
end
function LogicGameSetting.GetDamageNumberStyleTagName()
  return "Settings.GameSetting.DamageNumber.DamageNumberStyle"
end
function LogicGameSetting.GetTableRowNameByInputRowName(InputRowName)
  return LogicGameSetting.GamepadCustomKeyRowNameToTableRowName[InputRowName] and LogicGameSetting.GamepadCustomKeyRowNameToTableRowName[InputRowName] or InputRowName
end
function LogicGameSetting.GetGamepadCanNotChangeKeyNameList(...)
  return LogicGameSetting.GamepadCanNotChangeKeyNameList
end
function LogicGameSetting.SetVisEffectByParentOptionTag(TagName, IsShow)
  LogicGameSetting.VisEffectByParentOptionTagList[TagName] = IsShow
end
function LogicGameSetting.GetVisEffectByParentOptionTagList(...)
  return LogicGameSetting.VisEffectByParentOptionTagList
end
function LogicGameSetting.Clear()
  LogicGameSetting.IsInit = false
  LogicGameSetting.GameSettingsTreeStruct = {}
  LogicGameSetting.AllGameSettingsRowInfo = {}
  LogicGameSetting.AllGameSettingsLabelRowInfo = {}
  LogicGameSetting.GameSettingsParentChildTreeStruct = {}
  LogicGameSetting.VisEffectByParentOptionTagList = {}
  LogicGameSetting.ClearTempGameSettingValueList()
  LogicGameSetting.ClearPreCustomKeyList()
end
