local hero_tbprofylevel = {
  [1] = {
    Level = 1,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_1", "\229\136\157\229\133\165\231\159\169\233\152\181"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_1", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 0
  },
  [2] = {
    Level = 2,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_2", "\229\176\143\232\175\149\232\186\171\230\137\139"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_2", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 700
  },
  [3] = {
    Level = 3,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_3", "\230\184\144\229\133\165\228\189\179\229\162\131"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_3", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 2100
  },
  [4] = {
    Level = 4,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_4", "\231\134\159\231\187\131\233\171\152\231\142\169"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_4", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 3900
  },
  [5] = {
    Level = 5,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_5", "\229\176\143\230\156\137\230\136\144\229\176\177"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_5", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 6200
  },
  [6] = {
    Level = 6,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_6", "\231\178\190\230\185\155\228\184\147\229\174\182"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_6", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 8400
  },
  [7] = {
    Level = 7,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_7", "\231\159\169\233\152\181\230\188\171\229\174\162"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_7", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 11200
  },
  [8] = {
    Level = 8,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_8", "\231\159\169\233\152\181\232\190\190\228\186\186"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_8", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 14700
  },
  [9] = {
    Level = 9,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_9", "\229\165\135\232\191\185\233\170\135\229\174\162"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_9", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 18200
  },
  [10] = {
    Level = 10,
    NameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "Name_10", "\228\188\160\229\165\135\231\142\169\229\174\182"),
    IconPath = "",
    HeadFrameID = 0,
    HeadFrameNameLocMeta = NSLOCTEXT("hero_TBProfyLevel", "HeadFrameName_10", ""),
    HeadFrameIconPath = "/Game/Rouge/UI/Atlas/Proficiency/Frames/Icon_Proficiency01_01.Icon_Proficiency01_01",
    Exp = 21700
  }
}
local LinkTb = {
  Name = "NameLocMeta",
  HeadFrameName = "HeadFrameNameLocMeta"
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
IteratorSetMetaTable(hero_tbprofylevel, LuaTableMeta)
return hero_tbprofylevel
