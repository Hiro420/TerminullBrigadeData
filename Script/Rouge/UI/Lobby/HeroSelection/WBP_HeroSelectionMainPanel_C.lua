local climbtowerdata = require("UI.View.ClimbTower.ClimbTowerData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local WBP_HeroSelectionMainPanel_C = UnLua.Class()

function WBP_HeroSelectionMainPanel_C:Construct()
  self.Btn_ChangeHero.OnClicked:Add(self, self.BindOnChangeHeroButtonClicked)
  self.Btn_ChangeHero.OnHovered:Add(self, self.BindOnChangeHeroButtonHovered)
  self.Btn_ChangeHero.OnUnhovered:Add(self, self.BindOnChangeHeroButtonUnhovered)
  self.Btn_Pick.OnClicked:Add(self, self.BindOnPickButtonClicked)
  self.Btn_Pick.OnHovered:Add(self, self.BindOnPickButtonHovered)
  self.Btn_Pick.OnUnhovered:Add(self, self.BindOnPickButtonUnhovered)
  self.Btn_CancelPick.OnClicked:Add(self, self.BindOnCancelPickButtonClicked)
  self.Btn_CancelPick.OnHovered:Add(self, self.BindOnCancelPickButtonHovered)
  self.Btn_CancelPick.OnUnhovered:Add(self, self.BindOnCancelPickButtonUnhovered)
  self:InitTeamRoleActors()
  self.UseMemberList = {}
  self.Btn_Debuff.OnClicked:Add(self, function()
    UpdateVisibility(self.WBP_ClimbTower_DebuffPanle, true, true)
    local TeamInfo = DataMgr.GetTeamInfo()
    local Players = {}
    for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
      if SinglePlayerInfo.id ~= DataMgr.GetUserId() then
        table.insert(Players, SinglePlayerInfo.id)
      end
    end
    table.insert(Players, DataMgr.GetUserId())
    self.WBP_ClimbTower_DebuffPanle:Init(Players, 2)
  end)
end

function WBP_HeroSelectionMainPanel_C:InitTeamRoleActors()
  self.TeamMemberActors:Clear()
  local MaxTeamNum = 3
  local LobbySettings = UE.URGLobbySettings.GetSettings()
  if LobbySettings then
    MaxTeamNum = LobbySettings.LobbyRoomMaxMember
  end
  for i = 1, MaxTeamNum do
    local OutActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "HeroSelectRole" .. i):ToTable()
    if OutActors[1] then
      self.TeamMemberActors:Add(OutActors[1])
    end
  end
end

function WBP_HeroSelectionMainPanel_C:BindOnChangeHeroButtonClicked()
  LuaAddClickStatistics("PreparingChangeCharacter")
  self:ChangePanelStateVis(true)
  self:InitHeroSelectTeamInfoPanelVis()
  self:UpdateHeroSelectTeamInfo()
  self:PlayAnimationForward(self.Ani_ChangeHero_click)
end

function WBP_HeroSelectionMainPanel_C:BindOnChangeHeroButtonHovered()
  self:PlayAnimationForward(self.Ani_ChangeHero_hover_in)
end

function WBP_HeroSelectionMainPanel_C:BindOnChangeHeroButtonUnhovered()
  self:PlayAnimationForward(self.Ani_ChangeHero_hover_out)
end

function WBP_HeroSelectionMainPanel_C:BindOnPickButtonClicked()
  LuaAddClickStatistics("PreparingLockCharacter")
  LogicHeroSelect.RequestPickHeroDoneToServer()
  self:PlayAnimationForward(self.Ani_Pick_click)
end

function WBP_HeroSelectionMainPanel_C:BindOnPickButtonHovered()
  self:PlayAnimationForward(self.Ani_Pick_hover_in)
end

function WBP_HeroSelectionMainPanel_C:BindOnPickButtonUnhovered()
  self:PlayAnimationForward(self.Ani_Pick_hover_out)
end

function WBP_HeroSelectionMainPanel_C:BindOnCancelPickButtonClicked()
  LogicHeroSelect.RequestCancelPickHeroToServer()
  self:PlayAnimationForward(self.Ani_CancelPick_click)
end

function WBP_HeroSelectionMainPanel_C:BindOnCancelPickButtonHovered()
  self:PlayAnimationForward(self.Ani_CancelPick_hover_in)
end

function WBP_HeroSelectionMainPanel_C:BindOnCancelPickButtonUnhovered()
  self:PlayAnimationForward(self.Ani_CancelPick_hover_out)
end

function WBP_HeroSelectionMainPanel_C:OnShow()
  self.WBP_ChatView:FocusInput()
  if DataMgr.GetTeamState() < LogicTeam.TeamState.HeroPicking then
    UIMgr:Hide(ViewID.UI_HeroSelectionMainPanel)
    UIMgr:Show(ViewID.UI_LobbyPanel)
    return
  end
  self:StopAllAnimations()
  self:PlayAnimationForward(self.Ani_in)
  self:BindOnUpdateMyTeamInfo()
  self:BindOnChangeHeroButtonClicked()
  self:BindOnUpdateTeamMembersInfo(DataMgr.GetTeamMembersInfo())
  self.IsNeedExecCountDownLogic = false
  self:UpdateGameModeInfo()
  self.Txt_StartGameTip:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateRoomMembersInfo, self.BindOnUpdateTeamMembersInfo)
  EventSystem.AddListener(self, EventDef.HeroSelect.OnPickHeroStateChanged, self.BindOnPickHeroStateChanged)
  EventSystem.AddListener(self, EventDef.WSMessage.PickHeroDone, self.BindOnAllPickHeroDone)
  EventSystem.AddListener(self, EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimer)
  end
  self.RemainTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.UpdateRemainTime
  }, 1.0, true, -1.0)
  local TeamInfo = DataMgr.GetTeamInfo()
  local TeamCount = table.count(TeamInfo.players)
  UpdateVisibility(self.EscFunctionalButton, 1 == TeamCount)
  if 1 == TeamCount then
    self.EscFunctionalButton:BindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  end
  for key, SingleActor in pairs(self.TeamMemberActors) do
    SingleActor:ResetChildActorAnimation()
  end
  local Model = LogicHeroSelect.GetCloseShotHeroModel()
  if Model then
    Model:ResetChildActorAnimation()
  end
  UpdateVisibility(self.ScaleBox, climbtowerdata.GameMode == LogicTeam.SingleModeId)
  climbtowerdata:GameFloorPassData()
  local HeteromorphismTable = climbtowerdata:GetHeteromorphism(LogicTeam.SingleFloor)
  local Index = 0
  for index, value in ipairs(HeteromorphismTable) do
    Index = index
    local Item = GetOrCreateItem(self.ScrollList, Index, self.WBP_Heteromorphism_Item:GetClass())
    UpdateVisibility(Item, true)
    Item:SetHeteromorphismInfo(value)
  end
  HideOtherItem(self.ScrollList, Index + 1, true)
end

function WBP_HeroSelectionMainPanel_C:OnRollback(...)
  ChangeToLobbyAnimCamera()
end

function WBP_HeroSelectionMainPanel_C:OnHide()
  self.WBP_ChatView:UnfocusInput()
  local AllMainRoleNameItem = self.CanvasPanel_RoleName:GetAllChildren()
  for key, SingleMainRoleNameItem in pairs(AllMainRoleNameItem) do
    SingleMainRoleNameItem:Hide()
  end
  local AllRoleNameItem = self.CanvasPanel_HeroSelectTeamInfo:GetAllChildren()
  for key, SingleRoleNameItem in pairs(AllRoleNameItem) do
    SingleRoleNameItem:Hide()
  end
  self.HeroSelection:Hide()
  self:RemoveEvent()
end

function WBP_HeroSelectionMainPanel_C:InitHeroSelectTeamInfoPanelVis()
  local TeamInfo = DataMgr.GetTeamInfo()
  if table.count(TeamInfo.players) > 1 then
    self.CanvasPanel_HeroSelectTeamInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CanvasPanel_HeroSelectTeamInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_HeroSelectionMainPanel_C:BindOnEscKeyPressed()
  if not self.IsInHeroSelection then
    return
  end
  local TeamInfo = DataMgr.GetTeamInfo()
  local TeamCount = table.count(TeamInfo.players)
  if TeamCount > 1 then
    return
  end
  if not self.SendCancelStartGameTime or GetCurrentTimestamp(true) - self.SendCancelStartGameTime > 2 then
    LogicTeam.RequestCancelStartGameToServer()
    self.SendCancelStartGameTime = GetCurrentTimestamp(true)
  else
    print("\232\175\183\230\177\130\232\191\135\228\186\142\233\162\145\231\185\129")
  end
end

function WBP_HeroSelectionMainPanel_C:BindOnUpdateMyTeamInfo()
  if self.IsInHeroSelection then
    return
  end
  local TeamInfo = DataMgr.GetTeamInfo()
  if TeamInfo.state == LogicTeam.TeamState.HeroPicking then
    self:UpdateTeamMemberModels()
  end
end

function WBP_HeroSelectionMainPanel_C:UpdateTeamMemberModels()
  local TeamInfo = DataMgr.GetTeamInfo()
  if DataMgr.IsInTeam() then
    local RemoveList = {}
    local IdList = {}
    for index, SingleTeamPlayerInfo in ipairs(TeamInfo.players) do
      table.insert(IdList, SingleTeamPlayerInfo.id)
    end
    for RoleId, SingleActor in pairs(self.UseMemberList) do
      if not table.Contain(IdList, RoleId) then
        table.insert(RemoveList, RoleId)
      end
    end
    for i, SingleRoleId in pairs(RemoveList) do
      local TargetModel = self.UseMemberList[SingleRoleId]
      TargetModel:HideActor()
      local Index = self:GetTargetMemberModelAndWidgetIndex(SingleRoleId)
      if 0 ~= Index then
        local TargetRoleName = self.CanvasPanel_RoleName:GetChildAt(Index - 1)
        if TargetRoleName then
          TargetRoleName:Hide()
        end
      end
      self.UseMemberList[SingleRoleId] = nil
    end
    for i, SingleTeamPlayerInfo in ipairs(TeamInfo.players) do
      local Index = self:GetTargetMemberModelAndWidgetIndex(SingleTeamPlayerInfo.id)
      if 0 ~= Index then
        local Model = self.TeamMemberActors:Get(Index)
        Model:ShowActor(SingleTeamPlayerInfo.pickHeroInfo.id, tonumber(SingleTeamPlayerInfo.weapons[1].resourceId), SingleTeamPlayerInfo.pickHeroInfo.skinId, SingleTeamPlayerInfo.weapons[1].skin)
        local ParentId = SkinData.GetSkinParentId(SingleTeamPlayerInfo.pickHeroInfo.skinId)
        LogicRole.SetEffectState(Model.ChildActor.ChildActor, SingleTeamPlayerInfo.pickHeroInfo.skinId, nil, 1 == SingleTeamPlayerInfo.pickHeroInfo.specialEffectState[tostring(ParentId)])
        self.UseMemberList[SingleTeamPlayerInfo.id] = Model
      end
    end
  else
    for RoleId, SingleUseMemberModel in pairs(self.UseMemberList) do
      SingleUseMemberModel:HideActor()
    end
    self.UserMemberList = {}
    self:InitPanelStatus()
    self:InitOwnModelInfo()
  end
end

function WBP_HeroSelectionMainPanel_C:InitPanelStatus()
  local AllChildren = self.CanvasPanel_RoleName:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    if 1 ~= i then
      SingleItem:Hide()
    end
  end
end

function WBP_HeroSelectionMainPanel_C:InitOwnModelInfo(HeroId)
  local Index = self:GetTargetMemberModelAndWidgetIndex(DataMgr.GetUserId())
  if 0 == Index then
    return
  end
  local TargetActor = self.TeamMemberActors:Get(Index)
  if TargetActor then
    local HeroInfo = DataMgr.GetMyHeroInfo()
    local TargetHeroId = HeroId
    TargetHeroId = TargetHeroId or HeroInfo.equipHero
    local EquippedWeaponList = DataMgr.GetEquippedWeaponList(TargetHeroId)
    if not EquippedWeaponList then
      return
    end
    local TargetWeaponInfo = EquippedWeaponList[1]
    if not TargetWeaponInfo then
      return
    end
    TargetActor:ShowActor(TargetHeroId, TargetWeaponInfo.resourceId)
  end
  local TargetRoleName = self.CanvasPanel_RoleName:GetChildAt(Index - 1)
  if TargetRoleName then
    TargetRoleName:Show(DataMgr.GetBasicInfo())
    self.OwnRoleNamePositionTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        self:UpdateRoleNamePosition(Index)
      end
    }, 1.01, false)
  end
end

function WBP_HeroSelectionMainPanel_C:GetTargetMemberModelAndWidgetIndex(RoleId)
  if RoleId == DataMgr.GetUserId() then
    return 1
  end
  if self.UseMemberList[RoleId] then
    return self.TeamMemberActors:Find(self.UseMemberList[RoleId])
  end
  local AllUseMembers = {}
  for RoleId, SingleMemberModel in pairs(self.UseMemberList) do
    table.insert(AllUseMembers, SingleMemberModel)
  end
  for i, SingleTeamMemberModel in pairs(self.TeamMemberActors) do
    if 1 ~= i and not table.Contain(AllUseMembers, SingleTeamMemberModel) then
      return i
    end
  end
  print("\230\178\161\230\156\137\229\143\175\231\148\168\231\154\132\232\139\177\233\155\132\230\168\161\229\158\139\239\188\140\232\175\183\230\163\128\230\159\165\229\164\167\229\142\133\229\156\186\230\153\175\233\133\141\231\189\174\239\188\129")
  return 0
end

function WBP_HeroSelectionMainPanel_C:BindOnUpdateTeamMembersInfo(PlayerList)
  self.TeamMemberInfoList = PlayerList
  self:InitPanelStatus()
  local IndexList = {}
  for i, SinglePlayerInfo in ipairs(PlayerList) do
    local Index = self:GetTargetMemberModelAndWidgetIndex(SinglePlayerInfo.roleid)
    if 0 ~= Index then
      local TargetRoleName = self.CanvasPanel_RoleName:GetChildAt(Index - 1)
      if TargetRoleName then
        TargetRoleName:Show(SinglePlayerInfo)
        table.insert(IndexList, Index)
        UpdateVisibility(TargetRoleName, false)
      end
    end
  end
  self.TeamRoleNamePositionTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      for index, Index in ipairs(IndexList) do
        local TargetRoleName = self.CanvasPanel_RoleName:GetChildAt(Index - 1)
        if TargetRoleName then
          UpdateVisibility(TargetRoleName, true)
        end
        self:UpdateRoleNamePosition(Index)
      end
    end
  }, 1.01, false)
  self:UpdateHeroSelectTeamInfo()
end

function WBP_HeroSelectionMainPanel_C:UpdateHeroSelectTeamInfo()
  if not self.TeamMemberInfoList then
    return
  end
  if self.IsInHeroSelection then
    if table.count(self.TeamMemberInfoList) <= 1 then
      return
    end
    local AllChildren = self.CanvasPanel_HeroSelectTeamInfo:GetAllChildren()
    for key, SingleChildItem in pairs(AllChildren) do
      local TargetRoleInfo = self.TeamMemberInfoList[key]
      if TargetRoleInfo then
        SingleChildItem:Show(TargetRoleInfo)
      else
        SingleChildItem:Hide()
      end
    end
  end
end

function WBP_HeroSelectionMainPanel_C:BindOnPickHeroStateChanged(IsPick, HeroId)
  if IsPick then
    if self.IsInHeroSelection then
      self:BindOnUpdateMyTeamInfo()
    else
      local HeroInfo = DataMgr.GetMyHeroInfo()
    end
  end
  self:ChangeOperateButtonVis(IsPick)
end

function WBP_HeroSelectionMainPanel_C:BindOnAllPickHeroDone()
  print("PickHero BindOnAllPickHeroDone!")
  if self.IsNeedExecCountDownLogic then
    return
  end
  self.IsNeedExecCountDownLogic = true
  if self.IsInHeroSelection then
    self:BindOnPickHeroStateChanged(true)
    self:ChangePanelStateVis(false)
  else
  end
  self.Btn_CancelPick:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Btn_ChangeHero:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Btn_Pick:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Txt_StartGameTip:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local Time = tostring(math.max(0, LogicHeroSelect.GetEndTime() - GetTimeWithServerDelta()))
  self.Txt_RemainTime:SetText(Time)
  self:PlayCombatAnimation()
  local TeamInfo = DataMgr.GetTeamInfo()
  for key, SingleTeamPlayerInfo in pairs(TeamInfo.players) do
    if SingleTeamPlayerInfo.id == DataMgr.GetUserId() then
      LogicAudio.PickHero(SingleTeamPlayerInfo.pickHeroInfo.id)
    end
  end
end

function WBP_HeroSelectionMainPanel_C:BindOnEquippedWeaponInfoChanged()
  local Index = self:GetTargetMemberModelAndWidgetIndex(DataMgr.GetUserId())
  local Model = self.TeamMemberActors:Get(Index)
  local TeamInfo = DataMgr.GetTeamInfo()
  for key, SingleTeamPlayerInfo in pairs(TeamInfo.players) do
    if SingleTeamPlayerInfo.id == DataMgr.GetUserId() and Model then
      local EquippedWeaponList = DataMgr.GetEquippedWeaponList(SingleTeamPlayerInfo.pickHeroInfo.id)
      if EquippedWeaponList then
        local TargetWeaponInfo = EquippedWeaponList[1]
        if TargetWeaponInfo then
          Model:ChangeEquipWeaponMesh(TargetWeaponInfo.resourceId, TargetWeaponInfo.skin)
        end
      end
    end
  end
end

function WBP_HeroSelectionMainPanel_C:PlayCombatAnimation()
  for RoleId, SingleActor in pairs(self.UseMemberList) do
    if SingleActor.ChildActor.ChildActor then
      SingleActor.ChildActor.ChildActor:SetRoleStatus(UE.ERGLobbyRoleStatus.CombatIdle)
    end
  end
end

function WBP_HeroSelectionMainPanel_C:UpdateRoleNamePosition(Index)
  local TargetRoleName = self.CanvasPanel_RoleName:GetChildAt(Index - 1)
  local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(TargetRoleName)
  local TargetModel = self.TeamMemberActors:Get(Index)
  if TargetModel then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    local Location = TargetModel:K2_GetActorLocation()
    local Offset = UE.FVector()
    Offset.Z = self.ModelNameOffsetZ
    local Result, Position = UE.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(PC, Location + Offset, nil, false)
    Slot:SetPosition(Position)
  end
end

function WBP_HeroSelectionMainPanel_C:UpdateGameModeInfo()
  local BResult, WorldRowInfo = GetRowData(DT.DT_GameMode, LogicTeam.GetWorldId())
  if BResult then
    self.Txt_ModeName:SetText(WorldRowInfo.Name)
  end
  self.Txt_DifficultyLevel:SetText(LogicTeam.GetModeDifficultDisplayText())
end

function WBP_HeroSelectionMainPanel_C:UpdateRemainTime()
  print("PickHero UpdateRemainTime!")
  local Time = tostring(math.max(0, LogicHeroSelect.GetEndTime() - GetTimeWithServerDelta()))
  self.Txt_RemainTime:SetText(Time)
  if math.max(0, LogicHeroSelect.GetEndTime() - GetTimeWithServerDelta()) <= 5 then
    PlaySound2DEffect(14, "Countdown")
  end
  if LogicHeroSelect.GetEndTime() - GetTimeWithServerDelta() <= 5 then
    if 0 == LogicHeroSelect.GetEndTime() - GetTimeWithServerDelta() then
      self:PlayAnimationForward(self.Ani_out)
    else
      self:PlayAnimation(self.Ani_countdown, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, true)
    end
    if self.IsNeedExecCountDownLogic then
      return
    end
    self.IsNeedExecCountDownLogic = true
    if self.IsInHeroSelection then
      self:BindOnPickHeroStateChanged(true)
      self:ChangePanelStateVis(false)
    else
    end
    self:PlayCombatAnimation()
    self.Btn_CancelPick:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Btn_ChangeHero:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Btn_Pick:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_StartGameTip:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local TeamInfo = DataMgr.GetTeamInfo()
    for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
      if LogicTeam.CurTeamState == LogicTeam.TeamState.HeroPicking and SinglePlayerInfo.id == DataMgr.GetUserId() then
        if 0 == SinglePlayerInfo.pickDone then
          LogicHeroSelect.RequestPickHeroDoneToServer()
        end
        break
      end
    end
  end
end

function WBP_HeroSelectionMainPanel_C:ChangePanelStateVis(IsShowHeroSelection)
  self.IsInHeroSelection = IsShowHeroSelection
  LogicHeroSelect.IsInHeroSelection = IsShowHeroSelection
  if IsShowHeroSelection then
    self.HeroSelectionPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.HeroSelection:Show()
    self.MainPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self:PlayAnimation(self.Ani_out_2)
    self.HeroSelection:Hide()
    EventSystem.Invoke(EventDef.Lobby.WeaponItemSelected, false)
    self.MainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimationForward(self.Ani_in_2)
    self:ChangeOperateButtonVis()
  end
  self:ChangeModelVis()
end

function WBP_HeroSelectionMainPanel_C:ChangeModelVis()
  for key, SingleModel in pairs(self.TeamMemberActors) do
    local ModelIsNeedHide = self.IsInHeroSelection
    if not self.IsInHeroSelection then
      ModelIsNeedHide = true
      for key, SingleUseMemberModel in pairs(self.UseMemberList) do
        if SingleModel == SingleUseMemberModel then
          ModelIsNeedHide = false
          break
        end
      end
    end
    SingleModel:SetActorHiddenInGame(ModelIsNeedHide)
  end
  local Model = LogicHeroSelect.GetCloseShotHeroModel()
  if Model then
    Model:SetActorHiddenInGame(not self.IsInHeroSelection)
  end
end

function WBP_HeroSelectionMainPanel_C:ChangeOperateButtonVis(IsTargetPick)
  local IsPick = false
  if nil ~= IsTargetPick then
    IsPick = IsTargetPick
  else
    local TeamInfo = DataMgr.GetTeamInfo()
    for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
      if SinglePlayerInfo.id == DataMgr.GetUserId() then
        IsPick = 0 ~= SinglePlayerInfo.pickDone
        break
      end
    end
  end
  if IsPick then
    self.Btn_CancelPick:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_ChangeHero:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Btn_Pick:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Btn_CancelPick:SetVisibility(UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self.Btn_ChangeHero, LogicTeam.GetModeId() ~= TableEnums.ENUMGameMode.BEGINERGUIDANCE)
    self.Btn_Pick:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.IsNeedExecCountDownLogic then
    self.Btn_CancelPick:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Btn_ChangeHero:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Btn_Pick:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_HeroSelectionMainPanel_C:RemoveEvent()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateRoomMembersInfo, self.BindOnUpdateTeamMembersInfo, self)
  EventSystem.RemoveListener(EventDef.HeroSelect.OnPickHeroStateChanged, self.BindOnPickHeroStateChanged, self)
  EventSystem.RemoveListener(EventDef.WSMessage.PickHeroDone, self.BindOnAllPickHeroDone, self)
  EventSystem.RemoveListener(EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged, self)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimer)
  end
  self.EscFunctionalButton:UnBindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.OwnRoleNamePositionTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.OwnRoleNamePositionTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TeamRoleNamePositionTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TeamRoleNamePositionTimer)
  end
end

function WBP_HeroSelectionMainPanel_C:Destruct()
  self:RemoveEvent()
end

return WBP_HeroSelectionMainPanel_C
