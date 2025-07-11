local WBP_SettlementPlayerTitle_C = UnLua.Class()
function WBP_SettlementPlayerTitle_C:Construct()
  self.Btn_Check.OnClicked:Add(self, self.OnCheckClick)
end
function WBP_SettlementPlayerTitle_C:Destruct()
  self.Btn_Check.OnClicked:Remove(self, self.OnCheckClick)
end
function WBP_SettlementPlayerTitle_C:InitSettlementPlayerInfoTitle(PlayerInfo, SelectPlayerId, bIsFromBattleHistory)
  self.bIsFromBattleHistory = bIsFromBattleHistory
  UpdateVisibility(self, true)
  self.RGTextSelect:SetText(PlayerInfo.name)
  self.RGTextUnSelect:SetText(PlayerInfo.name)
  self.RGTextHover:SetText(PlayerInfo.name)
  self:UpdatePlatformIcon(SelectPlayerId)
end
function WBP_SettlementPlayerTitle_C:InitRankPlayerInfoTitle(PlayerName, SelectPlayerId)
  UpdateVisibility(self, true)
  self.RGTextSelect:SetText(PlayerName)
  self.RGTextUnSelect:SetText(PlayerName)
  self.RGTextHover:SetText(PlayerName)
  self:UpdatePlatformIcon(SelectPlayerId)
end
function WBP_SettlementPlayerTitle_C:UpdatePlatformIcon(SelectPlayerId)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_SettlementPlayerTitle_C SelectPlayerId: %s", tostring(SelectPlayerId)))
  if self.PlatformIconPanelUnSelect then
    self.PlatformIconPanelUnSelect:UpdateChannelInfo(SelectPlayerId)
  end
  if self.PlatformIconPanelSelect then
    self.PlatformIconPanelSelect:UpdateChannelInfo(SelectPlayerId)
  end
  if self.PlatformIconPanelHover then
    self.PlatformIconPanelHover:UpdateChannelInfo(SelectPlayerId)
  end
end
function WBP_SettlementPlayerTitle_C:OnMouseEnter()
  UpdateVisibility(self.CanvaspanelHover, true)
end
function WBP_SettlementPlayerTitle_C:OnMouseLeave()
  UpdateVisibility(self.CanvaspanelHover, false)
end
function WBP_SettlementPlayerTitle_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_SettlementPlayerTitle_C:OnCheckClick()
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr and not self.bIsFromBattleHistory then
    UserClickStatisticsMgr:AddClickStatistics("SelectTeammates")
    print("WBP_SettlementPlayerTitle_C:OnCheckClick SelectTeammates")
  end
  local bIsCheck = self.ToggleGroup.CurSelectId == self.ToggleIndex
  self:CheckStateChanged(not bIsCheck)
end
return WBP_SettlementPlayerTitle_C
