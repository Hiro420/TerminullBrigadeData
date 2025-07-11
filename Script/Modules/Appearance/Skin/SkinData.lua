local enum = _G.enum
local ESkinToggleStatus = {
  None = 0,
  HeroSkin = 1,
  WeaponSkin = 2
}
_G.ESkinToggleStatus = _G.ESkinToggleStatus or ESkinToggleStatus
local EWeaponSkinDisplayModel = {
  None = 0,
  WeaponModel = 1,
  HeroModel = 2
}
_G.EWeaponSkinDisplayModel = _G.EWeaponSkinDisplayModel or EWeaponSkinDisplayModel
local EWeaponSelectModel = {WeaponModel = 1, SkinModel = 2}
_G.EWeaponSelectModel = _G.EWeaponSelectModel or EWeaponSelectModel
local EWeaponShowModel = {WeaponModel = 1, ResStoneModel = 2}
_G.EWeaponShowModel = _G.EWeaponShowModel or EWeaponShowModel
local SkinRareTag = {
  [0] = 1061,
  [1] = 1062,
  [2] = 1063,
  [3] = 1064,
  [4] = 1065
}
_G.SkinRareTag = _G.SkinRareTag or SkinRareTag
local SkinData = {
  HeroSkinMap = {},
  WeaponSkinMap = {}
}
function SkinData.ClearData()
  SkinData.HeroSkinMap = {}
  SkinData.WeaponSkinMap = {}
end
function SkinData.GetEquipedSkinIdByHeroId(HeroId)
  if not SkinData.HeroSkinMap[HeroId] then
    return -1
  end
  return SkinData.HeroSkinMap[HeroId].EquipedSkinId
end
function SkinData.GetDefaultSkinIdByHeroId(HeroId)
  local result, row = GetRowData(DT.DT_Hero, tostring(HeroId))
  if result then
    return row.SkinID
  end
  return -1
end
function SkinData.GetEquipedWeaponSkinIdByWeaponResId(WeaponResId)
  if not SkinData.WeaponSkinMap[WeaponResId] then
    return -1
  end
  return SkinData.WeaponSkinMap[WeaponResId].EquipedSkinId
end
function SkinData.GetWeaponResIdBySkinId(SkinId)
  local skinResID = GetTbSkinRowNameBySkinID(SkinId)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, skinResID)
  if result then
    return row.WeaponID
  end
  return nil
end
function SkinData.GetWeaponResIdBySkinResId(SkinResId)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, SkinResId)
  if result then
    return row.WeaponID
  end
  return nil
end
function SkinData.CheckWeaponSkinCanEquip(SkinResId)
  local skinData
  local bEquiped = false
  for k, v in pairs(SkinData.WeaponSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.WeaponSkinTb.SkinID then
        skinData = vSkinData
        bEquiped = v.EquipedSkinId == vSkinData.WeaponSkinTb.SkinID
        break
      end
    end
  end
  if not skinData or not skinData.bUnlocked then
    return false
  end
  if bEquiped then
    return false
  end
  return true
end
function SkinData.GetWeaponSkinDataBySkinResId(SkinResId)
  for k, v in pairs(SkinData.WeaponSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.WeaponSkinTb.SkinID then
        return vSkinData
      end
    end
  end
  return nil
end
function SkinData.FindHeroSkin(SkinId)
  for HeroId, SkinDatas in pairs(SkinData.HeroSkinMap) do
    local SkinDataList = SkinDatas.SkinDataList
    for index, SkinData in ipairs(SkinDataList) do
      if SkinData.bUnlocked and SkinId == SkinData.HeroSkinTb.ID then
        return true
      end
    end
  end
  return false
end
function SkinData.FindWeaponSkin(SkinId)
  for HeroId, SkinDatas in pairs(SkinData.WeaponSkinMap) do
    local SkinDataList = SkinDatas.SkinDataList
    for index, SkinData in ipairs(SkinDataList) do
      if SkinData.bUnlocked and SkinId == SkinData.WeaponSkinTb.ID then
        return true
      end
    end
  end
  return false
end
function SkinData.GetSkinParentId(SkinID)
  local ResID = GetTbSkinRowNameBySkinID(SkinID)
  local result, rowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, ResID)
  if result and 0 ~= rowInfo.ParentSkinId then
    return rowInfo.ParentSkinId
  end
  return SkinID
end
return SkinData
