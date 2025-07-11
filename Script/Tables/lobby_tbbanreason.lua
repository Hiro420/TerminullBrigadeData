local lobby_tbbanreason = {
  [1] = {
    ID = 1,
    AnnotationLocMeta = NSLOCTEXT("lobby_TBBanReason", "Annotation_1", "\229\143\145\229\184\131\232\191\157\232\167\132\228\191\161\230\129\175"),
    Tips = "\229\143\145\229\184\131\232\191\157\232\167\132\228\191\161\230\129\175"
  },
  [2] = {
    ID = 2,
    AnnotationLocMeta = NSLOCTEXT("lobby_TBBanReason", "Annotation_2", "\228\184\170\228\186\186\232\181\132\230\150\153\232\191\157\232\167\132"),
    Tips = "\228\184\170\228\186\186\232\181\132\230\150\153\232\191\157\232\167\132"
  },
  [3] = {
    ID = 3,
    AnnotationLocMeta = NSLOCTEXT("lobby_TBBanReason", "Annotation_3", "\230\129\182\230\132\143\230\184\184\230\136\143\232\161\140\228\184\186"),
    Tips = "\230\129\182\230\132\143\230\184\184\230\136\143\232\161\140\228\184\186"
  },
  [4] = {
    ID = 4,
    AnnotationLocMeta = NSLOCTEXT("lobby_TBBanReason", "Annotation_4", "\228\189\191\231\148\168\228\189\156\229\188\138\229\183\165\229\133\183"),
    Tips = "\228\189\191\231\148\168\228\189\156\229\188\138\229\183\165\229\133\183"
  },
  [5] = {
    ID = 5,
    AnnotationLocMeta = NSLOCTEXT("lobby_TBBanReason", "Annotation_5", "\230\129\182\230\132\143\230\184\184\230\136\143\232\161\140\228\184\186"),
    Tips = "\230\129\182\230\132\143\230\184\184\230\136\143\232\161\140\228\184\186"
  }
}
local LinkTb = {
  Annotation = "AnnotationLocMeta"
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
IteratorSetMetaTable(lobby_tbbanreason, LuaTableMeta)
return lobby_tbbanreason
