local WBP_MatchingPanel_C = UnLua.Class()

function WBP_MatchingPanel_C:Construct()
  self.Btn_JoinTeam.OnClicked:Add(self, WBP_MatchingPanel_C.BindOnJoinTeamButtonClicked)
  self.Btn_Copy.OnClicked:Add(self, WBP_MatchingPanel_C.BindOnCopyTeamNumButtonClicked)
  self.Btn_Edit.OnHovered:Add(self, WBP_MatchingPanel_C.BindOnEditButtonHovered)
  self.Btn_Edit.OnUnhovered:Add(self, WBP_MatchingPanel_C.BindOnEditButtonUnhovered)
end

function WBP_MatchingPanel_C:OnAnimationFinished(Animation)
  if Animation == self.ani_MatchingPanel_Out then
    self:BindOnMatchingPanelOutAnimFinished()
  elseif Animation == self.ani_Click then
    self:BindOnClickAnimFinished()
  end
end

function WBP_MatchingPanel_C:BindOnClickAnimFinished()
  self:PlayAnimation(self.ani_Click_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward)
end

function WBP_MatchingPanel_C:StopClickLoopAnim()
  if self:IsAnimationPlaying(self.ani_Click_loop) then
    self:StopAnimation(self.ani_Click_loop)
    self:PlayAnimationTimeRange(self.ani_Click_loop, self.ani_Click_loop:GetEndTime(), self.ani_Click_loop:GetEndTime())
  end
end

function WBP_MatchingPanel_C:BindOnJoinTeamButtonClicked()
  LuaAddClickStatistics("LobbyJoinTeam")
  local TeamIdStr = tostring(self.Edit_TeamMember:GetText())
  local TeamId = tonumber(TeamIdStr)
  if not TeamId or 0 == TeamId then
    ShowWaveWindow(15011, {})
    print("\230\151\160\230\149\136\231\154\132\233\152\159\228\188\141\231\160\129")
    return
  end
  if DataMgr.IsInTeam() then
    print("\229\183\178\229\156\168\233\152\159\228\188\141\228\184\173")
    LogicTeam.RequestQuitTeamToServer({
      self,
      function()
        LogicTeam.RequestJoinTeamToServer(TeamIdStr, LogicTeam.JoinTeamWay.TeamCode)
      end
    })
  else
    LogicTeam.RequestJoinTeamToServer(TeamIdStr, LogicTeam.JoinTeamWay.TeamCode)
  end
end

function WBP_MatchingPanel_C:BindOnCopyTeamNumButtonClicked()
  LuaAddClickStatistics("LobbyCopyTeamcode")
  self:BindOnCopyTeamCodePressed()
end

function WBP_MatchingPanel_C:BindOnEditButtonHovered()
  self.Img_EditHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_MatchingPanel_C:BindOnEditButtonUnhovered()
  self.Img_EditHover:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_MatchingPanel_C:OnShow()
  self:InitTeamList()
  self:BindOnUpdateMyTeamInfo()
  self:BindOnUpdateRoomMembersInfo()
  self.Img_EditHover:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.TeamOperateButtonPanel:Hide()
  self:PlayAnimation(self.ani_MatchingPanel_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
  LogicAudio.OnPageOpen()
  ListenForInputAction(self.CopyTeamCodeName, UE.EInputEvent.IE_Pressed, true, {
    self,
    self.BindOnCopyTeamCodePressed
  })
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, WBP_MatchingPanel_C.BindOnUpdateMyTeamInfo)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateRoomMembersInfo, WBP_MatchingPanel_C.BindOnUpdateRoomMembersInfo)
  EventSystem.AddListener(self, EventDef.Lobby.OnMultiTeamMemberOmissionButtonClicked, self.BindOnMultiTeamMemberOmissionButtonClicked)
end

function WBP_MatchingPanel_C:InitTeamList()
  local AllItem = self.TeamMemberList:GetAllChildren()
  for i, SingleItem in pairs(AllItem) do
    SingleItem:InitStatus()
  end
  local BasicInfo = DataMgr.GetBasicInfo()
  local MyHeroInfo = DataMgr.GetMyHeroInfo()
  local Item = self.TeamMemberList:GetChildAt(0)
  if Item then
    Item:Show(BasicInfo, MyHeroInfo.equipHero, BasicInfo.roleid, false)
  end
end

function WBP_MatchingPanel_C:BindOnEscKeyPressed()
  self:PlayAnimation(self.ani_MatchingPanel_out, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
  LogicAudio.OnPageOpen()
end

function WBP_MatchingPanel_C:BindOnCopyTeamCodePressed()
  if DataMgr.IsInTeam() then
    local TeamInfo = DataMgr.GetTeamInfo()
    UE.URGBlueprintLibrary.CopyMessageToClipboard(TeamInfo.teamid)
  else
    LogicTeam.RequestCreateTeamToServer({
      self,
      function()
        local TeamInfo = DataMgr.GetTeamInfo()
        UE.URGBlueprintLibrary.CopyMessageToClipboard(TeamInfo.teamid)
      end
    })
  end
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if WaveWindowManager then
    WaveWindowManager:ShowWaveWindow(1097)
  end
end

function WBP_MatchingPanel_C:BindOnUpdateMyTeamInfo()
  if DataMgr.IsInTeam() then
    local TeamInfo = DataMgr.GetTeamInfo()
    self.Txt_TeamNum:SetText(TeamInfo.teamid)
  else
    self:InitTeamList()
    self.Txt_TeamNum:SetText("")
  end
end

function WBP_MatchingPanel_C:BindOnUpdateRoomMembersInfo()
  local PlayerInfoList = DataMgr.GetTeamMembersInfo()
  local TeamInfo = DataMgr.GetTeamInfo()
  local AllItem = self.TeamMemberList:GetAllChildren()
  for i, SingleItem in pairs(AllItem) do
    SingleItem:InitStatus()
  end
  local RoomPlayerInfo = {}
  local TeamCount = 0
  if TeamInfo.players then
    for i, SingleRoomPlayerInfo in ipairs(TeamInfo.players) do
      RoomPlayerInfo[SingleRoomPlayerInfo.id] = SingleRoomPlayerInfo
      TeamCount = TeamCount + 1
    end
  end
  local Index = 0
  for i, SinglePlayerInfo in ipairs(PlayerInfoList) do
    local SingleRoomPlayerInfo = RoomPlayerInfo[SinglePlayerInfo.roleid]
    if SingleRoomPlayerInfo then
      local Item = self.TeamMemberList:GetChildAt(Index)
      Item = Item or UE.UWidgetBlueprintLibrary.Create(self, self.ItemTemplate:StaticClass())
      if SinglePlayerInfo.roleid == DataMgr.GetUserId() and 1 == TeamCount then
        SinglePlayerInfo = DataMgr.GetBasicInfo()
      end
      Item:Show(SinglePlayerInfo, SingleRoomPlayerInfo.hero.id, TeamInfo.captain, false)
      Index = Index + 1
    end
  end
  for i, SingleItem in pairs(AllItem) do
    SingleItem:PlayTeamMemberAnim()
  end
end

function WBP_MatchingPanel_C:BindOnMultiTeamMemberOmissionButtonClicked(SingleRoleInfo, ViewportPos)
  local TeamInfo = DataMgr.GetTeamInfo()
  local TargetPlayerInfo
  for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
    if SingleRoleInfo.roleid == SinglePlayerInfo.id then
      TargetPlayerInfo = SinglePlayerInfo
      break
    end
  end
  local CachedGeometry = self.Img_Bottom:GetCachedGeometry()
  local PixelPosition, BottomViewportPosition = UE.USlateBlueprintLibrary.LocalToViewport(self, CachedGeometry, UE.FVector2D(), nil, nil)
  local LocalSize = UE.USlateBlueprintLibrary.GetLocalSize(CachedGeometry) * self.BottomScaleBox.UserSpecifiedScale
  self.TeamOperateButtonPanel:Show(TargetPlayerInfo)
  self.TeamOperateButtonPanel:UpdatePosition(UE.FVector2D(BottomViewportPosition.X + LocalSize.X + self.TeamOperatePanelXInterval, ViewportPos.Y))
end

function WBP_MatchingPanel_C:BindOnMatchingPanelOutAnimFinished()
  UIMgr:Hide(ViewID.UI_MatchingPanel)
end

function WBP_MatchingPanel_C:OnBGLeftMouseButtonDown()
  self:BindOnEscKeyPressed()
end

function WBP_MatchingPanel_C:OnHide()
  if IsListeningForInputAction(self, self.CopyTeamCodeName) then
    StopListeningForInputAction(self, self.CopyTeamCodeName, UE.EInputEvent.IE_Pressed)
  end
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, WBP_MatchingPanel_C.BindOnUpdateMyTeamInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateRoomMembersInfo, WBP_MatchingPanel_C.BindOnUpdateRoomMembersInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnMultiTeamMemberOmissionButtonClicked, self.BindOnMultiTeamMemberOmissionButtonClicked, self)
end

function WBP_MatchingPanel_C:Destruct()
  self:OnHide()
  self:StopClickLoopAnim()
end

return WBP_MatchingPanel_C
