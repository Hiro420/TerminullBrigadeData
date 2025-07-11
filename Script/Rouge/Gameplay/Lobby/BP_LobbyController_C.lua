require("Rouge.UI.HUD.Logic.Logic_Lobby")
require("Rouge.UI.Lobby.Logic.Logic_Role")
require("Rouge.UI.Lobby.Logic.Logic_OutsidePackback")
require("Rouge.UI.Lobby.Logic.Logic_Talent")
require("Rouge.UI.Lobby.Logic.Logic_Level")
require("Rouge.UI.Lobby.Logic.Logic_SoulCore")
require("Rouge.UI.Lobby.Logic.Logic_WeaponHandBook")
require("Rouge.UI.Lobby.Logic.Logic_OutsideWeapon")
require("Rouge.UI.Lobby.Logic.Logic_Team")
require("Rouge.UI.Lobby.Logic.Logic_Avatar")
require("Rouge.UI.Lobby.Logic.Logic_HeroSelect")
require("Rouge.UI.Lobby.Logic.Logic_CommonTips")
require("Rouge.UI.Mall.Logic_Mall")
local ClimbtowerData = require("UI.View.ClimbTower.ClimbTowerData")
local PayInnerCodeConfig = require("GameConfig.PayInnerCodeConfig")
local LoginHandler = require("Protocol.LoginHandler")
local BeginnerGuideHandler = require("Protocol.BeginnerGuide.BeginnerGuideHandler")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local TopupData = require("Modules.Topup.TopupData")
local TopupHandler = require("Protocol.Topup.TopupHandler")
local RechargeData = require("Modules.Recharge.RechargeData")
local rapidJson = require("rapidjson")
local BP_LobbyController_C = UnLua.Class()
local BanTipId = 303005
local TeamStateChangeFailErrorCode = 15004
local TopupFailTipId = 306005
function BP_LobbyController_C:ReceiveBeginPlay()
  LogicAvatar.Init()
  if UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    print("LobbyController DS")
    return
  end
  UE.URGGameplayLibrary.TriggerOnClientEnterLobby(GameInstance)
  LogicLobby.Init()
  self.CameraStateMachine = LogicLobby.InitCameraStateMachine()
  LogicRole.Init()
  LogicOutsidePackback.Init()
  LogicCommonTips.Init()
  self.WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/MainLobby/WBP_LobbyPanel.WBP_LobbyPanel_C")
  LogicTalent.Init()
  Logic_Level.Init()
  LogicSoulCore:Init()
  LogicWeaponHandBook:Init()
  LogicOutsideWeapon.Init()
  LogicTeam.Init()
  LogicRole.ChangeRoleSkyLight(false)
  LogicHeroSelect.Init()
  ClimbtowerData:GameFloorPassData()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:Reset(self)
    UIManager:PreloadWithAllScene(UE.EPreLoadScene.Lobby)
  end
  UIMgr:Init()
  UIMgr:Reset()
  UE.URGUIEffectMgr.Get(GameInstance):Reset()
  local Result = self:JudgeWhetherPlayAfterBeginnerGuidanceMovie()
  if not Result then
    print("BP_LobbyController_C:ReceiveBeginPlay \228\184\141\233\156\128\232\166\129\230\146\173\230\148\190\230\150\176\230\137\139\229\133\179\232\167\134\233\162\145")
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        self:ShowLobbyPanel()
      end
    }, 0.1, false)
  else
    ListenObjectMessage(nil, GMP.MSG_CG_Movie_Stop, self, self.BindOnCGMovieStop)
  end
  self:PlayLobbyDefaultVideo()
  self.LobbyActors = {}
  local LobbyModule = ModuleManager:Get("LobbyModule")
  LobbyModule:EnterLobby()
  local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
  if RGHttpClientMgr then
    RGHttpClientMgr.OnHttpBusinessErrorTip:Add(self, BP_LobbyController_C.BindOnHttpBusinessErrorTip)
    RGHttpClientMgr.OnHttpBanDelegate:Add(self, self.BindOnHttpBanDelegate)
  end
  if UE.URGPlatformFunctionLibrary.IsLIPassEnabled() and UE.ULIPassSubsystem then
    local LIPassSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.ULIPassSubsystem:StaticClass())
    if LIPassSystem then
      LIPassSystem.Delegate_OnLIWebViewResult:Add(self, self.BindOnLIWebViewResult)
    end
  end
  if TopupData:IsExecuteINTLPayLogic() then
    local PlatformSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGPlatformCommonSubsystemBase:StaticClass())
    if PlatformSubsystem then
      print("BP_LobbyController_C:ReceiveBeginPlay PlatformSubsystem")
      PlatformSubsystem.OnCtiPurchasePayCallback:Add(self, self.BindOnPurchaseProductsResponseDelegate)
      PlatformSubsystem.OnCtiGetProductInfoCallback:Add(self, self.BindOnGetProductInfoCallback)
      PlatformSubsystem.OnCtiShowPayPanel:Add(self, self.BindOnCtiShowPayPanel)
    end
    TopupHandler:RequestGetAllProductInfo()
  else
    local OnlinePurchaseSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UOnlinePurchaseSystem:StaticClass())
    if OnlinePurchaseSystem then
      OnlinePurchaseSystem.OnPurchaseProductsResponseDelegate:Add(self, self.BindOnPurchaseProductsResponseDelegate)
    end
  end
  print("BattleLagacyModule GetCurrBattleLagacyLogin")
  local BattleLagacyModule = ModuleManager:Get("BattleLagacyModule")
  BattleLagacyModule:GetCurrBattleLagacyLogin()
  if not BeginnerGuideData:CheckFreshmanBDIsFinished() then
    BeginnerGuideHandler.RequestGetFinishedGuideListFromServer()
  end
  LogicLobby.RequestAllGameModeFloorDataToServer()
end
function BP_LobbyController_C:Get2DLobbyWidgetClass()
  return UE.UClass.Load("/Game/Rouge/UI/Lobby/MainLobby/WBP_LobbyPanel.WBP_LobbyPanel_C")
end
function BP_LobbyController_C:BindOnHttpBusinessErrorTip(ErrorCode, ErrorMsg)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager or "" == ErrorMsg then
    return
  end
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
  if tonumber(ErrorCode) == TeamStateChangeFailErrorCode then
    LogicTeam.AddTeamStateChangeFailRecord()
  end
end
function BP_LobbyController_C:BindOnHttpBanDelegate(BanInfo)
  ChatDataMgr.UpdateVoiceBanInfo(BanInfo)
  print("BP_LobbyController_C:BindOnHttpBanDelegate", BanInfo.BanReasonId, BanInfo.BanEndTime, BanInfo.ErrorCode)
  local BanReason = "BanReason"
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBanReason, BanInfo.BanReasonId)
  if Result then
    BanReason = RowInfo.Tips
  end
  local ErrorCodeDesc = ""
  local Result, ErrorCodeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBErrorCode, BanInfo.ErrorCode)
  if Result then
    ErrorCodeDesc = ErrorCodeRowInfo.Tips
  end
  local BanEndTimeFormat = TimestampToDateTimeText(BanInfo.BanEndTime)
  local Params = {
    BanReason,
    ErrorCodeDesc,
    BanEndTimeFormat
  }
  ShowWaveWindowWithConsoleCheck(BanTipId, Params, BanInfo.ErrorCode)
end
function BP_LobbyController_C:ShowLobbyPanel()
  self:ChangeTo2DLobbyView()
  LogicLobby.HideAllLobbyStreamLevel()
  local TeamInfo = DataMgr.GetTeamInfo()
  if not DataMgr.IsInTeam() or TeamInfo.state ~= LogicTeam.TeamState.HeroPicking then
    UIMgr:Show(ViewID.UI_LobbyPanel)
  else
    LogicTeam.RequestGetMyTeamDataToServer()
  end
end
function BP_LobbyController_C:ChangeTo2DLobbyView()
  ChangeToLobbyAnimCamera()
end
function BP_LobbyController_C:JudgeWhetherPlayAfterBeginnerGuidanceMovie(...)
  if not LogicLobby.IsNeedPlayAfterBeginnerGuidanceMovie then
    return false
  else
    LogicLobby.SetIsNeedPlayAfterBeginnerGuidanceMovie(false)
    local MovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
    if not MovieSubsystem then
      return false
    end
    local Settings = UE.URGLobbySettings.GetLobbySettings()
    if 0 == Settings.AfterBeginnerGuidanceMovieId then
      print("BP_LobbyController_C:JudgeWhetherPlayAfterBeginnerGuidanceMovie media id is 0!")
      return false
    end
    if not MovieSubsystem:IsValidMediaId(Settings.AfterBeginnerGuidanceMovieId) then
      print("BP_LobbyController_C:JudgeWhetherPlayAfterBeginnerGuidanceMovie invalid media id, ", Settings.AfterBeginnerGuidanceMovieId)
      return false
    end
    local MoviePlayer = MovieSubsystem:GetDefaultMoviePlayer()
    if not MoviePlayer then
      return false
    end
    MoviePlayer:PlayMovie(Settings.AfterBeginnerGuidanceMovieId)
    return true
  end
end
function BP_LobbyController_C:BindOnCGMovieStop(MovieId)
  print("BP_LobbyController_C:BindOnCGMovieStop", MovieId)
  local Settings = UE.URGLobbySettings.GetLobbySettings()
  if MovieId == Settings.AfterBeginnerGuidanceMovieId then
    print("BP_LobbyController_C:BindOnCGMovieStop cg\230\146\173\230\148\190\229\174\140\230\136\144\239\188\140\230\152\190\231\164\186\229\164\167\229\142\133\228\184\187\231\149\140\233\157\162")
    self:ShowLobbyPanel()
    self.bShowMouseCursor = true
  end
end
function BP_LobbyController_C:PlayLobbyDefaultVideo()
  local LobbySettings = UE.URGLobbySettings.GetLobbySettings()
  local MovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
  if not MovieSubsystem then
    return
  end
  if 0 ~= LobbySettings.LobbyScreenMediaId then
    local MediaObj = MovieSubsystem:GetMediaSource(LobbySettings.LobbyScreenMediaId)
    if MediaObj then
      self.DefaultLobbyMediaPlayer:SetLooping(true)
      self.DefaultLobbyMediaPlayer:OpenSource(MediaObj)
      self.DefaultLobbyMediaPlayer:Rewind()
    end
  else
    self.bShowMouseCursor = true
    print("BP_LobbyController_C:PlayLobbyDefaultVideo MediaId is 0!")
  end
end
function BP_LobbyController_C:K2_OnBecomeViewTarget(PC)
  print("BP_LobbyController_C:OnBecomeViewTarget", PC)
end
function BP_LobbyController_C:BindOnPurchaseProductsResponseDelegate(Result, InnerCode)
  print("BP_LobbyController_C:BindOnPurchaseProductsResponseDelegate, Result:", Result)
  if 0 == Result then
    TopupHandler:RequestPaymentCurrencyAfterPay()
  elseif PayInnerCodeConfig and PayInnerCodeConfig[InnerCode] then
    ShowWaveWindow(PayInnerCodeConfig[InnerCode])
  else
    ShowWaveWindow(TopupFailTipId)
  end
end
function BP_LobbyController_C:BindOnGetProductInfoCallback(RetCode, ProductInfo)
  print("BP_LobbyController_C:BindOnGetProductInfoCallback", RetCode, ProductInfo)
  if 0 ~= RetCode then
    return
  end
  local JsonTable = rapidJson.decode(ProductInfo)
  for i, SingleProductInfo in ipairs(JsonTable) do
    TopupData:SetSDKProductInfo(SingleProductInfo)
  end
  EventSystem.Invoke(EventDef.Lobby.UpdateTopupProductInfo)
end
function BP_LobbyController_C:BindOnCtiShowPayPanel(URL)
  print("BP_LobbyController_C:BindOnCtiShowPayPanel", URL)
  UIMgr:Show(ViewID.UI_MidasPayPanel, false, URL)
end
function BP_LobbyController_C:BindOnLIWebViewResult(INTLWebViewResult)
  LogicLobby.HandleOnLIWebViewResult(INTLWebViewResult)
end
function BP_LobbyController_C:ReceiveEndPlay()
  if UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  LogicLobby.Clear()
  LogicRole.Clear()
  LogicTalent.Clear()
  Logic_Level.HideSelf()
  LogicSoulCore:Clear()
  LogicWeaponHandBook:Clear()
  LogicOutsideWeapon.Clear()
  LogicTeam.Clear()
  LogicOutsidePackback.Clear()
  LogicCommonTips.Clear()
  LogicHeroSelect.Clear()
  UnListenObjectMessage(GMP.MSG_CG_Movie_Stop, self)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CosCheckTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CosCheckTimer)
  end
  local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
  if RGHttpClientMgr then
    RGHttpClientMgr.OnHttpBusinessErrorTip:Remove(self, BP_LobbyController_C.BindOnHttpBusinessErrorTip)
    RGHttpClientMgr.OnHttpBanDelegate:Remove(self, self.BindOnHttpBanDelegate)
  end
  if UE.URGPlatformFunctionLibrary.IsLIPassEnabled() and UE.ULIPassSubsystem then
    local LIPassSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.ULIPassSubsystem:StaticClass())
    if LIPassSystem then
      LIPassSystem.Delegate_OnLIWebViewResult:Remove(self, self.BindOnLIWebViewResult)
    end
  end
  if TopupData:IsExecuteINTLPayLogic() then
    local PlatformSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGPlatformCommonSubsystemBase:StaticClass())
    if PlatformSubsystem then
      PlatformSubsystem.OnCtiPurchasePayCallback:Remove(self, self.BindOnPurchaseProductsResponseDelegate)
      PlatformSubsystem.OnCtiGetProductInfoCallback:Remove(self, self.BindOnGetProductInfoCallback)
      PlatformSubsystem.OnCtiShowPayPanel:Remove(self, self.BindOnCtiShowPayPanel)
    end
  else
    local OnlinePurchaseSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UOnlinePurchaseSystem:StaticClass())
    if OnlinePurchaseSystem then
      OnlinePurchaseSystem.OnPurchaseProductsResponseDelegate:Remove(self, self.BindOnPurchaseProductsResponseDelegate)
    end
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if UIManager then
    print("BP_LobbyController_C:ReceiveEndPlay Reset")
    UIManager:Reset()
    UIManager:UnloadPreloadWidget(UE.EPreLoadScene.Lobby)
  end
  UE.URGUIEffectMgr.Get(GameInstance):Reset()
  if self.DefaultLobbyMediaPlayer:IsPlaying() then
    self.DefaultLobbyMediaPlayer:SetLooping(false)
    self.DefaultLobbyMediaPlayer:Close()
  end
  ChatDataMgr.ClearDataWhenEnterBattle()
  DataMgr.ClearPlayerInfoData()
  local LobbyModule = ModuleManager:Get("LobbyModule")
  LobbyModule:ExitLobby()
end
function BP_LobbyController_C:OnWindowCloseRequested()
  print("BP_LobbyController_C:OnWindowCloseRequested")
  if DataMgr.GetDistributionChannel() == LogicLobby.DistributionChannelList.WeGame then
    print("BP_LobbyController_C:OnWindowCloseRequested ExecuteWeGameLogOut")
    local OnlineIdentitySystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UOnlineIdentitySystem:StaticClass())
    if OnlineIdentitySystem then
      local Result = OnlineIdentitySystem:Logout()
      print("WeGame Logout Result:", Result)
    end
  end
  return true
end
function BP_LobbyController_C:OpenLobbyGM()
  if UIMgr:IsShow(ViewID.UI_LobbyGM) then
    UIMgr:Hide(ViewID.UI_LobbyGM)
  else
    UIMgr:Show(ViewID.UI_LobbyGM)
  end
end
function BP_LobbyController_C:GetCurSceneStatus()
  return UE.ESceneStatus.ELobby
end
return BP_LobbyController_C
