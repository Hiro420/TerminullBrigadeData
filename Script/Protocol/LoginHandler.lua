local URGHttpHelper = UE.URGHttpHelper
local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local LoginData = require("Modules.Login.LoginData")
local SeasonData = require("Modules.Season.SeasonData")
local SystemUnlockHandler = require("Protocol.SystemUnlock.SystemUnlockHandler")
local SaveGrowthSnapHandler = require("Protocol.SaveGrowthSnap.SaveGrowthSnapHandler")
local TopupData = require("Modules.Topup.TopupData")
local PayInfoConfig = require("GameConfig.PayInfoConfig")
local LoginHandler = {}
function IsShippingGameTitle()
  local VersionSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URGVersionSubsystem:StaticClass())
  if VersionSubsystem and string.find(string.lower(VersionSubsystem.Branch), "shipping") then
    return true
  end
  return false
end
function IsInBranch(branch)
  local VersionSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URGVersionSubsystem:StaticClass())
  if VersionSubsystem and CompareStringsIgnoreCase(VersionSubsystem.Branch, branch) then
    return true
  end
  return false
end
function GetDefaultServerListLabel()
  local VersionSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URGVersionSubsystem:StaticClass())
  if VersionSubsystem then
    if IsInBranch("trunk") or IsInBranch("weekly") then
      return "dev"
    end
    if (IsInBranch("shipping") or IsInBranch("intl")) and not IsShippingGameTitle() then
      return "test"
    end
    if IsInBranch("shipping") and IsShippingGameTitle() then
      return "shipping"
    end
    if IsInBranch("intl") and IsShippingGameTitle() then
      return "intl"
    end
  end
  return "dev"
end
function LoginHandler.SendServerListReq()
  LoginData:AddGetServerListCount()
  local url = "https://serverlist.infrastructure.wooduan.com/serverlist/api/server/list?project=rouge&serverlistname="
  local ServerListLabel = LoginData:GetServerListLabel()
  ServerListLabel = ServerListLabel or GetDefaultServerListLabel()
  url = url .. ServerListLabel
  URGHttpHelper.LuaRequestByGetWithFullPath(url, function(Content, bSuccess)
    if not bSuccess then
      UnLua.LogError("LoginHandler.SendServerListReq failed.")
      return
    end
    print("LoginFlow", "LoginHandler.SendServerListReq - \230\148\182\229\136\176\230\156\141\229\138\161\229\153\168\229\136\151\232\161\168\229\155\158\229\140\133\239\188\154", Content)
    local JsonTable = rapidjson.decode(Content)
    if not JsonTable or 0 ~= JsonTable.errCode then
      UnLua.LogError("LoginHandler \230\139\137\229\143\150\230\156\141\229\138\161\229\153\168\229\136\151\232\161\168\229\164\177\232\180\165:", JsonTable.errMsg)
      EventSystem.Invoke(EventDef.Login.GetServerListFailed)
      return
    end
    if not JsonTable.data or next(JsonTable.data) == nil then
      UnLua.LogError("LoginHandler.SendServerListReq: - data is nil.")
      EventSystem.Invoke(EventDef.Login.GetServerListFailed)
      return
    end
    EventSystem.Invoke(EventDef.Login.GetServerList, JsonTable.data)
  end)
end
function LoginHandler.RequestLoginDevToServer(UserName, DeviceInfo)
  HttpCommunication.Request("login/logindev", {uid = UserName, deviceInfo = DeviceInfo}, {
    GameInstance,
    LoginHandler.OnLoginSuccess
  }, {
    GameInstance,
    function()
      print("LoginHandler.RequestLoginDevToServer OnLoginFail!")
      EventSystem.Invoke(EventDef.Login.OnLoginProtocolFail)
    end
  })
end
function LoginHandler.RequestLoginWeGameToServer(Params)
  HttpCommunication.Request("login/loginwegame", Params, {
    GameInstance,
    LoginHandler.OnLoginSuccess
  }, {
    GameInstance,
    function()
      print("LoginHandler.RequestLoginWeGameToServer OnLoginFail!")
      EventSystem.Invoke(EventDef.Login.OnLoginProtocolFail)
    end
  })
end
function LoginHandler.RequestLoginLIPassToServer(Params)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
  if UserOnlineSubsystem then
    if UserOnlineSubsystem:CheckRequestLoginStatus() ~= true then
      print("LoginHandler.UserOnlineSubsystem - CheckRequestLoginStatus Failed")
      return
    end
  else
    print("UserOnlineSubsystem is nil")
  end
  local PrivacySubSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserPrivacySubsystem:StaticClass())
  if PrivacySubSystem then
    if PrivacySubSystem:K2_HasPrivilege(0) == false then
      print("LoginHandler.PrivacySubSystem - CanPlay Failed")
      return
    end
    if PrivacySubSystem:K2_HasPrivilege(1) == false then
      print("LoginHandler.PrivacySubSystem - CanPlayOnline Failed")
      return
    end
  else
    print("LoginHandler.PrivacySubSystem - Get PrivacySubSystem Failed")
  end
  HttpCommunication.Request("login/loginlipass", Params, {
    GameInstance,
    LoginHandler.OnLoginSuccess
  }, {
    GameInstance,
    function()
      print("LoginHandler.RequestLoginLIPassToServer OnLoginFail!")
      EventSystem.Invoke(EventDef.Login.OnLoginProtocolFail)
      if UserOnlineSubsystem then
        UserOnlineSubsystem:Logout()
      end
    end
  })
end
function LoginHandler.OnLoginSuccess(Target, JsonResponse)
  print("LoginFlow", "LoginHandler.OnLoginSuccess - \232\180\166\229\143\183\231\153\187\229\189\149\230\136\144\229\138\159")
  local response = rapidjson.decode(JsonResponse.Content)
  if not response then
    UnLua.LogError("LoginHandler.OnLoginSuccess - decode failed!!!")
    return
  end
  local RGAccountSubsystem = UE.URGAccountSubsystem.Get()
  if RGAccountSubsystem then
    RGAccountSubsystem:SetUserId(tonumber(response.roleId))
  else
    UnLua.LogError("LoginHandler.OnLoginSuccess - Get RGAccountSubsystem failed!!!")
  end
  HttpCommunication.SetToken(response.token)
  DataMgr.SetUserId(response.roleId)
  DataMgr.SetServerOpenTime(response.serverOpenTime)
  DataMgr.SetServerTimeDelta(tonumber(response.serverTime))
  DataMgr.SetServerTimeZone(response.serverTimeZone)
  SeasonData.CurSeasonID = response.seasonID
  LoginHandler.CheckNetBarState(response.roleId)
  if TopupData:IsExecuteINTLPayLogic() then
    local TargetIdcInfo = UE.URGBlueprintLibrary.IsSteamCNChannel() and PayInfoConfig.SteamCNIdcInfo or PayInfoConfig.INTLIdcInfo
    local RGAccountSubsystem = UE.URGAccountSubsystem.Get()
    local Region = ConvertISOCountryCodeToAlpha2Code(RGAccountSubsystem:GetRegion())
    UE.URGPlatformFunctionLibrary.InitCTIUserInfo(DataMgr.GetUserId(), LoginData:GetLobbyServerId(), TargetIdcInfo, Region)
    TopupData:InitTopupAge()
  end
  UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType("LoginToLobby")
  UE.URGGameplayLibrary.TriggerOnClientConnectToLobby(GameInstance, LoginData:GetLobbyServerId(), response.roleId, response.token)
  local RGProfilerSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGProfilerSubsystem:StaticClass())
  if RGProfilerSubsystem then
    RGProfilerSubsystem:SetUserId(DataMgr.GetUserId())
  end
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice and GVoice:InitializeGVoiceEngine(response.roleId) then
      print("UGVoiceSubsystem: GVoice engine inited successfully!")
      GVoice:SetVoiceMode(UE.EVoiceMode.RealTime)
    end
  end
  LogicGameSetting.InitCustomKeySetting()
  LogicTeam.InitGameModeInfo()
  local ContactPersonManager = ModuleManager:Get("ContactPersonModule")
  if ContactPersonManager then
    ContactPersonManager:InitPersonalHistoryChatInfo(DataMgr.GetUserId())
  end
  SystemUnlockHandler:RequestGetSystemUnlockInfo()
  SaveGrowthSnapHandler.RequestGetGrowthSnapShot()
  EventSystem.Invoke(EventDef.Login.OnLoginProtocolSuccess)
end
function LoginHandler.CheckNetBarState(RoleID)
  local IigwSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGIigwGameInstanceSubsystem:StaticClass())
  if IigwSubsystem then
    local Ret, Ip, Mac, NetbarTokenBuffer = IigwSubsystem:RequestNetbar(RoleID)
    if 0 == Ret then
      local Params = {
        ip = Ip,
        macs = {Mac},
        netbarToken = NetbarTokenBuffer
      }
      print("LoginHandler: Requestprivilege", Params)
      HttpCommunication.Request("playergrowth/netbar/requestprivilege", Params, {
        GameInstance,
        function(Target, JsonResponse)
          local JsonTable = rapidjson.decode(JsonResponse.Content)
          if 0 == JsonTable.privilegeType then
            DataMgr.SetNetBarPrivilegeType(0)
          else
            local TBNetBarPrivilegeList = LuaTableMgr.GetLuaTableByName(TableNames.TBNEtBarPrivilege)
            local PrivilegeIno = TBNetBarPrivilegeList[JsonTable.privilegeType]
            if PrivilegeIno then
              DataMgr.SetNetBarPrivilegeType(JsonTable.privilegeType)
              EventSystem.Invoke(EventDef.Lobby.OnIigwRequestPrivilege)
            else
              DataMgr.SetNetBarPrivilegeType(0)
            end
          end
        end
      })
    end
  end
end
function LoginHandler.RequestLogoutToServer()
  if not UE.UKismetStringLibrary.IsEmpty(HttpCommunication.GetToken()) then
    LogicLobby.SendLogoutTime = GetCurrentTimestamp(true)
    HttpCommunication.Request("login/logout", {}, {
      GameInstance,
      LoginHandler.BindOnLogoutSuccess
    }, {
      GameInstance,
      LoginHandler.BindOnLogoutFail
    })
  end
end
function LoginHandler.BindOnLogoutSuccess(Target, JsonResponse)
  print("LogoutSuccess ", JsonResponse.Content)
  local JsonTable = rapidjson.decode(JsonResponse.Content)
  HttpCommunication.SetToken("")
  UE.URGGameplayLibrary.TriggerOnClientLogoutFromLobby(self)
  UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType()
  local LobbyModule = ModuleManager:Get("LobbyModule")
  if LobbyModule then
    LobbyModule:SaveSpecificDataToLocal()
  end
  DataMgr.ClearData()
  if WSCommunication.IsReconnectFail then
    WSCommunication.ExecuteReconnectFailLogic()
  else
    LogicLobby.OpenLevelByName("Login")
  end
end
function LoginHandler.BindOnLogoutFail()
  print("LogoutFail!")
  if WSCommunication.IsReconnectFail then
    WSCommunication.ExecuteReconnectFailLogic()
  end
end
return LoginHandler
