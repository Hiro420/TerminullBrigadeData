local mall_tbshelfsecondtab = {
  [1] = {
    ID = 1,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_1", "\232\167\146\232\137\178\230\151\182\232\163\133"),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Bat_clothing_icon.Bat_clothing_icon",
    SystemID = -1,
    CoinList = {300005}
  },
  [2] = {
    ID = 2,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_2", "\230\173\166\229\153\168\229\164\150\232\167\130"),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Icon_Skin_01.Icon_Skin_01",
    SystemID = -1,
    CoinList = {300005}
  },
  [3] = {
    ID = 3,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_3", "\229\184\157\232\176\183\229\184\129\229\133\145\230\141\162"),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Icon_SilverStore.Icon_SilverStore",
    SystemID = -1,
    CoinList = {300005, 300001}
  },
  [4] = {
    ID = 4,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_4", "\228\191\174\230\173\163\232\161\140\229\138\168\229\133\145\230\141\162\194\183\229\136\157\231\186\167"),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Icon_ClimbStore_01.Icon_ClimbStore_01",
    SystemID = 7,
    CoinList = {300006}
  },
  [5] = {
    ID = 5,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_5", "\228\191\174\230\173\163\232\161\140\229\138\168\229\133\145\230\141\162\194\183\228\184\173\231\186\167"),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Icon_ClimbStore_02.Icon_ClimbStore_02",
    SystemID = 5,
    CoinList = {300006}
  },
  [6] = {
    ID = 6,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_6", "\228\191\174\230\173\163\232\161\140\229\138\168\229\133\145\230\141\162\194\183\233\171\152\231\186\167"),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Icon_ClimbStore_03.Icon_ClimbStore_03",
    SystemID = 6,
    CoinList = {300006}
  },
  [7] = {
    ID = 7,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_7", "\233\128\154\232\161\140\232\175\129\229\133\145\230\141\162"),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Icon_BPStore.Icon_BPStore",
    SystemID = 2,
    CoinList = {300007}
  },
  [8] = {
    ID = 8,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_8", "\229\184\184\233\169\187\229\149\134\229\159\142"),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Icon_ResidentStore.Icon_ResidentStore",
    SystemID = -1,
    CoinList = {300005, 300001}
  },
  [9] = {
    ID = 9,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_9", "\230\149\176\230\141\174\229\174\157\229\186\147\229\133\145\230\141\162 "),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Icon_RaffleStore.Icon_RaffleStore",
    SystemID = -1,
    CoinList = {99035}
  },
  [10] = {
    ID = 10,
    NameLocMeta = NSLOCTEXT("mall_TBShelfSecondTab", "Name_10", "\230\168\161\231\187\132\229\133\145\230\141\162"),
    Icon = "/Game/Rouge/UI/Atlas/IconSkinView/Frames/Icon_PuzzleStore.Icon_PuzzleStore",
    SystemID = -1,
    CoinList = {
      99012,
      99013,
      99014
    }
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
IteratorSetMetaTable(mall_tbshelfsecondtab, LuaTableMeta)
return mall_tbshelfsecondtab
