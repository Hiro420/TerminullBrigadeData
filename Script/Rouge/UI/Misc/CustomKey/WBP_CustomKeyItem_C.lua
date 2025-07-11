local WBP_CustomKeyItem_C = UnLua.Class()
function WBP_CustomKeyItem_C:Construct()
  self.InputKeySelector:SetTextBlockVisibility(UE.ESlateVisibility.Collapsed)
  self.InputKeySelector.OnKeySelected:Add(self, WBP_CustomKeyItem_C.BindOnKeySelected)
  self.InputKeySelector.OnIsSelectingKeyChanged:Add(self, WBP_CustomKeyItem_C.BindOnIsSelectingKeyChanged)
  self.InputKeySelector.OnEscapeKeySelected:Add(self, WBP_CustomKeyItem_C.BindOnEscapeKeySelected)
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end
function WBP_CustomKeyItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.GameSettings.OnCustomKeyItemSelected, self.KeyRowName)
end
function WBP_CustomKeyItem_C:BindOnMainButtonHovered()
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_CustomKeyItem_C:BindOnMainButtonUnhovered()
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_CustomKeyItem_C:OnAddedToFocusPath(...)
  local IsFocus = self.IsFocus
  self.IsFocus = true
  if not IsFocus and self.CanChange then
    self.InputKeySelector:SetKeyboardFocus()
  end
end
function WBP_CustomKeyItem_C:OnRemovedFromFocusPath(...)
  self.IsFocus = false
end
function WBP_CustomKeyItem_C:InitInfo(RowName, InputType)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Img_KeySelectorBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.KeyTableRowName = RowName
  self.KeyRowName = RowName
  self.InputType = InputType
  self.CanChange = true
  if self.InputType == UE.ECommonInputType.MouseAndKeyboard then
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if not DTSubsystem then
      return
    end
    local Result, RowInfo = DTSubsystem:GetCustomKeyDataByName(self.KeyRowName, nil)
    if not Result then
      return
    end
    self.Txt_Name:SetText(RowInfo.DisplayName)
    self.InputKeySelector:SetAllowGamepadKeys(false)
  elseif self.InputType == UE.ECommonInputType.Gamepad then
    local Result, RowInfo = GetRowData(DT.DT_CustomKey_Gamepad, RowName)
    if Result then
      self.Txt_Name:SetText(RowInfo.DisplayName)
      self.CanChange = RowInfo.CanChange
      if RowInfo.RowNames:IsValidIndex(1) then
        self.KeyRowName = RowInfo.RowNames:Get(1)
      end
      self.InputKeySelector:SetAllowGamepadKeys(true)
    else
      return
    end
  end
  UpdateVisibility(self.InputKeySelector, self.CanChange)
  UpdateVisibility(self.Img_KeyChangedFlag, false)
  self:UpdateOriginSelectedKey()
  self.SelectedPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Line:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if self.CanChange then
    EventSystem.AddListener(self, EventDef.GameSettings.OnCustomKeySelected, self.BindOnCustomKeySelected)
    EventSystem.AddListener(self, EventDef.GameSettings.OnKeyChanged, self.BindOnKeyChanged)
  end
end
function WBP_CustomKeyItem_C:UpdateOriginSelectedKey()
  if self.CanChange then
    self.OriginSelectedKey = LogicGameSetting.GetCurPlayerMappableKey(self.KeyRowName, self.InputType)
    if not UE.URGBlueprintLibrary.EqualKey(self.OriginSelectedKey, self.InputKeySelector.SelectedKey.Key) then
      local CurInputChord = UE.FInputChord()
      CurInputChord.Key = self.OriginSelectedKey
      self.InputKeySelector:SetSelectedKey(CurInputChord)
    else
      self:SetKeyInfo()
    end
  else
    self:SetKeyInfo()
  end
end
function WBP_CustomKeyItem_C:SetKeyInfo(...)
  self:SetKeyNameDisplayInfo()
  self:ChangeEmptyFlagVis()
end
function WBP_CustomKeyItem_C:BindOnKeySelected(SelectedKey)
  if self.InputType == UE.ECommonInputType.Gamepad then
    local CanNotChangeList = LogicGameSetting.GetGamepadCanNotChangeKeyNameList()
    if table.Contain(CanNotChangeList, SelectedKey.Key.KeyName) or not UE.UKismetInputLibrary.Key_IsGamepadKey(SelectedKey.Key) then
      local InputChord = UE.FInputChord()
      InputChord.Key = self.OriginSelectedKey
      self.InputKeySelector:SetSelectedKey(InputChord)
      ShowWaveWindow(self.KeyCanNotChangeTipId)
      return
    end
  end
  self:SetKeyInfo()
  if UE.URGBlueprintLibrary.EqualKey(self.OriginSelectedKey, SelectedKey.Key) then
    print("\229\189\147\229\137\141\233\148\174\228\184\128\230\160\183\239\188\140\230\151\160\233\156\128\230\155\180\230\141\162")
    LogicGameSetting.SetPreCustomKeyList(self.KeyRowName, nil)
    UpdateVisibility(self.Img_KeyChangedFlag, false)
  else
    UpdateVisibility(self.Img_KeyChangedFlag, true)
    LogicGameSetting.SetPreCustomKeyList(self.KeyRowName, SelectedKey.Key.KeyName, self.KeyRowName, self.OriginSelectedKey.KeyName)
  end
  EventSystem.Invoke(EventDef.GameSettings.OnCustomKeySelected, self.KeyRowName, SelectedKey.Key.KeyName, self.InputType)
end
function WBP_CustomKeyItem_C:BindOnKeyChanged(ChangedKeyRowNameList)
  if table.Contain(ChangedKeyRowNameList, self.KeyRowName) then
    self:UpdateOriginSelectedKey()
    UpdateVisibility(self.Img_KeyChangedFlag, false)
  end
end
function WBP_CustomKeyItem_C:ChangeEmptyFlagVis()
  local CurSelectedKey = self.InputKeySelector.SelectedKey.Key
  if not UE.UKismetInputLibrary.Key_IsValid(CurSelectedKey) then
    self.Img_EmptyFlag:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.Img_EmptyFlag:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_CustomKeyItem_C:BindOnIsSelectingKeyChanged()
  self:SetKeyNameDisplayInfo()
  if self.InputKeySelector:GetIsSelectingKey() then
    self.KeyIconPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.KeyTextPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Img_KeyBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_KeySelectorBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    UpdateVisibility(self.Img_KeyBG, false)
  else
    self.Img_KeyBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_KeySelectorBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self.Img_KeyBG, true)
  end
end
function WBP_CustomKeyItem_C:SetKeyNameDisplayInfo()
  UpdateVisibility(self.Overlay_SecondKey, false)
  if self.CanChange then
    local TargetKey = self.InputKeySelector.SelectedKey.Key
    local BResult, KeyIconRowInfo = GetRowData(DT.DT_KeyIcon, TargetKey.KeyName)
    local IsIcon = false
    local KeyDisplayInfo = self.InputKeySelector:GetSelectedKeyText()
    if self.InputKeySelector:GetIsSelectingKey() then
      IsIcon = false
    else
      KeyDisplayInfo, IsIcon = LogicGameSetting.GetKeyDisplayInfoByKeyName(TargetKey.KeyName)
    end
    if IsIcon then
      self.KeyTextPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.KeyIconPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      SetImageBrushBySoftObject(self.Img_KeyIcon, KeyDisplayInfo)
    else
      self.KeyTextPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      self.KeyIconPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Txt_KeyName:SetText(KeyDisplayInfo)
    end
    self.RGStateController_FirstKeyBG:ChangeStatus("CanChange")
  else
    self.RGStateController_FirstKeyBG:ChangeStatus("CanNotChange")
    local Result, RowInfo = GetRowData(DT.DT_CustomKey_Gamepad, self.KeyTableRowName)
    if Result then
      if UE.UKismetSystemLibrary.IsValidSoftObjectReference(RowInfo.SpecifiedImage) then
        self.KeyTextPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.KeyIconPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
        SetImageBrushBySoftObject(self.Img_KeyIcon, RowInfo.SpecifiedImage)
      else
        local KeyRowNameList = RowInfo.RowNames:ToTable()
        if KeyRowNameList[1] then
          self:SetKeyDisplay(KeyRowNameList[1], self.KeyTextPanel, self.KeyIconPanel, self.Img_KeyIcon, self.Txt_KeyName)
        end
        if KeyRowNameList[2] then
          UpdateVisibility(self.Overlay_SecondKey, true)
          self:SetKeyDisplay(KeyRowNameList[2], self.Overlay_SecondKeyTextPanel, self.Overlay_SecondKeyIconPanel, self.Img_KeyIcon_Second, self.Txt_KeyName_Second)
        end
      end
    end
  end
end
function WBP_CustomKeyItem_C:SetKeyDisplay(KeyRowName, KeyTextPanel, KeyIconPanel, KeyIconImg, KeyTextBlock)
  local KeyDisplayInfo, IsIcon = LogicGameSetting.GetCurSelectedKeyNameByKeyRowName(KeyRowName, nil, self.InputType)
  if IsIcon then
    KeyTextPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    KeyIconPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    SetImageBrushBySoftObject(KeyIconImg, KeyDisplayInfo)
  else
    KeyTextPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    KeyIconPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    KeyTextBlock:SetText(KeyDisplayInfo)
  end
end
function WBP_CustomKeyItem_C:BindOnEscapeKeySelected()
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  WaveWindowManager:ShowWaveWindow(1093)
end
function WBP_CustomKeyItem_C:BindOnCustomKeySelected(KeyRowName, KeyName, InputType)
  if InputType ~= self.InputType then
    return
  end
  if KeyRowName == self.KeyRowName then
    return
  end
  local CurSelectedKeyName = self.InputKeySelector.SelectedKey.Key.KeyName
  if CurSelectedKeyName == KeyName then
    local InputChord = UE.FInputChord()
    InputChord.Key = self.EmptyKey
    self.InputKeySelector:SetSelectedKey(InputChord)
    ShowWaveWindow(self.KeyConflictTipId)
  end
end
function WBP_CustomKeyItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:RemoveBindEventListener()
  self.IsFocus = false
end
function WBP_CustomKeyItem_C:RemoveBindEventListener()
  EventSystem.RemoveListener(EventDef.GameSettings.OnCustomKeySelected, self.BindOnCustomKeySelected, self)
  EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, self.BindOnKeyChanged, self)
end
function WBP_CustomKeyItem_C:Destruct()
  self.InputKeySelector.OnKeySelected:Remove(self, WBP_CustomKeyItem_C.BindOnKeySelected)
  self.InputKeySelector.OnIsSelectingKeyChanged:Remove(self, WBP_CustomKeyItem_C.BindOnIsSelectingKeyChanged)
  self.InputKeySelector.OnEscapeKeySelected:Remove(self, WBP_CustomKeyItem_C.BindOnEscapeKeySelected)
  self:RemoveBindEventListener()
end
return WBP_CustomKeyItem_C
