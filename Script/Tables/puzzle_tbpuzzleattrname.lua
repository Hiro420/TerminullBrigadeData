local puzzle_tbpuzzleattrname = {
  ["11_18"] = {
    AttrCombination = "11_18",
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleAttrName", "Name_11_18", "[\231\169\185\233\148\139]"),
    DevelopDesc = "\231\148\159\229\145\189+\229\159\186\231\161\128\230\148\187\229\135\187"
  },
  ["12_19"] = {
    AttrCombination = "12_19",
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleAttrName", "Name_12_19", "[\233\148\139\229\141\171]"),
    DevelopDesc = "\230\138\164\231\155\190+\231\137\169\231\144\134\230\148\187\229\135\187"
  },
  ["11_20"] = {
    AttrCombination = "11_20",
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleAttrName", "Name_11_20", "[\232\163\130\229\143\152]"),
    DevelopDesc = "\231\148\159\229\145\189+\230\138\128\232\131\189\230\148\187\229\135\187"
  },
  ["12_18"] = {
    AttrCombination = "12_18",
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleAttrName", "Name_12_18", "[\230\152\159\229\158\146]"),
    DevelopDesc = "\230\138\164\231\155\190+\229\159\186\231\161\128\230\148\187\229\135\187"
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
IteratorSetMetaTable(puzzle_tbpuzzleattrname, LuaTableMeta)
return puzzle_tbpuzzleattrname
