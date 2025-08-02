local WBP_ControlSettingItem = UnLua.Class()

function WBP_ControlSettingItem:Show(InputType)
  if not UE.UKismetInputLibrary.Key_IsValid(self.KeyMapping) then
    return
  end
  local PC = self:GetOwningPlayer()
  local EnhancedInputLocalPlayerSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UEnhancedInputLocalPlayerSubsystem:StaticClass())
  local AllPlayerMappableKeyList = EnhancedInputLocalPlayerSystem:GetAllPlayerMappedKeyList()
  local AllCustomKeyRowNames = GetAllRowNames(DT.DT_CustomKey_Gamepad)
  local AllKeyRowNames = {}
  for i, SingleRowName in ipairs(AllCustomKeyRowNames) do
    local Result, RowInfo = GetRowData(DT.DT_CustomKey_Gamepad, SingleRowName)
    if 1 == RowInfo.RowNames:Length() then
      table.insert(AllKeyRowNames, RowInfo.RowNames:Get(1))
    end
  end
  local TargetKeyRowName
  local InputSettings = UE.URGInputSettings.GetInputSettings()
  local AllDefaultMappableKeyByInputType = InputSettings:GetAllPlayerMappableKey()
  local AllDefaultMappableKey = AllDefaultMappableKeyByInputType:Find(InputType)
  local PreKeyList = LogicGameSetting.GetPreCustomKeyList()
  for i, SingleKeyRowName in ipairs(AllKeyRowNames) do
    local MappableKey
    if PreKeyList[SingleKeyRowName] then
      MappableKey = UE.URGBlueprintLibrary.MakeKey(PreKeyList[SingleKeyRowName].Key, nil)
    end
    MappableKey = MappableKey or AllPlayerMappableKeyList:Find(SingleKeyRowName)
    MappableKey = MappableKey or AllDefaultMappableKey.MappableKeys:Find(SingleKeyRowName)
    if UE.UKismetInputLibrary.EqualEqual_KeyKey(self.KeyMapping, MappableKey) then
      TargetKeyRowName = SingleKeyRowName
    end
  end
  if not TargetKeyRowName then
    self.Text_KeyName:SetText("")
  elseif InputType == UE.ECommonInputType.MouseAndKeyboard then
    local Result, RowInfo = GetRowData(DT.DT_CustomKey, TargetKeyRowName)
    if Result then
      self.Text_KeyName:SetText(RowInfo.DisplayName)
    else
      self.Text_KeyName:SetText(self.KeyName)
    end
  elseif InputType == UE.ECommonInputType.Gamepad then
    local RowName = LogicGameSetting.GetTableRowNameByInputRowName(TargetKeyRowName)
    local Result, RowInfo = GetRowData(DT.DT_CustomKey_Gamepad, RowName)
    if Result then
      self.Text_KeyName:SetText(RowInfo.DisplayName)
    else
      self.Text_KeyName:SetText(self.KeyName)
    end
  else
    self.Text_KeyName:SetText(TargetKeyRowName)
  end
end

return WBP_ControlSettingItem
