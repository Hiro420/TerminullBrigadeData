local mall_tbgachapond = {
  [1] = {
    ID = 1,
    NameLocMeta = NSLOCTEXT("mall_TBGachaPond", "Name_1", "\230\181\174\228\184\150\233\170\135\229\174\162"),
    Desc = "\229\189\177\229\136\131\228\188\160\229\174\182\229\174\157+\230\155\153\229\133\137\230\138\164\229\163\171",
    BgPath = "/Game/Rouge/UI/Atlas_DT/Activity/Gacha/Banner_Gacha/Frames/Img_CardPools_02.Img_CardPools_02",
    TagNameLocMeta = NSLOCTEXT("mall_TBGachaPond", "TagName_1", "\231\131\173\229\141\150"),
    TagBgPath = "",
    ActorPath = "/Game/Rouge/NPC/Lobby/DrawCardChest/Chest01.Chest01_C",
    ExpendResource = {
      {key = 210001, value = 1}
    },
    GoodsId = 60000,
    RandomGiftId = 400001,
    GachaRewardID = 1,
    DynamicSafeguradID = 7,
    SafeguardIDList = {
      {key = 1, value = 10},
      {key = 2, value = 20},
      {key = 3, value = 30},
      {key = 7, value = 40}
    },
    SeasonID = 0,
    Rare = 5,
    SystemMsgID = 4,
    StartTime = "2025-06-01 00:00:00",
    EndTime = "2025-09-30 00:00:00",
    CharacterList = {1010, 1040},
    CharacterTitle1LocMeta = NSLOCTEXT("mall_TBGachaPond", "CharacterTitle1_1", "\229\189\177\229\136\131"),
    CharacterName1LocMeta = NSLOCTEXT("mall_TBGachaPond", "CharacterName1_1", "\230\181\174\228\184\150\233\156\147\229\133\137\194\183\230\154\174\229\164\156\229\130\128\229\167\172"),
    CharacterTitle2LocMeta = NSLOCTEXT("mall_TBGachaPond", "CharacterTitle2_1", "\230\155\153\229\133\137"),
    CharacterName2LocMeta = NSLOCTEXT("mall_TBGachaPond", "CharacterName2_1", "\231\148\156\229\191\131\230\138\164\229\163\171")
  },
  [2] = {
    ID = 2,
    NameLocMeta = NSLOCTEXT("mall_TBGachaPond", "Name_2", "\230\181\174\228\184\150\231\187\152\229\141\183"),
    Desc = "\229\189\177\229\136\131\228\188\160\229\174\182\229\174\157+\230\160\188\231\189\151\232\142\137\228\186\154\229\133\148\229\133\148\232\173\166\229\174\152",
    BgPath = "/Game/Rouge/UI/Atlas_DT/Activity/Gacha/Banner_Gacha/Frames/Img_CardPools_01.Img_CardPools_01",
    TagNameLocMeta = NSLOCTEXT("mall_TBGachaPond", "TagName_2", "\231\131\173\229\141\150"),
    TagBgPath = "",
    ActorPath = "/Game/Rouge/NPC/Lobby/DrawCardChest/Chest01.Chest01_C",
    ExpendResource = {
      {key = 210001, value = 1}
    },
    GoodsId = 60000,
    RandomGiftId = 400005,
    GachaRewardID = 2,
    DynamicSafeguradID = 7,
    SafeguardIDList = {
      {key = 4, value = 10},
      {key = 5, value = 20},
      {key = 6, value = 30},
      {key = 7, value = 40}
    },
    SeasonID = 0,
    Rare = 5,
    SystemMsgID = 4,
    StartTime = "2025-06-01 00:00:00",
    EndTime = "2025-09-30 00:00:00",
    CharacterList = {1010, 1000},
    CharacterTitle1LocMeta = NSLOCTEXT("mall_TBGachaPond", "CharacterTitle1_2", "\229\189\177\229\136\131"),
    CharacterName1LocMeta = NSLOCTEXT("mall_TBGachaPond", "CharacterName1_2", "\230\181\174\228\184\150\233\156\147\229\133\137\194\183\230\154\174\229\164\156\229\130\128\229\167\172"),
    CharacterTitle2LocMeta = NSLOCTEXT("mall_TBGachaPond", "CharacterTitle2_2", "\230\160\188\231\189\151\232\142\137\228\186\154"),
    CharacterName2LocMeta = NSLOCTEXT("mall_TBGachaPond", "CharacterName2_2", "\229\133\148\229\133\148\232\173\166\229\174\152")
  }
}
local LinkTb = {
  Name = "NameLocMeta",
  TagName = "TagNameLocMeta",
  CharacterTitle1 = "CharacterTitle1LocMeta",
  CharacterName1 = "CharacterName1LocMeta",
  CharacterTitle2 = "CharacterTitle2LocMeta",
  CharacterName2 = "CharacterName2LocMeta"
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
IteratorSetMetaTable(mall_tbgachapond, LuaTableMeta)
return mall_tbgachapond
