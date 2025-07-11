local hero_tbheroprofylvup = {
  [1] = {
    Level = 1,
    NameLocMeta = NSLOCTEXT("hero_TBHeroProfyLvUp", "Name_1", "\231\173\137\231\186\1671"),
    IconPath = "/iconf/xxx.icon",
    Exp = 100
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
IteratorSetMetaTable(hero_tbheroprofylvup, LuaTableMeta)
return hero_tbheroprofylvup
