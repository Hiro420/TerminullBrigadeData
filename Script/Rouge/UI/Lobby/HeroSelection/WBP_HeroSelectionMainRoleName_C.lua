local WBP_HeroSelectionMainRoleName_C = UnLua.Class()

function WBP_HeroSelectionMainRoleName_C:Show(PlayerInfo)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.PlayerInfo = PlayerInfo
  self.Txt_Name:SetText(self.PlayerInfo.nickname)
  self:ChangePickStateVis()
  if not self.IsBind then
    EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
    self.IsBind = true
  end
end

function WBP_HeroSelectionMainRoleName_C:BindOnUpdateMyTeamInfo()
  self:ChangePickStateVis()
end

function WBP_HeroSelectionMainRoleName_C:ChangePickStateVis()
  local TeamInfo = DataMgr.GetTeamInfo()
  if not TeamInfo.players then
    return
  end
  if not self.PlayerInfo then
    return
  end
  for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
    if SinglePlayerInfo.id == self.PlayerInfo.roleid then
      if 0 == SinglePlayerInfo.pickDone then
        self.Img_Pick:SetVisibility(UE.ESlateVisibility.Hidden)
        self.Txt_Status:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.Txt_HeroName:SetVisibility(UE.ESlateVisibility.Collapsed)
      else
        self.Img_Pick:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.Txt_Status:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.Txt_HeroName:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        local RowInfo = LogicRole.GetCharacterTableRow(SinglePlayerInfo.pickHeroInfo.id)
        if RowInfo then
          self.Txt_HeroName:SetText(RowInfo.Name)
        end
      end
    end
  end
end

function WBP_HeroSelectionMainRoleName_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.PlayerInfo = nil
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  self.IsBind = false
end

function WBP_HeroSelectionMainRoleName_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  self.IsBind = false
end

return WBP_HeroSelectionMainRoleName_C
