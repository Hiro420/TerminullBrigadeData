local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local ClimbTowerAward = UnLua.Class()
function ClimbTowerAward:InitClimbTowerAward(Floor)
  local PassFloor = 0
  if ClimbTowerData.PassData and ClimbTowerData.PassData[tostring(ClimbTowerData.WorldId)] then
    PassFloor = ClimbTowerData.PassData[tostring(ClimbTowerData.WorldId)]
  end
  local AwardTable = {}
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  if not ClimbTowerTable[Floor] then
    return
  end
  for key, value in pairs(ClimbTowerTable[Floor].FirstWinRewards) do
    local AwardItem = {
      Id = 0,
      Num = 0,
      MarkStr = "\233\166\150\233\128\154"
    }
    AwardItem.Id = value.key
    AwardItem.Num = value.value
    AwardItem.bFirstWinReward = true
    AwardItem.bReceive = Floor <= PassFloor
    table.insert(AwardTable, 1, AwardItem)
  end
  for i, v in ipairs(ClimbTowerTable[Floor].DropResources) do
    local AwardItem = {
      Id = 0,
      Num = -1,
      MarkStr = "",
      bFirstWinReward = false,
      bReceive = false
    }
    AwardItem.Id = v
    for index, value in ipairs(ClimbTowerTable[Floor].DropResourcesRatioKey) do
      if value == tostring(v) and ClimbTowerTable[Floor].DropResourcesRatioValue[index] then
        AwardItem.MarkStr = ClimbTowerTable[Floor].DropResourcesRatioValue[index]
      end
    end
    table.insert(AwardTable, AwardItem)
  end
  table.sort(AwardTable, function(a, b)
    local TBGeneralTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    if a.bReceive ~= b.bReceive then
      return not a.bReceive
    end
    if a.bFirstWinReward and b.bFirstWinReward then
      return TBGeneralTable[a.Id].Rare > TBGeneralTable[b.Id].Rare
    elseif a.bFirstWinReward ~= b.bFirstWinReward then
      return a.bFirstWinReward
    end
    return TBGeneralTable[a.Id].Rare > TBGeneralTable[b.Id].Rare
  end)
  local Index = 1
  for key, value in pairs(AwardTable) do
    local Item = GetOrCreateItem(self.AwardList, Index, self.WBP_ClimbTower_AwardItem:GetClass())
    if Item then
      Item:InitAwardItem(value)
      UpdateVisibility(Item, true)
    end
    Index = Index + 1
  end
  HideOtherItem(self.AwardList, Index, true)
end
function ClimbTowerAward:RefreshFloorDropPanel(Floor)
end
return ClimbTowerAward
