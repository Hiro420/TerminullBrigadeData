local hero_tbfamilytreasureupgrade = {
  {
    ID = 101,
    Level = 2,
    IconPath = "/Game/Rouge/UI/Atlas_DT/FamilyHeirloom/Frames/Icon_FamilyHeirloom_Lv2.Icon_FamilyHeirloom_Lv2",
    GiftID = 6201012,
    CostResources = {
      {key = 6201015, value = 1}
    },
    LinkId = "1012",
    LinkDescLocMeta = NSLOCTEXT("hero_TBFamilyTreasureUpgrade", "LinkDesc_101_2", "\229\149\134\229\159\142\230\141\134\231\187\145\229\140\133\232\142\183\229\143\150"),
    ParamList = {}
  },
  {
    ID = 101,
    Level = 3,
    IconPath = "/Game/Rouge/UI/Atlas_DT/FamilyHeirloom/Frames/Icon_FamilyHeirloom_Lv3.Icon_FamilyHeirloom_Lv3",
    GiftID = 6201013,
    CostResources = {
      {key = 6201015, value = 1}
    },
    LinkId = "1012",
    LinkDescLocMeta = NSLOCTEXT("hero_TBFamilyTreasureUpgrade", "LinkDesc_101_3", "\229\149\134\229\159\142\230\141\134\231\187\145\229\140\133\232\142\183\229\143\150"),
    ParamList = {}
  },
  {
    ID = 101,
    Level = 4,
    IconPath = "/Game/Rouge/UI/Atlas_DT/FamilyHeirloom/Frames/Icon_FamilyHeirloom_Lv4.Icon_FamilyHeirloom_Lv4",
    GiftID = 6201014,
    CostResources = {
      {key = 6201015, value = 1}
    },
    LinkId = "1012",
    LinkDescLocMeta = NSLOCTEXT("hero_TBFamilyTreasureUpgrade", "LinkDesc_101_4", "\229\149\134\229\159\142\230\141\134\231\187\145\229\140\133\232\142\183\229\143\150"),
    ParamList = {}
  },
  {
    ID = 1031,
    Level = 2,
    IconPath = "/Game/Rouge/UI/Atlas_DT/FamilyHeirloom/Frames/Icon_FamilyHeirloom_Lv2.Icon_FamilyHeirloom_Lv2",
    GiftID = 6203012,
    CostResources = {
      {key = 6203015, value = 1}
    },
    LinkId = "1005",
    LinkDescLocMeta = NSLOCTEXT("hero_TBFamilyTreasureUpgrade", "LinkDesc_1031_2", "\230\138\189\229\141\161\231\179\187\231\187\159\232\142\183\229\143\150"),
    ParamList = {}
  },
  {
    ID = 1031,
    Level = 3,
    IconPath = "/Game/Rouge/UI/Atlas_DT/FamilyHeirloom/Frames/Icon_FamilyHeirloom_Lv3.Icon_FamilyHeirloom_Lv3",
    GiftID = 6203013,
    CostResources = {
      {key = 6203015, value = 1}
    },
    LinkId = "1005",
    LinkDescLocMeta = NSLOCTEXT("hero_TBFamilyTreasureUpgrade", "LinkDesc_1031_3", "\230\138\189\229\141\161\231\179\187\231\187\159\232\142\183\229\143\150"),
    ParamList = {}
  },
  {
    ID = 1031,
    Level = 4,
    IconPath = "/Game/Rouge/UI/Atlas_DT/FamilyHeirloom/Frames/Icon_FamilyHeirloom_Lv4.Icon_FamilyHeirloom_Lv4",
    GiftID = 6203014,
    CostResources = {
      {key = 6203015, value = 1}
    },
    LinkId = "1005",
    LinkDescLocMeta = NSLOCTEXT("hero_TBFamilyTreasureUpgrade", "LinkDesc_1031_4", "\230\138\189\229\141\161\231\179\187\231\187\159\232\142\183\229\143\150"),
    ParamList = {}
  }
}
local LinkTb = {
  LinkDesc = "LinkDescLocMeta"
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
IteratorSetMetaTable(hero_tbfamilytreasureupgrade, LuaTableMeta)
return hero_tbfamilytreasureupgrade
