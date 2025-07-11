local story_tbworld = {
  [1] = {
    id = 1,
    worldID = 23,
    nameLocMeta = NSLOCTEXT("story_TBWorld", "name_1", "\231\142\175\233\131\189"),
    clueIDList = {
      101,
      102,
      103
    },
    icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/PlotFragments_B/Plot_Bg10.Plot_Bg10",
    baseImage = "/Game/Rouge/UI/Atlas_Alpha/A_DT/PlotFragments_B/Plot_Bg10.Plot_Bg10",
    worldIntelligenceID = {
      1,
      2,
      3
    },
    SettlementIncomeItemIcon = "/Game/Rouge/UI/Atlas_DT/IconPlotFragments/Frames/Icon_Diary_02.Icon_Diary_02",
    SettlementIncomeItemNameLocMeta = NSLOCTEXT("story_TBWorld", "SettlementIncomeItemName_1", "\230\149\176\230\141\174\230\131\133\230\138\165")
  },
  [2] = {
    id = 2,
    worldID = 24,
    nameLocMeta = NSLOCTEXT("story_TBWorld", "name_2", "\231\130\189\231\131\173\231\132\166\229\156\159"),
    clueIDList = {
      201,
      202,
      203
    },
    icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/PlotFragments_B/Plot_Bg28.Plot_Bg28",
    baseImage = "/Game/Rouge/UI/Atlas_Alpha/A_DT/PlotFragments_B/Plot_Bg28.Plot_Bg28",
    worldIntelligenceID = {
      11,
      12,
      13
    },
    SettlementIncomeItemIcon = "/Game/Rouge/UI/Atlas_DT/IconPlotFragments/Frames/Icon_ElectronicData_01.Icon_ElectronicData_01",
    SettlementIncomeItemNameLocMeta = NSLOCTEXT("story_TBWorld", "SettlementIncomeItemName_2", "\230\149\176\230\141\174\230\131\133\230\138\165")
  }
}
local LinkTb = {
  name = "nameLocMeta",
  SettlementIncomeItemName = "SettlementIncomeItemNameLocMeta"
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
IteratorSetMetaTable(story_tbworld, LuaTableMeta)
return story_tbworld
