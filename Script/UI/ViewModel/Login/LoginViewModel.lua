local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local LoginHandler = require("Protocol.LoginHandler")
local LoginData = require("Modules.Login.LoginData")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local PandoraData = require("Modules.Pandora.PandoraData")
local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local CommunicationHandler = require("Protocol.Appearance.Communication.CommunicationHandler")
local PlayerInfoHandler = require("Protocol.PlayerInfo.PlayerInfoHandler")
local PandoraHandler = require("Protocol.Pandora.PandoraHandler")
local InvalidNickNameTb = {"new user"}
local InvalidUserNameCharTb = {" "}
local ServerInfoList = {}
local MaxNickNameLen = 14
local ServerDefaultNickName = "new user"
local LoggedInWaitClickInterval = 3
local SystemPromptIdList = {
  NickNameHasSensitiveWord = 1128,
  AccountNameHasChinese = 1086,
  IllegalAccountName = 1088,
  NonConformityAccountName = 1081,
  NonConformityNickNameLength = 23009,
  IllegalNickName = 23008,
  AccountBlocked = 30004,
  AccountBeKickedOut = 20001,
  EmptyNickName = 1085
}
local LoginViewModel = CreateDefaultViewModel()
LoginViewModel.propertyBindings = {
  AccountName = "",
  IsShowLoginPanel = true,
  IsShowNicknamePanel = false
}

function LoginViewModel:OnInit()
  self.Super:OnInit()
  EventSystem.AddListenerNew(EventDef.Login.GetServerList, self, self.BindOnGetServerList)
  EventSystem.AddListener(self, EventDef.Login.GetServerListFailed, self.BindOnGetServerListFailed)
  self.RequestServerListTimer = nil
  local AccountPrefixSettings = UE.UAccountPrefixSettings.GetAccountPrefixSettings()
  if AccountPrefixSettings then
  end
  self.AccountName = AccountPrefixSettings.DefaultAccountPrefix
  self.DistributionChannel, self.LobbyServerId = self:ParseCommandLineParams()
  DataMgr.SetDistributionChannel(self.DistributionChannel)
  UE.URGGameplayLibrary.TriggerOnClientInitialized(self)
end

function LoginViewModel:BindOnUIChangeDisplayState(IsDisplay)
  if not IsDisplay then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    if PC then
      PC.bShowMouseCursor = true
    end
  end
end

function LoginViewModel:RegisterPropertyChanged(BindingTable, View)
  self.Super.RegisterPropertyChanged(self, BindingTable, View)
  EventSystem.AddListener(self, EventDef.Login.OnLoginProtocolSuccess, self.BindOnLoginProtocolSuccess)
  ListenObjectMessage(nil, GMP.MSG_CG_Movie_Stop, GameInstance, LoginViewModel.BindOnCGMovieStop)
  self:ExcuteLogicByDistributionChannel()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.DisplayDelegate:Bind(GameInstance, LoginViewModel.BindOnUIChangeDisplayState)
  end
end

function LoginViewModel:UnRegisterPropertyChanged(BindingTable, View)
  self.Super.UnRegisterPropertyChanged(self, BindingTable, View)
  EventSystem.RemoveListener(EventDef.Login.OnLoginProtocolSuccess, self.BindOnLoginProtocolSuccess, self)
  UnListenObjectMessage(GMP.MSG_CG_Movie_Stop, GameInstance)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.DisplayDelegate:Unbind()
  end
end

function LoginViewModel:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.Login.GetServerList, self, self.BindOnGetServerList)
  EventSystem.RemoveListener(EventDef.Login.GetServerListFailed, self.BindOnGetServerListFailed, self)
  self:UnRegisterPropertyChanged()
  self.Super:OnShutdown()
end

function LoginViewModel:ParseCommandLineParams()
  local CmdLine = UE.UKismetSystemLibrary.GetCommandLine()
  print("CmdLine", CmdLine)
  local Tokens, Switches, Params = UE.UKismetSystemLibrary.ParseCommandLine(CmdLine, nil, nil, nil)
  local DistributionChannel = Params:Find("dist_channel")
  print("\232\142\183\229\143\150\230\184\184\230\136\143\229\144\175\229\138\168\230\184\160\233\129\147", DistributionChannel)
  if not DistributionChannel then
    if UE.RGUtil and UE.RGUtil.IsEditor() then
      DistributionChannel = LogicLobby.DistributionChannelList.Normal
    else
      UE.UKismetSystemLibrary.QuitGame(GameInstance, UE.UGameplayStatics.GetPlayerController(GameInstance, 0), UE.EQuitPreference.Quit, false)
      return
    end
  end
  local LobbyServerID = Params:Find("lobby_server_id")
  if not LobbyServerID then
    LobbyServerID = "30001"
    self.IsForceServerId = false
  else
    self.IsForceServerId = true
  end
  local ServerListLabel = Params:Find("server_list_label")
  LoginData:SetServerListLabel(ServerListLabel)
  if not UE.URGBlueprintLibrary.IsShippingBuild() then
    LoginData:SetIsRequestServerList(true)
  else
    local HasRequestServerList = Switches:Contains("request_server_list")
    if HasRequestServerList then
      LoginData:SetIsRequestServerList(true)
      print("LoginViewModel:ParseCommandLineParams SetIsRequestServerList true")
    else
      LoginData:SetIsRequestServerList(false)
      print("LoginViewModel:ParseCommandLineParams SetIsRequestServerList false")
    end
  end
  return tonumber(DistributionChannel), LobbyServerID
end

function LoginViewModel:ExcuteLogicByDistributionChannel()
  local Logic = {
    [LogicLobby.DistributionChannelList.Normal] = function()
      print("ExecuteNormalLogic")
      local View = self:GetFirstView()
      if LoginData:GetIsLoginByDistributionChannel() then
        self.AccountName = DataMgr.GetAccountName()
        View:ChangeLoginPanelStep(ELoginStep.RegionClick)
      else
        View:ChangeLoginPanelStep(ELoginStep.NotLogin)
      end
    end,
    [LogicLobby.DistributionChannelList.WeGame] = function()
      print("ExecuteWeGameLogic")
      local View = self:GetFirstView()
      if LoginData:GetIsLoginByDistributionChannel() then
        View:ChangeLoginPanelStep(ELoginStep.RegionClick)
      else
        View:ChangeLoginPanelStep(ELoginStep.NotLoginAndNotShowAccountNameInputPanel)
        local OnlineIdentitySystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlineIdentitySystem:StaticClass())
        if OnlineIdentitySystem then
          OnlineIdentitySystem.Delegate_OnLoginComplete:Add(GameInstance, LoginViewModel.BindOnWeGameLoginComplete)
        end
        self:ExecuteWeGameLogin()
      end
    end,
    [LogicLobby.DistributionChannelList.LIPass] = function()
      print("ExecuteLIPassLogic")
      local View = self:GetFirstView()
      local IsChangeToWaitClick = false
      if UE.URGBlueprintLibrary.IsOfficialPackage() then
        local RGSailSDKSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSailSDKSubsystem:StaticClass())
        local Result, LoginAccountInfo = RGSailSDKSubsystem:GetLoginAccountInfo()
        local ChannelInfoResult, ChannelInfo = RGSailSDKSubsystem:GetThirdPartyChannelInfo()
        local RegionResult, RegionId = RGSailSDKSubsystem:GetRegion()
        local AdultStateResult, AdultState = RGSailSDKSubsystem:GetPlayerAdultState()
        local LipassResult = {}
        local ComplianceResult = {}
        if not Result then
          print("[LIPass] ExecuteLIPassLogic Offical Package Get LoginAccountInfo Fail!")
          LipassResult = {
            RetCode = -1,
            MethodId = 13100,
            RetMsg = NSLOCTEXT("LoginViewModel", "SailFailRetMsg", "\230\184\160\233\129\147SDK\231\153\187\229\189\149\229\164\177\232\180\165")
          }
        else
          print("[LIPass] ExecuteLIPassLogic Offical Package Get LoginAccountInfo Success!")
          LipassResult = {
            RetCode = 0,
            OpenID = LoginAccountInfo.OpenId,
            Token = LoginAccountInfo.Token,
            ChannelID = LoginAccountInfo.ChannelId,
            MethodId = 13100,
            ChannelInfo = ChannelInfoResult and ChannelInfo or ""
          }
          ComplianceResult = {
            Region = RegionResult and RegionId or "",
            AdultStatus = AdultStateResult and AdultState or 0
          }
          print("[LIPass] ExecuteLIPassLogic Offical Packag region", ComplianceResult.Region, " AdultStatus", ComplianceResult.AdultStatus)
          IsChangeToWaitClick = true
          local EncyptDataResult, EncryptedData = RGSailSDKSubsystem:GetEncyptData()
          if EncyptDataResult then
            local Result = UE.UINTLSDKAPI.SetAuthEncryptData(EncryptedData, true)
            print("[LIPass] ExecuteLIPassLogic Offical Package SetAuthEncryptData Result:", Result)
            if Result then
              UE.UINTLSDKAPI.AutoLogin()
            end
          end
        end
        self:OnLIPassLoginResult(LipassResult, ComplianceResult)
      end
      if LoginData:GetIsLoginByDistributionChannel() then
        if not IsChangeToWaitClick then
          View:ChangeLoginPanelStep(ELoginStep.RegionClick)
        end
      else
        View:ChangeLoginPanelStep(ELoginStep.NotLoginAndNotShowAccountNameInputPanel)
        local LIPassSystemClass
        if UE.URGBlueprintLibrary.IsPlatformConsole() then
          LIPassSystemClass = UE.ULIPassConsoleSubsystem:StaticClass()
        else
          LIPassSystemClass = UE.ULIPassSubsystem:StaticClass()
        end
        local LIPassSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, LIPassSystemClass)
        if LIPassSystem then
          LIPassSystem.Delegate_OnAuthResult:Add(GameInstance, LoginViewModel.OnLIPassLoginResult)
          LIPassSystem.Delegate_OnLIEvent:Add(GameInstance, LoginViewModel.OnLIPassEvent)
          LIPassSystem.Delegate_OnComplianceQueryUserInfo:Add(GameInstance, LoginViewModel.OnComplianceQueryUserInfo)
          self:ExecuteLIPassLogin()
        else
          print("[LIPass] LIPassSystem is nil")
        end
      end
    end
  }
  local TargetFunc = Logic[self.DistributionChannel]
  if TargetFunc then
    TargetFunc()
  end
end

function OpenMurSurvey()
  local INTLSDK = UE.UINTLSDKAPI
  if INTLSDK then
    local URL = "https://user.outweisurvey.com/v2/?sid=66a1bba234e1bf9a8903ba9e"
    local EncryptedURL = INTLSDK.GetEncryptUrl(URL)
    if EncryptedURL then
      INTLSDK.OpenUrl(EncryptedURL, UE.EINTLWebViewOrientation.kAuto, false, true, true)
    end
  end
end

function LoginViewModel:ExecuteLIPassLogin()
  print("[LIPass] UINTLSDKAPI call LoginChannelWithLIPASS")
  if UE.URGBlueprintLibrary.IsPlatformConsole() then
    local PlatformName = UE.URGBlueprintLibrary.GetPlatformName()
    if "PS5" == PlatformName then
      UE.ULevelInfiniteAPI.LoginChannelWithLIPass(UE.EINTLLoginChannel.kChannelPS5, "psn:s2s openid id_token:psn.basic_claims")
    elseif "XSX" == PlatformName then
      print("[DEBUG] LoginChannelWithLIPass: ", PlatformName)
      UE.ULevelInfiniteAPI.LoginChannelWithLIPass(UE.EINTLLoginChannel.kChannelXbox)
    else
      print("[DEBUG] Unhandled PlatformName: ", PlatformName)
    end
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
    if UserOnlineSubsystem then
      local OnLogout = function()
        local LoginViewModelSelf = UIModelMgr:Get("LoginViewModel")
        if LoginViewModelSelf then
          local FirstView = LoginViewModelSelf:GetFirstView()
          if FirstView then
            FirstView:ChangeLoginPanelStep(ELoginStep.NotLogin)
          end
        end
        LoginData:SetIsLoginByDistributionChannel(false)
      end
      UserOnlineSubsystem.OnConsolePlayerLogoutDelegate:Add(GameInstance, OnLogout)
    end
  else
    UE.ULevelInfiniteAPI.LoginChannelWithLIPASS(UE.EINTLLoginChannel.kChannelSteam)
  end
end

local METHODID_INTL_AUTH_AUTOLOGIN = 101
local METHODID_LIPASS_AUTH_AUTOLOGIN = 163
local METHODID_LIPASS_AUTH_LOGIN = 164
local METHODID_LIPASS_AUTH_LOGIN_WITH_CHANNEL = 178
local METHODID_LIPASS_AUTH_LOGIN_WITH_THIRD_CHANNEL = 172
local METHODID_LIPASS_LOGIN_ENTER_GAME = 13100

function LoginViewModel:OnLIPassEvent(evt)
  print("[LIPASS] OnLIPassEvent", evt.EventType, evt.ExtraJson)
  if evt.EventType == UE.ELIEventType.LIP_PANEL_CLOSE then
    local EventParams = rapidjson.decode(evt.ExtraJson)
    if EventParams.panelName == "RegionTerms" and EventParams.isClosedManually then
      print("[LIPass] OnLIPassEvent: User close the RegionTerms panel")
      local ErrorMsg = "User Reject the Privacy policy. Closing Game.."
      LoginViewModel:ShowWegameLoginFailWaveWindow(101003, {ErrorMsg})
    end
  end
end

function LoginViewModel:OnComplianceQueryUserInfo(ComplianceResult)
  local result = self.LipassAuthResult
  print("[LIPASS] OnComplianceQueryUserInfo", "OpenID", result.OpenID, "Token", result.Token, "ChannelID", result.ChannelID, "Region", ComplianceResult.Region, "AdultStatus", ComplianceResult.AdultStatus)
  local RGAccountSubsystem = UE.URGAccountSubsystem.Get()
  if RGAccountSubsystem then
    RGAccountSubsystem:SetRegion(ComplianceResult.Region)
    RGAccountSubsystem:SetAdultCheckStatus(ComplianceResult.AdultStatus)
  end
  LoginData:SetIsLoginByDistributionChannel(true)
  PandoraHandler.SetLoginChannel(result.ChannelID)
  UE.URGGameplayLibrary.TriggerOnClientLoginSuccess(GameInstance, tostring(result.ChannelID), result.OpenID, result.Token)
  local channelUIDWithPrefix = UE.URGBlueprintLibrary.GetChannelUserIDWithPrefix(result.ChannelInfo)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
  if UserOnlineSubsystem then
    channelUIDWithPrefix = UserOnlineSubsystem:GetNetIDWithPrefix()
    print("channelUIDWithPrefix:" .. channelUIDWithPrefix)
  else
    print("UserOnlineSubsystem is nil")
  end
  DataMgr.SetChannelUserIdWithPrefix(channelUIDWithPrefix)
  DataMgr.SetChannelUserId(UE.URGBlueprintLibrary.ConvertToChannelUserID(channelUIDWithPrefix))
  local LoginViewModel = UIModelMgr:Get("LoginViewModel")
  local DeviceInfo = UE.URGLogLibrary.FormatLoginDeviceInfo(GameInstance)
  LoginViewModel.LIPassLoginParam = {
    deviceInfo = DeviceInfo,
    token = result.Token,
    uid = result.OpenID,
    channelID = result.ChannelID,
    channelUID = channelUIDWithPrefix
  }
  print("[LIPass] loginlipass params ", RapidJsonEncode(LoginViewModel.LIPassLoginParam))
  LoginViewModel:CheckLoginSuccessNextStep()
end

local str_isempty = function(s)
  return nil == s or "" == s
end

function LoginViewModel:CheckLoginSuccessNextStep()
  if UE.URGBlueprintLibrary.IsPlatformConsole() then
    local RGPlayerSessionSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlayerSessionSubsystem:StaticClass())
    if RGPlayerSessionSubsystem and RGPlayerSessionSubsystem:IsGuiding() then
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local PrivacySubSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserPrivacySubsystem:StaticClass())
      local continueSkipLogin = function()
        if PrivacySubSystem:K2_HasPrivilege(0) == false then
          print("LoginViewModel.CheckLoginSuccessNextStep - CanPlay Failed")
          return
        end
        if PrivacySubSystem:K2_HasPrivilege(1) == false then
          print("LoginViewModel.CheckLoginSuccessNextStep - CanPlayOnline Failed")
          return
        end
        print("LoginViewModel:CheckLoginSuccessNextStep RGPlayerSessionSubsystem:IsGuiding() true")
        self:ChangeLoggedInWaitClickStepToNextStep()
      end
      if PrivacySubSystem then
        PrivacySubSystem.OnInitPrivilegeCompleteDelegate:Add(PC, continueSkipLogin)
        PrivacySubSystem:CheckAllPrivilegeInit()
      else
        print("LoginViewModel.CheckLoginSuccessNextStep - Get PrivacySubSystem Failed")
      end
      return
    end
  end
  local LoginViewModel = UIModelMgr:Get("LoginViewModel")
  local View = LoginViewModel:GetFirstView()
  if View then
    View:ChangeLoginPanelStep(ELoginStep.RegionClick)
  end
end

function LoginViewModel:OnLIPassLoginResult(result, ComplianceResult)
  if result.MethodId == METHODID_LIPASS_LOGIN_ENTER_GAME then
    print("[LIPass] OnAuthResult: ", "OpenID", result.OpenID, "Token", result.Token, "TokenExpireTime", result.TokenExpireTime, "FirstLogin", "UserName", result.UserName, result.FirstLogin, "MethodId", result.MethodId, "RetCode", result.RetCode, "RetMsg", result.RetMsg, "ThirdCode", result.ThirdCode, "ThirdMsg", result.ThirdMsg, "ExtraJson", result.ExtraJson)
    if 0 == result.RetCode and not str_isempty(result.Token) then
      self.LipassAuthResult = {
        OpenID = result.OpenID,
        Token = result.Token,
        ChannelID = result.ChannelID,
        ChannelInfo = result.ChannelInfo
      }
      if not ComplianceResult then
        UE.UINTLSDKAPI.ComplianceQueryUserInfo()
      else
        self:OnComplianceQueryUserInfo(ComplianceResult)
      end
    else
      print("[LIPass] [LIPassObserver] OnAuthResult: Login failed.")
      if UE.URGBlueprintLibrary.IsPlatformConsole() then
        LoginViewModel:ProcessPlatformError(result)
      else
        LoginViewModel:ShowWegameLoginFailWaveWindow(101003, {
          result.RetMsg
        })
      end
    end
  end
end

function LoginViewModel:ProcessPlatformError(result)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    print("LoginViewModel:ShowWegameLoginFailWaveWindow WaveWindowManager is nil.")
    return
  end
  WaveWindowManager:ShowWaveWindowWithDelegate(101003, {
    "Click to retry."
  }, nil, {
    GameInstance,
    function()
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
      if UserOnlineSubsystem then
        if UserOnlineSubsystem:CheckRequestLoginStatus() ~= true then
          print("LoginHandler.UserOnlineSubsystem - CheckRequestLoginStatus Failed")
          self:ProcessPlatformError()
          return
        end
      else
        print("UserOnlineSubsystem is nil")
      end
      self:ExecuteLIPassLogin()
    end
  })
end

function LoginViewModel:BindOnWeGameLoginComplete(bWasSuccessful, UserId, AuthToken, Error)
  print("BindOnWeGameLoginComplete")
  if bWasSuccessful then
    LoginData:SetIsLoginByDistributionChannel(true)
    local UserIdStr = UE.UOnlineIdentitySystem.UniqueNetIdReplToString(UserId)
    print("WeGameLoginComplete success, UserId:", UserIdStr, "Token:", AuthToken)
    local ChannelID = UE.URGLogLibrary.GetChannelID(GameInstance)
    local DistID = UE.URGLogLibrary.GetWegameDistributeID(GameInstance)
    print("WeGame DistributionChannelID", DistID)
    PandoraHandler.SetLoginChannel(ChannelID)
    UE.URGGameplayLibrary.TriggerOnClientLoginSuccess(GameInstance, "Wegame", UserIdStr, AuthToken)
    local LoginViewModel = UIModelMgr:Get("LoginViewModel")
    local DeviceInfo = UE.URGLogLibrary.FormatLoginDeviceInfo(GameInstance)
    LoginViewModel.WeGameLoginParam = {
      deviceInfo = DeviceInfo,
      sessionTicket = AuthToken,
      uid = UserIdStr,
      channelID = ChannelID,
      distributionChannelID = DistID
    }
    local FirstView = LoginViewModel:GetFirstView()
    FirstView:ChangeLoginPanelStep(ELoginStep.RegionClick)
  else
    print("WeGameLoginComplete fail, ", "ErrorMessage:", Error)
    LoginViewModel:ShowWegameLoginFailWaveWindow(101003, {Error})
  end
end

function LoginViewModel:ShowWegameLoginFailWaveWindow(WaveId, Params)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    print("LoginViewModel:ShowWegameLoginFailWaveWindow WaveWindowManager is nil")
    return
  end
  Params = Params or {}
  WaveWindowManager:ShowWaveWindowWithDelegate(WaveId, Params, nil, {
    GameInstance,
    function()
      UE.UKismetSystemLibrary.QuitGame(GameInstance, UE.UGameplayStatics.GetPlayerController(GameInstance, 0), UE.EQuitPreference.Quit, false)
    end
  })
end

function LoginViewModel:ExecuteWeGameLogin()
  if self.DistributionChannel ~= LogicLobby.DistributionChannelList.WeGame then
    return
  end
  print("LoginViewModel:ExecuteWeGameLogin")
  local OnlineIdentitySystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlineIdentitySystem:StaticClass())
  if not OnlineIdentitySystem then
    print("LoginViewModel:ExecuteWeGameLogin not find OnlineIdentitySystem")
    self:ShowWegameLoginFailWaveWindow(101001)
    return
  end
  local Result = OnlineIdentitySystem:Login("", "", "")
  if not Result then
    self:ShowWegameLoginFailWaveWindow(101002)
    print("LoginViewModel:ExecuteWeGameLogin OnlineIdentitySystem login fail!")
  end
end

function LoginViewModel.BindOnCGMovieStop(MovieId)
  print("LoginViewModel:BindOnCGMovieStop", MovieId)
  local Settings = UE.URGLobbySettings.GetLobbySettings()
  if not Settings then
    print("LoginViewModel:BindOnCGMovieStop not found LobbySettings")
    return
  end
  if MovieId == Settings.BeforeSetUserNickNameCGMovieId then
    local LoginViewModel = UIModelMgr:Get("LoginViewModel")
    local FirstView = LoginViewModel:GetFirstView()
    if FirstView then
      FirstView:ChangeLoginPanelStep(ELoginStep.SetNickName)
    end
  end
  if MovieId == Settings.AfterSetUserNickNameCGMovieId then
    print("LoginViewModel:BindOnCGMovieStop cg\230\146\173\230\148\190\229\174\140\230\136\144\239\188\140\229\136\135\229\133\165\230\150\176\230\137\139\229\133\179")
    DataMgr.GetOrQueryPlayerInfo({
      DataMgr.GetUserId()
    }, true, function(PlayerInfoList)
      LoginViewModel:OnGetRoleSuccess(PlayerInfoList)
    end, function(ErrorMsg)
      LoginViewModel:OnGetRoleError(ErrorMsg)
    end)
  end
end

function LoginViewModel:BindOnGetServerList(data)
  LoginData:SetIsServerListInited(true)
  local DevelopServerIndex = 0
  local View = self:GetFirstView()
  if View then
    View:ClearComboServerListOptions()
  end
  for i, SingleServerInfo in ipairs(data) do
    if View then
      View:AddServerList(SingleServerInfo.name)
    end
    HttpService:AddHttpServerList(SingleServerInfo.name, SingleServerInfo.ip, SingleServerInfo.port, SingleServerInfo.tls)
    ServerInfoList[SingleServerInfo.name] = SingleServerInfo
    if self.LobbyServerId == SingleServerInfo.code then
      DevelopServerIndex = i - 1
    end
  end
  if View then
    View:UpdateLastSelectedServer(HttpService.LastSelectedServerName, DevelopServerIndex, self.IsForceServerId)
  end
end

function LoginViewModel:BindOnGetServerListFailed()
  local View = self:GetFirstView()
  if View then
    View:ShowRequestServerListFailed()
  end
end

function LoginViewModel:BindOnLoginProtocolSuccess()
  print("LoginFlow", "LoginViewModel:BindOnLoginProtocolSuccess - \229\188\128\229\167\139\230\139\137\229\143\150\232\167\146\232\137\178\228\191\161\230\129\175")
  LogicTeam.UpdateRegionPing()
  DataMgr.GetOrQueryPlayerInfo({
    DataMgr.GetUserId()
  }, true, function(PlayerInfoList)
    LoginViewModel:OnGetRoleSuccess(PlayerInfoList)
  end, function(ErrorMsg)
    LoginViewModel:OnGetRoleError(ErrorMsg)
  end)
end

function LoginViewModel:Login(UserName)
  UserName = tostring(UserName)
  UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType("LoginToLobby")
  self.AccountName = UserName
  if self:CheckUserNameIsValid(self.AccountName) then
    DataMgr.SetAccountName(self.AccountName)
    local FirstView = self:GetFirstView()
    FirstView:ChangeLoginPanelStep(ELoginStep.RegionClick)
    PandoraHandler.SetLoginChannel("Wooduan")
    UE.URGGameplayLibrary.TriggerOnClientLoginSuccess(GameInstance, "Wooduan", UserName, "")
    LoginData:SetIsLoginByDistributionChannel(true)
  else
    print("LoginViewModel:ChangeLoggedInWaitClickStepToNextStep UserName is Invalid!")
  end
end

function LoginViewModel:SetLastSelectedServer(selectedItem)
  if not UE.UKismetStringLibrary.IsEmpty(selectedItem) then
    LoginData:SaveLastSelectServeName(selectedItem)
    local TargetServerInfo = ServerInfoList[selectedItem]
    if TargetServerInfo then
      LoginData:SetLobbyServerId(TargetServerInfo.code)
    end
    UE.URGLogLibrary.TriggerClientLogEvent(GameInstance, UE.ERGClientLogEvent.Activation)
  end
end

function LoginViewModel:SetNicknameButtonClicked(nickname)
  local nickname = tostring(nickname)
  if not self:CheckNickNameIsVaild(nickname) then
    print("LoginViewModel:SetNicknameButtonClicked NickName is Invalid!")
    return
  end
  local FirstView = self:GetFirstView()
  self:StartSetNickName()
end

function LoginViewModel:StartSetNickName()
  local FirstView = self:GetFirstView()
  local NickName = FirstView:GetInputNickName()
  HttpCommunication.Request("playerservice/nickname", {val = NickName}, {
    GameInstance,
    function(Target, JsonResponse)
      local Response = rapidjson.decode(JsonResponse.Content)
      FirstView:ChangeLoginPanelStep(ELoginStep.AfterSetNickName)
      if LogicLobby.IsExecuteBeginnerGuidance then
        local Settings = UE.URGLobbySettings.GetLobbySettings()
        local MovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGMovieSubSystem:StaticClass())
        if MovieSubsystem and 0 ~= Settings.AfterSetUserNickNameCGMovieId then
          local MoviePlayer = MovieSubsystem:GetDefaultMoviePlayer()
          if MoviePlayer then
            MoviePlayer:PlayMovie(Settings.AfterSetUserNickNameCGMovieId)
          else
            DataMgr.SetNickName(NickName)
            LoginViewModel:CheckSetNickName(NickName)
          end
        else
          DataMgr.SetNickName(NickName)
          LoginViewModel:CheckSetNickName(NickName)
        end
      else
        DataMgr.SetNickName(NickName)
        LoginViewModel:CheckSetNickName(NickName)
      end
    end
  }, {
    GameInstance,
    function()
      print("\230\148\185\229\144\141\229\164\177\232\180\165")
    end
  })
end

function LoginViewModel:OnFilterProfanity(bWasSuccessful, OutputMessage)
  print("LoginViewModel:OnFilterProfanity123", bWasSuccessful, OutputMessage)
  if not bWasSuccessful then
    print("LoginViewModel:OnFilterProfanity is fail!")
    return
  end
  local LoginViewModel = UIModelMgr:Get("LoginViewModel")
  local FirstView = LoginViewModel:GetFirstView()
  if OutputMessage == tostring(FirstView:GetInputNickName()) then
    LoginViewModel:StartSetNickName()
  else
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if WaveWindowManager then
      WaveWindowManager:ShowWaveWindow(SystemPromptIdList.NickNameHasSensitiveWord, {})
    end
  end
end

function LoginViewModel:ChangeLoggedInWaitClickStepToNextStep()
  local Logic = {
    [LogicLobby.DistributionChannelList.Normal] = function(self)
      print("LoginViewModel:ChangeLoggedInWaitClickStepToNextStep ExecuteNormalLoginToServer")
      local DeviceInfo = UE.URGLogLibrary.FormatLoginDeviceInfo(GameInstance)
      LoginHandler.RequestLoginDevToServer(self.AccountName, DeviceInfo)
    end,
    [LogicLobby.DistributionChannelList.WeGame] = function(self)
      print("LoginViewModel:ChangeLoggedInWaitClickStepToNextStep ExecuteWegameLoginToServer")
      LoginHandler.RequestLoginWeGameToServer(self.WeGameLoginParam)
    end,
    [LogicLobby.DistributionChannelList.LIPass] = function(self)
      local ContinueLogin = function()
        print("[LIPass] LoginViewModel:ChangeLoggedInWaitClickStepToNextStep ExecuteLIPassLoginToServer")
        LoginHandler.RequestLoginLIPassToServer(self.LIPassLoginParam)
      end
      print("[LIPass] LoginViewModel:ChangeLoggedInWaitClickStepToNextStep ExecuteLIPassLoginToServer")
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      local PrivacySubSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserPrivacySubsystem:StaticClass())
      if PrivacySubSystem then
        PrivacySubSystem.OnInitPrivilegeCompleteDelegate:Add(PC, ContinueLogin)
        PrivacySubSystem:CheckAllPrivilegeInit()
      else
        print("LoginViewModel.ChangeLoggedInWaitClickStepToNextStep - Get PrivacySubSystem Failed")
        ContinueLogin()
      end
    end
  }
  local TargetFunc = Logic[self.DistributionChannel]
  if TargetFunc then
    if self.LastLoggedInWaitClickTime and GetCurrentUTCTimestamp() - self.LastLoggedInWaitClickTime < LoggedInWaitClickInterval then
      print("\231\153\187\229\189\149\231\130\185\229\135\187\229\164\170\233\162\145\231\185\129!")
      return
    end
    self.LastLoggedInWaitClickTime = GetCurrentUTCTimestamp()
    UE.URGLogLibrary.TriggerClientLogEvent(GameInstance, UE.ERGClientLogEvent.ConnectLobby)
    TargetFunc(self)
  end
end

function LoginViewModel:ConnectWSGate()
  printShipping("LoginFlow", "LoginViewModel:ConnectWSGate - \229\188\128\229\167\139\232\191\158\230\142\165WebSocket")
  local GateService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UWSGateService:StaticClass())
  local LoginViewModel = UIModelMgr:Get("LoginViewModel")
  local ServerName = HttpService.LastSelectedServerName
  local TargetServerInfo = HttpService.HttpServerListForClient:Find(ServerName)
  if TargetServerInfo then
    UE.URGProfilerLibrary.SetNTLTargetAddress(GameInstance, TargetServerInfo.ip)
    GateService:Connect(TargetServerInfo.ip, TargetServerInfo.port, HttpCommunication.GetToken(), TargetServerInfo.TLS)
  end
end

function LoginViewModel:CheckUserNameIsValid(userName)
  userName = tostring(userName)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if HaveChineseChar(userName) then
    if WaveWindowManager then
      WaveWindowManager:ShowWaveWindow(SystemPromptIdList.AccountNameHasChinese, {})
    end
    print("\232\180\166\229\143\183\228\184\141\232\131\189\229\173\152\229\156\168\228\184\173\230\150\135\229\173\151\231\172\166")
    return false
  end
  for index, value in ipairs(InvalidUserNameCharTb) do
    if string.find(userName, value) then
      if WaveWindowManager then
        WaveWindowManager:ShowWaveWindow(SystemPromptIdList.IllegalAccountName, {})
      end
      return false
    end
  end
  local AccountPrefixSettings = UE.UAccountPrefixSettings.GetAccountPrefixSettings()
  if AccountPrefixSettings then
    for i, SingleAccountPrefix in pairs(AccountPrefixSettings.AccountPrefixs) do
      if string.sub(userName, 1, #SingleAccountPrefix) == SingleAccountPrefix then
        return true
      end
    end
  end
  print("\231\148\168\230\136\183\229\144\141\228\184\141\231\172\166\229\144\136\232\167\132\232\140\131")
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveWindowManager then
    WaveWindowManager:ShowWaveWindow(SystemPromptIdList.NonConformityAccountName, {})
  end
  return false
end

function LoginViewModel:CheckNickNameIsVaild(nickname)
  local Len = self:CalcNickNameLen(nickname)
  print("LoginView:CheckNickNameIsVaild Len:", Len)
  if Len <= 0 then
    ShowWaveWindow(SystemPromptIdList.EmptyNickName)
    return false
  end
  if Len > MaxNickNameLen then
    self:ShowNickNameErrorTip(SystemPromptIdList.NonConformityNickNameLength)
    return false
  end
  if not UE.URGPlatformFunctionLibrary.IsLIPassEnabled() and not UE.URGBlueprintLibrary.IsValidNickName(nickname) then
    self:ShowNickNameErrorTip(SystemPromptIdList.IllegalNickName)
    return false
  end
  for i, v in ipairs(InvalidNickNameTb) do
    if v == nickname then
      self:ShowNickNameErrorTip(SystemPromptIdList.IllegalNickName)
      return false
    end
  end
  return true
end

function LoginViewModel:ShowNickNameErrorTip(ErrorCode)
  local TargetId = tonumber(ErrorCode)
  local Params = {}
  local Result, PromptRowInfo = GetRowData(DT.DT_SystemPrompt, ErrorCode)
  if not Result then
    TargetId = 100001
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBErrorCode, tonumber(ErrorCode))
    if Result then
      table.insert(Params, RowInfo.Tips)
    end
  end
  ShowWaveWindowWithConsoleCheck(TargetId, Params, ErrorCode)
end

function LoginViewModel:CalcNickNameLen(NickNameParam)
  return UE.URGBlueprintLibrary.GetNickNameLength(NickNameParam)
end

function LoginViewModel:CheckSetNickName(NickName)
  print("LoginViewModel:CheckSetNickName", NickName)
  if nil == NickName or "" == NickName or NickName == ServerDefaultNickName then
    local IsNeedPlayMovie = false
    if LogicLobby.IsExecuteBeginnerGuidance then
      local MovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGMovieSubSystem:StaticClass())
      if MovieSubsystem then
        local Settings = UE.URGLobbySettings.GetLobbySettings()
        local MoviePlayer = MovieSubsystem:GetDefaultMoviePlayer()
        if MoviePlayer and 0 ~= Settings.BeforeSetUserNickNameCGMovieId then
          MoviePlayer:PlayMovie(Settings.BeforeSetUserNickNameCGMovieId)
          IsNeedPlayMovie = true
        end
      end
    end
    local FirstView = self:GetFirstView()
    if FirstView then
      if not IsNeedPlayMovie then
        FirstView:ChangeLoginPanelStep(ELoginStep.SetNickName)
      else
        FirstView:ChangeLoginPanelStep(ELoginStep.Empty)
      end
    end
  else
    local LoginViewModel = UIModelMgr:Get("LoginViewModel")
    local FirstView = LoginViewModel:GetFirstView()
    if FirstView then
      FirstView:DelayChangeToLoggedInWaitClickStep()
    end
    self:InitAccountInfo()
  end
end

function LoginViewModel:CheckNeedShowKickOutTip()
  if WSCommunication.bIskickOut then
    WSCommunication.bIskickOut = false
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if WaveWindowManager then
      if WSCommunication.bIsKickByBan then
        WSCommunication.bIsKickByBan = false
        local BanReason = "BanReason"
        local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBanReason, WSCommunication.KickBanReason)
        if Result then
          BanReason = RowInfo.Tips
        end
        local BanEndTimeFormat = TimestampToDateTimeText(WSCommunication.KickBanEndTime)
        local Params = {BanReason, BanEndTimeFormat}
        WaveWindowManager:ShowWaveWindowWithDelegate(SystemPromptIdList.AccountBlocked, Params, nil)
      else
        WaveWindowManager:ShowWaveWindowWithDelegate(SystemPromptIdList.AccountBeKickedOut, {}, nil)
      end
    end
  end
end

function LoginViewModel:InitAccountInfo()
  self:RequestAccountInfoToServer()
end

function LoginViewModel:OnGetRoleSuccess(PlayerInfoList)
  print("OnGetRoleSuccess", RapidJsonEncode(PlayerInfoList))
  for i, SingleInfo in ipairs(PlayerInfoList) do
    if SingleInfo.playerInfo.roleid == DataMgr.GetUserId() then
      DataMgr.SetBasicInfo(SingleInfo.playerInfo)
      local LoginViewModel = UIModelMgr:Get("LoginViewModel")
      LoginViewModel:CheckSetNickName(SingleInfo.nickname)
    end
  end
end

function LoginViewModel:OnGetRoleError(ErrorMessage)
  print("OnGetRoleFail", ErrorMessage.ErrorMessage)
end

function LoginViewModel:RequestAccountInfoToServer()
  print("LoginFlow", "LoginViewModel:RequestAccountInfoToServer - \229\188\128\229\167\139\230\139\137\229\143\150\231\179\187\231\187\159\229\188\128\229\133\179\230\149\176\230\141\174")
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr then
    SystemOpenMgr:RequestSystemSwitchsInitData(self.ConnectWSGate)
  else
    printError("LoginViewModel:RequestAccountInfoToServer() - require SystemOpenMgr is nil!!!")
  end
end

function LoginViewModel:PullCurrencyList()
  print("LoginFlow", "LoginViewModel:PullCurrencyList - \229\188\128\229\167\139\230\139\137\229\143\150\231\142\169\229\174\182\233\146\177\229\140\133\230\149\176\230\141\174")
  local CurrencyList = {}
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not TotalResourceTable then
    return
  end
  for SingleResourceId, SingleResourceInfo in pairs(TotalResourceTable) do
    if SingleResourceInfo.Type == TableEnums.ENUMResourceType.CURRENCY or SingleResourceInfo.Type == TableEnums.ENUMResourceType.PaymentCurrency then
      table.insert(CurrencyList, SingleResourceId)
    end
  end
  local Params = {currencyIds = CurrencyList}
  HttpCommunication.Request("resource/pullwallet", Params, {
    GameInstance,
    self.OnPullCurrencyListSuccess
  }, {
    GameInstance,
    LoginViewModel.OnPullCurrencyListFail
  })
end

function LoginViewModel:PullPropBackpack()
  print("LoginFlow", "LoginViewModel:PullPropBackpack - \229\188\128\229\167\139\230\139\137\229\143\150\231\142\169\229\174\182\232\131\140\229\140\133\230\149\176\230\141\174")
  HttpCommunication.Request("resource/pullproppack", {}, {
    GameInstance,
    function(self, JsonResponse)
      print("OnPullPropPack", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      local PackbackList = {}
      local PackJson = rapidjson.decode(JsonTable.props)
      if type(PackJson) ~= "function" then
        for i, SinglePackBackInfo in ipairs(PackJson) do
          if type(SinglePackBackInfo) ~= "function" then
            if PackbackList[SinglePackBackInfo.id] then
              table.insert(PackbackList[SinglePackBackInfo.id], SinglePackBackInfo)
            else
              local List = {}
              table.insert(List, SinglePackBackInfo)
              PackbackList[SinglePackBackInfo.id] = List
            end
          end
        end
      end
      DataMgr.SetOutsidePackbackList(PackbackList)
    end
  }, {
    GameInstance,
    function(self, ErrorMessage)
    end
  })
end

function LoginViewModel:OnPullCurrencyListSuccess(JsonResponse)
  print("OnPullCurrencyListSuccess", JsonResponse.Content)
  local JsonTable = rapidjson.decode(JsonResponse.Content)
  local CurrencyList = {}
  for i, SingleCurrencyInfo in ipairs(JsonTable.currencyList) do
    local CurrencyListTable = {
      currencyId = SingleCurrencyInfo.currencyId,
      number = SingleCurrencyInfo.number,
      expireAt = SingleCurrencyInfo.expireAt
    }
    table.insert(CurrencyList, CurrencyListTable)
  end
  DataMgr.SetOutsideCurrencyList(CurrencyList)
end

function LoginViewModel:OnPullCurrencyListFail(ErrorMessage)
  print("OnPullCurrencyListFail")
end

function LoginViewModel:OnAnnouncementButtonClicked()
  if not PandoraData:HasApp() then
    ShowWaveWindow(1140, {})
    return
  end
  local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  PandorSubsystem:OpenApp(PandoraData:GetAnnounceAppId(), "")
end

function LoginViewModel:OnExitAccountButtonClicked()
  print("OnExitAccountButtonClicked")
  local FirstView = self:GetFirstView()
  FirstView:ChangeLoginPanelStep(ELoginStep.NotLogin)
  LoginData:SetIsLoginByDistributionChannel(false)
end

function LoginViewModel:OnAgeReminderButtonClicked()
  UIMgr:Show(ViewID.UI_AgeReminder)
end

function LoginViewModel:OnCloseButtonClicked()
  print("OnExitAccountButtonClicked")
  local FirstView = self:GetFirstView()
  if FirstView then
    FirstView:ChangeLoginPanelStep(ELoginStep.LoggedInWaitClick)
  end
end

return LoginViewModel
