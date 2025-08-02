local WBP_RGPuzzleResetWaveWindow = UnLua.Class()
local PuzzleData = require("Modules.Puzzle.PuzzleData")

function WBP_RGPuzzleResetWaveWindow:Show(PuzzleIdList, IsNeedDecompose)
  local ResourceList = {}
  for index, PuzzleId in ipairs(PuzzleIdList) do
    local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(PuzzleId)
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
    local PuzzleDevelopViewModel = UIModelMgr:Get("PuzzleDevelopViewModel")
    local LevelInfo = PuzzleDevelopViewModel:GetLevelInfoByQuality(RowInfo.Rare)
    local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
    for i = 0, PackageInfo.level do
      local ResetResourceInfo = LevelInfo[i].ResetGetResource
      for i, SingleResourceInfo in ipairs(ResetResourceInfo) do
        if not ResourceList[SingleResourceInfo.key] then
          ResourceList[SingleResourceInfo.key] = 0
        end
        ResourceList[SingleResourceInfo.key] = ResourceList[SingleResourceInfo.key] + SingleResourceInfo.value
      end
    end
    if IsNeedDecompose then
      local Result, ResPuzzleRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
      for i, SingleResourceInfo in ipairs(ResPuzzleRowInfo.decomposeResource) do
        if not ResourceList[SingleResourceInfo.key] then
          ResourceList[SingleResourceInfo.key] = 0
        end
        ResourceList[SingleResourceInfo.key] = ResourceList[SingleResourceInfo.key] + SingleResourceInfo.value
      end
    end
  end
  local Index = 1
  for ResourceId, Value in pairs(ResourceList) do
    local Item = GetOrCreateItem(self.Horizontal_ItemList, Index, self.WBP_PuzzleResetItem:StaticClass())
    Item:Show(ResourceId, Value)
    Index = Index + 1
  end
  HideOtherItem(self.Horizontal_ItemList, Index, true)
end

return WBP_RGPuzzleResetWaveWindow
