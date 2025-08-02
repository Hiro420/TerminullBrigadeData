local WBP_RGGemDecomposeWaveWindow = UnLua.Class()
local GemData = require("Modules.Gem.GemData")

function WBP_RGGemDecomposeWaveWindow:Show(GemIdList)
  local ResourceList = {}
  for index, GemId in ipairs(GemIdList) do
    local ResourceId = GemData:GetGemResourceIdByUId(GemId)
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
    local GemUpgradeViewModel = UIModelMgr:Get("GemUpgradeViewModel")
    local LevelInfo = GemUpgradeViewModel:GetLevelInfoByQuality(RowInfo.Rare)
    local PackageInfo = GemData:GetGemPackageInfoByUId(GemId)
    for i = 0, PackageInfo.level do
      local DecomposeResourceInfo = LevelInfo[i].DecomposeGetResource
      for i, SingleResourceInfo in ipairs(DecomposeResourceInfo) do
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

return WBP_RGGemDecomposeWaveWindow
