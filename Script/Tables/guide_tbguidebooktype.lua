local guide_tbguidebooktype = {
  [2] = {
    id = 2,
    nameLocMeta = NSLOCTEXT("guide_TBGuidebooktype", "name_2", "\231\142\169\230\179\149"),
    icon = ""
  }
}
local LinkTb = {
  name = "nameLocMeta"
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
IteratorSetMetaTable(guide_tbguidebooktype, LuaTableMeta)
return guide_tbguidebooktype
