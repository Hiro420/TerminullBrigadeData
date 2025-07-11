local story_tbworldintelligence = {
  [1] = {
    id = 1,
    nameLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "name_1", ""),
    image = "/Game/Rouge/UI/Sprite/IconCharacterbust/Frames/Bat_djsboss_icon.Bat_djsboss_icon",
    storyLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "story_1", "")
  },
  [2] = {
    id = 2,
    nameLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "name_2", ""),
    image = "/Game/Rouge/UI/Sprite/IconCharacterbust/Frames/Bat_DJQR_icon.Bat_DJQR_icon",
    storyLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "story_2", "")
  },
  [3] = {
    id = 3,
    nameLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "name_3", ""),
    image = "/Game/Rouge/UI/Sprite/IconCharacterbust/Frames/Bat_FXB_icon.Bat_FXB_icon",
    storyLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "story_3", "")
  },
  [11] = {
    id = 11,
    nameLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "name_11", ""),
    image = "/Game/Rouge/UI/Sprite/IconCharacterbust/Frames/Bat_djsboss_icon.Bat_djsboss_icon",
    storyLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "story_11", "")
  },
  [12] = {
    id = 12,
    nameLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "name_12", ""),
    image = "/Game/Rouge/UI/Sprite/IconCharacterbust/Frames/Bat_DJQR_icon.Bat_DJQR_icon",
    storyLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "story_12", "")
  },
  [13] = {
    id = 13,
    nameLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "name_13", ""),
    image = "/Game/Rouge/UI/Sprite/IconCharacterbust/Frames/Bat_FXB_icon.Bat_FXB_icon",
    storyLocMeta = NSLOCTEXT("story_TBWorldIntelligence", "story_13", "")
  }
}
local LinkTb = {
  name = "nameLocMeta",
  story = "storyLocMeta"
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
IteratorSetMetaTable(story_tbworldintelligence, LuaTableMeta)
return story_tbworldintelligence
