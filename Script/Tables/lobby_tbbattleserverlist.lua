local lobby_tbbattleserverlist = {
  europe = {
    region = "europe",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_europe", "\230\172\167\230\180\178"),
    address = "battle-15001-eu.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  jp = {
    region = "jp",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_jp", "\230\151\165\230\156\172"),
    address = "battle-15001-jp.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  sa = {
    region = "sa",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_sa", "\229\141\151\231\190\142"),
    address = "battle-15001-sa.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  sea = {
    region = "sea",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_sea", "\230\150\176\229\138\160\229\157\161"),
    address = "battle-15001-sg.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  sv = {
    region = "sv",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_sv", "\231\161\133\232\176\183"),
    address = "battle-15001-sv.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  va = {
    region = "va",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_va", "\229\188\151\229\144\137\229\176\188\228\186\158"),
    address = "battle-15001-va.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  }
}
local LinkTb = {
  costType = "costTypeLocMeta"
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
IteratorSetMetaTable(lobby_tbbattleserverlist, LuaTableMeta)
return lobby_tbbattleserverlist
