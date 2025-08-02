local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local BattlePassHandler = require("Protocol.BattlePass.BattlePassHandler")
local PandoraData = require("Modules.Pandora.PandoraData")
local LobbyMainView = Class(ViewBase)

function LobbyMainView:BindClickHandler()
  self.Btn_ChangeMode.OnClicked:Add(self, self.BindOnChangeModeButtonClicked)
  self.Btn_ChangeMode.OnHovered:Add(self, self.BindOnChangeModeButtonHovered)
  self.Btn_ChangeMode.OnUnhovered:Add(self, self.BindOnChangeModeButtonUnhovered)
  self.Btn_DrawCard.OnClicked:Add(self, self.BindOnDrawCardButtonClicked)
  self.Btn_LoginRewards.OnClicked:Add(self, self.BindOnLoginRewardsButtonClicked)
  self.Btn_MiddleModelArea.OnHovered:Add(self, self.BindOnMiddleModelAreaHovered)
  self.Btn_MiddleModelArea.OnUnhovered:Add(self, self.BindOnMiddleModelAreaUnhovered)
  self.Btn_MiddleModelArea.OnClicked:Add(self, self.BindOnMiddleModelAreaClicked)
  self.Btn_LeftModelArea.OnHovered:Add(self, self.BindOnLeftModelAreaHovered)
  self.Btn_LeftModelArea.OnUnhovered:Add(self, self.BindOnLeftModelAreaUnhovered)
  self.Btn_LeftModelArea.OnClicked:Add(self, self.BindOnLeftModelAreaClicked)
  self.Btn_RightModelArea.OnHovered:Add(self, self.BindOnRightModelAreaHovered)
  self.Btn_RightModelArea.OnUnhovered:Add(self, self.BindOnRightModelAreaUnhovered)
  self.Btn_RightModelArea.OnClicked:Add(self, self.BindOnRightModelAreaClicked)
  self.Btn_Recruit.OnClicked:Add(self, self.BindOnRecruitClicked)
  self.Btn_ChangeToSeason.OnClicked:Add(self, self.BindOnChangeToSeasonClicked)
  self:RequesRewards()
  self:OnUpdateMyTeamInfo()
end

function LobbyMainView:UnBindClickHandler()
  self.Btn_ChangeMode.OnClicked:Remove(self, self.BindOnChangeModeButtonClicked)
  self.Btn_ChangeMode.OnHovered:Remove(self, self.BindOnChangeModeButtonHovered)
  self.Btn_ChangeMode.OnUnhovered:Remove(self, self.BindOnChangeModeButtonUnhovered)
  self.Btn_DrawCard.OnClicked:Remove(self, self.BindOnDrawCardButtonClicked)
  self.Btn_LoginRewards.OnClicked:Remove(self, self.BindOnLoginRewardsButtonClicked)
  self.Btn_MiddleModelArea.OnHovered:Remove(self, self.BindOnMiddleModelAreaHovered)
  self.Btn_MiddleModelArea.OnUnhovered:Remove(self, self.BindOnMiddleModelAreaUnhovered)
  self.Btn_MiddleModelArea.OnClicked:Remove(self, self.BindOnMiddleModelAreaClicked)
  self.Btn_LeftModelArea.OnHovered:Remove(self, self.BindOnLeftModelAreaHovered)
  self.Btn_LeftModelArea.OnUnhovered:Remove(self, self.BindOnLeftModelAreaUnhovered)
  self.Btn_LeftModelArea.OnClicked:Remove(self, self.BindOnLeftModelAreaClicked)
  self.Btn_RightModelArea.OnHovered:Remove(self, self.BindOnRightModelAreaHovered)
  self.Btn_RightModelArea.OnUnhovered:Remove(self, self.BindOnRightModelAreaUnhovered)
  self.Btn_RightModelArea.OnClicked:Remove(self, self.BindOnRightModelAreaClicked)
  self.Btn_Recruit.OnClicked:Remove(self, self.BindOnRecruitClicked)
  self.Btn_ChangeToSeason.OnClicked:Remove(self, self.BindOnChangeToSeasonClicked)
end

function LobbyMainView:RequesRewards()
  UpdateVisibility(self.Btn_LoginRewards, true, true)
end

function LobbyMainView:BindOnChangeModeButtonClicked()
  self:PlayAnimation(self.ani_ChangeModeBtnPanel_click)
end

function LobbyMainView:BindOnChangeModeButtonHovered()
  self:ChangeModeButtonHoverVis(true)
end

function LobbyMainView:BindOnChangeModeButtonUnhovered()
  self:ChangeModeButtonHoverVis(false)
end

function LobbyMainView:BindOnDrawCardButtonClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.CHOU_KA) then
    return
  end
  self.ViewModel:BindOnDrawCardButtonClicked()
end

function LobbyMainView:BindOnLoginRewardsButtonClicked()
  local LobbyModule = ModuleManager:Get("LobbyModule")
  local viewData = {
    ViewID = ViewID.UI_LoginRewardActivity,
    Params = {10000}
  }
  LobbyModule:PushView(viewData)
end

function LobbyMainView:BindOnMiddleModelAreaHovered()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaHoveredChanged, true, 1)
end

function LobbyMainView:BindOnMiddleModelAreaUnhovered()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaHoveredChanged, false)
end

function LobbyMainView:BindOnMiddleModelAreaClicked()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaClickedChanged, true, 1)
end

function LobbyMainView:BindOnLeftModelAreaHovered()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaHoveredChanged, true, 2)
end

function LobbyMainView:BindOnLeftModelAreaUnhovered()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaHoveredChanged, false)
end

function LobbyMainView:BindOnLeftModelAreaClicked()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaClickedChanged, true, 2)
end

function LobbyMainView:BindOnRightModelAreaHovered()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaHoveredChanged, true, 3)
end

function LobbyMainView:BindOnRightModelAreaUnhovered()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaHoveredChanged, false)
end

function LobbyMainView:BindOnRightModelAreaClicked()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaClickedChanged, true, 3)
end

function LobbyMainView:BindOnChangeToSeasonClicked()
  ShowWaveWindowWithDelegate(1452, {}, {
    GameInstance,
    function()
      local SeasonModule = ModuleManager:Get("SeasonModule")
      SeasonModule:SetSeasonMode(ESeasonMode.SeasonMode)
    end
  })
end

function LobbyMainView:BindOnRecruitClicked()
  UIMgr:Show(ViewID.UI_RecruitMainView, true)
end

function LobbyMainView:BindOnAddTeamButtonClicked()
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics("LobbyTeamEntrance")
  end
  if not DataMgr.IsInTeam() then
    LogicTeam.RequestCreateTeamToServer()
  end
  UIMgr:Show(ViewID.UI_MatchingPanel)
end

function LobbyMainView:PlayInAnimation()
  self:PlayAnimation(self.ani_lobbymain_in, 0, 1, UE.EUMGSequencePlayMode.Forward, 1, false)
  self.WBP_LobbyTaskPanel:PlayInAnimation()
end

function LobbyMainView:StopLobbyMainAni()
  self:StopAnimation(self.ani_lobbymain_in)
end

function LobbyMainView:PlayOutAnimation()
  self:PlayAnimation(self.ani_lobbymain_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 1, false)
end

function LobbyMainView:OnAnimationFinished(Animation)
  if Animation == self.ani_ChangeModeBtnPanel_click then
    self.ViewModel:OpenChangeModePanel()
  end
end

function LobbyMainView:ChangeModeButtonHoverVis(IsHover)
  if IsHover then
    self.Image_loop_2:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Image_loop_3:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_loop_2:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Image_loop_3:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function LobbyMainView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("LobbyMainViewModel")
  self:BindClickHandler()
  self.ViewModel:InitLobbyTeamRoleActors()
  LogicTeam.RequestGetMyTeamDataToServer()
  BeginnerGuideData:UpdateWidget("Button_StartMatch", self.WBP_StartOrMatch.Button_StartMatch)
end

function LobbyMainView:OnDestroy()
  self:UnBindClickHandler()
end

function LobbyMainView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr then
    if not SystemOpenMgr:IsSystemOpen(SystemOpenID.CHOU_KA, false) then
      UIUtil.SetVisibility(self.Btn_DrawCard, false)
    end
    if not SystemOpenMgr:IsSystemOpen(SystemOpenID.PASS, false) then
      UIUtil.SetVisibility(self.WBP_BattlePassEntry, false)
    end
  end
  self:ChangeModeButtonHoverVis(false)
  self.TeamOperateButtonPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ClickBG:SetVisibility(UE.ESlateVisibility.Collapsed)
  LogicLobby:ChangeLobbyBGVis(false)
  LogicLobby.ChangeLobbyMainModelVis(true)
  self.ViewModel:SetModelClickAreaOpacity(0)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.InitPosTimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.InitPosTimerHandle)
  end
  self.InitPosTimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.ViewModel:InitPanelPosition()
      self.ViewModel:SetModelClickAreaOpacity(1)
    end
  }, 0.6, false)
  self:PlayInAnimation()
  self.ViewModel:BindOnUpdateMyTeamInfo()
  self.ViewModel:BindOnUpdateTeamMembersInfo()
  local TeamInfo = DataMgr.GetTeamInfo()
  local TeamState = DataMgr.IsInTeam() and TeamInfo.state or 0
  self.ViewModel:BindOnTeamStateChanged(TeamState, TeamState)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShow)
  self.ViewModel:UpdateGameModeInfo()
  self.ViewModel:ChangeOwnNameWidgetVisibility()
  self.WBP_StartOrMatch:Show()
  self.WBP_CombatPowerTip:Show()
  self.WBP_ChatView:FocusInput()
  Logic_MainTask.LoadInviteDialogue()
  BeginnerGuideData:UpdateWBP("WBP_LobbyMain", self)
  self.WBP_BattleLagacyLobbyItem:InitBattleLagacyLobbyItem(self)
  self:GetBattlePassData()
  self.WBP_MonthCardIcon:Show(DataMgr.GetUserId(), true)
  EventSystem.AddListener(self, EventDef.Lobby.OnUpdateLoginRewards, self.OnUpdateLoginRewards)
  EventSystem.AddListenerNew(EventDef.SystemUnlock.SystemUnlockUpdate, self, self.GetBattlePassData)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraWidgetCreated, self.BindPandoraWidgetCreated)
  EventSystem.AddListener(self, EventDef.Pandora.pandoraWidgetDestroy, self.BindPandoraWidgetDestroy)
  ChangeToLobbyAnimCamera()
  local LobbyModule = ModuleManager:Get("LobbyModule")
  if LobbyModule then
    LobbyModule:CheckShowInitialRoleSelection()
  end
  SetLobbyPanelCurrencyList(true, {
    99994,
    300005,
    300101
  })
  EventSystem.AddListener(self, EventDef.Pandora.NotifyPandoraADPositionReady, self.BindNotifyPandoraADPositionReady)
  self:BindNotifyPandoraADPositionReady()
  self.WBP_StartOrMatch.CanvasPanel_start:UpdateWidget()
end

function LobbyMainView:LuaTick(InDeltaTime)
end

function LobbyMainView:OnUpdateLoginRewards()
  local VM = UIModelMgr:Get("LoginRewardsViewModel")
  if VM then
    if VM:HaveRewards() then
      self.WBP_RedDotView_LoginRewards:SetNum(7 - table.count(VM.Rewards))
    else
      self.WBP_RedDotView_LoginRewards:SetNum(0)
    end
  end
end

function LobbyMainView:OnHide()
  self.WBP_StartOrMatch:Hide()
  self.WBP_CombatPowerTip:Hide()
  EventSystem.RemoveListener(EventDef.Lobby.OnUpdateLoginRewards, self.OnUpdateLoginRewards, self)
  EventSystem.RemoveListenerNew(EventDef.SystemUnlock.SystemUnlockUpdate, self, self.GetBattlePassData)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraWidgetCreated, self.BindPandoraWidgetCreated, self)
  EventSystem.RemoveListener(EventDef.Pandora.pandoraWidgetCreated, self.BindPandoraWidgetDestroy, self)
  EventSystem.RemoveListener(EventDef.Pandora.NotifyPandoraADPositionReady, self.BindNotifyPandoraADPositionReady, self)
  local CarouselImageAppId = PandoraData:GetCarouselImageAppId()
  if CarouselImageAppId then
    ClosePandorApp(CarouselImageAppId)
  end
  local TreasureAppId = PandoraData:GetTreasureAppId()
  if TreasureAppId then
    ClosePandorApp(TreasureAppId)
  end
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function LobbyMainView:OnRollback()
  print("LobbyMainView:OnRollback")
  ChangeToLobbyAnimCamera()
  self.ViewModel:SetModelClickAreaOpacity(0)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.InitPosTimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.InitPosTimerHandle)
  end
  self.InitPosTimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.ViewModel:InitPanelPosition()
      self.ViewModel:SetModelClickAreaOpacity(1)
    end
  }, 0.6, false)
  LogicLobby.ChangeLobbyMainModelVis(true)
  self:PlayInAnimation()
  EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShow)
  self.WBP_StartOrMatch.CanvasPanel_start:UpdateWidget()
end

function LobbyMainView:OnBindUIInput()
  self.WBP_InteractTipWidgetChangeMode:BindInteractAndClickEvent(self, self.BindOnChangeModeButtonClicked)
end

function LobbyMainView:OnUnBindUIInput()
  self.WBP_InteractTipWidgetChangeMode:UnBindInteractAndClickEvent(self, self.BindOnChangeModeButtonClicked)
end

function LobbyMainView:OnUpdateMyTeamInfo()
  if BattleLagacyData.CurBattleLagacyData == nil then
    return
  end
  if BattleLagacyData.CurBattleLagacyData.BattleLagacyId == "0" then
    return
  end
  local bIsActive = BattleLagacyModule:CheckBattleLagacyIsActive()
  if not bIsActive and self.ViewModel.bBattleLagacyActive then
    UpdateVisibility(self.WBP_BattleLagacyLobbyNotActiveTips, true)
    self:PlayAnimation(self.ani_lobbymain_battlelagacynotactivetips_in)
  else
    UpdateVisibility(self.WBP_BattleLagacyLobbyNotActiveTips, false)
  end
  self.ViewModel.bBattleLagacyActive = bIsActive
end

function LobbyMainView:ShowBattleLagacyTips(bIsShow, CurBattleLagacyData, bActive)
  UpdateVisibility(self.WBP_GenericModifyBagTips, false)
  UpdateVisibility(self.WBP_BattleLagacyLobbyTips, false)
  if bIsShow then
    UpdateVisibility(self.WBP_BattleLagacyLobbyTips, true)
    self.WBP_BattleLagacyLobbyTips:InitBattleLagacyLobbyTips(CurBattleLagacyData, self)
  end
end

function LobbyMainView:ShowLagacyModifyDetailsTips(bIsShow, CurBattleLagacyData)
  UpdateVisibility(self.WBP_GenericModifyBagTips, bIsShow)
  if bIsShow then
    self.WBP_GenericModifyBagTips:InitGenericModifyTips(tonumber(CurBattleLagacyData.BattleLagacyId), false, -1)
  end
end

function LobbyMainView:GetBattlePassData()
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and not SystemUnlockModule:CheckIsSystemUnlock(2) then
    return
  end
  local openBattlePass = self.ViewModel:CheckOpeningBattlePass()
  local BattlePassSubViewModel = UIModelMgr:Get("BattlePassSubViewModel")
  BattlePassSubViewModel:SendGetBattlePassData(openBattlePass.BattlePassID)
end

function LobbyMainView:UpdateBattlePassInfo(BattlePassInfo, BattlePassID)
  local level = BattlePassInfo.level
  local exp = BattlePassInfo.exp
  local state = BattlePassInfo.battlePassActivateState
  self.WBP_BattlePassEntry:InitInfo(level, exp, state, BattlePassID)
end

function LobbyMainView:BindPandoraWidgetCreated(Widget, AppId)
  local PandoraWidgetSlot
  if AppId == PandoraData:GetCarouselImageAppId() then
    PandoraWidgetSlot = self.CanvasPanel_CarouselImage:AddChild(Widget)
  else
    PandoraWidgetSlot = self.CanvasPanel_Treasure:AddChild(Widget)
  end
  if PandoraWidgetSlot then
    local Anchors = UE.FAnchors()
    Anchors.Minimum = UE.FVector2D(0, 0)
    Anchors.Maximum = UE.FVector2D(1.0, 1.0)
    PandoraWidgetSlot:SetAnchors(Anchors)
    local Offsets = UE.FMargin()
    PandoraWidgetSlot:SetOffsets(Offsets)
  end
end

function LobbyMainView:BindPandoraWidgetDestroy(Widget, AppId)
  if AppId == PandoraData:GetCarouselImageAppId() then
    self.CanvasPanel_CarouselImage:ClearChildren()
  else
    self.CanvasPanel_Treasure:ClearChildren()
  end
end

function LobbyMainView:BindNotifyPandoraADPositionReady()
  local CarouselImageAppId = PandoraData:GetCarouselImageAppId()
  if CarouselImageAppId then
    OpenPandorApp(CarouselImageAppId)
  end
  local TreasureAppId = PandoraData:GetTreasureAppId()
  if TreasureAppId then
    OpenPandorApp(TreasureAppId)
  end
end

return LobbyMainView
