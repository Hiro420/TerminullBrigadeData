local hero_tbprofy = {
  [1] = {
    Level = 1,
    NameLocMeta = NSLOCTEXT("hero_TBProfy", "Name_1", "\229\136\157\229\133\165\231\159\169\233\152\181"),
    IconPath = ""
  },
  [2] = {
    Level = 2,
    NameLocMeta = NSLOCTEXT("hero_TBProfy", "Name_2", "\229\176\143\232\175\149\232\186\171\230\137\139"),
    IconPath = ""
  },
  [3] = {
    Level = 3,
    NameLocMeta = NSLOCTEXT("hero_TBProfy", "Name_3", "\230\184\144\229\133\165\228\189\179\229\162\131"),
    IconPath = ""
  },
  [4] = {
    Level = 4,
    NameLocMeta = NSLOCTEXT("hero_TBProfy", "Name_4", "\231\134\159\231\187\131\233\171\152\231\142\169"),
    IconPath = ""
  },
  [5] = {
    Level = 5,
    NameLocMeta = NSLOCTEXT("hero_TBProfy", "Name_5", "\231\178\190\230\185\155\228\184\147\229\174\182"),
    IconPath = ""
  },
  [6] = {
    Level = 6,
    NameLocMeta = NSLOCTEXT("hero_TBProfy", "Name_6", "\231\159\169\233\152\181\230\188\171\229\174\162"),
    IconPath = ""
  },
  [7] = {
    Level = 7,
    NameLocMeta = NSLOCTEXT("hero_TBProfy", "Name_7", "\229\165\135\232\191\185\233\170\135\229\174\162"),
    IconPath = ""
  },
  [8] = {
    Level = 8,
    NameLocMeta = NSLOCTEXT("hero_TBProfy", "Name_8", "\228\188\160\229\165\135\231\142\169\229\174\182"),
    IconPath = ""
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
IteratorSetMetaTable(hero_tbprofy, LuaTableMeta)
return hero_tbprofy
