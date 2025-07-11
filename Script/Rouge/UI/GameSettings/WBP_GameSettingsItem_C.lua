local WBP_GameSettingsItem_C = UnLua.Class()
local ResolutionTagName = "Settings.Screen.Common.Resolution"
local FullScreenModeTagName = "Settings.Screen.Common.FullscreenMode"
local MonitorTagName = "Settings.Screen.Common.Monitor"
local FPSTagName = "Settings.Screen.Common.MaxFPS"
local CustomSettingValue = 4
function WBP_GameSettingsItem_C:Construct()
  self.MainComboBox.OnSelectionChanged:Add(self, WBP_GameSettingsItem_C.BindOnSelectionChanged)
  self.MainComboBox.OnOpening:Add(self, self.BindOnComboBoxOpening)
  self.MainComboBox.OnClosing:Add(self, self.BindOnComboBoxClosing)
  self.Slider_Item.OnValueChanged:Add(self, WBP_GameSettingsItem_C.BindOnSliderValueChanged)
  self.Btn_Left.OnClicked:Add(self, WBP_GameSettingsItem_C.BindOnLeftButtonClicked)
  self.Btn_Right.OnClicked:Add(self, WBP_GameSettingsItem_C.BindOnRightButtonClicked)
  self.Btn_Main.OnClicked:Add(self, WBP_GameSettingsItem_C.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, WBP_GameSettingsItem_C.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, WBP_GameSettingsItem_C.BindOnMainButtonUnHovered)
  self.Btn_LeftSwitch.OnClicked:Add(self, self.BindOnLeftSwitchButtonClicked)
  self.Btn_RightSwitch.OnClicked:Add(self, self.BindOnRightSwitchButtonClicked)
end
function WBP_GameSettingsItem_C:BindOnInputMethodChanged(InputType)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
  local NeedShow = CurrentInputType == UE.ECommonInputType.Gamepad and self.IsItemHovered
  if self.Type ~= UE.ESettingWidgetType.LeftRightSwitch and self.Type ~= UE.ESettingWidgetType.SliderBar then
    NeedShow = false
  end
  UpdateVisibility(self.Canvas_GamePadOperateTip, NeedShow)
end
function WBP_GameSettingsItem_C:BindOnPreviousKeyPressed(TagName)
  if self.TagName ~= TagName then
    return
  end
  if self.Type == UE.ESettingWidgetType.LeftRightSwitch then
    self:BindOnLeftSwitchButtonClicked()
  elseif self.Type == UE.ESettingWidgetType.SliderBar then
    self:BindOnLeftButtonClicked()
  end
end
function WBP_GameSettingsItem_C:BindOnNextKeyPressed(TagName)
  if self.TagName ~= TagName then
    return
  end
  if self.Type == UE.ESettingWidgetType.LeftRightSwitch then
    self:BindOnRightSwitchButtonClicked()
  elseif self.Type == UE.ESettingWidgetType.SliderBar then
    self:BindOnRightButtonClicked()
  end
end
function WBP_GameSettingsItem_C:BindOnSelectionChanged(SelectedItem, SelectionType)
  if UE.UKismetStringLibrary.IsEmpty(SelectedItem) then
    return
  end
  local CurSelectedValue = self.SettingOptionToRealValueList[SelectedItem]
  if self.TagName == "Settings.Audio.ChatVolume.FreeChat" and 0 == tonumber(CurSelectedValue) then
    local CallBack = function(Obj)
      if IsValidObj(Obj) then
        local oldValue = LogicGameSetting.GetGameSettingValue(Obj.TagName)
        local CurSelectedOption = Obj:GetCurSelectedOptionByRealValue(oldValue)
        local OldOption = Obj.MainComboBox:GetSelectedOption()
        if OldOption ~= CurSelectedOption then
          Obj.MainComboBox:SetSelectedOption(CurSelectedOption)
        end
      end
    end
    local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
    if VoiceControlModule and VoiceControlModule:CheckIsVoiceControl(self, function(Obj, evt)
      local VoiceControlModuleTemp = ModuleManager:Get("VoiceControlModule")
      if VoiceControlModuleTemp then
        VoiceControlModuleTemp:OnLiPassEvent(evt, Obj, CallBack)
      end
    end) then
      return
    end
    if ChatDataMgr.CheckVoiceBan(true) then
      local oldValue = LogicGameSetting.GetGameSettingValue(self.TagName)
      local CurSelectedOption = self:GetCurSelectedOptionByRealValue(oldValue)
      local OldOption = self.MainComboBox:GetSelectedOption()
      if OldOption ~= CurSelectedOption then
        self.MainComboBox:SetSelectedOption(CurSelectedOption)
      end
      return
    end
  end
  if self.TagName == ResolutionTagName or self.TagName == MonitorTagName then
    LogicGameSetting.SetTempGameSettingsValue(self.TagName, SelectedItem)
  else
    local CurSelectedValue = self.SettingOptionToRealValueList[SelectedItem]
    LogicGameSetting.SetTempGameSettingsValue(self.TagName, CurSelectedValue)
  end
end
function WBP_GameSettingsItem_C:BindOnComboBoxOpening()
  self.URGImage_di:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:RefreshComboItemWidgetSelectedStatus(self.MainComboBox:GetSelectedOption())
  local GameSettingsMain
  if LogicLobby.IsInLobbyLevel() then
    GameSettingsMain = UIMgr:GetLuaFromActiveView(ViewID.UI_GameSettingsMain)
  else
    GameSettingsMain = RGUIMgr:GetUI(UIConfig.WBP_GameSettingsMain_C.UIName)
  end
  if GameSettingsMain then
    GameSettingsMain:ChangeScrollListConsumeMouseWheelStatus(UE.EConsumeMouseWheel.Never)
  end
end
function WBP_GameSettingsItem_C:BindOnComboBoxClosing()
  self.URGImage_di:SetVisibility(UE.ESlateVisibility.Collapsed)
  local GameSettingsMain
  if LogicLobby.IsInLobbyLevel() then
    GameSettingsMain = UIMgr:GetLuaFromActiveView(ViewID.UI_GameSettingsMain)
  else
    GameSettingsMain = RGUIMgr:GetUI(UIConfig.WBP_GameSettingsMain_C.UIName)
  end
  if GameSettingsMain then
    GameSettingsMain:ChangeScrollListConsumeMouseWheelStatus(UE.EConsumeMouseWheel.WhenScrollingPossible)
  end
end
function WBP_GameSettingsItem_C:BindOnSliderValueChanged(Value)
  local TargetValue = math.floor(Value)
  self.Txt_Num:SetText(tostring(TargetValue))
  LogicGameSetting.SetTempGameSettingsValue(self.TagName, TargetValue)
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(self.TagName)
  if math.floor(Value) - 1 < SettingRowInfo.MinValue then
    self.Btn_Left:SetIsEnabled(false)
  else
    self.Btn_Left:SetIsEnabled(true)
  end
  if math.floor(Value) + 1 > SettingRowInfo.MaxValue then
    self.Btn_Right:SetIsEnabled(false)
  else
    self.Btn_Right:SetIsEnabled(true)
  end
  if 0 ~= self.Slider_Item.MaxValue then
    self.Img_SliderFull:SetClippingValue((Value - SettingRowInfo.MinValue) / (self.Slider_Item.MaxValue - SettingRowInfo.MinValue))
  else
    self.Img_SlideFull:SetClippingValue(0)
  end
end
function WBP_GameSettingsItem_C:BindOnLeftButtonClicked()
  if self.Btn_Left:GetIsEnabled() then
    self:SetSliderValue(self.Slider_Item:GetValue() - 1)
  end
end
function WBP_GameSettingsItem_C:SetSliderValue(Value)
  self.Slider_Item:SetValue(Value)
  self:BindOnSliderValueChanged(Value)
end
function WBP_GameSettingsItem_C:BindOnRightButtonClicked()
  if self.Btn_Right:GetIsEnabled() then
    self:SetSliderValue(self.Slider_Item:GetValue() + 1)
  end
end
function WBP_GameSettingsItem_C:BindOnMainButtonClicked()
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(self.TagName)
  if SettingRowInfo.Type == UE.ESettingWidgetType.Edit then
    EventSystem.Invoke(EventDef.GameSettings.OnEditItemClicked, self.TagName)
  elseif SettingRowInfo.Type == UE.ESettingWidgetType.Url then
    EventSystem.Invoke(EventDef.GameSettings.OnUrlItemClicked, self.TagName)
  end
end
function WBP_GameSettingsItem_C:BindOnMainButtonHovered()
  self.IsItemHovered = true
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  EventSystem.Invoke(EventDef.GameSettings.OnItemHovered, true, self.TagName)
  self:BindOnInputMethodChanged()
end
function WBP_GameSettingsItem_C:OnAddedToFocusPath(...)
  self.RGStateController_126:ChangeStatus("Hover")
  self:BindOnMainButtonHovered()
end
function WBP_GameSettingsItem_C:OnRemovedFromFocusPath(...)
  self.RGStateController_126:ChangeStatus("UnHover")
  self:BindOnMainButtonUnHovered()
end
function WBP_GameSettingsItem_C:BindOnMainButtonUnHovered()
  self.IsItemHovered = false
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.Invoke(EventDef.GameSettings.OnItemHovered, false)
  self:BindOnInputMethodChanged()
end
function WBP_GameSettingsItem_C:BindOnLeftSwitchButtonClicked()
  if not self.Btn_LeftSwitch:GetIsEnabled() then
    return
  end
  self:SetLeftRightSwitchOptionIndex(self.CurLeftRightSwitchIndex - 1)
end
function WBP_GameSettingsItem_C:BindOnRightSwitchButtonClicked()
  if not self.Btn_RightSwitch:GetIsEnabled() then
    return
  end
  self:SetLeftRightSwitchOptionIndex(self.CurLeftRightSwitchIndex + 1)
end
function WBP_GameSettingsItem_C:Show(TagName)
  self.TagName = TagName
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(self.TagName)
  if not SettingRowInfo then
    print("not found Setting Row Info, TagName is", self.TagName)
    return
  end
  self.EffectOtherSettingsOptionList = SettingRowInfo.EffectOtherSettingsOptionList:ToTable()
  self.Type = SettingRowInfo.Type
  self.ParentOptionTag = nil
  if UE.UBlueprintGameplayTagLibrary.IsGameplayTagValid(SettingRowInfo.EffectByParentTagOption.ParentOptionTag) then
    self.ParentOptionTag = SettingRowInfo.EffectByParentTagOption.ParentOptionTag
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Name:SetText(SettingRowInfo.Name)
  self.ItemSwitcher:SetActiveWidgetIndex(SettingRowInfo.Type)
  self:InitInfo()
  self:SetMainComboBoxEnableStatus(true)
  self:SetLeftRightSwitchEnableStatus(true)
  self:JudgeCanChangeResolution()
  self:RefreshEffectByParentTagOptionStatus()
  EventSystem.AddListener(self, EventDef.GameSettings.OnGameSettingItemValueBeChanged, self.BindOnGameSettingItemValueBeChanged)
  EventSystem.AddListener(self, EventDef.GameSettings.OnItemSelected, self.BindOnItemSelected)
  EventSystem.AddListener(self, EventDef.GameSettings.OnTempGameSettingListChanged, self.BindOnTempGameSettingListChanged)
  EventSystem.AddListenerNew(EventDef.GameSettings.OnPreviousKeyPressed, self, self.BindOnPreviousKeyPressed)
  EventSystem.AddListenerNew(EventDef.GameSettings.OnNextKeyPressed, self, self.BindOnNextKeyPressed)
  if self.TagName == ResolutionTagName then
    EventSystem.AddListener(self, EventDef.GameSettings.OnMonitorValueChanged, self.BindOnMonitorValueChanged)
  end
  if self.Type == UE.ESettingWidgetType.PullDownList then
    ListenObjectMessage(nil, GMP.MSG_Localization_UpdateCulture, self, self.BindOnUpdateCulture)
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  CommonInputSubsystem.OnInputMethodChanged:Add(self, self.BindOnInputMethodChanged)
  self:BindOnInputMethodChanged()
end
function WBP_GameSettingsItem_C:RefreshEffectByParentTagOptionStatus(...)
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(self.TagName)
  local ParentOptionTag = SettingRowInfo.EffectByParentTagOption.ParentOptionTag
  if not UE.UBlueprintGameplayTagLibrary.IsGameplayTagValid(ParentOptionTag) then
    return
  end
  local ParentOptionTagName = UE.UBlueprintGameplayTagLibrary.GetTagName(ParentOptionTag)
  local ParentOptionValue = LogicGameSetting.GetTempGameSettingValue(ParentOptionTagName)
  ParentOptionValue = ParentOptionValue or LogicGameSetting.GetGameSettingValue(ParentOptionTagName)
  local IsContainValue = false
  if type(ParentOptionValue) == "number" then
    IsContainValue = SettingRowInfo.EffectByParentTagOption.ParentOptionValue:Contains(ParentOptionValue)
  end
  if not IsContainValue then
    LogicGameSetting.SetTempGameSettingsValue(self.TagName, LogicGameSetting.GetGameSettingValue(self.TagName), true)
    self:InitInfo()
  end
  if SettingRowInfo.EffectByParentTagOption.Type == UE.EEffectByParentTagOptionType.Show then
    UpdateVisibility(self, IsContainValue)
    LogicGameSetting.SetVisEffectByParentOptionTag(self.TagName, IsContainValue)
  end
end
function WBP_GameSettingsItem_C:SetMainComboBoxEnableStatus(IsEnable)
  UpdateVisibility(self.URGImage_Disable, not IsEnable, true)
  for key, SingleWidget in pairs(self.ComboItemWidgets) do
    if SingleWidget and SingleWidget:IsValid() then
      SingleWidget:RefreshEnableStatus(IsEnable)
    end
  end
end
function WBP_GameSettingsItem_C:SetLeftRightSwitchEnableStatus(IsEnable)
  self.Btn_LeftSwitch:SetIsEnabled(IsEnable)
  self.Btn_RightSwitch:SetIsEnabled(IsEnable)
  if IsEnable then
    self.RGStateController_Resolution:ChangeStatus("Able")
  else
    self.RGStateController_Resolution:ChangeStatus("Unable")
  end
end
function WBP_GameSettingsItem_C:BindOnGameSettingItemValueBeChanged(ChangedOptionList)
  if not table.Contain(ChangedOptionList, self.TagName) then
    return
  end
  if self.Type == UE.ESettingWidgetType.PullDownList then
    local CurValue = LogicGameSetting.GetTempGameSettingValue(self.TagName)
    CurValue = CurValue or LogicGameSetting.GetGameSettingValue(self.TagName)
    local CurSelectedOption = self:GetCurSelectedOptionByRealValue(CurValue)
    local OldOption = self.MainComboBox:GetSelectedOption()
    if OldOption ~= CurSelectedOption then
      self.MainComboBox:SetSelectedOption(CurSelectedOption)
    end
  elseif self.Type == UE.ESettingWidgetType.LeftRightSwitch then
    local CurValue = LogicGameSetting.GetTempGameSettingValue(self.TagName)
    CurValue = CurValue or LogicGameSetting.GetGameSettingValue(self.TagName)
    self:SetLeftRightSwitchOptionIndex(CurValue)
  end
end
function WBP_GameSettingsItem_C:BindOnTempGameSettingListChanged(HasChange, ChangeTagName)
  if ChangeTagName then
    if ChangeTagName == FullScreenModeTagName then
      self:JudgeCanChangeResolution()
    end
    if self.ParentOptionTag and ChangeTagName == UE.UBlueprintGameplayTagLibrary.GetTagName(self.ParentOptionTag) then
      self:RefreshEffectByParentTagOptionStatus()
    end
  end
  if table.count(self.EffectOtherSettingsOptionList) > 0 then
    self:JudgeNeedSetComboBoxToCustom()
  end
end
function WBP_GameSettingsItem_C:BindOnMonitorValueChanged()
  print("WBP_GameSettingsItem_C:BindOnMonitorValueChanged")
  self:InitInfo()
end
function WBP_GameSettingsItem_C:BindOnUpdateCulture(CultureName)
  self:InitInfo()
end
function WBP_GameSettingsItem_C:JudgeCanChangeResolution()
  if self.TagName == ResolutionTagName then
    local Value = LogicGameSetting.GetTempGameSettingValue(FullScreenModeTagName)
    Value = Value or LogicGameSetting.GetGameSettingValue(FullScreenModeTagName)
    if 1 == Value then
      local CurOption = tostring(LogicGameSetting.GetGameSettingValue(self.TagName))
      if self.Type == UE.ESettingWidgetType.PullDownList then
        self:SetMainComboBoxEnableStatus(false)
        local CurSelectedOption = self.MainComboBox:GetSelectedOption()
        if -1 ~= self.MainComboBox:FindOptionIndex(CurOption) and CurSelectedOption ~= CurOption then
          self.MainComboBox:SetSelectedOption(CurOption)
        end
      elseif self.Type == UE.ESettingWidgetType.LeftRightSwitch then
        self:SetLeftRightSwitchEnableStatus(false)
        local CurIndex = -1
        for i, SingleOption in ipairs(self.LeftRightSwitchOptions) do
          if SingleOption == CurOption then
            CurIndex = i - 1
          end
        end
        if CurIndex ~= self.CurLeftRightSwitchIndex then
          self:SetLeftRightSwitchOptionIndex(CurIndex)
        end
      end
    elseif self.Type == UE.ESettingWidgetType.PullDownList then
      self:SetMainComboBoxEnableStatus(true)
    elseif self.Type == UE.ESettingWidgetType.LeftRightSwitch then
      self:SetLeftRightSwitchEnableStatus(true)
    end
  end
end
function WBP_GameSettingsItem_C:JudgeNeedSetComboBoxToCustom()
  local CurValue = LogicGameSetting.GetTempGameSettingValue(self.TagName)
  CurValue = CurValue or LogicGameSetting.GetGameSettingValue(self.TagName)
  local TargetOptionList
  for index, SingleEffectOptionList in ipairs(self.EffectOtherSettingsOptionList) do
    if SingleEffectOptionList.MainOptionValue == CurValue then
      TargetOptionList = SingleEffectOptionList.EffectOtherSettingList:ToTable()
      break
    end
  end
  if not TargetOptionList then
    return
  end
  local IsShowCustom = false
  for OptionTag, OptionValue in pairs(TargetOptionList) do
    local TagName = UE.UBlueprintGameplayTagLibrary.GetTagName(OptionTag)
    local TempValue = LogicGameSetting.GetTempGameSettingValue(TagName)
    if TempValue and TempValue ~= OptionValue then
      IsShowCustom = true
      break
    end
  end
  if IsShowCustom then
    if self.Type == UE.ESettingWidgetType.PullDownList then
      self.MainComboBox:SetSelectedIndex(CustomSettingValue)
    elseif self.Type == UE.ESettingWidgetType.LeftRightSwitch then
      self:SetLeftRightSwitchOptionIndex(CustomSettingValue)
    end
  end
end
function WBP_GameSettingsItem_C:BindOnItemSelected(TagName)
  if self.TagName == TagName then
    self:SetKeyboardFocus()
  end
end
function WBP_GameSettingsItem_C:InitInfo()
  if self.Type == UE.ESettingWidgetType.PullDownList then
    self:InitPullDownListInfo()
  elseif self.Type == UE.ESettingWidgetType.SliderBar then
    self:InitSliderBarInfo()
  elseif self.Type == UE.ESettingWidgetType.LeftRightSwitch then
    self:InitLeftRightSwitchInfo()
  end
end
function WBP_GameSettingsItem_C:GetPullDownOptions()
  self.SettingOptionToRealValueList = {}
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(self.TagName)
  local SettingOptions = {}
  if self.TagName == ResolutionTagName then
    SettingOptions = LogicGameSetting.GetAllResolutions()
    for index, SingleOption in ipairs(SettingOptions) do
      self.SettingOptionToRealValueList[SingleOption] = index - 1
    end
  elseif self.TagName == MonitorTagName then
    SettingOptions = LogicGameSetting.GetAllMonitorNames()
    for index, SingleOption in ipairs(SettingOptions) do
      self.SettingOptionToRealValueList[SingleOption] = index - 1
    end
  elseif self.TagName == FPSTagName then
    local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
    if GameUserSettings then
      local TargetSettingOptions = GameUserSettings:GetFrameRateLimitList()
      for index, SingleOption in pairs(TargetSettingOptions) do
        self.SettingOptionToRealValueList[tostring(SingleOption.OptionText)] = SingleOption.OptionValue
        table.insert(SettingOptions, tostring(SingleOption.OptionText))
      end
    end
  else
    for key, SingleOptionInfo in pairs(SettingRowInfo.SettingOptionsList) do
      self.SettingOptionToRealValueList[tostring(SingleOptionInfo.OptionText)] = SingleOptionInfo.OptionValue
      table.insert(SettingOptions, tostring(SingleOptionInfo.OptionText))
    end
  end
  return SettingOptions
end
function WBP_GameSettingsItem_C:InitPullDownListInfo()
  self.MainComboBox:ClearOptions()
  local SettingOptions = self:GetPullDownOptions()
  self.ComboItemWidgets = {}
  for i, SingleOption in pairs(SettingOptions) do
    self.MainComboBox:AddOption(SingleOption)
  end
  local CurValue = LogicGameSetting.GetTempGameSettingValue(self.TagName)
  CurValue = CurValue or LogicGameSetting.GetGameSettingValue(self.TagName)
  local OldOption = self.MainComboBox:GetSelectedOption()
  if self.TagName == ResolutionTagName then
    local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
    if RGGameUserSettings then
      local ResolutionValue = RGGameUserSettings:Lua_GetCurrentResolutionByName(nil)
      if OldOption ~= ResolutionValue then
        self.MainComboBox:SetSelectedOption(ResolutionValue)
      end
      return
    end
  elseif self.TagName == MonitorTagName then
    if OldOption ~= CurValue then
      self.MainComboBox:SetSelectedOption(CurValue)
    end
    return
  end
  local CurSelectedOption = self:GetCurSelectedOptionByRealValue(CurValue)
  if OldOption ~= CurSelectedOption then
    self.MainComboBox:SetSelectedOption(CurSelectedOption)
  end
end
function WBP_GameSettingsItem_C:GetCurSelectedOptionByRealValue(RealValue)
  for OptionText, OptionValue in pairs(self.SettingOptionToRealValueList) do
    if OptionValue == RealValue then
      return OptionText
    end
  end
  return ""
end
function WBP_GameSettingsItem_C:AddComboBoxWidget(InUserWidget)
  if not self.ComboItemWidgets then
    self.ComboItemWidgets = {}
  end
  table.insert(self.ComboItemWidgets, InUserWidget)
end
function WBP_GameSettingsItem_C:RefreshComboItemWidgetSelectedStatus()
  for key, SingleWidget in pairs(self.ComboItemWidgets) do
    if SingleWidget and SingleWidget:IsValid() then
      SingleWidget:RefreshSelectedStatus(self.MainComboBox:GetSelectedOption())
    end
  end
end
function WBP_GameSettingsItem_C:InitSliderBarInfo()
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(self.TagName)
  self.Slider_Item:SetMinValue(SettingRowInfo.MinValue)
  self.Slider_Item:SetMaxValue(SettingRowInfo.MaxValue)
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  if not GameUserSettings then
    return
  end
  local CurValue = LogicGameSetting.GetTempGameSettingValue(self.TagName)
  CurValue = CurValue or LogicGameSetting.GetGameSettingValue(self.TagName)
  self:SetSliderValue(CurValue)
end
function WBP_GameSettingsItem_C:InitLeftRightSwitchInfo()
  self.CurLeftRightSwitchIndex = -1
  local SettingOptions = self:GetPullDownOptions()
  self.LeftRightSwitchOptions = SettingOptions
  local CurValue = LogicGameSetting.GetTempGameSettingValue(self.TagName)
  CurValue = CurValue or LogicGameSetting.GetGameSettingValue(self.TagName)
  if self.TagName == ResolutionTagName then
    local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
    if RGGameUserSettings then
      for i, SingleOption in ipairs(self.LeftRightSwitchOptions) do
        if SingleOption == CurValue then
          CurValue = i - 1
          break
        end
      end
    end
  elseif self.TagName == MonitorTagName then
    for i, SingleOption in ipairs(self.LeftRightSwitchOptions) do
      if SingleOption == CurValue then
        CurValue = i - 1
        break
      end
    end
  elseif self.TagName == FPSTagName then
    local TargetValue = tostring(LogicGameSetting.GetFPSLimitValue(CurValue))
    for i, SingleOption in pairs(self.LeftRightSwitchOptions) do
      if SingleOption == TargetValue then
        CurValue = i - 1
        break
      end
    end
  else
    for OptionText, OptionValue in pairs(self.SettingOptionToRealValueList) do
      if OptionValue == CurValue then
        CurValue = table.IndexOf(self.LeftRightSwitchOptions, OptionText) - 1
        break
      end
    end
  end
  local TemplateSlot = UE.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(self.GameSettingsItemIndexTemplate)
  local Index = 1
  for i, v in pairs(self.LeftRightSwitchOptions) do
    local Item = GetOrCreateItem(self.Horizontal_ItemIndexList, Index, self.GameSettingsItemIndexTemplate:StaticClass())
    Item:Show(Index)
    local Slot = UE.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(Item)
    if Slot then
      Slot:SetPadding(TemplateSlot.Padding)
    end
    Index = Index + 1
  end
  HideOtherItem(self.Horizontal_ItemIndexList, Index, true)
  self:SetLeftRightSwitchOptionIndex(CurValue)
end
function WBP_GameSettingsItem_C:SetLeftRightSwitchOptionIndex(OptionIndex, bSkipCheckVoiceControl, bSkipCheckBan)
  local MaxIndex = table.count(self.LeftRightSwitchOptions)
  if type(OptionIndex) ~= "number" then
    OptionIndex = -1
  elseif OptionIndex > MaxIndex - 1 then
    OptionIndex = 0
  elseif OptionIndex < 0 then
    OptionIndex = MaxIndex - 1
  end
  if self.TagName == "Settings.Audio.ChatVolume.FreeChat" then
    local OptionName = self.LeftRightSwitchOptions[OptionIndex + 1] and self.LeftRightSwitchOptions[OptionIndex + 1] or ""
    local TargetRealValue = self.SettingOptionToRealValueList[OptionName]
    local CallBack = function(Obj)
      if IsValidObj(Obj) then
        Obj:SetLeftRightSwitchOptionIndex(OptionIndex, true)
      end
    end
    if 0 == TargetRealValue then
      if not bSkipCheckVoiceControl and self.CurLeftRightSwitchIndex ~= OptionIndex then
        local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
        if VoiceControlModule and VoiceControlModule:CheckIsVoiceControl(self, function(Obj, evt)
          local VoiceControlModuleTemp = ModuleManager:Get("VoiceControlModule")
          if VoiceControlModuleTemp then
            VoiceControlModuleTemp:OnLiPassEvent(evt, Obj, CallBack)
          end
        end) then
          return
        end
      end
      if not bSkipCheckBan and ChatDataMgr.CheckVoiceBan(true) and self.CurLeftRightSwitchIndex ~= OptionIndex then
        self:SetLeftRightSwitchOptionIndex(OptionIndex, true, true)
        return
      end
    end
  end
  local LastSelectedIndex = self.CurLeftRightSwitchIndex
  self.CurLeftRightSwitchIndex = OptionIndex
  local OptionName = self.LeftRightSwitchOptions[OptionIndex + 1] and self.LeftRightSwitchOptions[OptionIndex + 1] or ""
  self.Txt_OptionName:SetText(OptionName)
  local LastSelectedIndexItem
  if nil ~= LastSelectedIndex then
    LastSelectedIndexItem = self.Horizontal_ItemIndexList:GetChildAt(LastSelectedIndex)
  end
  if LastSelectedIndexItem then
    LastSelectedIndexItem:ChangeSelectedStatus(false)
  end
  local CurSelectedIndexItem = self.Horizontal_ItemIndexList:GetChildAt(self.CurLeftRightSwitchIndex)
  if CurSelectedIndexItem then
    CurSelectedIndexItem:ChangeSelectedStatus(true)
  end
  if UE.UKismetStringLibrary.IsEmpty(OptionName) then
    return
  end
  if self.TagName == ResolutionTagName or self.TagName == MonitorTagName then
    LogicGameSetting.SetTempGameSettingsValue(self.TagName, OptionName)
  else
    local CurRealValue = self.SettingOptionToRealValueList[OptionName]
    LogicGameSetting.SetTempGameSettingsValue(self.TagName, CurRealValue)
  end
end
function WBP_GameSettingsItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.TagName = nil
  EventSystem.RemoveListener(EventDef.GameSettings.OnGameSettingItemValueBeChanged, self.BindOnGameSettingItemValueBeChanged, self)
  EventSystem.RemoveListener(EventDef.GameSettings.OnTempGameSettingListChanged, self.BindOnTempGameSettingListChanged, self)
  EventSystem.RemoveListener(EventDef.GameSettings.OnMonitorValueChanged, self.BindOnMonitorValueChanged, self)
  UnListenObjectMessage(GMP.MSG_Localization_UpdateCulture, self)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.BindOnInputMethodChanged)
  end
  EventSystem.RemoveListenerNew(EventDef.GameSettings.OnPreviousKeyPressed, self, self.BindOnPreviousKeyPressed)
  EventSystem.RemoveListenerNew(EventDef.GameSettings.OnNextKeyPressed, self, self.BindOnNextKeyPressed)
end
function WBP_GameSettingsItem_C:Destruct()
  self:Hide()
end
return WBP_GameSettingsItem_C
