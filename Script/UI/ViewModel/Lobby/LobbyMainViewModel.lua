local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local LobbyMainViewModel = CreateDefaultViewModel()
LobbyMainViewModel.propertyBindings = {
  BasicInfo = {}
}
LobbyMainViewModel.subViewModels = {}
local WidgetToModelZOffset = 190

function LobbyMainViewModel:OnInit()
  self.Super.OnInit(self)
  self.UseMemberList = {}
  self.TeamMemberActors = {}
  self.bBattleLagacyActive = true
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  EventSystem.AddListener(self, EventDef.Lobby.PlayInAnimation, self.OnPlayInAnimation)
  EventSystem.AddListener(self, EventDef.Lobby.PlayOutAnimation, self.OnPlayOutAnimation)
  EventSystem.AddListener(self, EventDef.Lobby.OnJoinGameFail, self.BindOnJoinGameFail)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateRoomMembersInfo, self.BindOnUpdateTeamMembersInfo)
  EventSystem.AddListener(self, EventDef.Lobby.OnTeamStateChanged, self.BindOnTeamStateChanged)
  EventSystem.AddListener(self, EventDef.Lobby.OnModelAreaClickedChanged, self.BindOnModelAreaClickedChanged)
  EventSystem.AddListener(self, EventDef.Lobby.OnInviteDialogue, self.BindInviteDialogue)
  EventSystem.AddListener(self, EventDef.Lobby.OnCameraTargetChangedToLobbyAnimCamera, self.BindOnCameraTargetChangedToLobbyAnimCamera)
  EventSystem.AddListener(self, EventDef.BattlePass.GetBattlePassData, self.BindOnGetBattlePassData)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateTicketStatus, self, self.RefreshRessourcenInfo)
end

function LobbyMainViewModel:RegisterPropertyChanged(BindingTable, View)
  self.Super.RegisterPropertyChanged(self, BindingTable, View)
end

function LobbyMainViewModel:UnRegisterPropertyChanged(BindingTable, View)
  self.Super.UnRegisterPropertyChanged(self, BindingTable, View)
end

function LobbyMainViewModel:RefreshRessourcenInfo(NotResource)
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    return
  end
  local TargetUnlockFloorTip = LobbyMainView.CanvasPanel_UnlockFloorTip:GetChildAt(0)
  if TargetUnlockFloorTip then
    TargetUnlockFloorTip:Show(DataMgr.GetUserId())
    TargetUnlockFloorTip:RefreshRessourcenInfo(NotResource)
  end
end

function LobbyMainViewModel:BindOnUpdateMyTeamInfo()
  self:OnUpdateMyTeamInfo()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:BindOnUpdateMyTeamInfo LobbyMainView is nil")
    return
  end
  self:UpdateGameModeInfo()
  self:UpdateTeamMemberModels()
end

function LobbyMainViewModel:UpdateTeamMemberModels()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:BindOnUpdateMyTeamInfo LobbyMainView is nil")
    return
  end
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
    if #RemoveList > 0 then
      LobbyMainView.TeamOperateButtonPanel:Hide()
    end
    for i, SingleRoleId in pairs(RemoveList) do
      local TargetModel = self.UseMemberList[SingleRoleId]
      if TargetModel:IsValid() then
        TargetModel:HideActor()
      end
      local Index = self:GetTargetMemberModelAndWidgetIndex(SingleRoleId)
      if 0 ~= Index then
        local TargetRoleName = LobbyMainView.CanvasPanel_RoleName:GetChildAt(Index - 1)
        if TargetRoleName then
          TargetRoleName:Hide()
        end
        local TargetUnlockFloorTip = LobbyMainView.CanvasPanel_UnlockFloorTip:GetChildAt(Index - 1)
        if TargetUnlockFloorTip then
          TargetUnlockFloorTip:Hide()
        end
      end
      self.UseMemberList[SingleRoleId] = nil
    end
    local oldTeamInfo = DataMgr.GetOldTeamInfo()
    local showActorIdxMap = {}
    for i, SingleTeamPlayerInfo in ipairs(TeamInfo.players) do
      local Index = self:GetTargetMemberModelAndWidgetIndex(SingleTeamPlayerInfo.id)
      showActorIdxMap[Index] = true
      if 0 ~= Index then
        local Model = self.TeamMemberActors[Index]
        if SingleTeamPlayerInfo.weapons[1] then
          local heroId = SingleTeamPlayerInfo.hero.id
          local skinId = SingleTeamPlayerInfo.hero.skinId
          local weaponResId = tonumber(SingleTeamPlayerInfo.weapons[1].resourceId)
          local weaponSkinId = SingleTeamPlayerInfo.weapons[1].skin
          if Model.bHidden or Model.heroId ~= heroId or Model.CurSkinId ~= skinId or Model.CurWeaponSkinId ~= weaponSkinId then
            Model:ShowActor(SingleTeamPlayerInfo.hero.id, weaponResId, skinId, weaponSkinId)
          end
          local ParentId = SkinData.GetSkinParentId(skinId)
          LogicRole.SetEffectState(Model.ChildActor.ChildActor, skinId, nil, 1 == SingleTeamPlayerInfo.pickHeroInfo.specialEffectState[tostring(ParentId)])
        end
        self.UseMemberList[SingleTeamPlayerInfo.id] = Model
      end
    end
    local lobbyMainView = self:GetFirstView()
    local bLeftRoleShow = showActorIdxMap[2]
    local bRightRoleShow = showActorIdxMap[3]
    UpdateVisibility(LobbyMainView.Btn_LeftModelArea, true, bLeftRoleShow)
    UpdateVisibility(LobbyMainView.Btn_RightModelArea, true, bRightRoleShow)
    UpdateVisibility(LobbyMainView.CanvasPanel_LeftModelRoot, not bLeftRoleShow)
    UpdateVisibility(LobbyMainView.CanvasPanel_RightModelRoot, not bRightRoleShow)
    if oldTeamInfo and oldTeamInfo.players and #oldTeamInfo.players > #TeamInfo.players then
      if bLeftRoleShow then
        lobbyMainView:PlayAnimation(lobbyMainView.Ani_right_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
      else
        lobbyMainView:PlayAnimation(lobbyMainView.Ani_left_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
      end
    end
  else
    for RoleId, SingleUseMemberModel in pairs(self.UseMemberList) do
      if SingleUseMemberModel:IsValid() then
        SingleUseMemberModel:HideActor()
      end
    end
    LobbyMainView.TeamOperateButtonPanel:Hide()
    self.UserMemberList = {}
    self:InitPanelStatus()
    self:InitOwnModelInfo()
    UpdateVisibility(LobbyMainView.Btn_LeftModelArea, true)
    UpdateVisibility(LobbyMainView.Btn_RightModelArea, true)
    UpdateVisibility(LobbyMainView.CanvasPanel_LeftModelRoot, true)
    UpdateVisibility(LobbyMainView.CanvasPanel_RightModelRoot, true)
  end
  self:InitOwnModelInfo()
end

function LobbyMainViewModel:ClearUseTeamMemberModels()
  self.UseMemberList = {}
end

function LobbyMainViewModel:GetTargetMemberModelAndWidgetIndex(RoleId)
  if RoleId == DataMgr.GetUserId() then
    return 1
  end
  if self.UseMemberList[RoleId] and self.UseMemberList[RoleId]:IsValid() then
    for key, SingleActor in pairs(self.TeamMemberActors) do
      if SingleActor == self.UseMemberList[RoleId] then
        return key
      end
    end
    return 0
  end
  local AllUseMembers = {}
  for RoleId, SingleMemberModel in pairs(self.UseMemberList) do
    if SingleMemberModel:IsValid() then
      table.insert(AllUseMembers, SingleMemberModel)
    end
  end
  for i, SingleTeamMemberModel in pairs(self.TeamMemberActors) do
    if 1 ~= i and not table.Contain(AllUseMembers, SingleTeamMemberModel) then
      return i
    end
  end
  print("\230\178\161\230\156\137\229\143\175\231\148\168\231\154\132\232\139\177\233\155\132\230\168\161\229\158\139\239\188\140\232\175\183\230\163\128\230\159\165\229\164\167\229\142\133\229\156\186\230\153\175\233\133\141\231\189\174\239\188\129")
  return 0
end

function LobbyMainViewModel:InitPanelStatus()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:BindOnUpdateMyTeamInfo LobbyMainView is nil")
    return
  end
  local AllChildren = LobbyMainView.CanvasPanel_RoleName:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local AllChildren = LobbyMainView.CanvasPanel_UnlockFloorTip:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
end

function LobbyMainViewModel:InitOwnModelInfo()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:BindOnUpdateMyTeamInfo LobbyMainView is nil")
    return
  end
  local Index = self:GetTargetMemberModelAndWidgetIndex(DataMgr.GetUserId())
  if 0 == Index then
    return
  end
  local TargetActor = self.TeamMemberActors[Index]
  if TargetActor then
    local HeroInfo = DataMgr.GetMyHeroInfo()
    local EquippedWeaponList = DataMgr.GetEquippedWeaponList(HeroInfo.equipHero)
    local weaponResId = -1
    if EquippedWeaponList and EquippedWeaponList[1] then
      weaponResId = EquippedWeaponList[1].resourceId
    end
    TargetActor:ShowActor(HeroInfo.equipHero, weaponResId)
  end
  local TargetRoleName = LobbyMainView.CanvasPanel_RoleName:GetChildAt(Index - 1)
  if TargetRoleName then
    local TeamInfo = DataMgr.GetTeamInfo()
    if DataMgr.IsInTeam() and table.count(TeamInfo.players) > 1 then
      TargetRoleName:Show(DataMgr.GetBasicInfo(), Index)
    end
  end
end

function LobbyMainViewModel:BindOnUpdateTeamMembersInfo()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:BindOnUpdateTeamMembersInfo LobbyMainView is nil")
    return
  end
  local PlayerList = DataMgr.GetTeamMembersInfo()
  self:InitPanelStatus()
  for i, SinglePlayerInfo in ipairs(PlayerList) do
    local Index = self:GetTargetMemberModelAndWidgetIndex(SinglePlayerInfo.roleid)
    if 0 ~= Index then
      local TargetRoleName = LobbyMainView.CanvasPanel_RoleName:GetChildAt(Index - 1)
      if TargetRoleName then
        local TeamInfo = DataMgr.GetTeamInfo()
        if DataMgr.IsInTeam() and TeamInfo.players and table.count(TeamInfo.players) > 1 then
          TargetRoleName:Show(SinglePlayerInfo, Index)
        end
      end
    end
    if DataMgr.IsInTeam() and table.count(PlayerList) > 1 then
      local TargetUnlockFloorTip = LobbyMainView.CanvasPanel_UnlockFloorTip:GetChildAt(Index - 1)
      if TargetUnlockFloorTip then
        TargetUnlockFloorTip:Show(SinglePlayerInfo.roleid)
      end
    end
  end
end

function LobbyMainViewModel:BindOnTeamStateChanged(OldState, NewState)
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:BindOnTeamStateChanged LobbyMainView is nil")
    return
  end
  if NewState == LogicTeam.TeamState.Idle then
    self:ShowIdleStatePanel()
  elseif NewState == LogicTeam.TeamState.Matching then
    self:ShowMatchingStatePanel()
  elseif NewState == LogicTeam.TeamState.None then
    self:ShowIdleStatePanel()
  elseif NewState == LogicTeam.TeamState.Recruiting then
    self:ShowRecruitingPanel()
  end
end

function LobbyMainViewModel:ShowIdleStatePanel()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:ShowIdleStatePanel LobbyMainView is nil")
    return
  end
  if UIMgr:IsShow(ViewID.UI_RecruitingTipPanel) then
    UIMgr:Hide(ViewID.UI_RecruitingTipPanel)
  end
  LobbyMainView.ChangeModeBtnPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function LobbyMainViewModel:ShowMatchingStatePanel()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:ShowMatchingStatePanel LobbyMainView is nil")
    return
  end
  LobbyMainView.ChangeModeBtnPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function LobbyMainViewModel:ShowRecruitingPanel()
  if UIMgr:IsShow(ViewID.UI_RecruitingTipPanel) then
    return
  end
  local recruitingPanel = UIMgr:Show(ViewID.UI_RecruitingTipPanel)
  local ModeID = LogicTeam.GetModeId()
  local WorldID = LogicTeam.GetWorldId()
  local Floor = LogicTeam:GetFloor()
  recruitingPanel:SetGameInfo(ModeID, WorldID, Floor)
end

function LobbyMainViewModel:OnPlayInAnimation()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:OnPlayInAnimation LobbyMainView is nil")
    return
  end
  LobbyMainView.CanvasPanel_RoleName:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function LobbyMainViewModel:OnPlayOutAnimation()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:OnPlayOutAnimation LobbyMainView is nil")
    return
  end
  LobbyMainView.CanvasPanel_RoleName:SetVisibility(UE.ESlateVisibility.Hidden)
end

function LobbyMainViewModel:BindOnJoinGameFail()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:BindOnJoinGameFail LobbyMainView is nil")
    return
  end
  LobbyMainView.WBP_LobbyTaskPanel:PlayInAnimation()
  LobbyMainView:PlayInAnimation()
  LobbyMainView.ChangeModeBtnPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  EventSystem.Invoke(EventDef.Lobby.PlayInAnimation)
end

function LobbyMainViewModel:BindOnModelAreaClickedChanged(IsClicked, ModelIndex)
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:BindOnModelAreaClickedChanged LobbyMainView is nil")
    return
  end
  if IsClicked then
    local TeamInfo = DataMgr.GetTeamInfo()
    local TargetPlayerInfo
    if TeamInfo and TeamInfo.players then
      for i, SingleTeamPlayerInfo in ipairs(TeamInfo.players) do
        local Index = self:GetTargetMemberModelAndWidgetIndex(SingleTeamPlayerInfo.id)
        if Index == ModelIndex then
          TargetPlayerInfo = SingleTeamPlayerInfo
          break
        end
      end
    else
      print("\230\178\161\230\156\137\233\152\159\228\188\141\228\191\161\230\129\175")
    end
    if not TargetPlayerInfo then
      print("\230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\231\154\132\228\186\186\229\145\152\230\149\176\230\141\174")
      if 2 == ModelIndex then
        local GeometryTipsParent = LobbyMainView.CanvasPanel_ModelClickArea:GetCachedGeometry()
        local GeometryItem = LobbyMainView.Btn_LeftModelArea:GetCachedGeometry()
        local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryTipsParent, GeometryItem) + LobbyMainView.EmptyMemberSlotOffset
        LobbyMainView.TeamOperateButtonPanel:UpdatePosition(Pos)
      elseif 3 == ModelIndex then
        local GeometryTipsParent = LobbyMainView.CanvasPanel_ModelClickArea:GetCachedGeometry()
        local GeometryItem = LobbyMainView.Btn_RightModelArea:GetCachedGeometry()
        local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryTipsParent, GeometryItem) + LobbyMainView.EmptyMemberSlotOffset
        LobbyMainView.TeamOperateButtonPanel:UpdatePosition(Pos)
      elseif 1 == ModelIndex and not DataMgr.IsInTeam() then
        print("\228\184\141\229\156\168\233\152\159\228\188\141\228\184\173")
        return
      end
      LobbyMainView.TeamOperateButtonPanel:Show(nil)
      return
    end
    if not DataMgr.IsInTeam() then
      print("\228\184\141\229\156\168\233\152\159\228\188\141\228\184\173")
      return
    end
    local TargetModel = self.TeamMemberActors[ModelIndex]
    if not TargetModel then
      print("WBP_LobbyMain_C:BindOnModelAreaClickedChanged \230\178\161\230\156\137\229\175\185\229\186\148\231\154\132\230\168\161\229\158\139", ModelIndex)
      return
    end
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local Location = TargetModel:K2_GetActorLocation()
    local Offset = UE.FVector()
    Offset.Z = WidgetToModelZOffset
    local Result, Position = UE.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(PC, Location + Offset, nil, false)
    LobbyMainView.TeamOperateButtonPanel:UpdatePosition(Position)
    LobbyMainView.TeamOperateButtonPanel:Show(TargetPlayerInfo)
  else
    LobbyMainView.TeamOperateButtonPanel:Hide()
  end
end

function LobbyMainViewModel:BindInviteDialogue(bShow, Id)
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:BindInviteDialogue LobbyMainView is nil")
    return
  end
  Logic_MainTask.BindInviteDialogue(bShow, Id, LobbyMainView.WBP_MainTask_RequestConversation)
end

function LobbyMainViewModel:BindOnCameraTargetChangedToLobbyAnimCamera(...)
end

function LobbyMainViewModel:SetModelClickAreaOpacity(Opacity)
  local LobbyMainViewModelTemp = UIModelMgr:Get("LobbyMainViewModel")
  local LobbyMainView = LobbyMainViewModelTemp:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:SetModelClickAreaOpacity LobbyMainView is nil")
    return
  end
  LobbyMainView.CanvasPanel_ModelClickArea:SetRenderOpacity(Opacity)
end

function LobbyMainViewModel:BindOnGetBattlePassData(BattlePassInfo, BattlePassID)
  local LobbyMainView = self:GetFirstView()
  if LobbyMainView then
    LobbyMainView:UpdateBattlePassInfo(BattlePassInfo, BattlePassID)
  end
end

function LobbyMainViewModel:OnUpdateMyTeamInfo()
  if BattleLagacyData.CurBattleLagacyData == nil then
    return
  end
  if BattleLagacyData.CurBattleLagacyData.BattleLagacyId == "0" then
    return
  end
  local LobbyMainView = self:GetFirstView()
  if LobbyMainView then
    LobbyMainView:OnUpdateMyTeamInfo()
  end
  self.bBattleLagacyActive = BattleLagacyModule:CheckBattleLagacyIsActive()
end

function LobbyMainViewModel:OpenChangeModePanel()
  UIMgr:Show(ViewID.UI_MainModeSelection, true)
end

function LobbyMainViewModel:BindOnDrawCardButtonClicked()
  UIMgr:Show(ViewID.UI_DrawCard, true)
end

function LobbyMainViewModel:InitLobbyTeamRoleActors()
  self.TeamMemberActors = {}
  local MaxTeamNum = 3
  local LobbySettings = UE.URGLobbySettings.GetSettings()
  if LobbySettings then
    MaxTeamNum = LobbySettings.LobbyRoomMaxMember
  end
  for i = 1, MaxTeamNum do
    local OutActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "LobbyMain" .. i):ToTable()
    if OutActors[1] then
      table.insert(self.TeamMemberActors, OutActors[1])
    end
  end
end

function LobbyMainViewModel:HideAllModel()
  for _, SingleActor in pairs(self.TeamMemberActors) do
    SingleActor:SetHiddenInGame(true)
  end
end

function LobbyMainViewModel:ShowAfterSequence()
  for _, SingleActor in pairs(self.TeamMemberActors) do
    SingleActor:SetHiddenInGame(SingleActor.bIsActived)
  end
end

function LobbyMainViewModel:UpdateGameModeInfo()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:UpdateGameModeInfo LobbyMainView is nil")
    return
  end
  local WorldId = LogicTeam.GetWorldId()
  local Floor = LogicTeam.GetFloor()
  local ModeId = LogicTeam.GetModeId()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(LobbyMainView, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if CheckIsInNormal(ModeId) then
    local BResult, ModeRowInfo = DTSubsystem:GetGameModeRowInfoById(WorldId, nil)
    if BResult then
      LobbyMainView.Txt_WorldName:SetText(ModeRowInfo.Name)
      LobbyMainView.Txt_WorldName_Projection:SetText(ModeRowInfo.Name)
      SetImageBrushBySoftObject(LobbyMainView.Img_WorldIcon, ModeRowInfo.ThumbnailLevelIcon)
    end
    UpdateVisibility(LobbyMainView.Overlay_Season, false)
  else
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, ModeId)
    if Result then
      LobbyMainView.Txt_WorldName:SetText(RowInfo.Name)
      LobbyMainView.Txt_WorldName_Projection:SetText(RowInfo.Name)
      UpdateVisibility(LobbyMainView.Overlay_Season, RowInfo.Season)
      SetImageBrushByPath(LobbyMainView.Img_WorldIcon, RowInfo.LevelIcon)
    else
      UpdateVisibility(LobbyMainView.Overlay_Season, false)
    end
  end
  LobbyMainView.Txt_DifficultyLevel:SetText(LogicTeam.GetModeDifficultDisplayText())
end

function LobbyMainViewModel:ChangeOwnNameWidgetVisibility()
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:ChangeOwnNameWidgetVisibility LobbyMainView is nil")
    return
  end
  local TargetRoleName = LobbyMainView.CanvasPanel_RoleName:GetChildAt(0)
  if not TargetRoleName then
    return
  end
  if TargetRoleName then
    UpdateVisibility(TargetRoleName, true)
    local TeamInfo = DataMgr.GetTeamInfo()
    if DataMgr.IsInTeam() and table.count(TeamInfo.players) > 1 then
      TargetRoleName:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      TargetRoleName:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function LobbyMainViewModel:InitPanelPosition()
  local LobbyMainViewModel = UIModelMgr:Get("LobbyMainViewModel")
  local LobbyMainView = LobbyMainViewModel:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:InitPanelPosition LobbyMainView is nil")
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(LobbyMainView, 0)
  for key, SingleTeamMemberActor in pairs(LobbyMainViewModel.TeamMemberActors) do
    local TargetClickAreaPanel = LobbyMainView.CanvasPanel_ModelClickArea:GetChildAt(key - 1)
    if TargetClickAreaPanel then
      local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(TargetClickAreaPanel)
      local CurPosition = Slot:GetPosition()
      local Location = SingleTeamMemberActor:K2_GetActorLocation()
      local Result, Position = UE.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(PC, Location, nil, false)
      CurPosition.X = Position.X
      Slot:SetPosition(CurPosition)
    end
    LobbyMainViewModel:UpdateRoleNamePosition(key)
  end
end

function LobbyMainViewModel:UpdateRoleNamePosition(Index)
  local LobbyMainView = self:GetFirstView()
  if not LobbyMainView then
    print("LobbyMainViewModel:UpdateRoleNamePosition LobbyMainView is nil")
    return
  end
  local TargetRoleName = LobbyMainView.CanvasPanel_RoleName:GetChildAt(Index - 1)
  local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(TargetRoleName)
  local TargetModel = self.TeamMemberActors[Index]
  if TargetModel then
    local PC = UE.UGameplayStatics.GetPlayerController(LobbyMainView, 0)
    local Location = TargetModel:K2_GetActorLocation()
    local Offset = UE.FVector()
    Offset.Z = WidgetToModelZOffset
    local Result, Position = UE.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(PC, Location + Offset, nil, false)
    Slot:SetPosition(Position)
    local TargetUnlockFloorTip = LobbyMainView.CanvasPanel_UnlockFloorTip:GetChildAt(Index - 1)
    local UnlockFloorTipSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(TargetUnlockFloorTip)
    UnlockFloorTipSlot:SetPosition(Position + UE.FVector2D(0, 20))
  end
end

function LobbyMainViewModel:CheckOpeningBattlePass()
  local battlePassTable = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePass)
  local UTCTimestamp = GetCurrentTimestamp(true)
  local ClientTimeOffset = GetCurrentTimestamp(false) - GetCurrentTimestamp(true)
  local CurTimestamp = ConvertTimestampToServerTimeByServerTimeZone(UTCTimestamp - ClientTimeOffset)
  for i, v in ipairs(battlePassTable) do
    local StartTimeZone = ConvertTimeStrToServerTimeByServerTimeZone(v.StartTime)
    local EndTimeZone = ConvertTimeStrToServerTimeByServerTimeZone(v.EndTime)
    if CurTimestamp >= StartTimeZone and CurTimestamp <= EndTimeZone then
      return v
    end
  end
  return battlePassTable[1]
end

function LobbyMainViewModel:OnShutdown()
  self.Super.OnShutdown(self)
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, self.BindOnChangeRoleItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.PlayInAnimation, self.OnPlayInAnimation, self)
  EventSystem.RemoveListener(EventDef.Lobby.PlayOutAnimation, self.OnPlayOutAnimation, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnJoinGameFail, self.BindOnJoinGameFail, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateRoomMembersInfo, self.BindOnUpdateTeamMembersInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnTeamStateChanged, self.BindOnTeamStateChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnModelAreaClickedChanged, self.BindOnModelAreaClickedChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnInviteDialogue, self.BindInviteDialogue, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnCameraTargetChangedToLobbyAnimCamera, self.BindOnCameraTargetChangedToLobbyAnimCamera, self)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateTicketStatus, self, self.RefreshRessourcenInfo)
end

return LobbyMainViewModel
