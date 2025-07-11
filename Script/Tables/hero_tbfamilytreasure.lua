local hero_tbfamilytreasure = {
  [101] = {
    ID = 101,
    HeroID = 1010,
    GiftID = 6201011,
    IconPath = "/Game/Rouge/UI/Atlas_DT/FamilyHeirloom/Frames/Icon_FamilyHeirloom_Lv1.Icon_FamilyHeirloom_Lv1",
    LinkId = "1012",
    LinkDescLocMeta = NSLOCTEXT("hero_TBFamilyTreasure", "LinkDesc_101", "\229\149\134\229\159\142\230\141\134\231\187\145\229\140\133\232\142\183\229\143\150"),
    ParamList = {}
  },
  [1031] = {
    ID = 1031,
    HeroID = 1030,
    GiftID = 6203011,
    IconPath = "/Game/Rouge/UI/Atlas_DT/FamilyHeirloom/Frames/Icon_FamilyHeirloom_Lv1.Icon_FamilyHeirloom_Lv1",
    LinkId = "1005",
    LinkDescLocMeta = NSLOCTEXT("hero_TBFamilyTreasure", "LinkDesc_1031", "\230\138\189\229\141\161\231\179\187\231\187\159\232\142\183\229\143\150"),
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
IteratorSetMetaTable(hero_tbfamilytreasure, LuaTableMeta)
return hero_tbfamilytreasure
