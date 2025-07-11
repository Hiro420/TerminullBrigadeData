local WBP_MultiTeamMemberItem_C = UnLua.Class()
function WBP_MultiTeamMemberItem_C:Construct()
  self.Btn_Exit.OnClicked:Add(self, WBP_MultiTeamMemberItem_C.BindOnExitButtonClicked)
  self.Btn_Exit.OnHovered:Add(self, WBP_MultiTeamMemberItem_C.BindOnExitButtonHovered)
  self.Btn_Exit.OnUnhovered:Add(self, WBP_MultiTeamMemberItem_C.BindOnExitButtonUnhovered)
  self.Btn_Kick.OnClicked:Add(self, WBP_MultiTeamMemberItem_C.BindOnKickButtonClicked)
  self.Btn_Kick.OnHovered:Add(self, WBP_MultiTeamMemberItem_C.BindOnKickButtonHovered)
  self.Btn_Kick.OnUnhovered:Add(self, WBP_MultiTeamMemberItem_C.BindOnKickButtonUnhovered)
  self.Btn_Omission.OnClicked:Add(self, WBP_MultiTeamMemberItem_C.BindOnOmissionButtonClicked)
  self.Btn_Omission.OnHovered:Add(self, WBP_MultiTeamMemberItem_C.BindOnOmissionButtonHovered)
  self.Btn_Omission.OnUnhovered:Add(self, WBP_MultiTeamMemberItem_C.BindOnOmissionButtonUnhovered)
  self.Btn_AddFriend.OnClicked:Add(self, WBP_MultiTeamMemberItem_C.BindOnAddFriendButtonClicked)
  self.Btn_AddFriend.OnHovered:Add(self, WBP_MultiTeamMemberItem_C.BindOnAddFriendButtonHovered)
  self.Btn_AddFriend.OnUnhovered:Add(self, WBP_MultiTeamMemberItem_C.BindOnAddFriendButtonUnhovered)
  self.Btn_EmptySlot.OnClicked:Add(self, self.BindOnEmptySlotButtonClicked)
  self.LastIsHaveMember = false
  self.CurIsHaveMember = false
end
function WBP_MultiTeamMemberItem_C:BindOnExitButtonClicked()
  LogicTeam.RequestQuitTeamToServer()
end
function WBP_MultiTeamMemberItem_C:BindOnExitButtonHovered()
  self.Img_ExitBottom:SetRenderOpacity(self.HoverBottomOpacity)
end
function WBP_MultiTeamMemberItem_C:BindOnExitButtonUnhovered()
  self.Img_ExitBottom:SetRenderOpacity(self.UnHoverBottomOpacity)
end
function WBP_MultiTeamMemberItem_C:BindOnKickButtonClicked()
  UIMgr:Show(ViewID.UI_KickTeamTip, nil, self.SinglePlayerInfo)
end
function WBP_MultiTeamMemberItem_C:BindOnKickButtonHovered()
  self.Img_KickBottom:SetRenderOpacity(self.HoverBottomOpacity)
end
function WBP_MultiTeamMemberItem_C:BindOnKickButtonUnhovered()
  self.Img_KickBottom:SetRenderOpacity(self.UnHoverBottomOpacity)
end
function WBP_MultiTeamMemberItem_C:BindOnOmissionButtonClicked()
  local CachedGeometry = self:GetCachedGeometry()
  local PixelPosition, ViewportPosition = UE.USlateBlueprintLibrary.LocalToViewport(self, CachedGeometry, UE.FVector2D(), nil, nil)
  EventSystem.Invoke(EventDef.Lobby.OnMultiTeamMemberOmissionButtonClicked, self.SinglePlayerInfo, ViewportPosition)
end
function WBP_MultiTeamMemberItem_C:BindOnOmissionButtonHovered()
  self.Img_OmissionBottom:SetRenderOpacity(self.HoverBottomOpacity)
end
function WBP_MultiTeamMemberItem_C:BindOnOmissionButtonUnhovered()
  self.Img_OmissionBottom:SetRenderOpacity(self.UnHoverBottomOpacity)
end
function WBP_MultiTeamMemberItem_C:BindOnAddFriendButtonClicked()
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics("LobbyTeamInvite")
  end
  UIMgr:Show(ViewID.UI_ContactPerson)
  UIMgr:Hide(ViewID.UI_MatchingPanel)
end
function WBP_MultiTeamMemberItem_C:BindOnAddFriendButtonHovered()
  self.Img_AddFriendBottom:SetRenderOpacity(self.HoverBottomOpacity)
end
function WBP_MultiTeamMemberItem_C:BindOnAddFriendButtonUnhovered()
  self.Img_AddFriendBottom:SetRenderOpacity(self.UnHoverBottomOpacity)
end
function WBP_MultiTeamMemberItem_C:BindOnEmptySlotButtonClicked()
  UIMgr:Show(ViewID.UI_ContactPerson)
  UIMgr:Hide(ViewID.UI_MatchingPanel)
end
function WBP_MultiTeamMemberItem_C:InitStatus()
  self.SinglePlayerInfo = nil
  self.CurIsHaveMember = false
  self.MemberPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  self.NoMemberPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Btn_Exit:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Btn_Kick:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Btn_Omission:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Btn_AddFriend:SetVisibility(UE.ESlateVisibility.Visible)
  if not self.IsHover then
    self.Img_MemberBottomHover:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_NoMemberBottomHover:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_MultiTeamMemberItem_C:Show(SinglePlayerInfo, HeroId, CaptainId, IsReady)
  self.SinglePlayerInfo = SinglePlayerInfo
  self.HeroId = HeroId
  self.CaptainId = CaptainId
  self.IsReady = IsReady
  self.MemberPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.NoMemberPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:RefreshBasicInfo()
  self:RefreshFunctionalBtnVis()
  self.CurIsHaveMember = true
end
function WBP_MultiTeamMemberItem_C:RefreshBasicInfo()
  self.Txt_Level:SetText(tostring(self.SinglePlayerInfo.level))
  self.Txt_Name:SetText(self.SinglePlayerInfo.nickname)
  if self.CaptainId == self.SinglePlayerInfo.roleid then
    self.Img_Captain:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Captain:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local RowInfo = LogicRole.GetCharacterTableRow(self.HeroId)
  if RowInfo then
    self.Txt_HeroName:SetText(RowInfo.Name)
  end
  local PortraitRowInfo = LogicLobby.GetPlayerPortraitTableRowInfo(self.SinglePlayerInfo.portrait)
  if PortraitRowInfo then
    SetImageBrushByPath(self.Image_Icon, PortraitRowInfo.portraitIconPath)
  end
end
function WBP_MultiTeamMemberItem_C:RefreshFunctionalBtnVis()
  self.Btn_Exit:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Btn_Kick:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Btn_Omission:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Btn_AddFriend:SetVisibility(UE.ESlateVisibility.Collapsed)
  local MyUserId = DataMgr.GetBasicInfo().roleid
  if self.SinglePlayerInfo.roleid == MyUserId then
    local TeamInfo = DataMgr.GetTeamInfo()
    local TeamStateCanExit = TeamInfo.state ~= LogicTeam.TeamState.Matching and TeamInfo.state ~= LogicTeam.TeamState.Preparing
    if DataMgr.IsInTeam() and TeamInfo.players and table.count(TeamInfo.players) > 1 and TeamStateCanExit then
      self.Btn_Exit:SetVisibility(UE.ESlateVisibility.Visible)
    else
      self.Btn_Exit:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  else
    if MyUserId == self.CaptainId then
      self.Btn_Kick:SetVisibility(UE.ESlateVisibility.Visible)
    end
    self.Btn_Omission:SetVisibility(UE.ESlateVisibility.Visible)
  end
end
function WBP_MultiTeamMemberItem_C:PlayTeamMemberAnim()
  if self.LastIsHaveMember == self.CurIsHaveMember then
    return
  end
  if self.CurIsHaveMember then
    self:PlayAnimationForward(self.ani_MemberInfoPanel_in)
  end
  self.LastIsHaveMember = self.CurIsHaveMember
end
function WBP_MultiTeamMemberItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self.IsHover = true
  if self.CurIsHaveMember then
    self.Img_MemberBottomHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_NoMemberBottomHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_MultiTeamMemberItem_C:OnMouseLeave(MyGeometry, MouseEvent)
  self.IsHover = false
  if self.CurIsHaveMember then
    self.Img_MemberBottomHover:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Img_NoMemberBottomHover:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
return WBP_MultiTeamMemberItem_C
