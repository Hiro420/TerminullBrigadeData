local EGemStatus = {
  Normal = 0,
  Lock = 1,
  Discard = 2
}
_G.EGemStatus = EGemStatus
local PuzzleInfoConfig = require("GameConfig.Puzzle.PuzzleInfoConfig")
local GemData = {
  AllPackageInfo = {}
}

function GemData:SetGemState(InGemId, State)
  local GemPackageInfo = GemData:GetGemPackageInfoByUId(InGemId)
  if not GemPackageInfo then
    return
  end
  GemPackageInfo.state = State
end

function GemData:SetGemPackageInfo(GemId, PackageInfo)
  GemData.AllPackageInfo[GemId] = PackageInfo
end

function GemData:SetGemEquipPuzzleId(InGemId, InPuzzleId)
  local GemPackageInfo = GemData:GetGemPackageInfoByUId(InGemId)
  if not GemPackageInfo then
    return
  end
  GemPackageInfo.pzUniqueID = InPuzzleId
end

function GemData:GetAllGemPackageInfo(...)
  return GemData.AllPackageInfo
end

function GemData:GetGemPackageInfoByUId(GemId)
  return GemData.AllPackageInfo[GemId]
end

function GemData:RemoveGemPackageInfo(GemId)
  GemData.AllPackageInfo[GemId] = nil
end

function GemData:GetGemResourceIdByUId(GemId, InPackageInfo)
  local PackageInfo = InPackageInfo
  PackageInfo = PackageInfo or GemData:GetGemPackageInfoByUId(GemId)
  if not PackageInfo then
    return -1
  end
  return tonumber(PackageInfo.resourceID)
end

function GemData:IsEquippedInPuzzle(GemId)
  local PackageInfo = GemData:GetGemPackageInfoByUId(GemId)
  if not PackageInfo then
    return false
  end
  return PackageInfo.pzUniqueID and PackageInfo.pzUniqueID ~= "0" and 0 ~= PackageInfo.pzUniqueID
end

function GemData:GetGemEquippedPuzzleId(GemId)
  local PackageInfo = GemData:GetGemPackageInfoByUId(GemId)
  if not PackageInfo then
    return 0
  end
  return PackageInfo.pzUniqueID
end

function GemData:GetMainAttrValueList(GemId)
  local TargetMainAttrList = {}
  local GemResourceId = GemData:GetGemResourceIdByUId(GemId)
  local AResult, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, GemResourceId)
  local BResult, GemResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResGem, GemResourceId)
  if not AResult or not BResult then
    return TargetMainAttrList
  end
  local MainAttrValueList = {}
  for index, SingleAttrInfo in ipairs(GemResRowInfo.Attr) do
    MainAttrValueList[SingleAttrInfo.key] = SingleAttrInfo.value
  end
  local MainAttrGrowthValueList = {}
  local Result, CoreAttrLvUpRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGemLevelUpAttr, ResourceRowInfo.Rare)
  for i, SingleAttrInfo in ipairs(CoreAttrLvUpRowInfo.LevelUpAttr) do
    MainAttrGrowthValueList[SingleAttrInfo.key] = SingleAttrInfo.value
  end
  local GemPackageInfo = GemData:GetGemPackageInfoByUId(GemId)
  for i, SingleCoreAttributeId in ipairs(GemPackageInfo.mainAttrIDs) do
    local Value = MainAttrValueList[SingleCoreAttributeId] + MainAttrGrowthValueList[SingleCoreAttributeId] * GemPackageInfo.level or 0
    TargetMainAttrList[SingleCoreAttributeId] = Value
  end
  return TargetMainAttrList
end

function GemData:GetGemName(InGemId, InPackageInfo)
  local PackageInfo = InPackageInfo or GemData:GetGemPackageInfoByUId(InGemId)
  if not PackageInfo then
    return ""
  end
  local ResourceId = tonumber(PackageInfo.resourceID)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return ""
  end
  local Text = RowInfo.Name
  if PackageInfo.mutation then
    local NameFmt = "{0}{1}"
    Text = UE.FTextFormat(NameFmt, PuzzleInfoConfig.MutationName(), RowInfo.Name)
  end
  return Text
end

function GemData:ClearData(...)
  GemData.AllPackageInfo = {}
end

return GemData
