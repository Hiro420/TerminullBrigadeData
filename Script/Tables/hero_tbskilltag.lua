local hero_tbskilltag = {
  [1] = {
    ID = 1,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_1", "\233\152\178\229\190\161"),
    IconPath = ""
  },
  [2] = {
    ID = 2,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_2", "\229\133\141\230\173\187"),
    IconPath = ""
  },
  [3] = {
    ID = 3,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_3", "\229\188\177\231\130\185"),
    IconPath = ""
  },
  [4] = {
    ID = 4,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_4", "\232\191\189\232\184\170"),
    IconPath = ""
  },
  [5] = {
    ID = 5,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_5", "\229\141\149\228\189\147"),
    IconPath = ""
  },
  [6] = {
    ID = 6,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_6", "\231\136\134\229\143\145"),
    IconPath = ""
  },
  [7] = {
    ID = 7,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_7", "\228\189\141\231\167\187"),
    IconPath = ""
  },
  [8] = {
    ID = 8,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_8", "\232\140\131\229\155\180"),
    IconPath = ""
  },
  [9] = {
    ID = 9,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_9", "\229\155\158\229\164\141"),
    IconPath = ""
  },
  [10] = {
    ID = 10,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_10", "\228\188\164\229\174\179"),
    IconPath = ""
  },
  [11] = {
    ID = 11,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_11", "\229\177\158\230\128\167"),
    IconPath = ""
  },
  [12] = {
    ID = 12,
    NameLocMeta = NSLOCTEXT("hero_TBSkillTag", "Name_12", "\229\143\172\229\148\164"),
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
IteratorSetMetaTable(hero_tbskilltag, LuaTableMeta)
return hero_tbskilltag
