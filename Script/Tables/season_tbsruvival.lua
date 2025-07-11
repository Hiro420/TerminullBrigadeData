local season_tbsruvival = {
  [1] = {
    Id = 1,
    LevelId = 1,
    DifficultyNameLocMeta = NSLOCTEXT("season_TBSruvival", "DifficultyName_1", "\230\153\174\233\128\154"),
    FloorDescription = {
      NSLOCTEXT("season_TBSruvival", "OBJSruvival_FloorDescription_1_1", "<img id=\"ModeDown\"/>\194\160 \230\149\140\228\186\186\232\175\141\230\157\161\231\173\137\231\186\167\239\188\154<CZ_HighLight>\230\140\145\230\136\152</>"),
      NSLOCTEXT("season_TBSruvival", "OBJSruvival_FloorDescription_1_2", "<img id=\"ModeDown\"/>\194\160 \231\178\190\232\139\177\230\149\140\228\186\186\231\173\137\231\186\167\239\188\154<CZ_HighLight>\228\189\142</>"),
      NSLOCTEXT("season_TBSruvival", "OBJSruvival_FloorDescription_1_3", "<img id=\"ModeDown\"/>\194\160 \230\156\137\229\135\160\231\142\135\233\129\173\233\129\135\231\137\185\230\174\138\228\186\139\228\187\182\239\188\154<CZ_HighLight>\232\144\189\233\155\183</>")
    },
    DropResources = {
      99994,
      240036,
      240023,
      240024
    },
    DropResourcesRatioKey = {"99994", "240021"},
    DropResourcesRatioValue = {
      NSLOCTEXT("season_TBSruvival", "OBJSruvival_DropResourcesRatioValue_1_1", "+40%"),
      NSLOCTEXT("season_TBSruvival", "OBJSruvival_DropResourcesRatioValue_1_2", "\230\150\176")
    },
    SmallIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/BossRush/Img_BossRush01_01.Img_BossRush01_01",
    BigIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/BossSilhouette/Img_Blade_BossSilhouette.Img_Blade_BossSilhouette"
  }
}
local LinkTb = {
  DifficultyName = "DifficultyNameLocMeta"
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
IteratorSetMetaTable(season_tbsruvival, LuaTableMeta)
return season_tbsruvival
