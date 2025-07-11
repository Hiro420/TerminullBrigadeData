local WBP_LobbyWeaponAccessorySlotPanel_C = UnLua.Class()
function WBP_LobbyWeaponAccessorySlotPanel_C:RefreshSlotPanel(WeaponInfo, WorldTypeId)
  local AllItem = self.SlotPanel:GetAllChildren()
  local AccessoryCount = 0
  local AccessoryTable = LuaTableMgr.GetLuaTableByName(TableNames.TBAccessory)
  if not AccessoryTable then
    return
  end
  for i, SingleAccessoryInfo in ipairs(WeaponInfo.acc) do
    local AccessoryTableInfo = AccessoryTable[tonumber(SingleAccessoryInfo.resourceId)]
    if AccessoryTableInfo and AccessoryTableInfo.AccessoryType == TableEnums.ENUMAccType.Accessory then
      AccessoryCount = AccessoryCount + 1
    end
  end
  for i, SingleItem in pairs(AllItem) do
    if i <= AccessoryCount then
      SingleItem:UpdateAccessorySlotByWorldTypeId(WorldTypeId)
    else
      SingleItem:UpdateEmptyAccessorySlot()
    end
  end
end
return WBP_LobbyWeaponAccessorySlotPanel_C
