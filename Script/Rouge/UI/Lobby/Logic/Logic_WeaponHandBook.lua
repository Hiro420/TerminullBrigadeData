local rapidjson = require("rapidjson")
LogicWeaponHandBook = LogicWeaponHandBook or {}
function LogicWeaponHandBook.Init()
end
function LogicWeaponHandBook:ShowSoulCore()
end
function LogicWeaponHandBook:HideSelf()
end
function LogicWeaponHandBook:Clear()
  LogicWeaponHandBook:HideSelf()
  self.WeaponMap = nil
end
function LogicWeaponHandBook:CheckWeaponUnLock(WeaponHandBook)
  return tonumber(DataMgr.GetRoleLevel()) >= WeaponHandBook.UnLockLv
end
function LogicWeaponHandBook:CheckWeaponUnLockById(WeaponId)
  local Result, WeaponHandBook = self:GetWeaponHandBookDataByRowName(WeaponId)
  if WeaponHandBook then
    return tonumber(DataMgr.GetRoleLevel()) >= WeaponHandBook.UnLockLv
  end
  return false
end
function LogicWeaponHandBook:GetItemRarityByRare(Rare)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicWeaponHandBook:GetItemRarityByRare not DTSubsystem")
    return
  end
  local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(Rare)
  return ItemRarityResult, ItemRarityData
end
function LogicWeaponHandBook:GetWorldInfoByWorldId(Id)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicWeaponHandBook:GetWorldInfoByRowName not DTSubsystem")
    return
  end
  local ResultWorld, World = DTSubsystem:GetWorldTypeTableRow(Id)
  return ResultWorld, World
end
function LogicWeaponHandBook:GetItemDataByRowName(ItemRowName)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicWeaponHandBook:GetItemDataByRowName not DTSubsystem")
    return
  end
  return DTSubsystem:K2_GetItemTableRow(ItemRowName, nil)
end
function LogicWeaponHandBook:GetWeaponHandBookDataByRowName(WeaponId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicWeaponHandBook:GetWeaponHandBookDataByRowName not DTSubsystem")
    return
  end
  return DTSubsystem:GetWeaponHandBookById(WeaponId, nil)
end
function LogicWeaponHandBook:GetAccessoryById(AccessoryId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicWeaponHandBook:GetAccessoryById not DTSubsystem")
    return
  end
  return DTSubsystem:GetAccessoryTableRow(AccessoryId, nil)
end
function LogicWeaponHandBook:GetWeaponListByWorldId(WorldId)
  local WeaponList = {}
  for i, v in ipairs(self.WeaponMap[WorldId]) do
    table.insert(WeaponList, v)
  end
  table.sort(WeaponList, LogicWeaponHandBook.WeaponListSort)
  return WeaponList
end
function LogicWeaponHandBook.WeaponListSort(A, B)
  local AUnLock = LogicWeaponHandBook:CheckWeaponUnLockById(A)
  local BUnLock = LogicWeaponHandBook:CheckWeaponUnLockById(B)
  if not AUnLock and BUnLock then
    return false
  end
  if AUnLock and not BUnLock then
    return true
  end
  return A < B
end
function LogicWeaponHandBook:InitWeaponData()
  if self.WeaponMap then
    return
  end
  self.WeaponMap = {}
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("LogicWeaponHandBook:InitWeaponData not DTSubsystem")
    return
  end
  local dataTable = DTSubsystem:GetDataTable("WeaponHandBook")
  if not dataTable then
    return
  end
  local RowNames = UE.TArray(UE.FName)
  RowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(dataTable)
  local RowNameTb = RowNames:ToTable()
  for i, v in ipairs(RowNameTb) do
    local Result, AccessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(v), nil)
    if self.WeaponMap[AccessoryData.WorldId] then
      table.insert(self.WeaponMap[AccessoryData.WorldId], AccessoryData.ConfigId)
    else
      self.WeaponMap[AccessoryData.WorldId] = {
        AccessoryData.ConfigId
      }
    end
  end
end
