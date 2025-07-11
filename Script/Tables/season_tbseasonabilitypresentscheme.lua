local season_tbseasonabilitypresentscheme = {
  {
    PresentSchemeID = 1,
    SeasonIDX = 1,
    UnlockConsumerResource = {
      {key = 300001, value = 10}
    },
    Remark = "",
    NameLocMeta = NSLOCTEXT("season_TBSeasonAbilityPresentScheme", "Name_1_1", "\233\162\132\232\174\190\230\150\185\230\161\136\228\184\128")
  },
  {
    PresentSchemeID = 2,
    SeasonIDX = 1,
    UnlockConsumerResource = {
      {key = 300001, value = 10}
    },
    Remark = "",
    NameLocMeta = NSLOCTEXT("season_TBSeasonAbilityPresentScheme", "Name_2_1", "\233\162\132\232\174\190\230\150\185\230\161\136\228\186\140")
  },
  {
    PresentSchemeID = 3,
    SeasonIDX = 1,
    UnlockConsumerResource = {
      {key = 300001, value = 10}
    },
    Remark = "",
    NameLocMeta = NSLOCTEXT("season_TBSeasonAbilityPresentScheme", "Name_3_1", "\233\162\132\232\174\190\230\150\185\230\161\136\228\184\137")
  },
  {
    PresentSchemeID = 4,
    SeasonIDX = 1,
    UnlockConsumerResource = {
      {key = 300001, value = 10}
    },
    Remark = "",
    NameLocMeta = NSLOCTEXT("season_TBSeasonAbilityPresentScheme", "Name_4_1", "\233\162\132\232\174\190\230\150\185\230\161\136\229\155\155")
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
IteratorSetMetaTable(season_tbseasonabilitypresentscheme, LuaTableMeta)
return season_tbseasonabilitypresentscheme
