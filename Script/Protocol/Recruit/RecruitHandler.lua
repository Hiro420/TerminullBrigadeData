local URGHttpHelper = UE.URGHttpHelper
local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local RecruitHandle = {}
function RecruitHandle:SendApplyRecruitTeam(Branch, TeamID)
  local url = "team/applyrecruitteam"
  print("Branch  " .. Branch .. "  TeamID  " .. TeamID .. "  Version  " .. LogicLobby.GetVersionID())
  HttpCommunication.Request(url, {
    branch = Branch,
    teamID = TeamID,
    version = LogicLobby.GetVersionID()
  }, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      print("SendApplyRecruitTeam succeeful")
      EventSystem.Invoke(EventDef.Recruit.ApplyRecruitTeam, JsonTable)
      ShowWaveWindow(1198)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function RecruitHandle:SendGetRecruitTeamList(AutoJoin, Floor, GameMode, WorldID)
  local url = "team/getrecruitteamlist"
  print("SendGetRecruitTeamList Auto  " .. tostring(AutoJoin) .. "  Floor  " .. Floor .. "  GameMode  " .. GameMode .. "  World" .. WorldID)
  HttpCommunication.Request(url, {
    autoJoin = AutoJoin,
    floor = Floor,
    gameMode = GameMode,
    worldID = WorldID
  }, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      EventSystem.Invoke(EventDef.Recruit.GetRecruitTeamList, JsonTable)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function RecruitHandle:SendGetRecruitApplyList(TeamID)
  local url = "team/getrecruitapplylist"
  HttpCommunication.Request(url, {teamID = TeamID}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      EventSystem.Invoke(EventDef.Recruit.GetRecruitApplyList, JsonTable)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function RecruitHandle:SendStartRecruit(AutoJoin, Content, Floor, GameMode, TeamID, WorldID)
  local url = "team/startrecruit"
  print("SendStartRecruit" .. "GameMode = " .. GameMode .. "  WorldID = " .. WorldID .. " Floor = " .. Floor .. "AutoJoin = " .. tostring(AutoJoin))
  HttpCommunication.Request(url, {
    autoJoin = AutoJoin,
    content = Content,
    floor = Floor,
    gameMode = GameMode,
    teamID = TeamID,
    worldID = WorldID
  }, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      EventSystem.Invoke(EventDef.Recruit.StartRecruit, JsonTable)
      LogicTeam.DealWithTeamInfo(JsonTable)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function RecruitHandle:SendStopRecruit(TeamID)
  local url = "team/stoprecruit"
  print("SendStopRecruit")
  HttpCommunication.Request(url, {teamID = TeamID}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      EventSystem.Invoke(EventDef.Recruit.StopRecruit, JsonTable)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function RecruitHandle:SendAgreeRecruitApply(RoleID, TeamID, Item)
  local url = "team/agreerecruitapply"
  HttpCommunication.Request(url, {roleID = RoleID, teamID = TeamID}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if Item then
        Item:RemoveSelf()
      end
      EventSystem.Invoke(EventDef.Recruit.AgreeRecruitApply)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function RecruitHandle:SendRefuseRecruitApply(RoleID, TeamID, Item)
  local url = "team/refuserecruitapply"
  HttpCommunication.Request(url, {roleID = RoleID, teamID = TeamID}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if Item then
        Item:RemoveSelf()
      end
      EventSystem.Invoke(EventDef.Recruit.RefuseRecruitApply)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function RecruitHandle:SendRolesGameFloorData(RoleIDs)
  local url = "playergrowth/gamefloor/rolesgamefloordata"
  HttpCommunication.Request(url, {roleIDs = RoleIDs}, {
    GameInstance,
    function(Target, JsonResponse)
      print("SendRolesGameFloorData Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      EventSystem.Invoke(EventDef.Recruit.GetRolesGameFloorData, JsonTable)
    end
  }, {
    GameInstance,
    function()
      print("SendRolesGameFloorData fail!")
    end
  })
end
return RecruitHandle
