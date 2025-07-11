local BattleHistoryData = {
  BattleHistory = {},
  AllHeroSelectId = -1,
  CurSelectBattleHistoryHeroId = -1
}
function BattleHistoryData:DealWithTable()
end
function BattleHistoryData:ResetWhenLogin()
  self.BattleHistory = {}
  self.CurSelectBattleHistoryHeroId = -1
end
return BattleHistoryData
