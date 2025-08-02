local lobby_tbbattleserverlist = {
  europe = {
    region = "europe",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_europe", "\230\172\167\230\156\141"),
    address = "battle-15001-eu.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  jp = {
    region = "jp",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_jp", "\228\186\154\230\156\141"),
    address = "battle-15001-jp.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  sa = {
    region = "sa",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_sa", "\229\141\151\231\190\142\230\156\141"),
    address = "battle-15001-sa.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  sea = {
    region = "sea",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_sea", "\228\184\156\229\141\151\228\186\154\230\156\141"),
    address = "battle-15001-sg.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  sv = {
    region = "sv",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_sv", "\229\140\151\231\190\142\230\156\141\239\188\136\232\165\191\233\131\168\239\188\137"),
    address = "battle-15001-sv.playprojectr.com",
    port = 50001,
    serverlist = {"15001"}
  },
  va = {
    region = "va",
    costTypeLocMeta = NSLOCTEXT("lobby_TBBattleServerList", "costType_va", "\229\140\151\231\190\142\230\156\141\239\188\136\228\184\156\233\131\168\239\188\137"),
    address = "battle-15001-ue.playprojectr.com",
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
