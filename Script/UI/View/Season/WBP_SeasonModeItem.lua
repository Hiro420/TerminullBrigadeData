local WBP_SeasonModeItem = Class()

function WBP_SeasonModeItem:Construct(...)
  self.Btn_LinkTo.Onclicked:Add(self, self.OnLinkTo)
end

function WBP_SeasonModeItem:Destruct()
  self.Btn_LinkTo.Onclicked:Remove(self, self.OnLinkTo)
end

function WBP_SeasonModeItem:InitSeasonModeItem(RowGameMode)
  self.LinkID = RowGameMode.SeasonLinkID
  self.GameModeID = RowGameMode.ID
  SetImageBrushByPath(self.Img_SeasonModBg, RowGameMode.SeasonModeIcon)
  self.Txt_SeasonModeName:SetText(RowGameMode.Name)
end

function WBP_SeasonModeItem:OnLinkTo()
  local TeamUnLock, LockTeamMembers = LogicTeam.GetTeamUnLockModeAndMember(self.GameModeId)
  if not TeamUnLock then
    ShowWaveWindow(1455)
    return
  end
  ComLink(self.LinkID, nil, -1, -1, -1)
end

return WBP_SeasonModeItem
