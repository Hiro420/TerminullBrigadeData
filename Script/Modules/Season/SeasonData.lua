local ESeasonMode = {SeasonMode = "SeasonMode", NormalMode = "NormalMode"}
_G.ESeasonMode = ESeasonMode
local SeasonData = {
  CurSelectSeasonMode = ESeasonMode.SeasonMode,
  CurSeasonID = -1
}

function SeasonData:DealWithTable()
end

return SeasonData
