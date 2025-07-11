local season_tbclimbtowerlobbyanomaly = {
  [1] = {
    AnomalyID = 1,
    Params = {},
    ContentLocMeta = NSLOCTEXT("season_TBClimbTowerLobbyAnomaly", "Content_1", "\227\128\144\230\181\139\232\175\149\227\128\145\233\152\159\228\188\141\230\136\144\229\145\152\229\191\133\233\161\187\228\189\191\231\148\168\228\184\141\229\144\140\231\154\132\232\167\146\232\137\178\230\136\152\230\150\151"),
    Remark = "\228\184\141\232\131\189\230\156\137\231\155\184\229\144\140\232\139\177\233\155\132"
  }
}
local LinkTb = {
  Content = "ContentLocMeta"
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
IteratorSetMetaTable(season_tbclimbtowerlobbyanomaly, LuaTableMeta)
return season_tbclimbtowerlobbyanomaly
