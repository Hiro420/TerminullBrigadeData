local season_tbseasongeneral = {
  [1] = {
    SeasonID = 1,
    TitleLocMeta = NSLOCTEXT("season_TBSeasonGeneral", "Title_1", "\229\142\159\231\136\134\231\130\185"),
    AwardLinkID1 = 1005,
    AwardLinkParam1 = {},
    AwardLinkID2 = 1023,
    AwardLinkParam2 = {},
    SeasonModeList = {
      1003,
      3001,
      3002
    },
    SeasonContentPath = "/Game/Rouge/UI/Atlas_Alpha/A_DT/Bgimage/bg06.bg06",
    SeasonBgPath = "/Game/Rouge/UI/Atlas_Alpha/A_DT/PlotFragments_B/Plot_Bg13.Plot_Bg13"
  },
  [2] = {
    SeasonID = 2,
    TitleLocMeta = NSLOCTEXT("season_TBSeasonGeneral", "Title_2", "\229\142\159\231\136\134\231\130\185"),
    AwardLinkID1 = 1005,
    AwardLinkParam1 = {},
    AwardLinkID2 = 1023,
    AwardLinkParam2 = {},
    SeasonModeList = {
      1003,
      3001,
      3002
    },
    SeasonContentPath = "/Game/Rouge/UI/Atlas_Alpha/A_DT/Bgimage/bg06.bg06",
    SeasonBgPath = "/Game/Rouge/UI/Atlas_Alpha/A_DT/PlotFragments_B/Plot_Bg13.Plot_Bg13"
  }
}
local LinkTb = {
  Title = "TitleLocMeta"
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
IteratorSetMetaTable(season_tbseasongeneral, LuaTableMeta)
return season_tbseasongeneral
