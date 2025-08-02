local WBP_GameSettingsMain_C = UnLua.Class()
local TLogSaveSettings = {
  "Settings.GameSetting.Control.AutoSprint"
}
local PadLeftSwitch = "MainPanelLeftSwitch"
local PadRightSwitch = "MainPanelRightSwitch"
local RestoreBtnCDTip = 1408
local DeleteAccountTagName = "Settings.Privacy.Agreement.Entrance6"

function WBP_GameSettingsMain_C:Construct()
  if self.EscFunctionalButton.OnMainButtonClicked then
    self.EscFunctionalButton.OnMainButtonClicked:Add(self, self.BindOnEscButtonClicked)
  end
  if self.RestoreFunctionalButton.OnMainButtonClicked then
    self.RestoreFunctionalButton.OnMainButtonClicked:Add(self, self.BindOnRestoreButtonClicked)
  end
  if self.SaveFunctionalButton.OnMainButtonClicked then
    self.SaveFunctionalButton.OnMainButtonClicked:Add(self, self.BindOnSaveButtonClicked)
  end
  EventSystem.AddListener(self, EventDef.GameSettings.OnTitleButtonClicked, WBP_GameSettingsMain_C.BindOnTitleButtonClicked)
  self:InitTitleButton()
  self.Btn_TipConfirm.OnClicked:Add(self, WBP_GameSettingsMain_C.BindOnTipConfirmButtonClicked)
  self.Btn_TipCancel.OnClicked:Add(self, WBP_GameSettingsMain_C.BindOnTipCancelButtonClicked)
  self.Btn_Cancel.OnClicked:Add(self, self.BindOnCancelButtonClicked)
end

function WBP_GameSettingsMain_C:ChangeSaveButtonVis(IsShow)
  if IsShow then
    self.SaveFunctionalButton:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.SaveFunctionalButton:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_GameSettingsMain_C:OnShow(...)
  print("WBP_GameSettingsMain_C:OnShow CursorVirtualFocus 1")
  UE.URGBlueprintLibrary.CursorVirtualFocus(1)
  self:OnDisplay()
end

function WBP_GameSettingsMain_C:OnHide(...)
  print("WBP_GameSettingsMain_C:OnHide CursorVirtualFocus 0")
  UE.URGBlueprintLibrary.CursorVirtualFocus(0)
  self:OnUnDisplay()
end

function WBP_GameSettingsMain_C:BindOnTipConfirmButtonClicked()
  self:BindOnSaveButtonClicked()
  self:HidePanel()
end

function WBP_GameSettingsMain_C:BindOnTipCancelButtonClicked()
  for key, SingleIndependentWidget in ipairs(self.NeedSaveIndependentWidgetList) do
    if SingleIndependentWidget.CancelSaveSettings then
      SingleIndependentWidget:CancelSaveSettings()
    end
  end
  self.NeedSaveIndependentWidgetList = {}
  LogicGameSetting.ClearTempGameSettingValueList()
  self:HidePanel()
end

function WBP_GameSettingsMain_C:BindOnCancelButtonClicked(...)
  UpdateVisibility(self.SaveSettingsTip, false)
  self:Bp_InputTypeToGamePadUpdateFocus()
end

function WBP_GameSettingsMain_C:HidePanel()
  self:PlayAnimation(self.Ani_out, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end

function WBP_GameSettingsMain_C:OnAnimationFinished(InAnimation)
  if self.Ani_out == InAnimation then
    LogicGameSetting.ShowGameSettingPanel()
  end
end

function WBP_GameSettingsMain_C:SaveScreenSettings()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local OverallQualityValue = LogicGameSetting.GetTempOverallQualityValue()
  if OverallQualityValue then
    RGGameUserSettings:SetOverallQualityValue(OverallQualityValue)
  end
  local IsUpdateScreenMode = false
  local AllScreenSettingTags = self.NumScreenSettingsTag:Keys():ToTable()
  for i, SingleScreenSettingTag in pairs(AllScreenSettingTags) do
    local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(SingleScreenSettingTag)
    local FunctionName = RGGameUserSettings[self.NumScreenSettingsTag:Find(SingleScreenSettingTag)]
    if LogicGameSetting.GetTempGameSettingValue(TagName) and FunctionName then
      if UE.UBlueprintGameplayTagLibrary.HasTag(self.ScreenModeTagContainer, SingleScreenSettingTag, true) then
        IsUpdateScreenMode = true
      end
      FunctionName(RGGameUserSettings, LogicGameSetting.GetTempGameSettingValue(TagName))
    end
  end
  local AllBoolScreenSettingTags = self.BoolScreenSettingsTag:Keys():ToTable()
  for i, SingleScreenSettingTag in pairs(AllBoolScreenSettingTags) do
    local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(SingleScreenSettingTag)
    local FunctionName = RGGameUserSettings[self.BoolScreenSettingsTag:Find(SingleScreenSettingTag)]
    if LogicGameSetting.GetTempGameSettingValue(TagName) and FunctionName then
      local BoolValue = 0 == LogicGameSetting.GetTempGameSettingValue(TagName) and true or false
      FunctionName(RGGameUserSettings, BoolValue)
    end
  end
  self:SaveResolution()
  self:SaveFPSLimit()
  self:SaveAntiAliasingQuality()
  self:SaveGraphicsRHI()
  self:SaveMonitorSetting()
  self:SaveResolutionRatio()
  self:SavePrivacy()
end

function WBP_GameSettingsMain_C:SaveResolution()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(self.ResolutionTag)
  local TargetValue = LogicGameSetting.GetTempGameSettingValue(TagName)
  if TargetValue then
    RGGameUserSettings:SetScreenResolutionByName(TargetValue)
  end
end

function WBP_GameSettingsMain_C:SaveFPSLimit()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(self.FPSTag)
  local TargetValue = LogicGameSetting.GetTempGameSettingValue(TagName)
  if not TargetValue then
    return
  end
  local FinalValue = LogicGameSetting.GetFPSLimitValue(TargetValue)
  RGGameUserSettings:SetFrameRateLimit(FinalValue)
end

function WBP_GameSettingsMain_C:SaveAntiAliasingQuality()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(self.AntiAliasingQualityTag)
  local TargetValue = LogicGameSetting.GetTempGameSettingValue(TagName)
  if not TargetValue then
    return
  end
  local FinalValue = LogicGameSetting.GetAntiAliasingScalabilityValue(TargetValue)
  RGGameUserSettings:SetAntiAliasingQuality(FinalValue)
end

function WBP_GameSettingsMain_C:SaveGraphicsRHI()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(self.GraphicsRHITag)
  local TargetValue = LogicGameSetting.GetTempGameSettingValue(TagName)
  if TargetValue then
    UE.URGGameUserSettings.SetDefaultGraphicsRHI(TargetValue + 1)
  end
end

function WBP_GameSettingsMain_C:SaveMonitorSetting()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(self.MonitorTag)
  local TargetValue = LogicGameSetting.GetTempGameSettingValue(TagName)
  if TargetValue then
    print("WBP_GameSettingsMain_C:SaveMonitorSetting InvokeMonitorValueChanged")
    EventSystem.Invoke(EventDef.GameSettings.OnMonitorValueChanged)
  end
end

function WBP_GameSettingsMain_C:SaveResolutionRatio(...)
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local TargetValue = LogicGameSetting.GetTempGameSettingValue("Settings.Screen.Common.ResolutionRatio")
  if not TargetValue then
    return
  end
  RGGameUserSettings:SetDLSSEnabled(1 == TargetValue)
  RGGameUserSettings:SetFSR2Enabled(2 == TargetValue)
end

function WBP_GameSettingsMain_C:SavePrivacy()
  local BattleRecord = LogicGameSetting.GetTempGameSettingValue("Settings.Privacy.Common.BattleRecord")
  if BattleRecord then
    DataMgr.SetPlayerInvisible(1, BattleRecord)
  end
  local RankValue = LogicGameSetting.GetTempGameSettingValue("Settings.Privacy.Common.Rank")
  if RankValue then
    DataMgr.SetPlayerInvisible(2, RankValue)
  end
end

function WBP_GameSettingsMain_C:InitTitleButton()
  local GameSettingTreeStruct = LogicGameSetting.GameSettingsTreeStruct
  local AllChildren = self.TitleButtonPanel:GetAllChildren()
  for i, SingleChild in pairs(AllChildren) do
    SingleChild:Hide()
  end
  self.FirstLabelTable = {}
  for SingleFirstLabel, SingleSecondLabelInfo in pairs(GameSettingTreeStruct) do
    table.insert(self.FirstLabelTable, SingleFirstLabel)
  end
  table.sort(self.FirstLabelTable, function(a, b)
    local ARowInfo = LogicGameSetting.GetLabelRowInfo(a)
    local BRowInfo = LogicGameSetting.GetLabelRowInfo(b)
    if ARowInfo.Priority == BRowInfo.Priority then
      return a < b
    end
    return ARowInfo.Priority > BRowInfo.Priority
  end)
  for i, SingleFirstLabel in ipairs(self.FirstLabelTable) do
    local Item = self.TitleButtonPanel:GetChildAt(i - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.ButtonItemTemplate:StaticClass())
      self.TitleButtonPanel:AddChild(Item)
    end
    Item:Show(SingleFirstLabel)
    Item:SetNavigationRuleCustom(UE.EUINavigation.Right, {
      self,
      self.DoCustomNavigation
    })
  end
end

function WBP_GameSettingsMain_C:OnDisplay()
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if RGGameUserSettings then
    RGGameUserSettings:RefreshAllCachedResolutions()
  end
  SetInputMode_GameAndUIEx(self:GetOwningPlayer(), self, UE.EMouseLockMode.LockAlways)
  self:PlayAnimation(self.Ani_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  LogicGameSetting.InitScreenSettingsValue()
  EventSystem.AddListener(self, EventDef.GameSettings.OnTitleButtonClicked, WBP_GameSettingsMain_C.BindOnTitleButtonClicked)
  EventSystem.AddListener(self, EventDef.GameSettings.OnEditItemClicked, WBP_GameSettingsMain_C.BindOnEditItemClicked)
  EventSystem.AddListener(self, EventDef.GameSettings.OnUrlItemClicked, WBP_GameSettingsMain_C.BindOnUrlItemClicked)
  EventSystem.AddListener(self, EventDef.GameSettings.OnItemHovered, WBP_GameSettingsMain_C.BindOnItemHovered)
  EventSystem.AddListener(self, EventDef.GameSettings.OnTempGameSettingListChanged, WBP_GameSettingsMain_C.BindOnTempGameSettingListChanged)
  EventSystem.AddListenerNew(EventDef.GameSettings.OnItemNavigation, self, self.BindOnItemNavigation)
  if not IsListeningForInputAction(self, self.EscKeyName) then
    ListenForInputAction(self.EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscButtonClicked
    })
  end
  if not IsListeningForInputAction(self, self.RestoreKeyName) then
    ListenForInputAction(self.RestoreKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnRestoreButtonClicked
    })
  end
  if not IsListeningForInputAction(self, self.SaveKeyName) then
    ListenForInputAction(self.SaveKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnSaveButtonClicked
    })
  end
  if not IsListeningForInputAction(self, PadLeftSwitch) then
    ListenForInputAction(PadLeftSwitch, UE.EInputEvent, true, {
      self,
      self.BindOnPreviousKeyPressed
    })
  end
  if not IsListeningForInputAction(self, PadRightSwitch) then
    ListenForInputAction(PadRightSwitch, UE.EInputEvent, true, {
      self,
      self.BindOnNextKeyPressed
    })
  end
  self:SetEnhancedInputActionBlocking(true)
  self:ChangeSaveButtonVis(false)
  self:RefreshEditWidgetVisibility(false)
  self.SaveSettingsTip:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.NeedSaveIndependentWidgetList = {}
  self.DescList:SetVisibility(UE.ESlateVisibility.Collapsed)
  UpdateVisibility(self.Img_DescMovie, false)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  self:RegisterScrollRecipient(self.MainList)
  local TargetSelectItem = self.TitleButtonPanel:GetChildAt(0)
  if TargetSelectItem then
    TargetSelectItem:BindOnMainButtonClicked()
  end
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      local TargetSelectItem = self.TitleButtonPanel:GetChildAt(0)
      if TargetSelectItem then
        TargetSelectItem:SetKeyboardFocus()
      end
    end
  }, 0.1, false)
end

function WBP_GameSettingsMain_C:Bp_InputTypeToGamePadUpdateFocus(...)
  EventSystem.Invoke(EventDef.GameSettings.OnTitleButtonClicked, self.CurSelectedTagName, true)
end

function WBP_GameSettingsMain_C:BindOnTitleButtonClicked(TagName, IsNeedFocus)
  if self.CurSelectedTagName == TagName then
    return
  end
  local TargetWidget = self.TitleIndependentWidgetSwitcher:GetActiveWidget()
  if self.TitleIndependentWidgetSwitcher:IsVisible() and TargetWidget and TargetWidget.HidePanel then
    TargetWidget:HidePanel()
  end
  self.CurSelectedTagName = TagName
  self.MainListPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.TitleIndependentWidgetSwitcher:SetVisibility(UE.ESlateVisibility.Collapsed)
  local FirstLabelInfo = LogicGameSetting.GetLabelRowInfo(self.CurSelectedTagName)
  if FirstLabelInfo and FirstLabelInfo.IsIndependentPanel then
    self.TitleIndependentWidgetSwitcher:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:ShowIndependentPanel()
  else
    self.TitleIndependentWidgetSwitcher:SetActiveWidget(nil)
    self.MainListPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshMainList()
    if not IsNeedFocus then
      local SecondLabelList = LogicGameSetting.GetSecondLabelsByFirstLabel(self.CurSelectedTagName)
      local Settings = LogicGameSetting.GetSettingsBySecondLabel(SecondLabelList[1])
      EventSystem.Invoke(EventDef.GameSettings.OnItemSelected, Settings[1])
    end
  end
end

function WBP_GameSettingsMain_C:BindOnEditItemClicked(TagName)
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(TagName)
  if UE.URGBlueprintLibrary.IsValidSoftObjectPath(SettingRowInfo.WidgetClassPath) then
    self:RefreshEditWidgetVisibility(true)
    local WidgetClass = UE.URGAssetManager.GetAssetByPath(SettingRowInfo.WidgetClassPath, true)
    local Item
    local AllChildren = self.EditWidgetSwitcher:GetAllChildren()
    for i, SingleItem in pairs(AllChildren) do
      if UE.UGameplayStatics.GetObjectClass(SingleItem) == WidgetClass then
        Item = SingleItem
        break
      end
    end
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
      self.EditWidgetSwitcher:AddChild(Item)
    end
    if Item.Show then
      Item:Show(TagName)
    end
    self.EditWidgetSwitcher:SetActiveWidget(Item)
  else
    print("\230\178\161\230\156\137\229\143\175\228\187\165\230\137\147\229\188\128\231\154\132\231\188\150\232\190\145\231\149\140\233\157\162,TagName:", TagName)
  end
end

function WBP_GameSettingsMain_C:OpenUrl(TagName)
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(TagName)
  if LogicLobby.IsLIPassLogin() then
    if UE.URGBlueprintLibrary.IsOfficialPackage() then
      UE.UKismetSystemLibrary.LaunchURL(SettingRowInfo.ForeignOfficialUrlPath)
    else
      UE.UKismetSystemLibrary.LaunchURL(SettingRowInfo.ForeignUrlPath)
    end
  elseif UE.URGBlueprintLibrary.IsSteamCNChannel() then
    UE.UKismetSystemLibrary.LaunchURL(SettingRowInfo.SteamChinaUrlPath)
  else
    UE.UKismetSystemLibrary.LaunchURL(SettingRowInfo.DomesticUrlPath)
  end
end

function WBP_GameSettingsMain_C:BindOnUrlItemClicked(TagName)
  if TagName == DeleteAccountTagName and UE.URGPlatformFunctionLibrary.IsLIPassEnabled() then
    LogicLobby.DeleteAccount()
    return
  end
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(TagName)
  local WaveId = SettingRowInfo.ShowWaveWindow or 0
  if 0 ~= WaveId then
    ShowWaveWindowWithDelegate(WaveId, nil, function()
      self:OpenUrl(TagName)
    end)
  else
    self:OpenUrl(TagName)
  end
end

function WBP_GameSettingsMain_C:BindOnItemHovered(IsHovered, TagName)
  self.CurHoveredTagName = TagName
  if IsHovered then
    local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(TagName)
    if not SettingRowInfo then
      return
    end
    local DamageNumberStyleTagName = LogicGameSetting.GetDamageNumberStyleTagName()
    if TagName == DamageNumberStyleTagName then
      local SettingValue = LogicGameSetting.GetTempGameSettingValue(DamageNumberStyleTagName)
      SettingValue = SettingValue or LogicGameSetting.GetGameSettingValue(DamageNumberStyleTagName)
      local TargetMediaSourceId = SettingRowInfo.OptionsMovieList:Find(SettingValue + 1)
      if TargetMediaSourceId then
        local MovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGMovieSubSystem:StaticClass())
        local MediaObj = MovieSubsystem:GetMediaSource(TargetMediaSourceId)
        if MediaObj then
          UpdateVisibility(self.Img_DescMovie, true)
          self.MediaPlayer:SetLooping(true)
          self.MediaPlayer:OpenSource(MediaObj)
          self.MediaPlayer:Rewind()
          return
        end
      end
    end
    local AllItem = self.DescList:GetAllChildren()
    for key, SingleItem in pairs(AllItem) do
      SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    local TargetDescCustomKeyNameList, Item
    local Index = 0
    for i, SingleDesc in pairs(SettingRowInfo.DevelopDescList) do
      if SettingRowInfo.DescCustomKeyNameList:IsValidIndex(i) then
        TargetDescCustomKeyNameList = SettingRowInfo.DescCustomKeyNameList:GetRef(i).CustomKeyNameList
      else
        TargetDescCustomKeyNameList = nil
      end
      Item = self.DescList:GetChildAt(Index)
      if not Item then
        Item = UE.UWidgetBlueprintLibrary.Create(self, self.TextWithInteractTipWidgetTemplate:StaticClass())
        Item:InitStyle(self.TextWithInteractTipWidgetTemplate.TextColorAndOpacity, self.TextWithInteractTipWidgetTemplate.Font, self.TextWithInteractTipWidgetTemplate.Justification, self.TextWithInteractTipWidgetTemplate.MinDesiredWidth, self.TextWithInteractTipWidgetTemplate.ShadowColor, self.TextWithInteractTipWidgetTemplate.ShadowOffset, self.TextWithInteractTipWidgetTemplate.StrikeBrush, self.TextWithInteractTipWidgetTemplate.TransformPolicy)
        self.DescList:AddChild(Item)
      end
      Item:RefreshInfo(SingleDesc, TargetDescCustomKeyNameList)
      Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      Index = Index + 1
    end
    self.DescList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.DescList:SetVisibility(UE.ESlateVisibility.Collapsed)
    if self.MediaPlayer:IsPlaying() then
      self.MediaPlayer:Close()
      UpdateVisibility(self.Img_DescMovie, false)
    end
  end
end

function WBP_GameSettingsMain_C:BindOnTempGameSettingListChanged(IsShow)
  self:ChangeSaveButtonVis(IsShow)
end

function WBP_GameSettingsMain_C:BindOnItemNavigation(Type)
  local SecondLabelList = LogicGameSetting.GetSecondLabelsByFirstLabel(self.CurSelectedTagName)
  local SettingsList = {}
  for index, SingleSecondLabel in ipairs(SecondLabelList) do
    local TempSettingsList = LogicGameSetting.GetSettingsBySecondLabel(SingleSecondLabel)
    if TempSettingsList then
      for k, SingleSettings in ipairs(TempSettingsList) do
        table.insert(SettingsList, SingleSettings)
      end
    end
  end
  if Type == UE.EUINavigation.Left then
    if self.CurHoveredTagName then
      EventSystem.Invoke(EventDef.GameSettings.OnItemHovered, false)
    end
    EventSystem.Invoke(EventDef.GameSettings.OnTitleButtonClicked, self.CurSelectedTagName, true)
  elseif Type == UE.EUINavigation.Up then
    if self.CurHoveredTagName then
      local CurIndex = table.IndexOf(SettingsList, self.CurHoveredTagName)
      local List = LogicGameSetting.GetVisEffectByParentOptionTagList()
      local TargetIndex = 1
      for i = CurIndex - 1, 1, -1 do
        if SettingsList[i] and (nil == List[SettingsList[i]] or List[SettingsList[i]]) then
          TargetIndex = i
          break
        end
      end
      if SettingsList[TargetIndex] then
        EventSystem.Invoke(EventDef.GameSettings.OnItemSelected, SettingsList[TargetIndex])
      end
      if 1 == TargetIndex then
        self.MainList:ScrollToStart()
      end
    else
      local CurIndex = table.IndexOf(self.FirstLabelTable, self.CurSelectedTagName)
      if self.FirstLabelTable[CurIndex - 1] then
        EventSystem.Invoke(EventDef.GameSettings.OnTitleButtonClicked, self.FirstLabelTable[CurIndex - 1])
      end
    end
  elseif Type == UE.EUINavigation.Down then
    if self.CurHoveredTagName then
      local CurIndex = table.IndexOf(SettingsList, self.CurHoveredTagName)
      if SettingsList[CurIndex + 1] then
        EventSystem.Invoke(EventDef.GameSettings.OnItemSelected, SettingsList[CurIndex + 1])
      end
    else
      local CurIndex = table.IndexOf(self.FirstLabelTable, self.CurSelectedTagName)
      if self.FirstLabelTable[CurIndex + 1] then
        EventSystem.Invoke(EventDef.GameSettings.OnTitleButtonClicked, self.FirstLabelTable[CurIndex + 1])
      end
    end
  elseif Type == UE.EUINavigation.Right and not self.CurHoveredTagName then
    EventSystem.Invoke(EventDef.GameSettings.OnTitleButtonClicked, self.CurSelectedTagName, true)
  end
end

function WBP_GameSettingsMain_C:DoCustomNavigation(Type)
  if Type == UE.EUINavigation.Right then
    local FirstLabelInfo = LogicGameSetting.GetLabelRowInfo(self.CurSelectedTagName)
    if not FirstLabelInfo then
      return
    end
    if FirstLabelInfo.IsIndependentPanel then
      local Widget = self.TitleIndependentWidgetSwitcher:GetActiveWidget()
      if Widget.ChangeFocusToFirstItem then
        Widget:ChangeFocusToFirstItem()
      end
    else
      local SecondLabelList = LogicGameSetting.GetSecondLabelsByFirstLabel(self.CurSelectedTagName)
      local Settings = LogicGameSetting.GetSettingsBySecondLabel(SecondLabelList[1])
      if Settings then
        EventSystem.Invoke(EventDef.GameSettings.OnItemSelected, Settings[1])
      end
    end
  end
end

function WBP_GameSettingsMain_C:RefreshEditWidgetVisibility(IsShowEditWidget, TagName)
  self.IsShowEditWidget = IsShowEditWidget
  if self.IsShowEditWidget then
    self.EditWidgetSwitcher:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.MainPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.EditWidgetSwitcher:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.MainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if TagName then
      EventSystem.Invoke(EventDef.GameSettings.OnItemSelected, TagName)
    end
  end
end

function WBP_GameSettingsMain_C:RefreshMainList()
  local AllChildren = self.MainList:GetAllChildren()
  for i, SingleChild in pairs(AllChildren) do
    SingleChild:Hide()
  end
  local TargetSecondLabelTable = LogicGameSetting.GetSecondLabelsByFirstLabel(self.CurSelectedTagName)
  if not TargetSecondLabelTable then
    print("\230\178\161\230\137\190\229\136\176\228\186\140\231\186\167\233\161\181\231\173\190\239\188\140\228\184\128\231\186\167\233\161\181\231\173\190\228\184\186", self.CurSelectedTagName)
    return
  end
  for i, SingleSecondLabelTagName in ipairs(TargetSecondLabelTable) do
    local Item = self.MainList:GetChildAt(i - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.ListItemTemplate:StaticClass())
      self.MainList:AddChild(Item)
    end
    Item:Show(SingleSecondLabelTagName)
  end
  self.MainList:ScrollToStart()
end

function WBP_GameSettingsMain_C:ShowIndependentPanel()
  local FirstLabelRowInfo = LogicGameSetting.GetLabelRowInfo(self.CurSelectedTagName)
  if FirstLabelRowInfo and UE.URGBlueprintLibrary.IsValidSoftObjectPath(FirstLabelRowInfo.WidgetClassPath) then
    local WidgetClass = UE.URGAssetManager.GetAssetByPath(FirstLabelRowInfo.WidgetClassPath, true)
    local AllChildren = self.TitleIndependentWidgetSwitcher:GetAllChildren()
    local TargetWidget
    for key, SingleWidget in pairs(AllChildren) do
      if UE.UGameplayStatics.GetObjectClass(SingleWidget) == WidgetClass then
        TargetWidget = SingleWidget
        break
      end
    end
    if not TargetWidget then
      TargetWidget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
      self.TitleIndependentWidgetSwitcher:AddChild(TargetWidget)
    end
    if TargetWidget then
      if TargetWidget.Show then
        TargetWidget:Show()
      end
      self.TitleIndependentWidgetSwitcher:SetActiveWidget(TargetWidget)
    end
  else
    print("WBP_GameSettingsMain_C:ShowIndependentPanel \230\178\161\230\137\190\229\136\176\231\139\172\231\171\139\231\149\140\233\157\162\231\177\187")
  end
end

function WBP_GameSettingsMain_C:OnUnDisplay()
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  if LogicLobby and not LogicLobby.IsInLobbyLevel() and self:GetOwningPlayer() then
    UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(self:GetOwningPlayer())
  end
  self:RemoveEventListener()
  self:SetEnhancedInputActionBlocking(false)
  self.CurHoveredTagName = nil
  self.CurSelectedTagName = nil
  self:UnregisterScrollRecipient(self.MainList)
end

function WBP_GameSettingsMain_C:BindOnEscButtonClicked()
  if not self.IsShowEditWidget then
    local IsNeedShowSaveTip = false
    local AllIndependentWidget = self.TitleIndependentWidgetSwitcher:GetAllChildren()
    for i, SingleWidget in pairs(AllIndependentWidget) do
      if SingleWidget.IsNeedShowSaveTip and SingleWidget:IsNeedShowSaveTip() then
        IsNeedShowSaveTip = true
        table.insert(self.NeedSaveIndependentWidgetList, SingleWidget)
      end
    end
    if table.count(LogicGameSetting.TempGameSettingsValueList) > 0 then
      IsNeedShowSaveTip = true
    end
    if IsNeedShowSaveTip then
      self.SaveSettingsTip:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Btn_TipConfirm:SetKeyboardFocus()
    else
      self:HidePanel()
    end
  else
    local ActiveWidget = self.EditWidgetSwitcher:GetActiveWidget()
    if ActiveWidget and ActiveWidget.ShowExitConfirmTip then
      function ActiveWidget.ShowMainSettingWidget(Target, TagName)
        self:RefreshEditWidgetVisibility(false, TagName)
      end
      
      ActiveWidget:ShowExitConfirmTip()
    else
      self:RefreshEditWidgetVisibility(false)
    end
  end
end

function WBP_GameSettingsMain_C:BindOnRestoreButtonClicked()
  if self.LastClickRestoreBtnTime and GetCurrentUTCTimestamp() - self.LastClickRestoreBtnTime < self.RestoreBtnCD then
    ShowWaveWindow(RestoreBtnCDTip)
    return
  end
  if self.IsShowEditWidget then
    local Widget = self.EditWidgetSwitcher:GetActiveWidget()
    if Widget.BindOnRestoreButtonClicked then
      Widget:BindOnRestoreButtonClicked()
    end
    return
  end
  local FirstLabelRowInfo = LogicGameSetting.GetLabelRowInfo(self.CurSelectedTagName)
  if FirstLabelRowInfo and FirstLabelRowInfo.IsIndependentPanel then
    local Widget = self.TitleIndependentWidgetSwitcher:GetActiveWidget()
    if Widget.BindOnRestoreButtonClicked then
      Widget:BindOnRestoreButtonClicked()
    end
    return
  end
  local SecondLabelList = LogicGameSetting.GetSecondLabelsByFirstLabel(self.CurSelectedTagName)
  if not SecondLabelList then
    return
  end
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  local RestoreScreenSettingsTagList = {
    "Settings.Screen.Common.FullscreenMode",
    "Settings.Screen.Common.Resolution",
    "Settings.Screen.Common.MaxFPS",
    "Settings.Screen.Common.Lightness",
    "Settings.Screen.Common.VSync",
    "Settings.Screen.Common.AntiAliasingQuality",
    "Settings.Screen.Common.MotionBlur"
  }
  LogicGameSetting.ExecuteScreenSettingsRecommendLogic()
  for i, SingleSecondLabel in ipairs(SecondLabelList) do
    local SettingsList = LogicGameSetting.GetSettingsBySecondLabel(SingleSecondLabel)
    if SettingsList then
      for i, SingleSettingTag in ipairs(SettingsList) do
        local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(SingleSettingTag)
        if "Settings.Screen.Common.Resolution" == SingleSettingTag then
          LogicGameSetting.SetTempGameSettingsValue(SingleSettingTag, LogicGameSetting.GetDefaultResolution(), false)
        elseif "Settings.Screen.Common.MaxFPS" == SingleSettingTag then
          local RestoreFPS = RGGameUserSettings:GetCurrentRefreshRate()
          local OptionIndex = LogicGameSetting.GetFPSLimitDisplayOptionIndex(RestoreFPS)
          LogicGameSetting.SetTempGameSettingsValue(SingleSettingTag, OptionIndex, false)
        else
          local Value = LogicGameSetting.GetScreenSettingValue(SingleSettingTag)
          if not Value then
            Value = SettingRowInfo.DefaultValue
          elseif table.Contain(RestoreScreenSettingsTagList, SingleSettingTag) then
            Value = SettingRowInfo.DefaultValue
          end
          LogicGameSetting.SetTempGameSettingsValue(SingleSettingTag, Value, false)
          RGGameUserSettings:SetGameSettingByTag(SettingRowInfo.Tag, tonumber(Value))
        end
      end
    end
  end
  self:SaveScreenSettings()
  RGGameUserSettings:ApplySettings(false)
  self.LastClickRestoreBtnTime = GetCurrentUTCTimestamp()
  self:RefreshMainList()
  EventSystem.Invoke(EventDef.GameSettings.OnSettingsSaved)
end

function WBP_GameSettingsMain_C:BindOnSaveButtonClicked()
  local TargetWidget = self.TitleIndependentWidgetSwitcher:GetActiveWidget()
  if TargetWidget and TargetWidget.IsNeedShowSaveTip and TargetWidget:IsNeedShowSaveTip() and TargetWidget.SaveSettings then
    TargetWidget:SaveSettings()
  end
  if table.count(LogicGameSetting.TempGameSettingsValueList) <= 0 then
    return
  end
  local AllTempSettings = LogicGameSetting.TempGameSettingsValueList
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  local IsNeedSendTLog = false
  for SingleTagName, SingleValue in pairs(AllTempSettings) do
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(SingleTagName, nil)
    RGGameUserSettings:SetGameSettingByTag(Tag, tonumber(SingleValue))
    if table.Contain(TLogSaveSettings, SingleTagName) then
      IsNeedSendTLog = true
    end
  end
  if IsNeedSendTLog then
    local LogContent = ""
    for i, SingleSettingTagName in ipairs(TLogSaveSettings) do
      local SettingValue = LogicGameSetting.GetTempGameSettingValue(SingleSettingTagName)
      SettingValue = SettingValue or LogicGameSetting.GetGameSettingValue(SingleSettingTagName)
      if UE.UKismetStringLibrary.IsEmpty(LogContent) then
        LogContent = LogContent .. tostring(SettingValue)
      else
        LogContent = LogContent .. "|" .. tostring(SettingValue)
      end
    end
    UE.URGLogLibrary.BP_SendClientLog(self, "system_set", LogContent)
  end
  if AllTempSettings["Settings.Language.Common.Interface"] then
    ShowWaveWindow(305007)
  end
  self:SaveScreenSettings()
  RGGameUserSettings:ApplySettings(false)
  LogicGameSetting.ClearTempGameSettingValueList()
  local RGWaveWindowManger = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if RGWaveWindowManger then
    RGWaveWindowManger:ShowWaveWindow(1114)
  end
  EventSystem.Invoke(EventDef.GameSettings.OnSettingsSaved)
end

function WBP_GameSettingsMain_C:BindOnPreviousKeyPressed(...)
  local TargetTagName = not self.IsShowEditWidget and self.CurHoveredTagName or nil
  if self.CurHoveredTagName or self.IsShowEditWidget then
    EventSystem.Invoke(EventDef.GameSettings.OnPreviousKeyPressed, TargetTagName)
  end
end

function WBP_GameSettingsMain_C:BindOnNextKeyPressed(...)
  local TargetTagName = not self.IsShowEditWidget and self.CurHoveredTagName or nil
  if self.CurHoveredTagName or self.IsShowEditWidget then
    EventSystem.Invoke(EventDef.GameSettings.OnNextKeyPressed, TargetTagName)
  end
end

function WBP_GameSettingsMain_C:ChangeScrollListConsumeMouseWheelStatus(Status)
  self.MainList:SetConsumeMouseWheel(Status)
end

function WBP_GameSettingsMain_C:RemoveEventListener()
  EventSystem.RemoveListener(EventDef.GameSettings.OnTitleButtonClicked, WBP_GameSettingsMain_C.BindOnTitleButtonClicked, self)
  EventSystem.RemoveListener(EventDef.GameSettings.OnEditItemClicked, WBP_GameSettingsMain_C.BindOnEditItemClicked, self)
  EventSystem.RemoveListener(EventDef.GameSettings.OnUrlItemClicked, WBP_GameSettingsMain_C.BindOnUrlItemClicked, self)
  EventSystem.RemoveListener(EventDef.GameSettings.OnItemHovered, WBP_GameSettingsMain_C.BindOnItemHovered, self)
  EventSystem.RemoveListener(EventDef.GameSettings.OnTempGameSettingListChanged, WBP_GameSettingsMain_C.BindOnTempGameSettingListChanged, self)
  EventSystem.RemoveListener(EventDef.GameSettings.OnItemNavigation, self.BindOnItemNavigation, self)
  if IsListeningForInputAction(self, self.EscKeyName) then
    StopListeningForInputAction(self, self.EscKeyName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.RestoreKeyName) then
    StopListeningForInputAction(self, self.RestoreKeyName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.SaveKeyName) then
    StopListeningForInputAction(self, self.SaveKeyName, UE.EInputEvent.IE_Pressed)
  end
  if PadLeftSwitch then
    StopListeningForInputAction(self, PadLeftSwitch, UE.EInputEvent.IE_Pressed)
  end
  if PadRightSwitch then
    StopListeningForInputAction(self, PadRightSwitch, UE.EInputEvent.IE_Pressed)
  end
end

function WBP_GameSettingsMain_C:Destruct()
  self:RemoveEventListener()
  LogicGameSetting.ClearTempGameSettingValueList()
  if LogicLobby then
    LogicLobby.SetCanMove3DLobby(true)
  end
  if self:GetOwningPlayerPawn() then
    local InputHandle = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
    if InputHandle then
      InputHandle:SetAllInputIgnored(false)
    end
  end
  if self.MediaPlayer:IsPlaying() then
    self.MediaPlayer:Close()
  end
end

return WBP_GameSettingsMain_C
