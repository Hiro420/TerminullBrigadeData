local chat_tbchat = {
  [0] = {
    Channel = 0,
    ChannelNameLocMeta = NSLOCTEXT("chat_TBChat", "ChannelName_0", "\229\164\167\229\142\133"),
    IconPath = "",
    OpenLevel = 8,
    TextLimit = 100,
    Period = 10
  },
  [1] = {
    Channel = 1,
    ChannelNameLocMeta = NSLOCTEXT("chat_TBChat", "ChannelName_1", "\233\152\159\228\188\141"),
    IconPath = "",
    OpenLevel = 1,
    TextLimit = 100,
    Period = 5
  },
  [2] = {
    Channel = 2,
    ChannelNameLocMeta = NSLOCTEXT("chat_TBChat", "ChannelName_2", "\229\165\189\229\143\139"),
    IconPath = "",
    OpenLevel = 1,
    TextLimit = 100,
    Period = 1
  },
  [3] = {
    Channel = 3,
    ChannelNameLocMeta = NSLOCTEXT("chat_TBChat", "ChannelName_3", "\230\139\155\229\139\159"),
    IconPath = "",
    OpenLevel = 0,
    TextLimit = 0,
    Period = 0
  },
  [4] = {
    Channel = 4,
    ChannelNameLocMeta = NSLOCTEXT("chat_TBChat", "ChannelName_4", "\231\179\187\231\187\159"),
    IconPath = "",
    OpenLevel = 0,
    TextLimit = 0,
    Period = 0
  }
}
local LinkTb = {
  ChannelName = "ChannelNameLocMeta"
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
IteratorSetMetaTable(chat_tbchat, LuaTableMeta)
return chat_tbchat
