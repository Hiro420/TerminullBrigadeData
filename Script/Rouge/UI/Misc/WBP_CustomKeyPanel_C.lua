local WBP_CustomKeyPanel_C = UnLua.Class()

function WBP_CustomKeyPanel_C:Construct()
end

function WBP_CustomKeyPanel_C:SaveSettings()
  self:SaveKeyMappings()
  local GameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  GameUserSettings:SaveSettings()
end

function WBP_CustomKeyPanel_C:SaveKeyMappings()
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

function WBP_CustomKeyPanel_C:CancelSaveSettings()
  LogicGameSetting.ClearPreCustomKeyList()
end

function WBP_CustomKeyPanel_C:ChangeFocusToFirstItem()
  local TargetItem = self.CustomKeyList:GetChildAt(0)
  if TargetItem then
    TargetItem:SetKeyboardFocus()
    UE.URGBlueprintLibrary.SetTimerForNextTick(TargetItem, {
      TargetItem,
      function()
        TargetItem.InputKeySelector:SetKeyboardFocus()
      end
    })
  end
end

function WBP_CustomKeyPanel_C:DoCustomNavigation(Type)
  EventSystem.Invoke(EventDef.GameSettings.OnItemNavigation, Type)
end

function WBP_CustomKeyPanel_C:Show()
  LogicGameSetting.ClearPreCustomKeyList()
  local Index = 0
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local AllRowNames = self:GetAllCustomTableRowNames():ToTable()
  local AllChildren = self.CustomKeyList:GetAllChildren()
  for i, SingleChild in pairs(AllChildren) do
    SingleChild:Hide()
  end
  for index, SingleRowName in ipairs(AllRowNames) do
    local Result, RowInfo = DTSubsystem:GetCustomKeyDataByName(SingleRowName, nil)
    if Result then
      if RowInfo.CanChange then
        local Item = self.CustomKeyList:GetChildAt(Index)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, self.ItemTemplate:StaticClass())
          self.CustomKeyList:AddChild(Item)
        end
        Item:InitInfo(SingleRowName, UE.ECommonInputType.MouseAndKeyboard)
        Item:SetNavigationRuleCustom(UE.EUINavigation.Left, {
          self,
          self.DoCustomNavigation
        })
        Index = Index + 1
      end
    else
      print("not found rowInfo in DT_CustomKey, RowName is", SingleRowName)
    end
  end
end

function WBP_CustomKeyPanel_C:BindOnRestoreButtonClicked()
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

function WBP_CustomKeyPanel_C:IsNeedShowSaveTip()
  local List = LogicGameSetting.GetPreCustomKeyList()
  return table.count(List) > 0
end

function WBP_CustomKeyPanel_C:HidePanel(...)
  LogicGameSetting.ClearPreCustomKeyList()
end

return WBP_CustomKeyPanel_C
