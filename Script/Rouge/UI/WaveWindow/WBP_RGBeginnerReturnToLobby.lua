local WBP_RGBeginnerReturnToLobby = UnLua.Class()
function WBP_RGBeginnerReturnToLobby:Construct()
  self:Show()
end
function WBP_RGBeginnerReturnToLobby:Show()
  local WorldId = LogicTeam.GetWorldId()
  local AllLevels = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  local RowInfo
  for LevelID, LevelFloorInfo in pairs(AllLevels) do
    if LevelFloorInfo.gameWorldID == WorldId then
      RowInfo = LevelFloorInfo
      break
    end
  end
  local Index = 1
  if RowInfo then
    for i, RewardInfo in ipairs(RowInfo.FirstPassReward) do
      local Item = GetOrCreateItem(self.BeginnerClearRewardList, Index, self.BeginnerItemTemplate:StaticClass())
      Item:InitByItemId(RewardInfo.value, RewardInfo.key)
      Item:ShowBeginnerClearFlag()
      UpdateVisibility(Item, true)
      Index = Index + 1
    end
  end
  HideOtherItem(self.BeginnerClearRewardList, Index, true)
end
return WBP_RGBeginnerReturnToLobby
