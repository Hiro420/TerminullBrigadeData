require("Rouge.UI.HUD.Logic.Logic_HUD")
require("Rouge.UI.Battle.Logic.Logic_DamageNumber")
require("Rouge.UI.HUD.Buff.Logic_Element")
require("Rouge.UI.Battle.Logic.Logic_HitEffect")
require("Rouge.UI.Battle.Logic.Logic_BuffList")
require("Rouge.UI.Battle.Logic.Logic_PickUp")
require("Rouge.UI.Battle.Logic.Logic_Scroll")
require("Rouge.UI.Radio.LogicRadio")
require("Rouge.UI.Radio.BattleData")
require("Rouge.UI.Radio.LogicCondition")
require("Rouge.UI.Lobby.Logic.Logic_Role")
require("Rouge.UI.Lobby.Logic.Logic_GameSetting")
require("Rouge.UI.Battle.Logic.Logic_Mark")
require("Rouge.UI.Battle.Logic.Logic_GenericModify")
require("Rouge.UI.Battle.Logic.Logic_Shop")
require("Rouge.UI.Lobby.Logic.Logic_Talent")
require("Rouge.UI.Lobby.Logic.Logic_OutsidePackback")
require("Rouge.UI.Battle.Logic.Logic_Vote")
require("Rouge.UI.Battle.Logic.Logic_SurVivor")
require("Rouge.UI.Lobby.Logic.Logic_Team")
require("Rouge.UI.Battle.Logic.Logic_BodyPart")
require("Rouge.UI.Progerss.LogicProgressSystem")
require("Rouge.UI.HUD.Logic.Logic_BeginnerGuidance")
require("Rouge.UI.IllustratedGuide.Logic_IllustratedGuide")
require("Rouge.UI.TaskPanel.Logic_TaskPanel")
require("Rouge.UI.Lobby.Logic.Logic_CommonTips")
require("Rouge.UI.Battle.Logic.Logic_BossRush")
require("Rouge.UI.Battle.Logic.Logic_SurvivalTips")
require("Rouge.UI.Battle.UIScalability")
if Logic_MainTask == nil then
  require("Rouge.UI.MainTask.Logic_MainTask")
end
local LoginHandler = require("Protocol.LoginHandler")
local BanTipId = 303005
local BP_RGPlayerController_C = UnLua.Class()

function BP_RGPlayerController_C:Initialize(Initializer)
  print("BP_RGPlayerController_C:Initialize")
  self.GCTimer = nil
  self.GCTickInterval = 0.033
end

function BP_RGPlayerController_C:ReceiveBeginPlay()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:PreloadWithAllScene(UE.EPreLoadScene.Battle)
  end
  DataMgr.ResetFreezeTimestamp()
  if not UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    if UE.URGBlueprintLibrary.CheckWithEditor() then
      LogicGameSetting.InitCustomKeySetting()
    end
    UIMgr:Init(10)
    UIMgr:Reset()
    UE.URGUIEffectMgr.Get(GameInstance):Reset()
    local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
    if RGHttpClientMgr then
      RGHttpClientMgr.OnHttpBanDelegate:Add(self, self.BindOnHttpBanDelegate)
    end
    if UE.URGPlatformFunctionLibrary.IsLIPassEnabled() and UE.ULIPassSubsystem then
      local LIPassSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.ULIPassSubsystem:StaticClass())
      if LIPassSystem then
        LIPassSystem.Delegate_OnLIWebViewResult:Add(self, self.BindOnLIWebViewResult)
      end
    end
    print("BP_RGPlayerController_C:ReceiveBeginPlay CursorVirtualFocus 1")
    UE.URGBlueprintLibrary.CursorVirtualFocus(1)
  end
end

function BP_RGPlayerController_C:BindOnHttpBanDelegate(BanInfo)
  ChatDataMgr.UpdateVoiceBanInfo(BanInfo)
  print("BP_RGPlayerController_C:BindOnHttpBanDelegate", BanInfo.BanReasonId, BanInfo.BanEndTime, BanInfo.ErrorCode)
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

function BP_RGPlayerController_C:BindOnLIWebViewResult(INTLWebViewResult)
  LogicLobby.HandleOnLIWebViewResult(INTLWebViewResult)
end

function BP_RGPlayerController_C:ReceiveEndPlay()
  if not UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    LogicDamageNumber:Clear()
    LogicBossRush:Clear()
    LogicHitEffect:Clear()
    LogicBuffList.Clear()
    LogicPickup.Clear()
    Logic_Scroll.Clear()
    LogicGenericModify.Clear()
    LogicHUD.Clear()
    LogicElement.Clear()
    BattleData.Clear()
    LogicRadio.ClearBattleData()
    LogicRole.Clear()
    LogicMark.Clear()
    LogicShop.Clear()
    LogicTalent.Clear()
    LogicOutsidePackback.Clear()
    LogicCommonTips.Clear()
    LogicVote.Clear()
    LogicSurvivor.Clear()
    LogicBodyPart.Clear()
    LogicBeginnerGuidance.Clear()
    Logic_SurvivalTips.Clear()
    DataMgr.ResetFreezeTimestamp()
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
    if UIManager then
      UIManager:Reset(self)
      UIManager:UnloadPreloadWidget(UE.EPreLoadScene.Battle)
    end
    local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
    if RGHttpClientMgr then
      RGHttpClientMgr.OnHttpBanDelegate:Remove(self, self.BindOnHttpBanDelegate)
    end
    if UE.URGPlatformFunctionLibrary.IsLIPassEnabled() and UE.ULIPassSubsystem then
      local LIPassSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.ULIPassSubsystem:StaticClass())
      if LIPassSystem then
        LIPassSystem.Delegate_OnLIWebViewResult:Remove(self, self.BindOnLIWebViewResult)
      end
    end
  end
end

function BP_RGPlayerController_C:RequestConnectLobbyToServer()
  if WSCommunication and WSCommunication.IsReconnectFail then
    LoginHandler.RequestLogoutToServer()
  else
    local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGGameLevelSystem:StaticClass())
    if GameLevelSystem and GameLevelSystem:IsAutoPlayerRun() then
      LogicLobby.OpenLobbyLevel()
    else
      LogicSettlement.SetClearanceStatus(SettlementStatus.Exit)
      NotifyObjectMessage(nil, "OnSettlement")
    end
  end
end

function BP_RGPlayerController_C:OnWindowCloseRequested()
  print("BP_RGPlayerController_C:OnWindowCloseRequested")
  if DataMgr.GetDistributionChannel() == LogicLobby.DistributionChannelList.WeGame then
    print("BP_RGPlayerController_C:OnWindowCloseRequested ExecuteWeGameLogOut")
    local OnlineIdentitySystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UOnlineIdentitySystem:StaticClass())
    if OnlineIdentitySystem then
      local Result = OnlineIdentitySystem:Logout()
      print("WeGame Logout Result:", Result)
    end
  end
  return true
end

function BP_RGPlayerController_C:BindHUDEvent()
  LogicRadio.Init()
  BattleData.Init()
  LogicCondition.Init()
  LogicHUD:Init()
  LogicDamageNumber.Init()
  LogicElement.Init()
  LogicHitEffect.Init()
  LogicBuffList.Init()
  LogicPickup.Init()
  Logic_Scroll.Init()
  LogicGenericModify.Init()
  LogicSettlement.Init()
  LogicRole.Init(true)
  LogicGameSetting.Init()
  LogicMark.Init()
  LogicShop.Init()
  LogicTalent.Init()
  LogicOutsidePackback.Init()
  LogicVote.Init()
  LogicSurvivor.Init()
  Logic_IllustratedGuide.LoadGenericModifyTable()
  LogicTeam.Init()
  LogicBodyPart.Init()
  LogicCommonTips.Init()
  LogicBossRush:Init()
  Logic_SurvivalTips.Init()
  LogicBeginnerGuidance.Init()
  RGUIMgr:OpenUI(UIConfig.WBP_Marquee.UIName)
end

function BP_RGPlayerController_C:CreateHUDEvent()
  LogicHUD:CreateHUD()
  NotifyObjectMessage(nil, GMP.MSG_UI_HUD_OnCreate)
end

function BP_RGPlayerController_C:RefreshHUDEvent()
  LogicPickup.Init()
  Logic_Scroll.Init()
  LogicHUD.RefreshHUDEvent()
end

function BP_RGPlayerController_C:BP_InitSettlementBattleLegacy(BattleLegacyData)
  print("BP_RGPlayerController_C:BP_InitSettlementBattleLegacy", BattleLegacyData)
  self.Overridden.BP_InitSettlementBattleLegacy(self, BattleLegacyData)
  LogicSettlement:InitBattleLegacyData(BattleLegacyData)
end

function BP_RGPlayerController_C:BP_OpenMODChoosePanel(NPCCharacterMOD)
end

function BP_RGPlayerController_C:BP_OnAllPlayerDead()
  LogicSettlement.SetClearanceStatus(SettlementStatus.AllDie)
  NotifyObjectMessage(nil, "OnSettlement")
end

function BP_RGPlayerController_C:BP_OnGameSuccess(Result)
  if Result == UE.EGameResult.WIN then
    LogicSettlement.SetClearanceStatus(SettlementStatus.Finish)
  elseif Result == UE.EGameResult.FAILED or Result == UE.EGameResult.QUIT then
    LogicSettlement.SetClearanceStatus(SettlementStatus.AllDie)
  end
  NotifyObjectMessage(nil, "OnSettlement")
end

function BP_RGPlayerController_C:BP_OnGameSuccessCountDown(DelayTime, ServerUTCTimeStampParam)
  print("BP_RGPlayerController_C:BP_OnGameSuccessCountDown", DelayTime, ServerUTCTimeStampParam)
  RGUIMgr:OpenUI(UIConfig.WBP_SettleCountDown_C.UIName, false)
  local CountDownWidget = RGUIMgr:GetUI(UIConfig.WBP_SettleCountDown_C.UIName)
  if IsValidObj(CountDownWidget) then
    CountDownWidget:InitCountDwon(DelayTime)
  end
end

function BP_RGPlayerController_C:BP_OnSettlementSummaryData(SummaryDataAryParam)
end

function BP_RGPlayerController_C:BP_OnSettlementModifyData()
end

function BP_RGPlayerController_C:BP_OnSettlementItemData()
end

function BP_RGPlayerController_C:OnAttributeModifyUpdate()
end

function BP_RGPlayerController_C:BP_NotifySkillIsCooldowning()
end

function BP_RGPlayerController_C:ChooseAIAttributeTarget()
  local ScreenX = UE.UWidgetLayoutLibrary.GetViewportSize(self).X / 2.0
  local ScreenY = UE.UWidgetLayoutLibrary.GetViewportSize(self).Y / 2.0
  local bResult, WorldLocation, WorldDirection = self:DeprojectScreenPositionToWorld(ScreenX, ScreenY, nil, nil)
  local Result, HitResult = UE.UKismetSystemLibrary.LineTraceSingle(self, WorldLocation, WorldLocation + WorldDirection * 20000, UE.ETraceTypeQuery.ShootTrace, false, nil, UE.EDrawDebugTrace.None, nil)
  local TargetActor
  if HitResult.Actor then
    TargetActor = HitResult.Actor:Cast(UE.AAICharacterBase)
  end
  if TargetActor then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGUIManager:StaticClass())
    if UIManager then
      local Widget = UIManager:K2_GetUI(UE.UClass.Load("/Game/Rouge/UI/GM/WBP_AIAttribute.WBP_AIAttribute_C"))
      if Widget then
        Widget:UpdateInfo(TargetActor)
      end
    end
  end
end

function BP_RGPlayerController_C:ShowPickupList()
end

function BP_RGPlayerController_C:BP_CheckIsMvp(PlayerId)
  local MvpPlayer, _ = LogicSettlement:CalMvp(true)
  print("BP_RGPlayerController_C:BP_CheckIsMvp CHJ", PlayerId, MvpPlayer.PlayerId, MvpPlayer.PlayerId == PlayerId)
  return MvpPlayer.PlayerId == PlayerId
end

function BP_RGPlayerController_C:GetCurSceneStatus()
  return UE.ESceneStatus.EBattle
end

local ImportantUMG = {
  "WBP_BattleModeTeaching_C",
  "WBP_BattleMode_RuleTip_C",
  "WBP_GenericModifyChoosePanel_C",
  "WBP_GenericModifyChooseSell_C",
  "WBP_RGBeginnerGuidancePanel_C"
}

function BP_RGPlayerController_C:CheckCanOpenUI()
  for i, WidgetName in ipairs(ImportantUMG) do
    if RGUIMgr:GetUI(WidgetName) and RGUIMgr:GetUI(WidgetName).CheckShouldBlockOpenOtherUI then
      if RGUIMgr:GetUI(WidgetName):CheckShouldBlockOpenOtherUI() then
        return false
      end
    elseif RGUIMgr:IsShown(WidgetName) then
      return false
    end
  end
  return true
end

function BP_RGPlayerController_C:ShowOrHideRoulette(IsShow)
  if not self:CheckCanOpenUI() then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_HUDRoulette_C.UIName) then
    if not IsShow then
      RGUIMgr:HideUI(UIConfig.WBP_HUDRoulette_C.UIName)
    end
  elseif IsShow then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC.bShowMouseCursor then
      return
    end
    RGUIMgr:OpenUI(UIConfig.WBP_HUDRoulette_C.UIName, false)
  end
end

function BP_RGPlayerController_C:TriggerBossTipsUI(BossType)
  EventSystem.Invoke(EventDef.BossTips.BossTipsUI, BossType)
end

return BP_RGPlayerController_C
