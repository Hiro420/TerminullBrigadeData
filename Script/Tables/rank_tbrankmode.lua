local rank_tbrankmode = {
  [1] = {
    RowName = 1,
    Desc = "",
    SeasonId = 1,
    SeasonNameLocMeta = NSLOCTEXT("rank_TBRankMode", "SeasonName_1", "S0\232\181\155\229\173\163"),
    bEnable = true,
    ModeId = 1001,
    ModeNameLocMeta = NSLOCTEXT("rank_TBRankMode", "ModeName_1", "\229\184\184\232\167\132\230\168\161\229\188\143"),
    WorldIds = {23, 24},
    SoloBoardType = 2,
    TeamBoardType = 1
  },
  [2] = {
    RowName = 2,
    Desc = "",
    SeasonId = 1,
    SeasonNameLocMeta = NSLOCTEXT("rank_TBRankMode", "SeasonName_2", "S0\232\181\155\229\173\163"),
    bEnable = true,
    ModeId = 1003,
    ModeNameLocMeta = NSLOCTEXT("rank_TBRankMode", "ModeName_2", "\228\191\174\230\173\163\232\161\140\229\138\168"),
    WorldIds = {38},
    SoloBoardType = 3,
    TeamBoardType = 4
  },
  [3] = {
    RowName = 3,
    Desc = "",
    SeasonId = 1,
    SeasonNameLocMeta = NSLOCTEXT("rank_TBRankMode", "SeasonName_3", "S0\232\181\155\229\173\163"),
    bEnable = true,
    ModeId = 3002,
    ModeNameLocMeta = NSLOCTEXT("rank_TBRankMode", "ModeName_3", "\231\151\133\230\175\146\231\139\130\230\189\174"),
    WorldIds = {
      33,
      34,
      35,
      36,
      37
    },
    SoloBoardType = 0,
    TeamBoardType = 6
  },
  [4] = {
    RowName = 4,
    Desc = "",
    SeasonId = 1,
    SeasonNameLocMeta = NSLOCTEXT("rank_TBRankMode", "SeasonName_4", "S0\232\181\155\229\173\163"),
    bEnable = true,
    ModeId = 3001,
    ModeNameLocMeta = NSLOCTEXT("rank_TBRankMode", "ModeName_4", "\229\164\177\229\186\143\233\147\190\229\140\186"),
    WorldIds = {
      100,
      101,
      102,
      103,
      104,
      105
    },
    SoloBoardType = 0,
    TeamBoardType = 5
  }
}
local LinkTb = {
  SeasonName = "SeasonNameLocMeta",
  ModeName = "ModeNameLocMeta"
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
IteratorSetMetaTable(rank_tbrankmode, LuaTableMeta)
return rank_tbrankmode
