local battlepass_tbbattlepasstask = {
  [1] = {
    ID = 1,
    NameLocMeta = NSLOCTEXT("battlepass_TBBattlePassTask", "Name_1", "\232\182\133\232\189\189\230\181\139\232\175\149\229\145\168\229\184\184\228\187\187\229\138\161"),
    BattlePassID = 2,
    TaskType = 0,
    TaskGroupID = 10001
  },
  [2] = {
    ID = 2,
    NameLocMeta = NSLOCTEXT("battlepass_TBBattlePassTask", "Name_2", "\232\182\133\232\189\189\230\181\139\232\175\149\230\180\187\229\138\168\228\187\187\229\138\161"),
    BattlePassID = 2,
    TaskType = 1,
    TaskGroupID = 10002
  },
  [3] = {
    ID = 3,
    NameLocMeta = NSLOCTEXT("battlepass_TBBattlePassTask", "Name_3", "\229\145\168\229\184\184\228\187\187\229\138\161"),
    BattlePassID = 1,
    TaskType = 0,
    TaskGroupID = 10003
  },
  [4] = {
    ID = 4,
    NameLocMeta = NSLOCTEXT("battlepass_TBBattlePassTask", "Name_4", "\230\180\187\229\138\168\228\187\187\229\138\161"),
    BattlePassID = 1,
    TaskType = 1,
    TaskGroupID = 10004
  }
}
local LinkTb = {
  Name = "NameLocMeta"
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
IteratorSetMetaTable(battlepass_tbbattlepasstask, LuaTableMeta)
return battlepass_tbbattlepasstask
