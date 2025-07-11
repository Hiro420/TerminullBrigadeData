local chat_tbchatcontent = {
  [1] = {
    ID = 1,
    ContentLocMeta = NSLOCTEXT("chat_TBChatContent", "Content_1", "\229\134\133\230\156\137\230\149\143\230\132\159\232\175\141\239\188\140\229\143\145\233\128\129\229\164\177\232\180\165")
  },
  [2] = {
    ID = 2,
    ContentLocMeta = NSLOCTEXT("chat_TBChatContent", "Content_2", "\232\129\138\229\164\169\230\182\136\230\129\175\229\143\145\233\128\129\232\191\135\233\149\191")
  },
  [3] = {
    ID = 3,
    ContentLocMeta = NSLOCTEXT("chat_TBChatContent", "Content_3", "\229\143\145\232\168\128\233\162\145\231\142\135\229\164\170\233\171\152\239\188\140\232\175\183X\231\167\146\229\144\142\229\134\141\232\175\149")
  },
  [4] = {
    ID = 4,
    ContentLocMeta = NSLOCTEXT("chat_TBChatContent", "Content_4", "\230\130\168\231\154\132\229\143\145\232\168\128\233\162\145\231\142\135\229\164\170\229\191\171\239\188\140\232\175\183\231\168\141\229\144\142\229\134\141\232\175\149")
  },
  [5] = {
    ID = 5,
    ContentLocMeta = NSLOCTEXT("chat_TBChatContent", "Content_5", "\229\175\185\230\150\185\229\183\178\231\187\143\231\166\187\231\186\191\239\188\140\229\173\152\229\133\165\231\149\153\232\168\128\231\174\177")
  },
  [6] = {
    ID = 6,
    ContentLocMeta = NSLOCTEXT("chat_TBChatContent", "Content_6", "\233\157\153\233\187\152")
  }
}
local LinkTb = {
  Content = "ContentLocMeta"
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
IteratorSetMetaTable(chat_tbchatcontent, LuaTableMeta)
return chat_tbchatcontent
