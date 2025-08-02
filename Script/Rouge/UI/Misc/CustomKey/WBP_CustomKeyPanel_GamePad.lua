local WBP_CustomKeyPanel_GamePad = UnLua.Class()

function WBP_CustomKeyPanel_GamePad:SaveSettings()
  self:SaveKeyMappings()
  local GameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  GameUserSettings:SaveSettings()
end

function WBP_CustomKeyPanel_GamePad:SaveKeyMappings()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local InputSettings = UE.UInputSettings.GetInputSettings()
  if not InputSettings then
    print("WBP_CustomKeyPanel_C InputSettings is nil")
    return
  end
  local List = LogicGameSetting.GetPreCustomKeyList()
  local ChangedKeyRowNameList = {}
  local CurCustomKeyDataList = {}
  local EnhancedInputLocalPlayerSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(self:GetOwningPlayer(), UE.UEnhancedInputLocalPlayerSubsystem:StaticClass())
  local Options = UE.FModifyContextOptions()
  for KeyRowName, SingleList in pairs(List) do
    EnhancedInputLocalPlayerSystem:AddPlayerMappedKey(KeyRowName, UE.URGBlueprintLibrary.MakeKey(SingleList.Key, nil), Options)
    local CustomKeyData = UE.FCustomKeyData()
    CustomKeyData.InputName = KeyRowName
    CustomKeyData.KeyName = SingleList.Key
    table.insert(CurCustomKeyDataList, CustomKeyData)
    table.insert(ChangedKeyRowNameList, KeyRowName)
  end
  if next(CurCustomKeyDataList) ~= nil then
    local GameUserSetting = UE.URGGameUserSettings.GetRGGameUserSettings()
    local UserId = DataMgr.GetUserId()
    if UE.URGBlueprintLibrary.CheckWithEditor() and not LogicLobby.IsInLobbyLevel() then
      UserId = ""
    end
    GameUserSetting:SaveCustomKeyDatas(UserId, CurCustomKeyDataList)
  end
  LogicGameSetting.ClearPreCustomKeyList()
  EventSystem.Invoke(EventDef.GameSettings.OnKeyChanged, ChangedKeyRowNameList)
end

function WBP_CustomKeyPanel_GamePad:CancelSaveSettings()
  LogicGameSetting.ClearPreCustomKeyList()
end

function WBP_CustomKeyPanel_GamePad:ChangeFocusToFirstItem()
  local KeyItemList = self.AllLabelKeyItemList[self.AllKeyRowNames[1]]
  EventSystem.Invoke(EventDef.GameSettings.OnFocusGamePadCustomKeyItem, self.AllKeyRowNames[1], KeyItemList[1])
end

function WBP_CustomKeyPanel_GamePad:DoCustomNavigation(Type)
  EventSystem.Invoke(EventDef.GameSettings.OnItemNavigation, Type)
end

function WBP_CustomKeyPanel_GamePad:Show()
  LogicGameSetting.ClearPreCustomKeyList()
  self.AllLabelRowNames = GetAllRowNames(DT.DT_CustomKeyLabel)
  table.sort(self.AllLabelRowNames, function(A, B)
    local AResult, ARowInfo = GetRowData(DT.DT_CustomKeyLabel, A)
    local BResult, BRowInfo = GetRowData(DT.DT_CustomKeyLabel, B)
    return ARowInfo.Priority > BRowInfo.Priority
  end)
  self.AllKeyRowNames = GetAllRowNames(DT.DT_CustomKey_Gamepad)
  table.sort(self.AllKeyRowNames, function(A, B)
    local AResult, ARowInfo = GetRowData(DT.DT_CustomKey_Gamepad, A)
    local BResult, BRowInfo = GetRowData(DT.DT_CustomKey_Gamepad, B)
    if table.IndexOf(self.AllLabelRowNames, ARowInfo.LabelName) == table.IndexOf(self.AllLabelRowNames, BRowInfo.LabelName) then
      return tonumber(A) < tonumber(B)
    end
    return table.IndexOf(self.AllLabelRowNames, ARowInfo.LabelName) < table.IndexOf(self.AllLabelRowNames, BRowInfo.LabelName)
  end)
  self.AllLabelKeyItemList = {}
  for i, SingleRowName in ipairs(self.AllKeyRowNames) do
    local AResult, ARowInfo = GetRowData(DT.DT_CustomKey_Gamepad, SingleRowName)
    if not self.AllLabelKeyItemList[ARowInfo.LabelName] then
      self.AllLabelKeyItemList[ARowInfo.LabelName] = {}
    end
    table.insert(self.AllLabelKeyItemList[ARowInfo.LabelName], SingleRowName)
  end
  local Index = 1
  for i, SingleRowName in ipairs(self.AllLabelRowNames) do
    if self.AllLabelKeyItemList[SingleRowName] then
      local Item = GetOrCreateItem(self.CustomKeyList, Index, self.WBP_CustomKeyItemList:StaticClass())
      Item:Show(SingleRowName, self.AllLabelKeyItemList[SingleRowName], UE.ECommonInputType.Gamepad)
      Index = Index + 1
    end
  end
  HideOtherItem(self.CustomKeyList, Index, true)
  self:RefreshGamepadInfo()
  EventSystem.AddListenerNew(EventDef.GameSettings.OnGamepadCustomKeyNavitionUp, self, self.BindOnGamepadCustomKeyNavitionUp)
  EventSystem.AddListenerNew(EventDef.GameSettings.OnCustomKeySelected, self, self.BindOnCustomKeySelected)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    local CurGamepadName = CommonInputSubsystem:GetCurrentGamepadName()
    print("WBP_CustomKeyPanel_GamePad:Show CurGamepadName = ", CurGamepadName)
    local TargetIconSoftObj = self.GamepadKeyIcon:Find(CurGamepadName) or self.GamepadKeyIcon:Find("Default")
    SetImageBrushBySoftObject(self.Img_Icon, TargetIconSoftObj)
  end
end

function WBP_CustomKeyPanel_GamePad:RefreshGamepadInfo()
  local AllChildren = self.CanvasPanel_Gamepad:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    if SingleItem:Cast(self.WBP_ControlSettingItem:StaticClass()) then
      SingleItem:Show(UE.ECommonInputType.Gamepad)
    end
  end
end

function WBP_CustomKeyPanel_GamePad:BindOnRestoreButtonClicked()
  local GameUserSetting = UE.URGGameUserSettings.GetRGGameUserSettings()
  local UserId = DataMgr.GetUserId()
  if UE.URGBlueprintLibrary.CheckWithEditor() and not LogicLobby.IsInLobbyLevel() then
    UserId = ""
  end
  local ChangedKeyRowNameList = {}
  local AllPreCustomKeyList = LogicGameSetting.GetPreCustomKeyList()
  for SingleMappableName, value in pairs(AllPreCustomKeyList) do
    if not table.Contain(ChangedKeyRowNameList, SingleMappableName) then
      table.insert(ChangedKeyRowNameList, SingleMappableName)
    end
  end
  LogicGameSetting.ClearPreCustomKeyList()
  GameUserSetting:ClearCustomKeyDatasByRoleId(UserId)
  local EnhancedInputLocalPlayerSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(self:GetOwningPlayer(), UE.UEnhancedInputLocalPlayerSubsystem:StaticClass())
  local Options = UE.FModifyContextOptions()
  local AllPlayerMappedKeyList = EnhancedInputLocalPlayerSystem:GetAllPlayerMappedKeyList(nil)
  for MappableName, Key in pairs(AllPlayerMappedKeyList) do
    if not table.Contain(ChangedKeyRowNameList, MappableName) then
      table.insert(ChangedKeyRowNameList, MappableName)
    end
  end
  EnhancedInputLocalPlayerSystem:RemoveAllPlayerMappedKeys(Options)
  EventSystem.Invoke(EventDef.GameSettings.OnKeyChanged, ChangedKeyRowNameList)
end

function WBP_CustomKeyPanel_GamePad:BindOnGamepadCustomKeyNavitionUp(LabelItemName)
  local CurLabelIndex = table.IndexOf(self.AllKeyRowNames, LabelItemName)
  if 1 == CurLabelIndex then
    return
  end
  if self.AllKeyRowNames[CurLabelIndex - 1] then
    EventSystem.Invoke(EventDef.GameSettings.OnFocusGamePadCustomKeyItem, self.AllKeyRowNames[CurLabelIndex - 1])
  end
end

function WBP_CustomKeyPanel_GamePad:BindOnCustomKeySelected(ChangedKeyRowNameList)
  self:RefreshGamepadInfo()
end

function WBP_CustomKeyPanel_GamePad:IsNeedShowSaveTip()
  local List = LogicGameSetting.GetPreCustomKeyList()
  return table.count(List) > 0
end

function WBP_CustomKeyPanel_GamePad:HidePanel(...)
  local AllChildren = self.CustomKeyList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  LogicGameSetting.ClearPreCustomKeyList()
  EventSystem.RemoveListenerNew(EventDef.GameSettings.OnGamepadCustomKeyNavitionUp, self, self.BindOnGamepadCustomKeyNavitionUp)
  EventSystem.RemoveListenerNew(EventDef.GameSettings.OnCustomKeySelected, self, self.BindOnCustomKeySelected)
end

return WBP_CustomKeyPanel_GamePad
