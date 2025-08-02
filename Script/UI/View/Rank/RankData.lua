local rapidjson = require("rapidjson")
ERankType = {Team = "1", Solo = "2"}
local RankData = {
  TeamRankCache = {},
  TeamRankingChange = {},
  ElementData = {}
}

function RankData.ClearData()
  RankData.TeamRankCache = {}
  RankData.TeamRankingChange = {}
end

function RankData.RequestServerData(SeasonId, GameMode, GameWorld, HeroId, TopCnt)
  local boardType = "?boardType=" .. RankData.GetBoardType(GameMode, HeroId, SeasonId)
  local boardMetaJson = {
    gameMode = GameMode,
    gameWorld = GameWorld,
    seasonID = SeasonId
  }
  if nil ~= HeroId then
    boardMetaJson = {
      gameMode = GameMode,
      gameWorld = GameWorld,
      seasonID = SeasonId,
      heroID = HeroId
    }
  end
  local boardMeta = "&&boardMeta=" .. RapidJsonEncode(boardMetaJson)
  local topCnt = "&&topCnt=" .. TopCnt
  print("RankData.RequestServerData", "rank/boardelement" .. boardType .. boardMeta .. topCnt)
  if 0 == RankData.GetBoardType(GameMode, HeroId, SeasonId) then
    EventSystem.Invoke(EventDef.Rank.OnRequestServerDataSuccess, {
      ranklist = {}
    })
    return
  end
  HttpCommunication.RequestByGet("rank/boardtoplist" .. boardType .. boardMeta .. topCnt, {
    GameInstance,
    RankData.OnRequestServerDataSuccess
  }, {
    GameInstance,
    RankData.OnRequestServerDataFail
  }, false, true)
end

function RankData.OnRequestServerDataSuccess(Target, JsonResponse)
  local JsonTable = rapidjson.decode(JsonResponse.Content)
  EventSystem.Invoke(EventDef.Rank.OnRequestServerDataSuccess, JsonTable)
end

function RankData.OnRequestServerDataFail(Target, JsonResponse)
end

function RankData.RequestServerElementData(SeasonId, GameMode, GameWorld, HeroId, UniqueID)
  local boardType = "?boardType=" .. RankData.GetBoardType(GameMode, HeroId, SeasonId)
  local boardMetaJson = {
    gameMode = GameMode,
    gameWorld = GameWorld,
    seasonID = SeasonId
  }
  if nil ~= HeroId then
    boardMetaJson = {
      gameMode = GameMode,
      gameWorld = GameWorld,
      seasonID = SeasonId,
      heroID = HeroId
    }
  end
  local boardMeta = "&&boardMeta=" .. RapidJsonEncode(boardMetaJson)
  local uniqueID = "&&uniqueID=" .. UniqueID
  HttpCommunication.RequestByGet("rank/boardelement" .. boardType .. boardMeta .. uniqueID, {
    GameInstance,
    RankData.OnRequestServerElementDataSuccess
  }, {
    GameInstance,
    RankData.OnRequestServerElementDataFail
  }, false, true)
end

function RankData.OnRequestServerElementDataSuccess(Target, JsonResponse)
  local JsonTable = rapidjson.decode(JsonResponse.Content)
  if not JsonTable.data then
    return
  end
  local Data = rapidjson.decode(JsonTable.data)
  if not Data then
    return
  end
  if not Data.List then
    return
  end
  for index, Value in ipairs(Data.List) do
    RankData.ElementData[Value.roleId] = Value
  end
  EventSystem.Invoke(EventDef.Rank.OnRequestServerElementDataSuccess, Data.List)
end

function RankData.OnRequestServerElementDataFail(Target, JsonResponse)
end

function RankData.DetectingRankingChanges(World, GameMode, HeroId, Index)
  local RemoveIndex = 0
  local Ranking = 0
  for index, value in ipairs(RankData.TeamRankCache) do
    if World == value.World and GameMode == value.GameMode and HeroId == value.HeroId then
      Ranking = value.Index
      RemoveIndex = index
    end
  end
  if RemoveIndex > 0 then
    table.remove(RankData.TeamRankCache, RemoveIndex)
  end
  local CacheTable = {
    World = World,
    GameMode = GameMode,
    HeroId = HeroId,
    Index = Index
  }
  table.insert(RankData.TeamRankCache, CacheTable)
  if 0 == Ranking then
    return 0
  end
  return Ranking - Index
end

function RankData.GetPlayerInfo(RoleId)
  if not RankData.PlayerInfo then
    return
  end
  if RankData.PlayerInfo[RoleId] then
    return RankData.PlayerInfo[RoleId]
  end
end

function RankData.SetPlayerInfo(RoleId, Data)
  if RankData.PlayerInfo == nil then
    RankData.PlayerInfo = {}
  end
  if RankData.PlayerInfo[RoleId] then
    RankData.PlayerInfo[RoleId] = Data
    EventSystem.Invoke(EventDef.Rank.OnRefreshMVP)
    return
  end
  RankData.PlayerInfo[RoleId] = {}
  RankData.PlayerInfo[RoleId] = Data
  EventSystem.Invoke(EventDef.Rank.OnRefreshMVP)
end

function RankData.GetPlayerName(RoleId)
  if RankData.PlayerInfo[RoleId] and RankData.PlayerInfo[RoleId].nickname then
    return RankData.PlayerInfo[RoleId].nickname
  end
  return nil
end

function RankData.GetBoardType(ModeId, HeroId, SeasonId)
  local TBRankModeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRankMode)
  for index, value in ipairs(TBRankModeTable) do
    if value.ModeId == ModeId and value.bEnable and value.SeasonId == SeasonId then
      if HeroId then
        return value.SoloBoardType
      else
        return value.TeamBoardType
      end
    end
  end
end

return RankData
