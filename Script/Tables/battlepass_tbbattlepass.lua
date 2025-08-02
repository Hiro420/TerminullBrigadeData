local battlepass_tbbattlepass = {
  [1] = {
    BattlePassID = 1,
    NameLocMeta = NSLOCTEXT("battlepass_TBBattlePass", "Name_1", "\229\142\159\231\136\134\231\130\185"),
    PremiumUnlockResourceID = 300304,
    UltraUnlockResourceID = 300305,
    PremiumToUltraResourceID = 300306,
    BattlePassExpID = 99008,
    BattlePassGoodsID = 990080,
    StartTime = "2025-06-02 00:00:00",
    EndTime = "2025-09-24 05:00:00",
    IconPath = "",
    NormalDescLocMeta = NSLOCTEXT("battlepass_TBBattlePass", "NormalDesc_1", "\233\171\152\231\186\167\231\137\136\233\128\154\232\161\140\232\175\129\229\165\150\229\138\177"),
    UltraDescLocMeta = NSLOCTEXT("battlepass_TBBattlePass", "UltraDesc_1", "\229\133\184\232\151\143\231\137\136\233\128\154\232\161\140\232\175\129\229\165\150\229\138\177"),
    UltraReward = {
      {key = 600002, value = 1},
      {key = 600001, value = 1},
      {key = 81449, value = 1},
      {key = 82451, value = 1},
      {key = 20703051, value = 1}
    }
  },
  [2] = {
    BattlePassID = 2,
    NameLocMeta = NSLOCTEXT("battlepass_TBBattlePass", "Name_2", "\232\182\133\232\189\189\233\128\154\232\161\140\232\175\129"),
    PremiumUnlockResourceID = 300301,
    UltraUnlockResourceID = 300302,
    PremiumToUltraResourceID = 300303,
    BattlePassExpID = 99009,
    BattlePassGoodsID = 990090,
    StartTime = "2023-03-01 00:00:00",
    EndTime = "2025-06-01 00:00:00",
    IconPath = "",
    NormalDescLocMeta = NSLOCTEXT("battlepass_TBBattlePass", "NormalDesc_2", "\233\171\152\231\186\167\231\137\136\233\128\154\232\161\140\232\175\129\229\165\150\229\138\177"),
    UltraDescLocMeta = NSLOCTEXT("battlepass_TBBattlePass", "UltraDesc_2", "\229\133\184\232\151\143\231\137\136\233\128\154\232\161\140\232\175\129\229\165\150\229\138\177"),
    UltraReward = {
      {key = 99008, value = 10000},
      {key = 300001, value = 100},
      {key = 36143, value = 5}
    }
  }
}
local LinkTb = {
  Name = "NameLocMeta",
  NormalDesc = "NormalDescLocMeta",
  UltraDesc = "UltraDescLocMeta"
}
local LuaTableMeta = {
  __index = function(table, key)
    local keyIdx = LinkTb[key]
    if keyIdx then
      return table[keyIdx]()
    elseif rawget(table, key) then
      return rawget(table, key)
    end
  end
}
IteratorSetMetaTable(battlepass_tbbattlepass, LuaTableMeta)
return battlepass_tbbattlepass
