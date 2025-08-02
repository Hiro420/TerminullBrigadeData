require("Rouge.UI.Lobby.Logic.Logic_Team")
local rapidjson = require("rapidjson")
local LoginHandler = require("Protocol.LoginHandler")
local LoginData = require("Modules.Login.LoginData")
local BeginnerGuideHandler = require("Protocol.BeginnerGuide.BeginnerGuideHandler")
local URGHttpHelper = UE.URGHttpHelper
local WBP_AutoProcessPanel_C = UnLua.Class()
local GetRobotVersionID = function()
  return GetVersionID()
end

function WBP_AutoProcessPanel_C:Construct()
  print("WBP_AutoProcessPanel_C Construct")
  EventSystem.AddListener(self, EventDef.WSMessage.ConnectWSSuccess, WBP_AutoProcessPanel_C.BindOnWSConnSucc)
  EventSystem.AddListener(self, EventDef.WSMessage.ConnectBattleServer, WBP_AutoProcessPanel_C.BindOnConnectBattleServer)
  EventSystem.AddListener(self, EventDef.WSMessage.TeamUpdate, WBP_AutoProcessPanel_C.BindOnTeamUpdate)
  EventSystem.AddListener(self, EventDef.WSMessage.PlayStartGameAnimation, self.BindOnReceiveStartGame)
  EventSystem.AddListener(self, EventDef.WSMessage.ChatMsg, self.BindOnReceiveNewMsg)
  EventSystem.AddListener(self, EventDef.Login.OnLoginProtocolSuccess, self.BindOnLoginProtocolSuccess)
  self.FindGITimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_AutoProcessPanel_C.StartLogin
  }, 0.1, true)
  self.IsSendStartGame = false
  self:StartLogin()
  self.MsgSenderRoleInfoList = {}
end

function WBP_AutoProcessPanel_C:BindOnWSConnSucc(Json)
  print("Auto BindOnWSConnSucc")
  LogicAutoRobot.IsLogin = true
  self:StartLobby()
end

function WBP_AutoProcessPanel_C:BindOnConnectBattleServer(Json)
  print("WBP_AutoProcessPanel_C:BindOnConnectBattleServer", Json)
  local JsonTable = rapidjson.decode(Json)
  if JsonTable.method == EventDef.WSMessage.ConnectBattleServer then
    local DSInfo = {
      Id = "",
      publicIp = JsonTable.ip,
      innerIp = JsonTable.ip,
      tcpPort = JsonTable.tcpPort,
      udpPort = JsonTable.udpPort,
      name = JsonTable.name
    }
    UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType("LobbyToBattle")
    DataMgr.SetDSInfo(DSInfo)
    local LevelName = DSInfo.publicIp .. ":" .. DSInfo.udpPort
    local DSCheckVersion = GetVersionID()
    local Options = "Version=" .. DSCheckVersion .. "?" .. "UserId=" .. DataMgr.GetUserId()
    print("LevelName" .. LevelName, "Options", Options)
    if DSInfo.publicIp == "127.0.0.1" then
      LogicLobby.PlayInStandalone(Options)
    else
      LogicLobby.OpenLevelByName(LevelName, Options)
    end
  end
end

function WBP_AutoProcessPanel_C:BindOnTeamUpdate()
  self:GetMyTeamInfo()
end

function WBP_AutoProcessPanel_C:BindOnReceiveStartGame()
  print("BindOnReceiveStartGame")
  self.IsReceiveWSStartGame = true
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.StartGameTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.StartGameTimer)
  end
  if not DataMgr.IsInTeam() then
    return
  end
  self:RequestJoinGame()
  print("BindOnReceiveStartGame \229\143\145\233\128\129JoinGame")
end

function WBP_AutoProcessPanel_C:BindOnReceiveNewMsg(ChatContentData)
  print("BindOnReceiveNewMsg", ChatContentData)
  if LogicAutoRobot.GetIsTeamCaptain() then
    return
  end
  if DataMgr.IsInTeam() then
    print("WBP_AutoProcessPanel_C:BindOnReceiveNewMsg \229\183\178\229\156\168\233\152\159\228\188\141\228\184\173")
    return
  end
  if self.IsRequestJoinTeam then
    print("WBP_AutoProcessPanel_C:BindOnReceiveNewMsg \229\183\178\231\187\143\229\143\145\233\128\129\232\191\135\229\133\165\233\152\159\231\148\179\232\175\183\228\186\134")
    return
  end
  local JsonTable = rapidjson.decode(ChatContentData)
  local TargetPlayerInfo = self.MsgSenderRoleInfoList[JsonTable.sender]
  if not TargetPlayerInfo then
    print("WBP_AutoProcessPanel_C:BindOnReceiveNewMsg \230\178\161\230\137\190\229\136\176\229\143\145\233\128\129\232\128\133\231\154\132\228\184\170\228\186\186\228\191\161\230\129\175", JsonTable.sender)
    HttpCommunication.Request("playerservice/roles", {
      idList = {
        JsonTable.sender
      }
    }, {
      self,
      function(self, JsonResponse)
        print("MsgSenderOnGetRoleSuccess", JsonResponse.Content, JsonResponse)
        local Response = rapidjson.decode(JsonResponse.Content)
        local TargetId = 0
        for index, SinglePlayerInfo in ipairs(Response.players) do
          self.MsgSenderRoleInfoList[SinglePlayerInfo.roleid] = SinglePlayerInfo
          TargetId = SinglePlayerInfo.roleid
        end
        self:DealWithChatContent(TargetId, JsonTable.msg)
      end
    }, {
      self,
      function()
        print("MsgSenderOnGetRoleFail", JsonTable.sender)
      end
    })
    return
  end
  self:DealWithChatContent(JsonTable.sender, JsonTable.msg)
end

function WBP_AutoProcessPanel_C:BindOnLoginProtocolSuccess()
  BeginnerGuideHandler.RequestFinishGuideToServer(301)
  HttpCommunication.Request("playerservice/nickname", {
    val = self.UserName
  }, {
    self,
    function()
      print("\230\148\185\229\144\141\230\136\144\229\138\159")
      HttpCommunication.Request("playerservice/roles", {
        idList = {
          DataMgr.GetUserId()
        }
      }, {
        self,
        self.OnGetRoleSuccess
      }, {
        self,
        function()
        end
      })
    end
  }, {
    self,
    function()
      print("\230\148\185\229\144\141\229\164\177\232\180\165")
    end
  })
  self:ConnectWSGate()
end

function WBP_AutoProcessPanel_C:DealWithChatContent(Id, ChatMsg)
  local TargetPlayerInfo = self.MsgSenderRoleInfoList[Id]
  if not string.sub(TargetPlayerInfo.nickname, 1, #LogicAutoRobot.GetBotNamePrefix()) == LogicAutoRobot.GetBotNamePrefix() then
    print("DealWithChatContent \229\144\141\229\173\151\229\137\141\231\188\128\228\184\142\230\156\186\229\153\168\228\186\186\229\144\141\229\173\151\229\137\141\231\188\128\228\184\141\231\172\166", LogicAutoRobot.GetBotNamePrefix(), TargetPlayerInfo.nickname)
    return
  end
  self:JoinTeam(ChatMsg)
end

function WBP_AutoProcessPanel_C:RequestJoinGame()
  local TeamInfo = DataMgr.GetTeamInfo()
  HttpCommunication.Request("team/joingame", {
    teamid = TeamInfo.teamid
  }, {
    GameInstance,
    function()
      print("JoinGameSuccess")
    end
  }, {
    GameInstance,
    function()
      print("JoinGameFail")
    end
  })
end

function WBP_AutoProcessPanel_C:StartLogin()
  if not GameInstance then
    return
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.FindGITimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.FindGITimer)
  end
  if LogicAutoRobot.IsLogin then
    print("WBP_AutoProcessPanel_C\229\183\178\231\187\143\229\164\132\228\186\142\231\153\187\229\189\149\228\184\173")
    self:JudgeCanChangeMode()
    self:StartLobby()
    return
  end
  self.Txt_Step:SetText("\231\153\187\229\189\149")
  self.UserName = LogicAutoRobot.BotNamePrefix
  local GUID = UE.UKismetGuidLibrary.NewGuid()
  local BotFixedName = LogicAutoRobot.GetBotFixedName()
  if UE.UKismetStringLibrary.IsEmpty(BotFixedName) then
    self.UserName = self.UserName .. UE.UKismetGuidLibrary.Conv_GuidToString(GUID)
  else
    self.UserName = BotFixedName
  end
  UE.URGGameplayLibrary.TriggerOnClientLoginSuccess(GameInstance, "Wooduan", self.UserName, "")
  self:Login()
end

function WBP_AutoProcessPanel_C:JudgeCanChangeMode()
  LogicAutoRobot.AddModeIndex()
  local TargetModeId = LogicAutoRobot.GetTargetGameMode()
  if not TargetModeId then
    self.Txt_CloseTip:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    print("\230\168\161\229\188\143\229\136\151\232\161\168\229\190\170\231\142\175\231\187\147\230\157\159\239\188\140\229\141\179\229\176\134\229\133\179\233\151\173\230\184\184\230\136\143")
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        UE.UKismetSystemLibrary.QuitGame(self, UE.UGameplayStatics.GetPlayerController(self, 0), UE.EQuitPreference.Quit, false)
      end
    }, 2, false)
    return
  end
  if LogicAutoRobot.GetIsTeamCaptain() then
    self.IsNeedChangeTeamData = true
    self:GetMyTeamInfo()
  end
end

function WBP_AutoProcessPanel_C:Login()
  local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, HttpCommunication.GetHttpServiceClass())
  if not HttpService then
    return
  end
  local DeviceInfo = UE.URGLogLibrary.FormatLoginDeviceInfo(self:GetWorld())
  local ServerListPath = "http://serverlist.infrastructure.wooduan.com/serverlist/api/server/list?project=rouge&serverlistname="
  local ServerListLabel = LoginData:GetServerListLabel()
  ServerListLabel = ServerListLabel or "dev"
  ServerListPath = ServerListPath .. ServerListLabel
  URGHttpHelper.LuaRequestByGetWithFullPath(ServerListPath, function(Content, bSuccess)
    if not bSuccess then
      UnLua.LogError("WBP_AutoProcessPanel_C:Login failed.")
      return
    end
    print("WBP_AutoProcessPanel_C:Login.SendServerListReq:", Content)
    local JsonTable = rapidjson.decode(Content)
    if not JsonTable or 0 ~= JsonTable.errCode then
      print("WBP_AutoProcessPanel_C:ConnectWSGate\230\139\137\229\143\150\230\156\141\229\138\161\229\153\168\229\136\151\232\161\168\229\164\177\232\180\165")
      return
    end
    if not JsonTable.data or next(JsonTable.data) == nil then
      UnLua.LogError("WBP_AutoProcessPanel_C:Login.SendServerListReq: - data is nil.")
      return
    end
    for i, SingleServerInfo in ipairs(JsonTable.data) do
      HttpService:AddHttpServerList(SingleServerInfo.name, SingleServerInfo.ip, SingleServerInfo.port, SingleServerInfo.tls)
      if SingleServerInfo.code == "30001" then
        self.DevelopServerIp = SingleServerInfo.ip
        self.DevelopServerPort = SingleServerInfo.port
        self.IsTls = SingleServerInfo.tls
        LoginData:SaveLastSelectServeName(SingleServerInfo.name)
        break
      end
    end
    LoginHandler.RequestLoginDevToServer(self.UserName, DeviceInfo)
  end)
end

function WBP_AutoProcessPanel_C:ConnectWSGate()
  local GateService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.UWSGateService:StaticClass())
  GateService:Connect(self.DevelopServerIp, self.DevelopServerPort, HttpCommunication.GetToken(), self.IsTls)
end

function WBP_AutoProcessPanel_C:OnGetRoleSuccess(JsonResponse)
  print("OnGetRoleSuccess", JsonResponse.Content)
  local Response = rapidjson.decode(JsonResponse.Content)
  for i, SingleInfo in ipairs(Response.players) do
    if SingleInfo.roleid == DataMgr.GetUserId() then
      DataMgr.SetBasicInfo(SingleInfo)
    end
  end
end

function WBP_AutoProcessPanel_C:StartLobby()
  self.Txt_Step:SetText("\229\164\167\229\142\133")
  self:RefreshLogicStatus()
end

function WBP_AutoProcessPanel_C:CreateTeam()
  local TargetModeId = LogicAutoRobot.GetTargetGameMode()
  if not TargetModeId then
    self.Txt_CloseTip:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    print("\230\168\161\229\188\143\229\136\151\232\161\168\229\190\170\231\142\175\231\187\147\230\157\159\239\188\140\229\141\179\229\176\134\229\133\179\233\151\173\230\184\184\230\136\143")
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        UE.UKismetSystemLibrary.QuitGame(self, UE.UGameplayStatics.GetPlayerController(self, 0), UE.EQuitPreference.Quit, false)
      end
    }, 2, false)
    return
  end
  local Params = {
    worldID = TargetModeId,
    gameMode = 1001,
    floor = 1,
    branch = LogicLobby.GetBrunchType(),
    version = GetRobotVersionID()
  }
  HttpCommunication.Request("team/createteam", Params, {
    GameInstance,
    function(Target, JsonResponse)
      print("CreateTeam", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      local TeamInfo = {
        teamid = JsonTable.teamId,
        captain = DataMgr.GetUserId()
      }
      DataMgr.SetTeamInfo(TeamInfo)
      self:GetMyTeamInfo()
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function WBP_AutoProcessPanel_C:RefreshLogicStatus()
  HttpCommunication.Request("playerservice/roles", {
    idList = {
      DataMgr.GetUserId()
    }
  }, {
    self,
    function(self, JsonResponse)
      local Response = rapidjson.decode(JsonResponse.Content)
      for i, SingleInfo in ipairs(Response.players) do
        if SingleInfo.roleid == DataMgr.GetUserId() then
          DataMgr.SetBasicInfo(SingleInfo)
        end
      end
      local HeroPath = "hero/getmyheroinfo?type=0"
      HttpCommunication.RequestByGet(HeroPath, {
        self,
        function(self, JsonResponse)
          print("OnGetMyHeroInfoSuccess")
          local JsonTable = rapidjson.decode(JsonResponse.Content)
          DataMgr.SetMyHeroInfo(JsonTable)
          local MyHeroInfo = DataMgr.GetMyHeroInfo()
          if MyHeroInfo and MyHeroInfo.equipHero ~= LogicAutoRobot.GetBotHeroId() then
            HttpCommunication.Request("hero/equiphero", {
              heroId = LogicAutoRobot.GetBotHeroId()
            }, {
              self,
              function()
                print("OnEquipHeroSuccess", LogicAutoRobot.GetBotHeroId())
                local MyHeroInfo = {
                  equipHero = LogicAutoRobot.GetBotHeroId()
                }
                DataMgr.SetMyHeroInfo(MyHeroInfo)
              end
            }, {
              self,
              function()
                print("OnEquipHeroFail", LogicAutoRobot.GetBotHeroId())
              end
            })
          end
          self:DealWithTeam()
        end
      }, {
        GameInstance,
        function()
        end
      })
    end
  }, {
    self,
    function()
    end
  })
end

function WBP_AutoProcessPanel_C:DealWithTeam()
  self:GetMyTeamInfo()
end

function WBP_AutoProcessPanel_C:GetMyTeamInfo()
  print("WBP_AutoProcessPanel_C:GetMyTeamInfo")
  HttpCommunication.RequestByGet("team/getmyteamdata", {
    self,
    WBP_AutoProcessPanel_C.BindOnGetMyTeamDataSuccess
  }, {
    self,
    function()
    end
  })
end

function WBP_AutoProcessPanel_C:BindOnGetMyTeamDataSuccess(JsonResponse)
  print("GetMyTeamData", JsonResponse.Content)
  local TeamInfoTable = rapidjson.decode(JsonResponse.Content)
  if TeamInfoTable then
    DataMgr.SetTeamInfo(TeamInfoTable)
    self:RefreshTeamInfo()
  end
  if LogicAutoRobot.GetIsTeamCaptain() then
    if DataMgr.IsInTeam() then
      if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.SendTeamCodeMsgTimer) then
        self.SendTeamCodeMsgTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
          self,
          function()
            self:SendTeamCodeMsg()
          end
        }, 10.0, true, -10.0)
      end
      local TargetModeId = LogicAutoRobot.GetTargetGameMode()
      if self.IsNeedChangeTeamData then
        local TeamInfo = DataMgr.GetTeamInfo()
        local Params = {
          teamid = TeamInfo.teamid,
          worldID = tonumber(TargetModeId),
          gameMode = 1001,
          floor = 1
        }
        HttpCommunication.Request("team/setteamdata", Params, {
          self,
          function()
            print("SetTeamDataSuccess \229\136\135\230\141\162\230\168\161\229\188\143\230\136\144\229\138\159", TargetModeId)
            self.IsNeedChangeTeamData = false
          end
        }, {
          self,
          function()
            print("SetTeamDataFail")
          end
        })
      end
    else
      self:CreateTeam()
    end
  end
end

function WBP_AutoProcessPanel_C:SendTeamCodeMsg()
  local TeamInfo = DataMgr.GetTeamInfo()
  if 0 ~= TeamInfo.state then
    print("\233\152\159\228\188\141\231\138\182\230\128\129\228\184\141\229\164\132\228\186\142\231\169\186\233\151\178\228\184\173, \228\184\141\229\143\145\230\182\136\230\129\175")
    return
  end
  if table.count(TeamInfo.players) >= LogicAutoRobot.GetStartGameNum() then
    print("\233\152\159\228\188\141\228\186\186\230\149\176\229\183\178\230\187\161\239\188\140\228\184\141\229\143\145\230\182\136\230\129\175")
    return
  end
  local Param = {
    group = {},
    msg = TeamInfo.teamid,
    channelUID = DataMgr.ChannelUserIdWithPrefix,
    worldChatChannel = ChatDataMgr.ChatChannel or 0
  }
  HttpCommunication.Request("chatservice/message", Param, {
    self,
    function()
      print("Robot Send Message Success!")
    end
  }, {
    self,
    function()
      print("Robot Send Message Fail!")
    end
  })
end

function WBP_AutoProcessPanel_C:JoinTeam(TeamId)
  print("WBP_AutoProcessPanel_C:JoinTeam", TeamId)
  self.IsRequestJoinTeam = true
  local Param = {
    teamid = TeamId,
    branch = LogicLobby.GetBrunchType(),
    version = GetRobotVersionID()
  }
  HttpCommunication.Request("team/jointeam", Param, {
    GameInstance,
    function()
      self:GetMyTeamInfo()
      self.IsRequestJoinTeam = false
    end
  }, {
    GameInstance,
    function()
      self.IsRequestJoinTeam = false
    end
  })
end

function WBP_AutoProcessPanel_C:StartGame()
  print("WBP_AutoProcessPanel_C:StartGame", LogicAutoRobot.GetIsTeamCaptain())
  if self.IsSendStartGame then
    print("\229\183\178\231\187\143\229\143\145\233\128\129\232\191\135\229\188\128\229\167\139\230\184\184\230\136\143\228\186\134\239\188\129")
    return
  end
  self.IsSendStartGame = true
  local TeamInfo = DataMgr.GetTeamInfo()
  local DebugDSName = CmdLineMgr.FindParam("DebugDSName")
  if DebugDSName then
    print("LogicTeam.RequestStartGameToServer, DebugDSName: ", DebugDSName)
    HttpCommunication.Request("dbg/team/startgame", {
      teamid = TeamInfo.teamid,
      name = DebugDSName
    }, {
      nil,
      function()
        print("HttpCommunication.DbgStartMatch Succeeded.")
        self.IsReceiveWSStartGame = false
        self.StartGameTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
          self,
          function()
            if not self.IsReceiveWSStartGame then
              print("6s\229\134\133\230\178\161\230\148\182\229\136\176\229\188\128\229\167\139\230\184\184\230\136\143\231\154\132websocket\230\182\136\230\129\175\230\142\168\233\128\129")
              self.IsSendStartGame = false
            end
          end
        }, 6.0, false)
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
      version = LogicLobby.GetVersionID()
    }, {
      GameInstance,
      function()
        print("StartGameSuccess")
        self.IsReceiveWSStartGame = false
        self.StartGameTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
          self,
          function()
            if not self.IsReceiveWSStartGame then
              print("6s\229\134\133\230\178\161\230\148\182\229\136\176\229\188\128\229\167\139\230\184\184\230\136\143\231\154\132websocket\230\182\136\230\129\175\230\142\168\233\128\129")
              self.IsSendStartGame = false
            end
          end
        }, 6.0, false)
      end
    }, {
      GameInstance,
      function()
      end
    })
  end
end

function WBP_AutoProcessPanel_C:RefreshTeamInfo()
  local TeamInfo = DataMgr.GetTeamInfo()
  local TeamMemberCount = table.count(TeamInfo.players)
  if 0 == TeamInfo.state then
    self.Txt_Step:SetText(string.format("\233\152\159\228\188\141\228\184\173%s/%s", TeamMemberCount, LogicAutoRobot.GetStartGameNum()))
    if TeamMemberCount >= LogicAutoRobot.GetStartGameNum() then
      if self.IsNeedChangeTeamData then
        print("\233\156\128\232\166\129\231\173\137\229\190\133\228\191\174\230\148\185\233\152\159\228\188\141")
        return
      end
      if LogicAutoRobot.GetIsTeamCaptain() then
        print("Captain StartGame!")
        self:StartGame()
      end
    end
  elseif 3 == TeamInfo.state then
    self.Txt_Step:SetText("\233\128\137\232\167\146\228\184\173")
    local TeamInfo = DataMgr.GetTeamInfo()
    for index, SingleTeamMemberInfo in ipairs(TeamInfo.players) do
      if SingleTeamMemberInfo.id == DataMgr.GetUserId() and 1 ~= SingleTeamMemberInfo.pickDone then
        HttpCommunication.Request("team/pickherodone", {
          teamid = TeamInfo.teamid
        }, {
          GameInstance,
          function()
            print("WBP_AutoProcessPanel_C:RefreshTeamInfo PickHeroDone Succ!")
          end
        }, {
          GameInstance,
          function()
            print("WBP_AutoProcessPanel_C:RefreshTeamInfo PickHeroDone Fail!")
          end
        })
      end
    end
  end
end

function WBP_AutoProcessPanel_C:Destruct()
  print("WBP_AutoProcessPanel_C Destruct")
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.FindGITimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.FindGITimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.SendTeamCodeMsgTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.SendTeamCodeMsgTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.StartGameTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.StartGameTimer)
  end
  EventSystem.RemoveListener(EventDef.WSMessage.ConnectWSSuccess, WBP_AutoProcessPanel_C.BindOnWSConnSucc, self)
  EventSystem.RemoveListener(EventDef.WSMessage.ConnectBattleServer, WBP_AutoProcessPanel_C.BindOnConnectBattleServer, self)
  EventSystem.RemoveListener(EventDef.WSMessage.TeamUpdate, WBP_AutoProcessPanel_C.BindOnTeamUpdate, self)
  EventSystem.RemoveListener(EventDef.WSMessage.PlayStartGameAnimation, self.BindOnReceiveStartGame, self)
  EventSystem.RemoveListener(EventDef.WSMessage.ChatMsg, self.BindOnReceiveNewMsg, self)
  EventSystem.RemoveListener(EventDef.Login.OnLoginProtocolSuccess, self.BindOnLoginProtocolSuccess, self)
end

return WBP_AutoProcessPanel_C
