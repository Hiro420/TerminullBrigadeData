local mainstoryline_tbmainstoryline = {
  [3] = {
    id = 3,
    nameLocMeta = NSLOCTEXT("mainstoryline_TBMainStoryLine", "name_3", "\228\184\138\231\186\191\231\172\172\228\184\128\231\137\136\228\184\187\231\186\191"),
    descLocMeta = NSLOCTEXT("mainstoryline_TBMainStoryLine", "desc_3", "\228\184\138\231\186\191\231\172\172\228\184\128\231\137\136\228\184\187\231\186\191"),
    icon = "",
    taskgrouplist = {3001, 3002},
    centralgroup = 3003
  },
  [2] = {
    id = 2,
    nameLocMeta = NSLOCTEXT("mainstoryline_TBMainStoryLine", "name_2", "2\229\145\168\229\185\180\229\186\134\228\184\187\231\186\191"),
    descLocMeta = NSLOCTEXT("mainstoryline_TBMainStoryLine", "desc_2", "2\229\145\168\229\185\180\229\186\134\228\184\187\231\186\191"),
    icon = "",
    taskgrouplist = {
      4001,
      4002,
      4003,
      3004
    },
    centralgroup = 4005
  },
  [1] = {
    id = 1,
    nameLocMeta = NSLOCTEXT("mainstoryline_TBMainStoryLine", "name_1", "LO\233\133\141\231\189\174\231\137\136\228\184\187\231\186\191"),
    descLocMeta = NSLOCTEXT("mainstoryline_TBMainStoryLine", "desc_1", "L0\230\181\139\232\175\149\231\137\136\228\184\187\231\186\191"),
    icon = "",
    taskgrouplist = {4001, 5001},
    centralgroup = 0
  }
}
local LinkTb = {
  name = "nameLocMeta",
  desc = "descLocMeta"
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
IteratorSetMetaTable(mainstoryline_tbmainstoryline, LuaTableMeta)
return mainstoryline_tbmainstoryline
