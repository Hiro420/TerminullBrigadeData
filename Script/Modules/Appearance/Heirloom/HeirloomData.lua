local HeirloomData = {
  UnLockHeirloomList = {},
  AllHeirloomInfo = {},
  CurSelectHeirloomId = -1,
  CurSelectLevel = -1
}
function HeirloomData:DealWithHeirloomTable()
  local HeirloomTotalTable = LuaTableMgr.GetLuaTableByName(TableNames.TBFamilyTreasure)
  if not HeirloomTotalTable then
    return
  end
  local AllHeirloomInfo = HeirloomData.AllHeirloomInfo
  for HeirloomId, HeirloomRowInfo in pairs(HeirloomTotalTable) do
    local TargetHeirloomInfo = AllHeirloomInfo[HeirloomId]
    if not TargetHeirloomInfo then
      TargetHeirloomInfo = {}
      AllHeirloomInfo[HeirloomId] = TargetHeirloomInfo
    end
    TargetHeirloomInfo[1] = HeirloomRowInfo
  end
  local HeirloomUpgradeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBFamilyTreasureUpgrade)
  if not HeirloomUpgradeTable then
    return
  end
  for i, HeirloomRowInfo in ipairs(HeirloomUpgradeTable) do
    local TargetHeirloomLevelInfo = AllHeirloomInfo[HeirloomRowInfo.ID]
    if TargetHeirloomLevelInfo then
      TargetHeirloomLevelInfo[HeirloomRowInfo.Level] = HeirloomRowInfo
    end
  end
end
function HeirloomData:GetHeirloomSkinID(HeirloomID, Level)
  local HeirloomUpgradeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBFamilyTreasureUpgrade)
  if not HeirloomUpgradeTable then
    return
  end
  local GiftID = 0
  for i, HeirloomRowInfo in ipairs(HeirloomUpgradeTable) do
    if HeirloomRowInfo.ID == HeirloomID and HeirloomRowInfo.Level == Level then
      GiftID = HeirloomRowInfo.GiftID
      break
    end
  end
  local result, GiftInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGift, GiftID)
  if result then
    local resID = 0
    for i, v in pairs(GiftInfo.Resources[1]) do
      if "key" == i then
        resID = v
        break
      end
    end
    local skinResult, CharacterSkinInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, resID)
    if skinResult then
      return CharacterSkinInfo.SkinID
    end
  end
end
function HeirloomData:SetUnLockHeirloomList(InUnLockHeirloomList)
  HeirloomData.UnLockHeirloomList = DeepCopy(InUnLockHeirloomList)
end
function HeirloomData:SetCurSelectHeirloomIdAndLevel(InHeirloomId, InLevel)
  HeirloomData.CurSelectHeirloomId = InHeirloomId
  HeirloomData.CurSelectLevel = InLevel
end
function HeirloomData:GetCurSelectHeirloomId()
  return HeirloomData.CurSelectHeirloomId
end
function HeirloomData:GetCurSelectLevel()
  return HeirloomData.CurSelectLevel
end
function HeirloomData:IsUnLockHeirloom(HeirloomId, Level)
  for index, SingleHeirloomInfo in ipairs(HeirloomData.UnLockHeirloomList) do
    if SingleHeirloomInfo.id == HeirloomId and Level <= SingleHeirloomInfo.level then
      return true
    end
  end
  return false
end
function HeirloomData:IsUnLockHeirloomDataEmpty(...)
  return next(HeirloomData.UnLockHeirloomList) == nil
end
function HeirloomData:GetMaxUnLockHeirloomLevel(HeirloomId)
  local Level = 0
  for index, SingleHeirloomInfo in ipairs(HeirloomData.UnLockHeirloomList) do
    if SingleHeirloomInfo.id == HeirloomId then
      Level = SingleHeirloomInfo.level
    end
  end
  return Level
end
function HeirloomData:GetAllResourceIdByGiftId(RandomGiftId)
  local Table = LuaTableMgr.GetLuaTableByName(TableNames.TBGift)
  local AllResourceId = {}
  if not Table then
    return AllResourceId
  end
  local RowInfo = Table[RandomGiftId]
  if not RowInfo then
    return AllResourceId
  end
  for index, SingleResourceInfo in ipairs(RowInfo.Resources) do
    table.insert(AllResourceId, SingleResourceInfo.key)
  end
  return AllResourceId
end
function HeirloomData:GetAllHeirloomByHeroId(HeroId)
  local HeirIdList = {}
  local FirstLevelInfo
  for HeirloomId, HeirloomRowList in pairs(HeirloomData.AllHeirloomInfo) do
    FirstLevelInfo = HeirloomRowList[1]
    if FirstLevelInfo and FirstLevelInfo.HeroID == HeroId then
      table.insert(HeirIdList, HeirloomId)
    end
  end
  return HeirIdList
end
function HeirloomData:GetHeirloomInfoByLevel(HeirloomId, Level)
  local LevelInfoList = HeirloomData.AllHeirloomInfo[HeirloomId]
  return LevelInfoList and LevelInfoList[Level] or nil
end
function HeirloomData:GetHeirloomMaxLevel(HeirloomId)
  local LevelInfoList = HeirloomData.AllHeirloomInfo[HeirloomId]
  return LevelInfoList and table.count(LevelInfoList) or 0
end
function HeirloomData:GetHeroSkinByHeirloomLevel(InHeirloomId, InLevel)
  local TargetSkinId = -1
  local TargetSkinResourceId = -1
  local IsCurLevelHasSkin = false
  local HeirloomInfoList = HeirloomData.AllHeirloomInfo[InHeirloomId]
  if not HeirloomInfoList then
    return TargetSkinId, IsCurLevelHasSkin
  end
  local Table = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not Table then
    return TargetSkinId, IsCurLevelHasSkin
  end
  local ResourceIdList = {}
  for Level, HeriloomRowInfo in pairs(HeirloomInfoList) do
    if Level <= InLevel then
      ResourceIdList = HeirloomData:GetAllResourceIdByGiftId(HeriloomRowInfo.GiftID)
      if next(ResourceIdList) ~= nil then
        for index, SingleResourceId in ipairs(ResourceIdList) do
          local ResourceRowInfo = Table[SingleResourceId]
          if ResourceRowInfo and ResourceRowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
            TargetSkinResourceId = SingleResourceId
            if Level == InLevel then
              IsCurLevelHasSkin = true
            end
          end
        end
      end
    end
  end
  local HeroSkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  local RowInfo = HeroSkinTable[TargetSkinResourceId]
  if not RowInfo then
    return TargetSkinId, IsCurLevelHasSkin
  end
  TargetSkinId = RowInfo.SkinID
  return TargetSkinId, IsCurLevelHasSkin
end
function HeirloomData:GetHeirloomBySkinId(SkinId)
  local Tb = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local HeroSkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  local ResourceIdList, RowInfo = {}
  for HeirloomId, HeirloomInfoList in pairs(HeirloomData.AllHeirloomInfo) do
    for Level, HeirloomRowInfo in pairs(HeirloomInfoList) do
      ResourceIdList = HeirloomData:GetAllResourceIdByGiftId(HeirloomRowInfo.GiftID)
      if next(ResourceIdList) ~= nil then
        for index, SingleResourceId in ipairs(ResourceIdList) do
          RowInfo = HeroSkinTable[SingleResourceId]
          if Tb and Tb[SingleResourceId] and Tb[SingleResourceId].Type == TableEnums.ENUMResourceType.HeroSkin and RowInfo and SkinId == RowInfo.SkinID then
            return HeirloomId, Level
          end
        end
      end
    end
  end
  return -1, -1
end
function HeirloomData:GetHeirloomInfoListByHeirloomId(HeirloomId)
  local heirloomInfoList = {}
  if HeirloomData.AllHeirloomInfo[HeirloomId] then
    for i, v in pairs(HeirloomData.AllHeirloomInfo[HeirloomId]) do
      table.insert(heirloomInfoList, v)
    end
  end
  return heirloomInfoList
end
function HeirloomData:GetWeaponSkinByHeirloomLevel(InHeirloomId, InLevel)
  local TargetSkinId = -1
  local TargetSkinResourceId = -1
  local HeirloomInfoList = HeirloomData.AllHeirloomInfo[InHeirloomId]
  if not HeirloomInfoList then
    return TargetSkinId
  end
  local Table = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not Table then
    return TargetSkinId
  end
  local ResourceIdList = {}
  for Level, HeriloomRowInfo in pairs(HeirloomInfoList) do
    if Level <= InLevel then
      ResourceIdList = HeirloomData:GetAllResourceIdByGiftId(HeriloomRowInfo.GiftID)
      if next(ResourceIdList) ~= nil then
        for index, SingleResourceId in ipairs(ResourceIdList) do
          local ResourceRowInfo = Table[SingleResourceId]
          if ResourceRowInfo and ResourceRowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin then
            TargetSkinResourceId = SingleResourceId
            break
          end
        end
      end
    end
  end
  local HeroSkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBWeaponSkin)
  local RowInfo = HeroSkinTable[TargetSkinResourceId]
  if not RowInfo then
    return TargetSkinId
  end
  TargetSkinId = RowInfo.SkinID
  return TargetSkinId
end
function HeirloomData:GetHeirloomResourceId(HeirloomId)
  local TargetResourceId = 0
  local ResHeirloomTable = LuaTableMgr.GetLuaTableByName(TableNames.TBResFamilyTreasure)
  for ResourceId, SingleRowInfo in pairs(ResHeirloomTable) do
    if SingleRowInfo.FamilyTreasureID == HeirloomId then
      TargetResourceId = ResourceId
      break
    end
  end
  return TargetResourceId
end
return HeirloomData
