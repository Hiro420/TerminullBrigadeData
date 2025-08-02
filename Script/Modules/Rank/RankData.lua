local EnumRankMode = {
  season = {
    cyber = "season:cyber",
    fairyTale = "season:fairyTale",
    wasteland = "season:wasteland",
    star = "season:star"
  },
  racing = "racing"
}
_G.EnumRankMode = EnumRankMode
local EnumRankModeString = {
  "\232\181\155\229\141\154",
  "\231\171\165\232\175\157",
  "\229\186\159\229\156\159",
  "\230\152\159\233\153\133"
}
_G.EnumRankModeString = EnumRankModeString
local RankData = {
  PlayerInfo = {}
}

function RankData:Test()
end

function RankData:GetPlayerInfo(RoleId)
  if RankData.PlayerInfo[RoleId] and RankData.PlayerInfo[RoleId].Data then
    return RankData.PlayerInfo[RoleId].Data
  end
end

function RankData:SetPlayerInfo(RoleId, Data)
  if RankData.PlayerInfo[RoleId] then
    RankData.PlayerInfo[RoleId].Data = Data
    return
  end
  RankData.PlayerInfo[RoleId] = {}
  RankData.PlayerInfo[RoleId].Data = Data
end

function RankData:GetPlayerName(RoleId)
  if RankData.PlayerInfo[RoleId] and RankData.PlayerInfo[RoleId].Name then
    return RankData.PlayerInfo[RoleId].Name
  end
  return nil
end

function RankData:SetPlayerName(RoleId, Name)
  if RankData.PlayerInfo[RoleId] then
    RankData.PlayerInfo[RoleId].Name = Name
    return
  end
  RankData.PlayerInfo[RoleId] = {}
  RankData.PlayerInfo[RoleId].Name = Name
end

return RankData
