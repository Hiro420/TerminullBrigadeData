require("UI.UIDef")
local RapidJson = require("rapidjson")
local ClimbtowerData = require("UI.View.ClimbTower.ClimbTowerData")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local rapidjson = require("rapidjson")
local Loginhandler = require("Protocol.LoginHandler")
local LobbyInfoConfig = require("GameConfig.LobbyInfoConfig")
local LoginData = require("Modules.Login.LoginData")
LogicTeam = LogicTeam or {
  TeamState = {
    None = -1,
    Idle = 0,
    Matching = 1,
    Preparing = 2,
    HeroPicking = 3,
    Displaying = 4,
    Battle = 5,
    Recruiting = 6
  },
  TipList = {},
  IsInit = false,
  IngoreDuration = 300,
  InvitedList = {},
  InviteInterval = 30,
  LastClickStartButtonTime = 0,
  DefaultGameModeId = 1001,
  BGCanNotInviteTeamTipId = 305002,
  HideLobbyViewList = {
    ViewID.UI_Apearance,
    ViewID.UI_ProficiencyView,
    ViewID.UI_WeaponMain,
    ViewID.UI_DrawCard,
    ViewID.UI_Mall_Bundle_Content,
    ViewID.UI_DevelopMain,
    ViewID.UI_PlayerInfoMain,
    ViewID.UI_IGuidePlotFragmentsWorldMenu,
    ViewID.UI_IllustratedGuidePlotFragments,
    ViewID.UI_IllustratedGuideSpecificModify,
    ViewID.UI_BattlePassMainView,
    ViewID.UI_RankView_Nor,
    ViewID.UI_Mail,
    ViewID.UI_ActivityPanel,
    ViewID.UI_MainTaskDetail,
    ViewID.UI_BeginnerGuideBookView,
    ViewID.UI_ProficiencyLegendSynopsis,
    ViewID.UI_SurvivalPanel,
    ViewID.UI_RecruitMainView
  },
  HideLobbyModelViewList = {
    ViewID.UI_MainModeSelection,
    ViewID.UI_IllustratedGuideMenu,
    ViewID.UI_Mall_Bundle,
    ViewID.UI_Mall_Bundle_1,
    ViewID.UI_Mall_Bundle_2,
    ViewID.UI_IGuidePlotFragmentsWorldMenu,
    ViewID.UI_IllustratedGuidePlotFragments,
    ViewID.UI_IllustratedGuideSpecificModify,
    ViewID.UI_MainTaskDetail,
    ViewID.UI_ProficiencyLegendSynopsis,
    ViewID.UI_SurvivalPanel
  },
  HideAllViewExceptViewIds = {
    [ViewID.UI_Marquee] = true
  },
  JoinTeamWay = {
    FriendInvite = 3,
    ChatInvite = 4,
    TeamCode = 5
  },
  RolesGameFloorInfo = {},
  Region = ""
}

function LogicTeam.Init()
  LogicTeam.TeamStateChangeFailRecord = {}
  LogicTeam.StartMatchingTime = 0
  LogicTeam.IsMatching = false
  LogicTeam.DefaultCountDownTime = 3
  LogicTeam.CurTeamState = -2
  LogicTeam.OldTeamState = -2
  LogicTeam.RecoverTime = 8
  LogicTeam.IsRequestJoinGame = false
  if LogicTeam.IsInit then
    return
  end
  LogicTeam.TeamInviteList = {}
  LogicTeam.IngoreTeamInviteList = {}
  if LogicTeam.IsDefaultNeedMatchTeammate == nil then
    LogicTeam.IsDefaultNeedMatchTeammate = true
    local LobbySaveGame = LogicLobby.GetLobbySaveGame()
    if LobbySaveGame and LobbySaveGame:IsValid() then
      LogicTeam.IsDefaultNeedMatchTeammate = LobbySaveGame:GetIsTeamMatching()
    end
  end
  LogicTeam.UpdateRegionPing()
  LogicTeam.IsInit = true
  EventSystem.AddListener(nil, EventDef.WSMessage.TeamUpdate, LogicTeam.BindOnTeamUpdate)
  EventSystem.AddListener(nil, EventDef.WSMessage.TeamKickOut, LogicTeam.BindOnTeamKickOut)
  EventSystem.AddListener(nil, EventDef.WSMessage.PlayStartGameAnimation, LogicTeam.BindOnPlayStartGameAnimation)
  EventSystem.AddListener(nil, EventDef.Lobby.UpdateMyTeamInfo, LogicTeam.BindOnUpdateVoiceTeam)
  EventSystem.AddListener(nil, EventDef.Lobby.OnTeamStateChanged, LogicTeam.BindOnTeamStateChanged)
  EventSystem.AddListener(nil, EventDef.WSMessage.CancelPrepare, LogicTeam.BindOnCancelPrepare)
  EventSystem.AddListener(nil, EventDef.WSMessage.StopMatch, LogicTeam.BindOnStopMatch)
  EventSystem.AddListener(nil, EventDef.WSMessage.LeaveTeam, LogicTeam.BindOnSomeOneLeaveTeam)
  EventSystem.AddListener(nil, EventDef.WSMessage.AllocateBattleServerFail, LogicTeam.BindOnAllocateBattleServerFail)
  EventSystem.AddListener(nil, EventDef.WSMessage.InviteJoinTeam, LogicTeam.BindOnInviteJoinTeam)
  EventSystem.AddListener(nil, EventDef.WSMessage.ApplyJoinTeam, LogicTeam.BindOnApplyJoinTeam)
  EventSystem.AddListener(nil, EventDef.WSMessage.RefuseFriendJoinTeam, LogicTeam.BindOnRefuseFriendJoinTeam)
  EventSystem.AddListener(nil, EventDef.WSMessage.RefuseJoinFriendTeam, LogicTeam.BindOnRefuseJoinFriendTeam)
  EventSystem.AddListener(nil, EventDef.WSMessage.AgreeJoinTeam, LogicTeam.BindOnAgreeJoinTeam)
  EventSystem.AddListener(nil, EventDef.WSMessage.ChangeTeamCaptain, LogicTeam.BindOnChangeTeamCaptain)
  EventSystem.AddListener(nil, EventDef.WSMessage.PickHeroDone, LogicTeam.BindOnPickHeroDone)
  EventSystem.AddListener(nil, EventDef.BeginnerGuide.OnGetFinishedGuideList, LogicTeam.BindOnGetFinishedGuideList)
end

function LogicTeam.SetLastClickStartButtonTime(InClickTime)
  LogicTeam.LastClickStartButtonTime = InClickTime
end

function LogicTeam.SetIsDefaultNeedMatchTeammate(IsNeed)
  if LogicTeam.IsDefaultNeedMatchTeammate == IsNeed then
    return
  end
  LogicTeam.IsDefaultNeedMatchTeammate = IsNeed
  local LobbySaveGame = LogicLobby.GetLobbySaveGame()
  if LobbySaveGame and LobbySaveGame:IsValid() then
    LobbySaveGame:SetIsTeamMatching(LogicTeam.IsDefaultNeedMatchTeammate)
    LogicLobby.SaveLobbySaveGame(LobbySaveGame)
  end
  EventSystem.Invoke(EventDef.Lobby.OnChangeDefaultNeedMatchTeammate)
end

function LogicTeam.GetIsDefaultNeedMatchTeammate()
  return LogicTeam.IsDefaultNeedMatchTeammate
end

function LogicTeam.SetIsMatching(IsMatching)
  if LogicTeam.IsMatching ~= IsMatching then
    LogicTeam.IsMatching = IsMatching
  end
end

function LogicTeam.GetIsMatching()
  return LogicTeam.IsMatching
end

function LogicTeam.GetCurMatchingTime()
  return math.floor(GetTimeWithServerDelta() - LogicTeam.StartMatchingTime)
end

function LogicTeam.RequestCreateTeamToServer(SuccessFuncList)
  local Params = {
    worldID = LogicTeam.GetWorldId(),
    gameMode = LogicTeam.GetModeId(),
    floor = LogicTeam.GetFloor(),
    branch = LogicLobby.GetBrunchType(),
    version = LogicLobby.GetVersionID(),
    region = LogicTeam.GetRegion(),
    debuffChoices = ClimbtowerData:GetLocalDebuff(LogicTeam.GetFloor())
  }
  table.Print(Params)
  HttpCommunication.Request("team/createteam", Params, {
    GameInstance,
    function(Target, JsonResponse)
      print("CreateTeam", JsonResponse.Content)
      local JsonTable = RapidJson.decode(JsonResponse.Content)
      local TeamInfo = {
        teamid = JsonTable.teamId,
        captain = DataMgr.GetUserId()
      }
      DataMgr.SetTeamInfo(TeamInfo)
      LogicTeam.RequestGetMyTeamDataToServer()
      if SuccessFuncList then
        SuccessFuncList[2](SuccessFuncList[1])
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function LogicTeam.DealWithTeamInfo(InTeamInfo)
  local TeamInfo = DataMgr.GetTeamInfo()
  local IsInTeam = InTeamInfo.teamid and InTeamInfo.teamid ~= "0" or false
  if TeamInfo.stateVersion ~= nil and IsInTeam and TeamInfo.stateVersion > InTeamInfo.stateVersion then
    print(string.format("LogicTeam.DealWithTeamInfo \233\152\159\228\188\141\228\191\161\230\129\175\231\137\136\230\156\172\232\191\135\230\156\159\239\188\140\232\191\135\230\156\159\231\137\136\230\156\172\228\184\186:%d, \229\189\147\229\137\141\231\137\136\230\156\172\228\184\186:%d", InTeamInfo.stateVersion, TeamInfo.stateVersion))
    return
  end
  LogicTeam.CollectMembershipChangeList(InTeamInfo)
  local LastModeId = LogicTeam.GetModeId()
  DataMgr.SetTeamInfo(InTeamInfo)
  if nil ~= InTeamInfo.region and InTeamInfo.region ~= "" and LogicTeam.GetRegion() ~= InTeamInfo.region then
    LogicTeam.SetRegion(InTeamInfo.region, true)
  end
  EventSystem.Invoke(EventDef.Lobby.UpdateMyTeamInfo)
  if LastModeId == TableEnums.ENUMGameMode.BEGINERGUIDANCE and LogicTeam.GetModeId() ~= TableEnums.ENUMGameMode.BEGINERGUIDANCE then
    LogicTeam.SetIsDefaultNeedMatchTeammate(true)
  end
  if DataMgr.IsInTeam() then
    local TeamInfo = DataMgr.GetTeamInfo()
    LogicTeam.SetTeamState(TeamInfo.state)
    LogicTeam.SetSingleWorldId(TeamInfo.worldID)
    LogicTeam.SetSingleModeId(TeamInfo.gameMode)
    LogicTeam.SetSingleFloor(TeamInfo.floor)
    local PlayerList = {}
    for i, SinglePlayerInfo in ipairs(TeamInfo.players) do
      if UE.URGBlueprintLibrary.CheckWithEditor() and LogicLobby.IsFakeTeamData then
        table.insert(PlayerList, SinglePlayerInfo.id)
        break
      end
      table.insert(PlayerList, SinglePlayerInfo.id)
    end
    LogicTeam.SendRolesGameFloorData(PlayerList)
    DataMgr.GetOrQueryPlayerInfo(PlayerList, true, function(PlayerCacheInfoList)
      print("LogicLobby GetRoomMemberInfoSuccess", RapidJsonEncode(PlayerCacheInfoList))
      local PlayerInfoList = DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoList)
      local List = {}
      local PlayerNameList = {}
      for i, SinglePlayerInfo in ipairs(PlayerInfoList) do
        List[SinglePlayerInfo.roleid] = SinglePlayerInfo
        if SinglePlayerInfo.roleid == DataMgr.GetUserId() then
          DataMgr.SetBasicInfo(SinglePlayerInfo)
        end
        PlayerNameList[SinglePlayerInfo.roleid] = SinglePlayerInfo.nickname
      end
      DataMgr.SetTeamMemberNameList(PlayerNameList)
      local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if WaveWindowManager then
        for i, SingleParam in ipairs(LogicTeam.TipList) do
          local TargetPlayerInfo = List[SingleParam.Id]
          if TargetPlayerInfo then
            WaveWindowManager:ShowWaveWindow(SingleParam.WaveId, {
              TargetPlayerInfo.nickname
            })
          end
        end
        LogicTeam.TipList = {}
      end
      local TargetPlayerList = PlayerInfoList
      if UE.URGBlueprintLibrary.CheckWithEditor() and LogicLobby.IsFakeTeamData and TargetPlayerList then
        local IdDiffValue = 1
        while table.count(TargetPlayerList) < 3 do
          local TargetPlayerInfo = DeepCopy(TargetPlayerList[1])
          TargetPlayerInfo.id = tostring(tonumber(TargetPlayerList[1].roleid) + IdDiffValue)
          table.insert(TargetPlayerList, TargetPlayerInfo)
          IdDiffValue = IdDiffValue + 1
        end
      end
      DataMgr.SetTeamMembersInfo(TargetPlayerList)
      EventSystem.Invoke(EventDef.Lobby.UpdateRoomMembersInfo, TargetPlayerList)
    end, function()
    end)
  else
    LogicTeam.SetTeamState(LogicTeam.TeamState.None)
    LogicTeam.SendRolesGameFloorData({
      DataMgr.UserId
    })
  end
end

function LogicTeam.RequestGetMyTeamDataToServer()
  HttpCommunication.RequestByGet("team/getmyteamdata", {
    GameInstance,
    function(Target, JsonResponse)
      print("GetMyTeamData", JsonResponse.Content)
      local JsonTable = RapidJson.decode(JsonResponse.Content)
      LogicTeam.DealWithTeamInfo(JsonTable)
    end
  })
end

function LogicTeam.ResetTeamData()
end

function LogicTeam.SetTeamState(InState)
  if LogicTeam.CurTeamState ~= InState then
    EventSystem.Invoke(EventDef.Lobby.OnTeamStateChanged, LogicTeam.CurTeamState, InState)
  end
  LogicTeam.OldTeamState = LogicTeam.CurTeamState
  LogicTeam.CurTeamState = InState
end

function LogicTeam.CollectMembershipChangeList(JsonTable)
  local LastTeamInfo = DataMgr.GetTeamInfo()
  if LastTeamInfo.teamid == JsonTable.teamid then
    local LastTeamMemberList = {}
    if LastTeamInfo.players then
      for i, SinglePlayerInfo in ipairs(LastTeamInfo.players) do
        table.insert(LastTeamMemberList, SinglePlayerInfo.id)
      end
    end
    local UserId = DataMgr.GetUserId()
    for i, SinglePlayerInfo in ipairs(JsonTable.players) do
      if not table.Contain(LastTeamMemberList, SinglePlayerInfo.id) and SinglePlayerInfo.id ~= UserId then
        local Param = {
          Id = SinglePlayerInfo.id,
          WaveId = 1082
        }
        table.insert(LogicTeam.TipList, Param)
      end
    end
  elseif 0 ~= tonumber(JsonTable.teamid) then
    local UserId = DataMgr.GetUserId()
    if UserId ~= JsonTable.captain then
      local Param = {
        Id = JsonTable.captain,
        WaveId = 1084
      }
      table.insert(LogicTeam.TipList, Param)
    end
  end
end

function LogicTeam.RequestJoinTeamToServer(TeamId, JoinWay, SuccessDelegate)
  local Param = {
    teamid = TeamId,
    branch = LogicLobby.GetBrunchType(),
    version = LogicLobby.GetVersionID(),
    joinway = JoinWay
  }
  print("LogicTeam.RequestJoinTeamToServer JoinWay", Param.joinway)
  HttpCommunication.Request("team/jointeam", Param, SuccessDelegate, {
    GameInstance,
    function()
    end
  })
end

function LogicTeam.RequestKickTeamMemberToServer(RoleId, IsBlock)
  local TeamInfo = DataMgr.GetTeamInfo()
  if LogicTeam.CurTeamState == LogicTeam.TeamState.Matching or LogicTeam.CurTeamState == LogicTeam.TeamState.HeroPicking or LogicTeam.CurTeamState == LogicTeam.TeamState.Battle then
    ShowWaveWindow(15016)
    return
  end
  local Block = 0
  if IsBlock then
    Block = 1
  end
  local Param = {
    block = Block,
    roleId = RoleId,
    teamid = TeamInfo.teamid
  }
  HttpCommunication.Request("team/kickteammember", Param, {
    GameInstance,
    function(Target, JsonResponse)
      print("KickTeamMemberSucc")
      LogicTeam.RequestGetMyTeamDataToServer()
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function LogicTeam.RequestQuitTeamToServer(SuccessFuncList)
  local TeamInfo = DataMgr.GetTeamInfo()
  local Param = {
    teamid = TeamInfo.teamid
  }
  HttpCommunication.Request("team/quitteam", Param, {
    GameInstance,
    function()
      print("\228\184\187\229\138\168\233\128\128\229\135\186\233\152\159\228\188\141")
      DataMgr.ClearTeamInfo()
      LogicTeam.SendRolesGameFloorData({
        DataMgr.UserId
      })
      LogicTeam.SetTeamState(LogicTeam.TeamState.None)
      EventSystem.Invoke(EventDef.Lobby.UpdateMyTeamInfo)
      if SuccessFuncList then
        SuccessFuncList[2](SuccessFuncList[1])
      end
      LogicTeam.ClearSession()
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function LogicTeam.RequestSetTeamDataToServer(WorldId, ModeIdParam, Floor)
  if not LogicTeam.IsCaptain() then
    return
  end
  local ModeId = ModeIdParam
  if CheckIsInNormal(ModeId) then
    local SeasonModule = ModuleManager:Get("SeasonModule")
    ModeId = SeasonModule:GetCurNormalMode()
  end
  print("LogicTeam.RequestSetTeamDataToServer Info", WorldId, ModeId, Floor)
  if DataMgr.IsInTeam() then
    local TeamInfo = DataMgr.GetTeamInfo()
    if TeamInfo.state ~= LogicTeam.TeamState.Idle then
      print("LogicTeam.RequestSetTeamDataToServer Fail, TeamState is Invalid!", TeamInfo.state)
      return
    end
    local Params = {
      teamid = TeamInfo.teamid,
      worldID = WorldId,
      gameMode = ModeId,
      floor = Floor,
      region = LogicTeam.GetRegion()
    }
    HttpCommunication.Request("team/setteamdata", Params, {
      GameInstance,
      function()
        print("SetTeamDataSuccess")
      end
    }, {
      GameInstance,
      function()
      end
    })
  else
    local LastModeId = LogicTeam.GetModeId()
    LogicTeam.SetSingleWorldId(WorldId)
    LogicTeam.SetSingleModeId(ModeId)
    if LastModeId == TableEnums.ENUMGameMode.BEGINERGUIDANCE and LogicTeam.GetModeId() ~= TableEnums.ENUMGameMode.BEGINERGUIDANCE then
      LogicTeam.SetIsDefaultNeedMatchTeammate(true)
    end
    if LogicTeam.GetModeId() == TableEnums.ENUMGameMode.BEGINERGUIDANCE then
      LogicTeam.SetIsDefaultNeedMatchTeammate(false)
    end
    LogicTeam.SetSingleFloor(Floor)
    EventSystem.Invoke(EventDef.Lobby.UpdateMyTeamInfo)
  end
end

function LogicTeam.RequestStartGameToServer(SuccessCallback)
  local TeamInfo = DataMgr.GetTeamInfo()
  local DebugDSName = CmdLineMgr.FindParam("DebugDSName")
  if DebugDSName then
    print("LogicTeam.RequestStartGameToServer, DebugDSName: ", DebugDSName)
    HttpCommunication.Request("dbg/team/startgame", {
      teamid = TeamInfo.teamid,
      name = DebugDSName,
      region = LogicTeam.GetRegion()
    }, {
      nil,
      function()
        print("HttpCommunication.DbgStartMatch Succeeded.")
      end
    }, {
      nil,
      function()
        print("HttpCommunication.DbgStartMatch Failed.")
      end
    })
  else
    HttpCommunication.Request("team/startgame", {
      teamid = TeamInfo.teamid,
      version = LogicLobby.GetVersionID(),
      region = LogicTeam.GetRegion()
    }, {
      GameInstance,
      function(Target, JsonResponse)
        print("StartGameSuccess")
        local TeamInfoTable = rapidjson.decode(JsonResponse.Content)
        LogicTeam.DealWithTeamInfo(TeamInfoTable)
        if SuccessCallback then
          SuccessCallback[2](SuccessCallback[1])
        end
      end
    }, {
      GameInstance,
      function()
      end
    })
  end
end

function LogicTeam.RequestStartMatchToServer()
  local TeamInfo = DataMgr.GetTeamInfo()
  if not LogicTeam.IsCaptain() then
    print("StartMatch \228\184\141\230\152\175\233\152\159\233\149\191")
    return
  end
  HttpCommunication.Request("team/startmatch", {
    teamid = TeamInfo.teamid,
    version = LogicLobby.GetVersionID(),
    region = LogicTeam.GetRegion()
  }, {
    GameInstance,
    function(Target, JsonResponse)
      print("StartMatchSuccess")
      local TeamInfoTable = rapidjson.decode(JsonResponse.Content)
      LogicTeam.DealWithTeamInfo(TeamInfoTable)
    end
  }, {
    GameInstance,
    function()
    end
  })
  UE.URGGameplayLibrary.TriggerOnClientStartMatching(GameInstance)
end

function LogicTeam.RequestStopMatchToServer(SuccessCallback)
  local TeamInfo = DataMgr.GetTeamInfo()
  HttpCommunication.Request("team/stopmatch", {
    teamid = TeamInfo.teamid
  }, {
    GameInstance,
    function()
      print("StopMatchSuccess")
      if SuccessCallback then
        SuccessCallback[2](SuccessCallback[1])
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
  UE.URGGameplayLibrary.TriggerOnClientStopMatching(GameInstance)
end

function LogicTeam.RequestJoinGameToServer()
  if not DataMgr.IsInTeam() then
    return
  end
  if LogicTeam.IsRequestJoinGame then
    print("LogicTeam.RequestJoinGameToServer \229\183\178\231\187\143\229\143\145\233\128\129\232\191\135JoinGame\231\148\179\232\175\183\228\186\134")
    return
  end
  LogicTeam.IsRequestJoinGame = true
  print("RequestJoinGame")
  local TeamInfo = DataMgr.GetTeamInfo()
  HttpCommunication.Request("team/joingame", {
    teamid = TeamInfo.teamid
  }, {
    GameInstance,
    function()
      print("JoinGameSuccess")
      LogicTeam.IsRequestJoinGame = false
      LogicTeam.RecoverTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        GameInstance,
        LogicTeam.StartJoinGameResultTimer
      }, LogicTeam.RecoverTime, false)
    end
  }, {
    GameInstance,
    function()
      LogicTeam.IsRequestJoinGame = false
      EventSystem.Invoke(EventDef.Lobby.OnJoinGameFail)
      LogicTeam.RequestGetMyTeamDataToServer()
    end
  })
end

function LogicTeam.StartJoinGameResultTimer()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(LogicTeam.RecoverTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, LogicTeam.RecoverTimer)
  end
  EventSystem.Invoke(EventDef.Lobby.OnJoinGameFail)
end

function LogicTeam.RequestCancelPrepareToServer()
  local TeamInfo = DataMgr.GetTeamInfo()
  HttpCommunication.Request("team/cancelprepare", {
    teamid = TeamInfo.teamid
  }, {
    GameInstance,
    function()
      print("CancelPrepare Succ!")
      LogicTeam.RequestGetMyTeamDataToServer()
    end
  }, {
    GameInstance,
    function()
      print("CancelPrepare Fail!")
    end
  })
end

function LogicTeam.RequestApplyJoinTeamToServer(RoleId, InviteTeamWay)
  if LogicTeam.InvitedList[RoleId] and GetTimeWithServerDelta() - LogicTeam.InvitedList[RoleId] < LogicTeam.InviteInterval then
    ShowWaveWindow(15023, {})
    return
  end
  LogicTeam.InvitedList[RoleId] = GetTimeWithServerDelta()
  local Params = {roleID = RoleId, joinway = InviteTeamWay}
  HttpCommunication.Request("team/applyjointeam", Params, {
    GameInstance,
    function()
      print("ApplyJoinTeam Succ!")
    end
  }, {
    GameInstance,
    function()
      print("ApplyJoinTeam Fail!")
    end
  })
end

function LogicTeam.RequestInviteJoinTeamToServer(RoleId, InviteTeamWay)
  if LogicTeam.GetModeId() == TableEnums.ENUMGameMode.BEGINERGUIDANCE then
    ShowWaveWindow(LogicTeam.BGCanNotInviteTeamTipId, {})
    return
  end
  if LogicTeam.InvitedList[RoleId] and GetTimeWithServerDelta() - LogicTeam.InvitedList[RoleId] < LogicTeam.InviteInterval then
    ShowWaveWindow(15023, {})
    return
  end
  LogicTeam.InvitedList[RoleId] = GetTimeWithServerDelta()
  local TeamInfo = DataMgr.GetTeamInfo()
  local JsonParam = {
    roleID = RoleId,
    teamID = TeamInfo.teamid,
    joinway = InviteTeamWay
  }
  HttpCommunication.Request("team/invitejointeam", JsonParam, {
    GameInstance,
    function()
      print("InviteJoinTeam Succ!")
    end
  }, {
    GameInstance,
    function()
      print("InviteJoinTeam Fail!")
    end
  })
end

function LogicTeam.RequestAgreeJoinTeamToServer(RoleId, TeamId, TeamJoinWay)
  local JsonParam = {
    roleID = RoleId,
    teamID = TeamId,
    joinway = TeamJoinWay
  }
  HttpCommunication.Request("team/agreejointeam", JsonParam, {
    GameInstance,
    function()
      print("AgreeJoinTeam Succ!")
    end
  }, {
    GameInstance,
    function()
      print("AgreeJoinTeam Fail!")
    end
  })
end

function LogicTeam.RequestRefuseFriendJoinTeam(RoleId, TeamId)
  local JsonParam = {roleID = RoleId, teamID = TeamId}
  HttpCommunication.Request("team/refusefriendjointeam", JsonParam, {
    GameInstance,
    function()
      print("refusefriendjointeam Succ!")
    end
  }, {
    GameInstance,
    function()
      print("refusefriendjointeam Fail!")
    end
  })
end

function LogicTeam.RequestRefuseJoinFriendTeam(RoleId, TeamId)
  local JsonParam = {roleID = RoleId, teamID = TeamId}
  HttpCommunication.Request("team/refusejoinfriendteam", JsonParam, {
    GameInstance,
    function()
      print("refusejoinfriendteam Succ!")
    end
  }, {
    GameInstance,
    function()
      print("refusejoinfriendteam Fail!")
    end
  })
end

function LogicTeam.RequestChangeCaptainToServer(RoleId)
  if not DataMgr.IsInTeam() or not LogicTeam.IsCaptain() then
    print("ChangeCaptain Error")
    return
  end
  if LogicTeam.CurTeamState == LogicTeam.TeamState.Matching or LogicTeam.CurTeamState == LogicTeam.TeamState.HeroPicking or LogicTeam.CurTeamState == LogicTeam.TeamState.Battle then
    ShowWaveWindow(15015)
    return
  end
  local TeamInfo = DataMgr.GetTeamInfo()
  local JsonParam = {
    roleID = RoleId,
    teamID = TeamInfo.teamid
  }
  HttpCommunication.Request("team/changecaptain", JsonParam, {
    GameInstance,
    function()
      print("ChangeCaptain Succ!")
      LogicTeam.RequestGetMyTeamDataToServer()
    end
  }, {
    GameInstance,
    function()
      print("ChangeCaptain Fail!")
    end
  })
end

function LogicTeam.RequestGetTeamMemberCountToServer(RoleId, SuccessFuncList)
  HttpCommunication.Request("team/getteammembercount", {roleID = RoleId}, {
    GameInstance,
    function(Target, JsonResponse)
      print("GetTeamMemberCount", RoleId, JsonResponse.Content)
      local JsonTable = RapidJson.decode(JsonResponse.Content)
      if SuccessFuncList then
        SuccessFuncList[2](SuccessFuncList[1], JsonTable.count)
      end
    end
  })
end

function LogicTeam.RequestPreDeductTicket(Ticket)
  local MyTeamInfo = DataMgr.GetTeamInfo()
  local JsonParam = {
    teamID = MyTeamInfo.teamid,
    ticket = Ticket
  }
  HttpCommunication.Request("team/predeductticket", JsonParam, {
    GameInstance,
    function()
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function LogicTeam.RequestCancelStartGameToServer()
  local MyTeamInfo = DataMgr.GetTeamInfo()
  local JsonParam = {
    teamid = MyTeamInfo.teamid
  }
  HttpCommunication.Request("team/cancelstartgame", JsonParam, {
    GameInstance,
    function()
      print("LogicTeam.RequestCancelStartGameToServer Success!")
      LogicTeam.RequestGetMyTeamDataToServer()
    end
  })
end

function LogicTeam.SendRolesGameFloorData(RoleIDs)
  local url = "playergrowth/gamefloor/rolesgamefloordata"
  HttpCommunication.Request(url, {roleIDs = RoleIDs}, {
    GameInstance,
    function(Target, JsonResponse)
      print("SendRolesGameFloorData Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      LogicTeam.RolesGameFloorInfo = {}
      local modeList = {}
      local worldList = {}
      for roleid, v in pairs(JsonTable.rolesGameFloorData) do
        modeList = {}
        for modeid, modeinfo in pairs(v.gameModeAndWorldAndFloorData) do
          worldList = {}
          for worldid, floor in pairs(modeinfo.gameWorldAndFloorData) do
            worldList[worldid] = floor
          end
          modeList[modeid] = worldList
        end
        LogicTeam.RolesGameFloorInfo[roleid] = modeList
      end
      for roleid, v in pairs(LogicTeam.RolesGameFloorInfo) do
        local LevelInfoList = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
        for LevelID, LevelInfo in pairs(LevelInfoList) do
          if LevelInfo.initUnlock then
            if v[tostring(LevelInfo.gameMode)] == nil then
              local UnlockWorldList = {}
              v[tostring(LevelInfo.gameMode)] = UnlockWorldList
              UnlockWorldList[tostring(LevelInfo.gameWorldID)] = LevelInfo.floor
            else
              local WorldFloor = v[tostring(LevelInfo.gameMode)][tostring(LevelInfo.gameWorldID)]
              if nil == WorldFloor or WorldFloor < LevelInfo.floor then
                v[tostring(LevelInfo.gameMode)][tostring(LevelInfo.gameWorldID)] = LevelInfo.floor
              end
            end
          end
        end
      end
      EventSystem.Invoke(EventDef.Lobby.GetRolesGameFloorData, LogicTeam.RolesGameFloorInfo)
    end
  }, {
    GameInstance,
    function()
      print("SendRolesGameFloorData fail!")
    end
  })
end

function LogicTeam.GetTeamUnLockMode(ModeID, WorldId)
  for RoleId, ModeInfo in pairs(LogicTeam.RolesGameFloorInfo) do
    if RoleId == DataMgr.GetUserId() then
    elseif ModeInfo[tostring(ModeID)] and not ModeInfo[tostring(ModeID)][tostring(WorldId)] then
      return false
    end
  end
  return true
end

function LogicTeam.GetTeamUnLockModeAndMember(ModeID, WorldId)
  local LockModeTeamMember = {}
  for RoleId, ModeInfo in pairs(LogicTeam.RolesGameFloorInfo) do
    if RoleId == DataMgr.GetUserId() then
    elseif not ModeInfo[tostring(ModeID)] then
      table.insert(LockModeTeamMember, RoleId)
    elseif not ModeInfo[tostring(ModeID)][tostring(WorldId)] then
      table.insert(LockModeTeamMember, RoleId)
    end
  end
  return 0 == #LockModeTeamMember, LockModeTeamMember
end

function LogicTeam.GetTeamUnLockModeFloor(ModeID, WorldId, floor)
  for RoleId, ModeInfo in pairs(LogicTeam.RolesGameFloorInfo) do
    if RoleId == DataMgr.GetUserId() then
    elseif ModeInfo[tostring(ModeID)] then
      if ModeInfo[tostring(ModeID)][tostring(WorldId)] and floor > ModeInfo[tostring(ModeID)][tostring(WorldId)] then
        return false
      end
    else
      return false
    end
  end
  return true
end

function LogicTeam.GetTeamUnLockModeFloorAndMember(ModeID, WorldId, floor)
  local LockFloorTeamMember = {}
  for RoleId, ModeInfo in pairs(LogicTeam.RolesGameFloorInfo) do
    if RoleId == DataMgr.GetUserId() then
    elseif ModeInfo[tostring(ModeID)] and ModeInfo[tostring(ModeID)][tostring(WorldId)] and floor > ModeInfo[tostring(ModeID)][tostring(WorldId)] then
      table.insert(LockFloorTeamMember, RoleId)
    end
  end
  return 0 == #LockFloorTeamMember, LockFloorTeamMember
end

function LogicTeam.CheckIsDefaultUnLock(WorldId, Floor)
  local floor
  floor = Floor or 1
  local TBGameFloor = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  if TBGameFloor then
    for LevelId, LevelInfo in pairs(TBGameFloor) do
      if LevelInfo.gameWorldID == WorldId and LevelInfo.floor == Floor then
        return LevelInfo.initUnlock
      end
    end
  end
end

function LogicTeam.BindOnTeamUpdate()
  LogicTeam.RequestGetMyTeamDataToServer()
end

function LogicTeam.BindOnTeamKickOut(Json)
  print("LogicTeam.BindOnTeamKickOut")
  local JsonTable = RapidJson.decode(Json)
  if JsonTable.id == DataMgr.GetUserId() then
    print("\232\162\171\233\152\159\228\188\141\232\184\162\229\135\186")
    DataMgr.ClearTeamInfo()
    EventSystem.Invoke(EventDef.Lobby.UpdateMyTeamInfo)
    LogicTeam.ClearSession()
  end
  DataMgr.GetOrQueryPlayerInfo({
    JsonTable.id
  }, false, function(PlayerInfoList)
    for index, SinglePlayerInfo in ipairs(PlayerInfoList) do
      ShowWaveWindow(15026, {
        SinglePlayerInfo.playerInfo.nickname
      })
    end
  end)
  LogicTeam.RequestGetMyTeamDataToServer()
end

function LogicTeam.BindOnPlayStartGameAnimation()
  print("BindOnWSStartGame")
  if DataMgr.IsInTeam() then
    LogicTeam.RequestJoinGameToServer()
  end
  LogicTeam.RequestGetMyTeamDataToServer()
end

function LogicTeam.BindOnUpdateVoiceTeam()
  print("LogicTeam.BindOnUpdateVoiceTeam")
  if DataMgr.IsInTeam() then
    local CurrentVoiceRoom = DataMgr.MyTeamInfo.teamid
    print("LogicTeam.BindOnUpdateVoiceTeam1", CurrentVoiceRoom)
    if UE.UGVoiceSubsystem ~= nil then
      local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
      if GVoice then
        print("LogicTeam.BindOnUpdateVoiceTeam2", CurrentVoiceRoom, GVoice:GetCurrentTeamRoomName())
        if CurrentVoiceRoom ~= GVoice:GetCurrentTeamRoomName() then
          if GVoice:GetCurrentTeamRoomName() ~= "" then
            GVoice:QuitTeamRoom()
          end
          local Result = GVoice:JoinTeamRoom(CurrentVoiceRoom, 6000)
          print("LogicTeam.BindOnUpdateVoiceTeam3", Result)
          if 0 == Result then
            print("LogicTeam.BindOnUpdateVoiceTeam4", CurrentVoiceRoom, DataMgr.MyTeamInfo.teamid)
          end
        end
      end
    end
    local TeamInfo = DataMgr.GetTeamInfo()
    if TeamInfo.captain == DataMgr.GetUserId() then
      LogicTeam.ResetTeamData()
      LogicTeam.SaveGameModeInfo()
    end
  else
    if UE.UGVoiceSubsystem ~= nil then
      local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
      if GVoice then
        print("LogicTeam.BindOnUpdateVoiceTeam5")
        if GVoice:GetCurrentTeamRoomName() ~= "" then
          GVoice:QuitTeamRoom()
        end
      end
    end
    LogicTeam.ResetTeamData()
    LogicTeam.SaveGameModeInfo()
  end
end

function LogicTeam.SaveGameModeInfo()
  local LobbySaveGame = LogicLobby.GetLobbySaveGame()
  if LobbySaveGame then
    local SeasonModule = ModuleManager:Get("SeasonModule")
    local IsNormalMode = SeasonModule and (not SeasonModule:CheckIsInSeasonMode() or SeasonModule:CheckIsInFirstSeason())
    LobbySaveGame:SetGameModeInfo(DataMgr.GetUserId(), LogicTeam.GetModeId(), LogicTeam.GetWorldId(), LogicTeam.GetFloor(), IsNormalMode)
  end
end

LogicTeam.OldStateSwitch = {
  [LogicTeam.TeamState.None] = function()
  end,
  [LogicTeam.TeamState.Idle] = function()
  end,
  [LogicTeam.TeamState.Matching] = function()
    LogicTeam.StartMatchingTime = 0
    UIMgr:Hide(ViewID.UI_MatchingTipPanel)
  end,
  [LogicTeam.TeamState.Preparing] = function()
    LogicTeam.EndPrepareTime = 0
    local PrepareTipPanel = UIMgr:GetLuaFromActiveView(ViewID.UI_PrepareTipPanel)
    if PrepareTipPanel then
      PrepareTipPanel:HideUI()
    end
  end,
  [LogicTeam.TeamState.HeroPicking] = function()
    UIMgr:Hide(ViewID.UI_HeroSelectionMainPanel)
  end
}
LogicTeam.NewStateSwitch = {
  [LogicTeam.TeamState.None] = function()
    LogicLobby.ChangeLobbyMainModelVis(true)
    LogicLobby.ChangeHeroSelectionModelVis(false)
    local needHideLobby = false
    for i, v in pairs(LogicTeam.HideLobbyViewList) do
      if UIMgr:IsShow(v) then
        needHideLobby = true
      end
    end
    if not needHideLobby and not UIMgr:IsShow(ViewID.UI_LobbyPanel) then
      UIMgr:Show(ViewID.UI_LobbyPanel)
    end
  end,
  [LogicTeam.TeamState.Idle] = function()
    LogicLobby.ChangeHeroSelectionModelVis(false)
    if not UIMgr:IsShow(ViewID.UI_MainModeSelection) then
      local needHideLobby = false
      for i, v in pairs(LogicTeam.HideLobbyViewList) do
        if UIMgr:IsShow(v) then
          needHideLobby = true
        end
      end
      if not needHideLobby then
        if not UIMgr:IsShow(ViewID.UI_LobbyPanel) then
          UIMgr:Show(ViewID.UI_LobbyPanel)
        end
      elseif UIMgr:IsShow(ViewID.UI_LobbyPanel) then
        UIMgr:Hide(ViewID.UI_LobbyPanel)
      end
    end
    local IsNeedHideLobbyModel = false
    for index, ViewID in ipairs(LogicTeam.HideLobbyModelViewList) do
      if UIMgr:IsShow(ViewID) then
        IsNeedHideLobbyModel = true
        break
      end
    end
    LogicLobby.ChangeLobbyMainModelVis(not IsNeedHideLobbyModel)
  end,
  [LogicTeam.TeamState.Matching] = function()
    local TeamInfo = DataMgr.GetTeamInfo()
    LogicTeam.StartMatchingTime = TeamInfo.stateStartTime
    DataMgr.SetTimeVelocityDifferenceByServer(TeamInfo.stateStartTime)
    UIMgr:Show(ViewID.UI_MatchingTipPanel)
  end,
  [LogicTeam.TeamState.Preparing] = function()
    local TeamInfo = DataMgr.GetTeamInfo()
    LogicTeam.EndPrepareTime = TeamInfo.stateEndTime
    UIMgr:Show(ViewID.UI_PrepareTipPanel)
  end,
  [LogicTeam.TeamState.HeroPicking] = function()
    if RGUIMgr:IsShown(UIConfig.WBP_GameSettingsMain_C.UIName) then
      LogicGameSetting.ShowGameSettingPanel()
    end
    UIMgr:HideAllActiveViews(LogicTeam.HideAllViewExceptViewIds)
    LogicRole.ShowOrLoadLevel(-1)
    LogicRole.ShowLevelForSequence(true)
    ChangeToLobbyAnimCamera()
    UIMgr:Hide(ViewID.UI_MainModeSelection)
    LogicLobby.ChangeLobbyMainModelVis(false)
    LogicLobby.ChangeHeroSelectionModelVis(true)
    local TeamInfo = DataMgr.GetTeamInfo()
    DataMgr.SetTimeVelocityDifferenceByServer(tonumber(TeamInfo.stateStartTime))
    LogicHeroSelect.SetStartTime(tonumber(TeamInfo.stateStartTime))
    LogicHeroSelect.SetEndTime(tonumber(TeamInfo.stateEndTime))
    UIMgr:Show(ViewID.UI_HeroSelectionMainPanel)
    LogicTeam.TeamInviteList = {}
    LogicTeam.ShowTeamInviteTipWindow()
  end,
  [LogicTeam.TeamState.Battle] = function(OldState)
    local CurLevelName = UE.UGameplayStatics.GetCurrentLevelName(GameInstance, true)
    if "Lobby" == CurLevelName and OldState == LogicTeam.TeamState.HeroPicking then
      UIMgr:HideAllActiveViews(LogicTeam.HideAllViewExceptViewIds)
      local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
      if UIManager then
        for SingleWidgetName, SingleWidget in pairs(UIManager.AliveWidget) do
          RGUIMgr:HideUI(SingleWidgetName)
        end
      end
      ChangeToLobbyAnimCamera()
    end
  end
}

function LogicTeam.BindOnTeamStateChanged(OldState, NewState)
  print(string.format("OnTeamStateChanged, OldState:%d, NewState:%d", OldState, NewState))
  if not LogicLobby.IsInLobbyLevel() then
    return
  end
  if LogicTeam.OldStateSwitch[OldState] then
    LogicTeam.OldStateSwitch[OldState]()
  end
  if LogicTeam.NewStateSwitch[NewState] then
    LogicTeam.NewStateSwitch[NewState](OldState)
  end
end

function LogicTeam.BindOnCancelPrepare(Json)
  local JsonTable = RapidJson.decode(Json)
  print("LogicTeam.BindOnCancelPrepare\230\156\137\231\142\169\229\174\182\230\139\146\231\187\157\228\186\134\232\175\183\230\177\130,\229\143\150\230\182\136\229\140\185\233\133\141\230\136\144\229\138\159\229\144\142\231\154\132\229\135\134\229\164\135", JsonTable.id)
  DataMgr.GetOrQueryPlayerInfo({
    JsonTable.id
  }, false, function(PlayerInfoList)
    for i, v in ipairs(PlayerInfoList) do
      ShowWaveWindow(15022, {
        v.playerInfo.nickname
      })
    end
  end)
  LogicTeam.RequestGetMyTeamDataToServer()
end

function LogicTeam.BindOnStopMatch(Json)
  local JsonTable = RapidJson.decode(Json)
  print("LogicTeam.BindOnStopMatch\230\156\137\231\142\169\229\174\182\229\143\150\230\182\136\228\186\134\229\140\185\233\133\141", JsonTable.id)
  DataMgr.GetOrQueryPlayerInfo({
    JsonTable.id
  }, false, function(PlayerInfoList)
    for i, v in ipairs(PlayerInfoList) do
      ShowWaveWindow(15024, {
        v.playerInfo.nickname
      })
    end
  end)
  LogicTeam.RequestGetMyTeamDataToServer()
end

function LogicTeam.BindOnSomeOneLeaveTeam(Json)
  local JsonTable = RapidJson.decode(Json)
  print("LogicTeam.BindOnSomeOneLeaveTeam\230\156\137\231\142\169\229\174\182\231\166\187\229\188\128\228\186\134\233\152\159\228\188\141", JsonTable.id)
  LogicTeam.RequestGetMyTeamDataToServer()
end

function LogicTeam.BindOnAllocateBattleServerFail(Json)
  local JsonTable = RapidJson.decode(Json)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBErrorCode, JsonTable.errcode)
  if Result then
    ShowWaveWindowWithConsoleCheck(100001, {
      RowInfo.Tips
    }, JsonTable.errcode)
  end
  LogicTeam.RequestGetMyTeamDataToServer()
end

function LogicTeam.BindOnInviteJoinTeam(Json)
  print("BindOnInviteJoinTeam", Json)
  local JsonTable = RapidJson.decode(Json)
  local SingleInviteInfo = {
    InviterId = JsonTable.id,
    TeamId = JsonTable.teamId,
    IsApply = false,
    InviteJoinTeamInfo = JsonTable
  }
  local ChannelUID
  local ChannelInfo = DataMgr.GetChannelUserInfo(JsonTable.id, ChannelUID)
  if UE.URGBlueprintLibrary.IsPlatformConsole() then
    if not ChannelInfo.ChannelUserId then
      local OnQueryPlayerInfo = function(PlayerInfoList)
        LogicTeam:BindOnInviteJoinTeam(Json)
      end
      DataMgr.GetOrQueryPlayerInfo({
        JsonTable.id
      }, false, OnQueryPlayerInfo)
      return
    else
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local PrivacySubSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserPrivacySubsystem:StaticClass())
      if PrivacySubSystem and not PrivacySubSystem:IsPartyInviteAllowed(ChannelInfo.ChannelUserId, PrivacySubSystem:GetNetIDStr()) then
        return
      end
    end
  end
  if LogicTeam.CurTeamState == LogicTeam.TeamState.Idle or LogicTeam.CurTeamState == LogicTeam.TeamState.None then
    table.insert(LogicTeam.TeamInviteList, SingleInviteInfo)
    if not UIMgr:IsShow(ViewID.UI_InviteTeamTip) then
      LogicTeam.ShowTeamInviteTipWindow()
    end
  end
end

function LogicTeam.ShowTeamInviteTipWindow()
  local CurShowInfo = LogicTeam.TeamInviteList[1]
  if not CurShowInfo then
    local UIInstance = UIMgr:GetLuaFromActiveView(ViewID.UI_InviteTeamTip)
    if UIInstance then
      UIInstance:PlayOutAnimation()
    end
    return
  end
  if CurShowInfo then
    local StartIngoreTime = LogicTeam.IngoreTeamInviteList[CurShowInfo.InviterId]
    if StartIngoreTime and UE.URGStatisticsLibrary.GetTimestamp(true) - StartIngoreTime < LogicTeam.IngoreDuration then
      print("LogicTeam.ShowTeamInviteTipWindow \229\183\178\229\191\189\231\149\165")
      LogicTeam.ShowNextTeamInviteTipWindow()
      return
    end
  end
  if GetCurSceneStatus() == UE.ESceneStatus.ESettlement then
    LogicTeam.ShowNextTeamInviteTipWindow()
    return
  end
  LogicLobby.RequestGetRoleListInfoToServer({
    CurShowInfo.InviterId
  }, {
    GameInstance,
    function(Target, PlayerListTable)
      for i, SinglePlayerInfo in ipairs(PlayerListTable) do
        CurShowInfo.PlayerInfo = SinglePlayerInfo
      end
      local InviteTeamTip = UIMgr:Show(ViewID.UI_InviteTeamTip)
      if InviteTeamTip then
        InviteTeamTip:RefreshInfo(CurShowInfo)
      end
    end
  })
end

function LogicTeam.ShowNextTeamInviteTipWindow()
  table.remove(LogicTeam.TeamInviteList, 1)
  local NextTeamInviteInfo = LogicTeam.TeamInviteList[1]
  if NextTeamInviteInfo then
    local StartIngoreTime = LogicTeam.IngoreTeamInviteList[NextTeamInviteInfo.InviterId]
    if StartIngoreTime and UE.URGStatisticsLibrary.GetTimestamp(true) - StartIngoreTime < LogicTeam.IngoreDuration then
      LogicTeam.ShowNextTeamInviteTipWindow()
      return
    end
  end
  LogicTeam.ShowTeamInviteTipWindow()
end

function LogicTeam.BindOnApplyJoinTeam(Json)
  print("BindOnApplyJoinTeam", Json)
  local JsonTable = RapidJson.decode(Json)
  JsonTable.floor = LogicTeam.GetFloor()
  JsonTable.world = LogicTeam.GetWorldId()
  JsonTable.gameMode = LogicTeam.GetModeId()
  local SingleInviteInfo = {
    InviterId = JsonTable.id,
    TeamId = JsonTable.teamId,
    IsApply = true,
    InviteJoinTeamInfo = JsonTable
  }
  local curState = LogicTeam.CurTeamState
  if curState == LogicTeam.TeamState.Idle or curState == LogicTeam.TeamState.None or curState == LogicTeam.TeamState.Recruiting then
    table.insert(LogicTeam.TeamInviteList, SingleInviteInfo)
    if not UIMgr:IsShow(ViewID.UI_InviteTeamTip) then
      LogicTeam.ShowTeamInviteTipWindow()
    end
  end
end

function LogicTeam.ClearSession()
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    return
  end
  local RGPlayerSessionSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlayerSessionSubsystem:StaticClass())
  if RGPlayerSessionSubsystem then
    RGPlayerSessionSubsystem:Clear()
  end
end

function LogicTeam.DoJoinSession()
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    return
  end
  local RGPlayerSessionSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlayerSessionSubsystem:StaticClass())
  if RGPlayerSessionSubsystem then
    RGPlayerSessionSubsystem:DoJoinSession()
  end
end

function LogicTeam.BindOnRefuseJoinFriendTeam(Json)
  print("BindOnRefuseJoinFriendTeam", Json)
  ShowWaveWindow(15025, {})
end

function LogicTeam.BindOnRefuseFriendJoinTeam(Json)
  print("BindOnRefuseFriendJoinTeam", Json)
  ShowWaveWindow(15025, {})
end

function LogicTeam.BindOnAgreeJoinTeam(Json)
  print("BindOnAgreeJoinTeam", Json)
  local JsonTable = RapidJson.decode(Json)
  LogicTeam.RequestJoinTeamToServer(JsonTable.teamId, JsonTable.joinway)
end

function LogicTeam.BindOnChangeTeamCaptain(Json)
  print("BindOnChangeTeamCaptain", Json)
  local JsonTable = RapidJson.decode(Json)
  DataMgr.GetOrQueryPlayerInfo({
    JsonTable.id
  }, false, function(PlayerInfoList)
    local SinglePlayerInfo = PlayerInfoList[1]
    if SinglePlayerInfo then
      ShowWaveWindow(15017, {
        SinglePlayerInfo.playerInfo.nickname
      })
    end
  end)
  LogicTeam.RequestGetMyTeamDataToServer()
end

function LogicTeam.BindOnPickHeroDone()
  print("LogicTeam.BindOnPickHeroDone")
  LogicTeam.RequestGetMyTeamDataToServer()
end

function LogicTeam.InitDefaultId()
  local LobbySettings = UE.URGLobbySettings.GetSettings()
  LogicTeam.DefaultWorldId = LobbySettings.InitWorldId
  LogicTeam.DefaultSeasonWorldId = LobbySettings.InitSeasonWorldId
end

function LogicTeam.InitGameModeInfo(...)
  local Result, GameModeInfo = false
  local LobbySaveGame = LogicLobby.GetLobbySaveGame()
  if LobbySaveGame then
    local SeasonModule = ModuleManager:Get("SeasonModule")
    local IsNormalMode = SeasonModule and (not SeasonModule:CheckIsInSeasonMode() or SeasonModule:CheckIsInFirstSeason())
    Result, GameModeInfo = LobbySaveGame:GetGameModeInfoByUserId(DataMgr.GetUserId(), IsNormalMode, nil)
  end
  print("LogicTeam.InitGameModeInfo", Result, GameModeInfo)
  print("LogicTeam.InitGameModeInfo1", LogicTeam.SingleWorldId, LogicTeam.SingleModeId, LogicTeam.SingleFloor)
  LogicTeam.SingleWorldId = Result and GameModeInfo.WorldId or LogicTeam.GetCurSeasonModeDefaultWorldId()
  LogicTeam.SingleModeId = Result and GameModeInfo.ModeId or GetCurNormalMode()
  LogicTeam.SingleFloor = Result and GameModeInfo.Floor or 1
  LogicTeam.RequestSetTeamDataToServer(LogicTeam.SingleWorldId, LogicTeam.SingleModeId, LogicTeam.SingleFloor)
end

function LogicTeam.GetCurSeasonModeDefaultWorldId()
  local seasonModule = ModuleManager:Get("SeasonModule")
  if seasonModule then
    if seasonModule:CheckIsInSeasonMode() and not seasonModule:CheckIsInFirstSeason() then
      return LogicTeam.DefaultSeasonWorldId
    else
      return LogicTeam.DefaultWorldId
    end
  else
    return LogicTeam.DefaultWorldId
  end
end

function LogicTeam.BindOnGetFinishedGuideList()
  LogicTeam.RefreshTeamWorldId()
end

function LogicTeam.RefreshTeamWorldId()
  local ModeId = LogicTeam.GetModeId()
  if BeginnerGuideData:CheckFreshmanBDIsFinished() then
    if ModeId == TableEnums.ENUMGameMode.BEGINERGUIDANCE then
      print("LogicTeam.RefreshTeamWorldId", ModeId)
      local LobbySettings = UE.URGLobbySettings.GetSettings()
      local WorldId = LobbySettings.InitWorldId
      LogicTeam.RequestSetTeamDataToServer(WorldId, TableEnums.ENUMGameMode.NORMAL, 1)
      LogicTeam.SetIsDefaultNeedMatchTeammate(true)
    end
  elseif LogicLobby.NeedRefreshModeToBD then
    local WorldId = LogicTeam.GetWorldId()
    local BeginnerWorldId = 42
    if WorldId ~= BeginnerWorldId or ModeId ~= TableEnums.ENUMGameMode.BEGINERGUIDANCE then
      local Result, RowInfo = GetRowData(DT.DT_GameMode, BeginnerWorldId)
      if Result and RowInfo.bCanSelected then
        LogicTeam.RequestSetTeamDataToServer(BeginnerWorldId, TableEnums.ENUMGameMode.BEGINERGUIDANCE, 1)
      end
    end
    LogicLobby.NeedRefreshModeToBD = false
  end
end

function LogicTeam.AddIngoreTeamInviteList(RoleId)
  LogicTeam.IngoreTeamInviteList[RoleId] = UE.URGStatisticsLibrary.GetTimestamp(true)
end

function LogicTeam.GetEndPrepareTime()
  return LogicTeam.EndPrepareTime
end

function LogicTeam.SetSingleFloor(InFloor)
  LogicTeam.SingleFloor = InFloor
end

function LogicTeam.GetFloor()
  return DataMgr.IsInTeam() and DataMgr.GetTeamInfo().floor or LogicTeam.SingleFloor
end

function LogicTeam.SetSingleWorldId(InWorldId)
  LogicTeam.SingleWorldId = InWorldId
end

function LogicTeam.GetWorldId()
  return DataMgr.IsInTeam() and DataMgr.GetTeamInfo().worldID or LogicTeam.SingleWorldId
end

function LogicTeam.SetSingleModeId(InModeId)
  LogicTeam.SingleModeId = InModeId
end

function LogicTeam.GetModeId()
  return DataMgr.IsInTeam() and DataMgr.GetTeamInfo().gameMode or LogicTeam.SingleModeId
end

function LogicTeam.IsCaptain()
  local TeamInfo = DataMgr.GetTeamInfo()
  local UserId = DataMgr.GetUserId()
  if DataMgr.IsInTeam() then
    return TeamInfo.captain == UserId
  else
    return true
  end
end

function LogicTeam.IsFullTeam()
  local TeamInfo = DataMgr.GetTeamInfo()
  return TeamInfo.players and 3 == table.count(TeamInfo.players) or false
end

function LogicTeam.GetVoiceMemberIdByRoleId(RoleIdParam)
  local RoleId = tostring(RoleIdParam)
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      local MemberAry = UE.TArray(UE.FRoomMembers)
      local Num = GVoice:GetRoomMembers(MemberAry, 3)
      for i, v in iterator(MemberAry) do
        if v.OpenId == RoleId then
          return v.MemberId
        end
      end
    end
  end
  return -1
end

function LogicTeam.CheckIsOwnerVoiceRoom(RoomName)
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      return GVoice:GetCurrentTeamRoomName() == RoomName
    end
  end
  return false
end

function LogicTeam.IsMuteVoice(RoleId)
  local MemberId = LogicTeam.GetVoiceMemberIdByRoleId(RoleId)
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys and MemberId > 0 then
    return TeamVoiceSubSys:CheckMemberIsMute(MemberId)
  end
  return false
end

function LogicTeam.IsTeammate(RoleId)
  if not DataMgr.IsInTeam() then
    return false
  end
  local TeamInfo = DataMgr.GetTeamInfo()
  if not TeamInfo or not TeamInfo.players then
    return false
  end
  for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
    if SinglePlayerInfo.id == RoleId then
      return true
    end
  end
  return false
end

function LogicTeam.GetModeDifficultDisplayText(ModeId, Floor, WorldId)
  ModeId = ModeId or LogicTeam.GetModeId()
  Floor = Floor or LogicTeam.GetFloor()
  WorldId = WorldId or LogicTeam.GetWorldId()
  local LobbySettings = UE.URGLobbySettings.GetLobbySettings()
  local TargetFloorDisplayText = LobbySettings.ModeDifficultLevelDisplayTextList:Find(tonumber(ModeId))
  if not TargetFloorDisplayText then
    TargetFloorDisplayText = Floor
  else
    TargetFloorDisplayText = UE.FTextFormat(TargetFloorDisplayText, Floor)
  end
  if ModeId == TableEnums.ENUMGameMode.BOSSRUSH or ModeId == TableEnums.ENUMGameMode.SURVIVAL then
    local TBGameFloor = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
    if TBGameFloor then
      for LevelId, LevelInfo in pairs(TBGameFloor) do
        if LevelInfo.gameWorldID == WorldId and LevelInfo.gameMode == ModeId and LevelInfo.floor == Floor then
          TargetFloorDisplayText = LevelInfo.Name
        end
      end
    end
  end
  return TargetFloorDisplayText
end

function LogicTeam.AddTeamStateChangeFailRecord()
  local CurTimestamp = GetCurrentUTCTimestamp()
  table.insert(LogicTeam.TeamStateChangeFailRecord, CurTimestamp)
  local Count = 0
  for i, SingleTimestamp in ipairs(LogicTeam.TeamStateChangeFailRecord) do
    if SingleTimestamp >= CurTimestamp - LobbyInfoConfig.TeamStateChangeFailDuration then
      Count = Count + 1
    end
  end
  if Count >= LobbyInfoConfig.TeamStateChangeFailCount then
    ShowWaveWindowWithDelegate(303019, {}, function()
      Loginhandler.RequestLogoutToServer()
    end)
  end
end

function LogicTeam.GetTeamTicketNum(FilterSelf)
  local TicketNum = 0
  for i, v in ipairs(DataMgr.MyTeamInfo.players) do
    if FilterSelf and v.id == DataMgr.GetUserId() then
    else
      TicketNum = TicketNum + v.ticket
    end
  end
  return TicketNum
end

function LogicTeam.GetMemberTicketNum(RoleId)
  for i, v in ipairs(DataMgr.MyTeamInfo.players) do
    if v.id == RoleId then
      return v.ticket
    end
  end
  return 0
end

function LogicTeam.GetRegion()
  print("LogicTeam", LogicTeam.Region)
  return LogicTeam.Region
end

function LogicTeam.GetLevelIsInitUnLock(LevelId, WorldId, Difficulty)
  if LevelId then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, LevelId)
    if Result then
      return RowInfo.initUnlock
    end
  else
    local RowList = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
    local difficulty = 1
    if Difficulty then
      difficulty = Difficulty
    end
    for i, v in pairs(RowList) do
      if WorldId == v.gameWorldID and difficulty == v.floor then
        return v.initUnlock
      end
    end
  end
end

function LogicTeam.GetMemberHeroEffectState(roleid, SkinId)
  local TeamMember = DataMgr.GetTeamInfo()
  for i, v in ipairs(TeamMember.players) do
    if tostring(roleid) == v.id then
      local AttachId = SkinId
      local result, rowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, GetTbSkinRowNameBySkinID(SkinId))
      if result and 0 ~= rowInfo.ParentSkinId then
        AttachId = rowInfo.ParentSkinId
      end
      return 1 == v.hero.specialEffectState[tostring(AttachId)]
    end
  end
end

function LogicTeam.SetRegion(Region, bFormServer)
  local RGAccountSubsystem = UE.URGAccountSubsystem.Get()
  if RGAccountSubsystem then
    RGAccountSubsystem:SetBattleRegion(Region)
  end
  if LogicTeam.Region == Region then
    return
  end
  print("LogicTeam.SetRegion", Region, DataMgr.GetTeamInfo().state)
  if DataMgr.IsInTeam() and DataMgr.GetTeamInfo().state >= LogicTeam.TeamState.Matching then
    print("\229\140\185\233\133\141\228\184\173 \230\151\160\230\179\149\230\155\180\230\148\185\229\140\186\229\159\159")
    EventSystem.Invoke(EventDef.Lobby.UpdateMyTeamInfo)
    return
  end
  LogicTeam.Region = Region
  EventSystem.Invoke(EventDef.Lobby.UpdateRegionPing)
  if not bFormServer then
    LogicTeam.RequestSetTeamDataToServer(LogicTeam.GetWorldId(), LogicTeam.GetModeId(), LogicTeam.GetFloor())
  end
end

function LogicTeam.SetRegionPingValue(Region, Ping)
  if LogicTeam.RegionPing == nil then
    LogicTeam.RegionPing = {}
  end
  LogicTeam.RegionPing[Region] = Ping
  EventSystem.Invoke(EventDef.Lobby.UpdateRegionPing)
end

function LogicTeam.GetRegionPingValue(Region)
  if LogicTeam.RegionPing == nil then
    LogicTeam.RegionPing = {}
    return -1
  end
  if LogicTeam.RegionPing[Region] ~= nil then
    return LogicTeam.RegionPing[Region]
  else
    return -1
  end
end

function LogicTeam.UpdateRegionPing()
  local ServerId = LoginData:GetLobbyServerId()
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    function()
      local RowInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBBattleServerList)
      for key, value in pairs(RowInfo) do
        for i, v in ipairs(value.serverlist) do
          if tonumber(v) == tonumber(ServerId) then
            local UDPPingProxy = UE.URGUDPPingProxy.CreateUdpPing(GameInstance, value.address, value.port)
            UDPPingProxy.OnComplete:Add(GameInstance, function(TargetActor, LatencyMs, bSuccess)
              LogicTeam.SetRegionPingValue(key, LatencyMs)
            end)
            break
          end
        end
      end
    end
  }, 60, true, 0)
  local RowInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBBattleServerList)
  local Latency = 0
  for key, value in pairs(RowInfo) do
    for i, v in ipairs(value.serverlist) do
      if tonumber(v) == tonumber(ServerId) then
        local UDPPingProxy = UE.URGUDPPingProxy.CreateUdpPing(GameInstance, value.address, value.port)
        UDPPingProxy.OnComplete:Add(GameInstance, function(TargetActor, LatencyMs, bSuccess)
          LogicTeam.SetRegionPingValue(key, LatencyMs)
          if bSuccess then
            if 0 == Latency then
              Latency = LatencyMs
              LogicTeam.SetRegion(key)
            elseif LatencyMs <= Latency and bSuccess then
              Latency = LatencyMs
              LogicTeam.SetRegion(key)
            end
          end
        end)
        break
      end
    end
  end
end

function LogicTeam.RegionPingRefresh()
  local ServerId = LoginData:GetLobbyServerId()
  local RowInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBBattleServerList)
  local Latency = 0
  for key, value in pairs(RowInfo) do
    for i, v in ipairs(value.serverlist) do
      if tonumber(v) == tonumber(ServerId) then
        local UDPPingProxy = UE.URGUDPPingProxy.CreateUdpPing(GameInstance, value.address, value.port)
        UDPPingProxy.OnComplete:Add(GameInstance, function(TargetActor, LatencyMs, bSuccess)
          LogicTeam.SetRegionPingValue(key, LatencyMs)
        end)
        break
      end
    end
  end
end

function LogicTeam.GetTeamMemberIdList()
  local IdList = {}
  if DataMgr.IsInTeam() then
    local TeamInfo = DataMgr.GetTeamInfo()
    for i, Player in ipairs(TeamInfo.players) do
      table.insert(IdList, Player.id)
    end
  else
    IdList = {
      DataMgr.GetUserId()
    }
  end
  return IdList
end

function LogicTeam.Clear()
  LogicTeam.IsInit = false
  LogicTeam.TeamInviteList = {}
  LogicTeam.IngoreTeamInviteList = {}
  LogicTeam.InvitedList = {}
  LogicTeam.TeamStateChangeFailRecord = {}
  EventSystem.RemoveListener(EventDef.WSMessage.TeamUpdate, LogicTeam.BindOnTeamUpdate)
  EventSystem.RemoveListener(EventDef.WSMessage.TeamKickOut, LogicTeam.BindOnTeamKickOut)
  EventSystem.RemoveListener(EventDef.WSMessage.PlayStartGameAnimation, LogicTeam.BindOnPlayStartGameAnimation)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, LogicTeam.BindOnUpdateVoiceTeam)
  EventSystem.RemoveListener(EventDef.Lobby.OnTeamStateChanged, LogicTeam.BindOnTeamStateChanged)
  EventSystem.RemoveListener(EventDef.WSMessage.CancelPrepare, LogicTeam.BindOnCancelPrepare)
  EventSystem.RemoveListener(EventDef.WSMessage.StopMatch, LogicTeam.BindOnStopMatch)
  EventSystem.RemoveListener(EventDef.WSMessage.LeaveTeam, LogicTeam.BindOnSomeOneLeaveTeam)
  EventSystem.RemoveListener(EventDef.WSMessage.AllocateBattleServerFail, LogicTeam.BindOnAllocateBattleServerFail)
  EventSystem.RemoveListener(EventDef.WSMessage.InviteJoinTeam, LogicTeam.BindOnInviteJoinTeam)
  EventSystem.RemoveListener(EventDef.WSMessage.ApplyJoinTeam, LogicTeam.BindOnApplyJoinTeam)
  EventSystem.RemoveListener(EventDef.WSMessage.RefuseFriendJoinTeam, LogicTeam.BindOnRefuseFriendJoinTeam)
  EventSystem.RemoveListener(EventDef.WSMessage.RefuseJoinFriendTeam, LogicTeam.BindOnRefuseJoinFriendTeam)
  EventSystem.RemoveListener(EventDef.WSMessage.AgreeJoinTeam, LogicTeam.BindOnAgreeJoinTeam)
  EventSystem.RemoveListener(EventDef.WSMessage.ChangeTeamCaptain, LogicTeam.BindOnChangeTeamCaptain)
  EventSystem.RemoveListener(EventDef.WSMessage.PickHeroDone, LogicTeam.BindOnPickHeroDone)
  EventSystem.RemoveListener(EventDef.BeginnerGuide.OnGetFinishedGuideList, LogicTeam.BindOnGetFinishedGuideList)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(LogicTeam.RecoverTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, LogicTeam.RecoverTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(LogicTeam.CountTimeTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, LogicTeam.CountTimeTimer)
  end
end
