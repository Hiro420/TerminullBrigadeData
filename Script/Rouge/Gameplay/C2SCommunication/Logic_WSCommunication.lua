local rapidjson = require("rapidjson")
local RGUIMgr = require("Rouge.UI.UIBase.RGUIMgr")
local LoginHandler = require("Protocol.LoginHandler")
local PandoraModule = require("Modules.Pandora.PandoraModule")
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local BeginnerGuideHandler = require("Protocol.BeginnerGuide.BeginnerGuideHandler")
local ContactPersonHandler = require("Protocol.ContactPerson.ContactPersonHandler")
local MailHandler = require("Protocol.Mail.MailHandler")
local IllustratedGuideHandler = require("Protocol.IllustratedGuide.IllustratedGuideHandler")
local RuleTaskHandler = require("Protocol.RuleTask.RuleTaskHandler")
local PrivilegeHandler = require("Protocol.Privilege.PrivilegeHandler")
local CommunicationHandler = require("Protocol.Appearance.Communication.CommunicationHandler")
local PlayerInfoHandler = require("Protocol.PlayerInfo.PlayerInfoHandler")
local PuzzleHandler = require("Protocol.Puzzle.PuzzleHandler")
local GemHandler = require("Protocol.Gem.GemHandler")
local MonthCardHandler = require("Protocol.MonthCard.MonthCardHandler")
local LoadingViewClsPath = "/Game/Rouge/UI/Common/WBP_LoadingView.WBP_LoadingView_C"
require("Rouge.UI.Mall.Logic_Mall")
local climbtowerdata = require("UI.View.ClimbTower.ClimbTowerData")
local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
if Logic_MainTask == nil then
  require("Rouge.UI.MainTask.Logic_MainTask")
end
if not LogicTalent then
  require("Rouge.UI.Lobby.Logic.Logic_Talent")
end
local TimerCount = 0
WSCommunication = WSCommunication or {IsInit = false}
function WSCommunication.Init()
  WSCommunication.IsReconnectFail = false
  if WSCommunication.IsInit then
    return
  end
  WSCommunication.IsInit = true
  WSCommunication:RegisterEvent()
end
function WSCommunication:RegisterEvent()
  EventSystem.AddListener(nil, EventDef.WSMessage.ConnectWSSuccess, WSCommunication.BindOnWSConnSucc)
  EventSystem.AddListener(nil, EventDef.WSMessage.KickOut, WSCommunication.BindOnKickOut)
  EventSystem.AddListener(nil, EventDef.WSMessage.KickByBan, WSCommunication.BindOnKickByBan)
  local GateService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UWSGateService:StaticClass())
  if GateService then
    GateService.WSGate_OnReconnectFailed:Add(GameInstance, WSCommunication.BindOnReconnectFailed)
    GateService.WSGate_OnReconnectingCountDown:Add(GameInstance, WSCommunication.BindOnUpdateLoadingView)
    GateService.WSGate_OnReconnecting:Add(GameInstance, WSCommunication.BindOnReconnecting)
    GateService.WSGate_OnMessageRecv:Add(GameInstance, WSCommunication.BindOnMessageRecv)
  end
end
function WSCommunication.BindOnWSConnSucc(Json)
  print("LoginFlow", "WSCommunication.BindOnWSConnSucc - wsConnSucc \228\186\139\228\187\182\232\167\166\229\143\145\230\136\144\229\138\159")
  if LogicAutoRobot and LogicAutoRobot.GetIsAutoBot() then
    print("WSCommunication.BindOnWSConnSucc return by Robot")
    return
  end
  local GateService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UWSGateService:StaticClass())
  if not GateService or not GateService:IsConnected() then
    print("wsConnSucc \228\186\139\228\187\182\232\167\166\229\143\145\230\136\144\229\138\159 WebSocket\229\183\178\230\150\173\229\188\128\232\191\158\230\142\165")
    return
  end
  if UIMgr:IsShow(ViewID.UI_Loading) then
    UIMgr:Hide(ViewID.UI_Loading)
  end
  local JsonTable = rapidjson.decode(Json)
  WSCommunication.InitAccountInfo()
  local LevelName = UE.UGameplayStatics.GetCurrentLevelName(GameInstance, true)
  if "Login" == LevelName then
    local Name = "127.0.0.1:7777"
    if LogicLobby.IsExecuteBeginnerGuidance then
      LogicLobby.CheckNeedOpenBeginGuidanceLevel()
    else
      print("LoginFlow", "WSCommunication.BindOnWSConnSucc - \229\188\128\229\167\139\230\139\137\229\143\150\230\150\176\230\137\139\230\140\135\229\188\149\232\191\155\229\186\166\230\149\176\230\141\174")
      BeginnerGuideHandler.RequestGetFinishedGuideListFromServer()
      print("LoginFlow", "WSCommunication.BindOnWSConnSucc - \229\188\128\229\167\139\229\136\135\229\164\167\229\142\133\229\133\179\229\141\161")
      LogicLobby.OpenLobbyLevel()
    end
  else
    BeginnerGuideHandler.RequestGetFinishedGuideListFromServer()
  end
  Logic_MainTask.LoadMainTaskModule()
  print("WSCommunication.BindOnWSConnSucc LoadMainTaskModule")
  ChatDataMgr.GetVoiceBanStatus(nil, true)
end
function WSCommunication.InitAccountInfo()
  LogicLobby.IsFirstTeamInfoUpdate = true
  WSCommunication.PullCurrencyList()
  WSCommunication.PullPropBackpack()
  Logic_Mall.PushBundleInfo(true)
  Logic_Mall.PushExteriorInfo(true)
  Logic_Mall.PushPropsInfo(true)
  LogicLobby.RequestAllGameModeFloorDataToServer()
  LogicTalent.RequestGetCommonTalentsToServer()
  climbtowerdata:GetDailyRewardInfo()
  ContactPersonHandler:RequestGetFriendListToServer()
  ContactPersonHandler:RequestGetApplyListToServer()
  ContactPersonHandler:RequestOfflineMessagesToServer()
  MailHandler:RequestGetMailListToServer()
  IllustratedGuideHandler.RequestGetOwnedSpecificModifyListFromServer()
  PuzzleHandler:RequestPuzzlepackageToServer()
  PuzzleHandler:RequestGetAllPuzzleDetailToServer()
  GemHandler:RequestGetGemPackageInfoToServer()
  MonthCardHandler:RequestRolesMonthCardInfoToServer({
    DataMgr.GetUserId()
  })
  PrivilegeHandler:RequestRolesPrivilegeInfoToServer({
    DataMgr.GetUserId()
  })
  local RuleTaskTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRuleTask)
  for i, ActivityId in ipairs(RuleTaskTable) do
    local Result, ActivityRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBActivityGeneral)
    Logic_MainTask.PullTask(ActivityRowInfo.taskGroupList)
    RuleTaskHandler:RequestGetRuleTaskDataToServer(ActivityId)
  end
  local LevelName = UE.UGameplayStatics.GetCurrentLevelName(GameInstance, true)
  if "Lobby" == LevelName then
    LogicTeam.RequestGetMyTeamDataToServer()
    WSCommunication.RequestWhenWSConNotInBattle()
    LogicLobby.CheckReConBattle()
    LogicOutsideWeapon.RequestGetWeaponList()
    SkinHandler.SendGetHeroSkinList()
    SkinHandler.SendGetWeaponSkinList()
  elseif "Login" == LevelName then
    WSCommunication.RequestWhenWSConNotInBattle()
    if LogicTeam then
      LogicTeam.RequestGetMyTeamDataToServer()
    end
  end
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  ClimbTowerData:PassRewardStatus(#ClimbTowerTable)
end
function WSCommunication.RequestWhenWSConNotInBattle()
  local callback = function(JsonTable)
    LogicOutsideWeapon.RequestEquippedWeaponInfo(JsonTable.equipHero)
    CommunicationHandler.RequestGetCommunicationBag()
    PlayerInfoHandler.RequestGetPortraits()
    PlayerInfoHandler.RequestGetBanners()
  end
  LogicRole.RequestMyHeroInfoToServer(callback)
end
function WSCommunication.BindOnKickOut()
  print("KickOut")
  local LobbyModule = ModuleManager:Get("LobbyModule")
  if LobbyModule then
    LobbyModule:SaveSpecificDataToLocal()
  end
  HttpCommunication.SetToken("")
  local GateService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UWSGateService:StaticClass())
  if GateService then
    GateService:Disconnect()
  end
  LogicLobby.OpenLevelByName("Login")
  if not LogicLobby.SendLogoutTime or GetCurrentTimestamp(true) - LogicLobby.SendLogoutTime > 3 then
    WSCommunication.bIskickOut = true
  end
end
function WSCommunication.BindOnKickByBan(Json)
  print("BindOnKickByBan ", Json)
  local JsonTable = rapidjson.decode(Json)
  WSCommunication.bIsKickByBan = true
  WSCommunication.KickBanReason = JsonTable.banReason
  WSCommunication.KickBanEndTime = JsonTable.banEndTime
end
function WSCommunication.BindOnReconnectFailed()
  print("WSCommunication.BindOnReconnectFailed")
  WSCommunication.IsRealReconnectFail = true
  WSCommunication.StartExecuteReconnectFailLogic()
end
function WSCommunication.StartExecuteReconnectFailLogic()
  print("WSCommunication.StartExecuteReconnectFailLogic")
  WSCommunication.IsReconnectFail = true
  if GameInstance.IsNetWorkError then
    print("WSCommunication.StartExecuteReconnectFailLogic not Logout, Is DS NetWorkError!")
    WSCommunication.ExecuteReconnectFailLogic()
  elseif WSCommunication.IsRealReconnectFail then
    local TutorialSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local IsFreshPlayer = TutorialSubsystem and TutorialSubsystem:IsFreshPlayer() or false
    if not IsFreshPlayer and PC and PC.LeaveFromMatch then
      print("WSCommunication.StartExecuteReconnectFailLogic Start LeaveFromMatch")
      PC:LeaveFromMatch()
    else
      print("WSCommunication.StartExecuteReconnectFailLogic Start Logout")
      LoginHandler.RequestLogoutToServer()
    end
    WSCommunication.ReconnectFailReturnToLoginTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        print("WSCommunication.BindOnReconnectFailed Protocol is OverTime, Execute ReconnectFailLogin AtOnce")
        WSCommunication.ExecuteReconnectFailLogic()
      end
    }, 3.0, false)
  end
end
function WSCommunication.ExecuteReconnectFailLogic()
  print("WSCommunication.ExecuteReconnectFailLogic")
  WSCommunication.IsReconnectFail = false
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(WSCommunication.ReconnectFailReturnToLoginTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, WSCommunication.ReconnectFailReturnToLoginTimer)
  end
  local CurLevelName = UE.UGameplayStatics.GetCurrentLevelName(GameInstance, true)
  if "Login" == CurLevelName then
    if WSCommunication.IsRealReconnectFail then
      PandoraModule:OpenAnnounceApp()
    end
  else
    if WSCommunication.IsRealReconnectFail then
      WSCommunication.IsNeedShowAnnouncement = true
    end
    LogicLobby.OpenLevelByName("Login")
  end
  WSCommunication.IsRealReconnectFail = false
end
function WSCommunication:BindOnReconnecting(ReconnectNum)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local Param = {}
  local ReconFmt = NSLOCTEXT("WSCommunication", "ReconTxt", "\231\172\172{0}\230\172\161\233\135\141\232\191\158\229\188\128\229\167\139")
  local ReconTxt = UE.FTextFormat(ReconFmt(), ReconnectNum + 1)
  table.insert(Param, ReconTxt)
  WaveWindowManager:ShowWaveWindow(100001, Param)
end
function WSCommunication:BindOnMessageRecv(Message)
  print("BindOnMessageRecv:", Message)
  local JsonTable = rapidjson.decode(Message)
  EventSystem.Invoke(JsonTable.method, Message)
end
function WSCommunication:BindOnUpdateLoadingView(CountDown)
  local WaitReconTxt = NSLOCTEXT("WSCommunication", "WaitReconTxt", "\231\173\137\229\190\133\233\135\141\232\191\158......{0}")
  local ReconTxt = UE.FTextFormat(WaitReconTxt(), CountDown)
  local Str = string.format(ReconTxt)
  if not UIMgr:IsShow(ViewID.UI_Loading) then
    UIMgr:Show(ViewID.UI_Loading, nil, Str)
  else
    local loadingView = UIMgr:GetLuaFromActiveView(ViewID.UI_Loading)
    if loadingView then
      loadingView:UpdateDesc(Str)
    end
  end
end
function WSCommunication.PullCurrencyList()
  local CurrencyList = {}
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not TotalResourceTable then
    return
  end
  for SingleResourceId, SingleResourceInfo in pairs(TotalResourceTable) do
    if SingleResourceInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
      table.insert(CurrencyList, SingleResourceId)
    end
  end
  local PaymentCurrencyTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPaymentCurrency)
  if PaymentCurrencyTable then
    for CurrencyId, v in pairs(PaymentCurrencyTable) do
      table.insert(CurrencyList, CurrencyId)
    end
  end
  local Params = {currencyIds = CurrencyList}
  HttpCommunication.Request("resource/pullwallet", Params, {
    GameInstance,
    function(self, JsonResponse)
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
      EventSystem.Invoke(EventDef.Lobby.UpdateResourceInfo)
    end
  }, {
    GameInstance,
    function(self, JsonResponse)
    end
  })
end
function WSCommunication.PullPropBackpack()
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
      EventSystem.Invoke(EventDef.Lobby.UpdateResourceInfo)
    end
  }, {
    GameInstance,
    function(self, ErrorMessage)
    end
  })
end
function WSCommunication.Clear()
  WSCommunication.IsInit = false
  EventSystem.RemoveListener(EventDef.WSMessage.ConnectWSSuccess, WSCommunication.BindOnWSConnSucc)
  EventSystem.RemoveListener(EventDef.WSMessage.KickOut, WSCommunication.BindOnKickOut)
  EventSystem.RemoveListener(EventDef.WSMessage.KickByBan, WSCommunication.BindOnKickByBan)
  local GateService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UWSGateService:StaticClass())
  if GateService then
    GateService.WSGate_OnReconnectFailed:Remove(GameInstance, WSCommunication.BindOnReconnectFailed)
    GateService.WSGate_OnReconnecting:Remove(GameInstance, WSCommunication.BindOnReconnecting)
    GateService.WSGate_OnReconnectingCountDown:Remove(GameInstance, WSCommunication.BindOnUpdateLoadingView)
    GateService.WSGate_OnMessageRecv:Remove(GameInstance, WSCommunication.BindOnMessageRecv)
  end
end
