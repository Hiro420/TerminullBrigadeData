local WBP_TeamMemberItem_C = UnLua.Class()
function WBP_TeamMemberItem_C:Construct()
  self.LastIsHaveMemeber = nil
  self.CurIsHaveMemeber = false
end
function WBP_TeamMemberItem_C:Show(PlayerInfo, IsCaptain, IsReady)
  self.MemberInfoPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Img_Captain:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.NoMemberPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  self.PlayerInfo = PlayerInfo
  self.Txt_Name:SetText(PlayerInfo.nickname)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local TeamInfo = DataMgr.GetTeamInfo()
    local HeroId = 0
    for i, SingleTeamPlayerInfo in ipairs(TeamInfo.players) do
      if self.PlayerInfo.roleid == SingleTeamPlayerInfo.id then
        HeroId = SingleTeamPlayerInfo.hero.id
        break
      end
    end
    local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
    if RowInfo then
      self.Txt_HeroName:SetText(RowInfo.Name)
    end
  end
  self.Txt_Level:SetText(PlayerInfo.level)
  if IsCaptain then
    self.Img_Captain:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:UpdateReadyState(false)
  else
    self.Img_Captain:SetVisibility(UE.ESlateVisibility.Hidden)
    self:UpdateReadyState(IsReady)
  end
  self.CurIsHaveMemeber = true
end
function WBP_TeamMemberItem_C:UpdateReadyState(IsReady)
  if IsReady then
    self.Img_ReadyState:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_ReadyState:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_TeamMemberItem_C:Hide()
  self.MemberInfoPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Img_Captain:SetVisibility(UE.ESlateVisibility.Hidden)
  self.NoMemberPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.PlayerInfo = nil
  self.CurIsHaveMemeber = false
end
function WBP_TeamMemberItem_C:ShowTeamMemberAnimation()
  if self.LastIsHaveMemeber == self.CurIsHaveMemeber then
    return
  end
  if self.CurIsHaveMemeber then
    self:ShowMemberAnimation()
  else
    self:ShowNoMemebrAnimation()
  end
  self.LastIsHaveMemeber = self.CurIsHaveMemeber
end
function WBP_TeamMemberItem_C:ShowNoMemebrAnimation()
  self:PlayAnimationForward(self.ani_NoMemberPanel_in)
end
function WBP_TeamMemberItem_C:ShowMemberAnimation()
  self:PlayAnimationForward(self.ani_MemberInfoPanel_in)
end
return WBP_TeamMemberItem_C
