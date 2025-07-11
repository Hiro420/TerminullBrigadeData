local RankData = require("UI.View.Rank.RankData")
local RankPlayerItem = UnLua.Class()
function RankPlayerItem:Construct()
  self.Button_Player.OnHovered:Add(self, self.OnButtonPlayerHovered)
  self.Button_Player.OnUnhovered:Add(self, self.OnUnButtonPlayerHovered)
end
function RankPlayerItem:OnButtonPlayerHovered()
  self.Hover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if self.ParentWidget and self.ParentWidget.OnHoveredPlayerIcon then
    self.ParentWidget:OnHoveredPlayerIcon(self)
  end
end
function RankPlayerItem:OnUnButtonPlayerHovered()
  self.Hover:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self.ParentWidget and self.ParentWidget.OnHoveredPlayerIcon then
    self.ParentWidget:OnHoveredPlayerIcon(nil)
  end
end
function RankPlayerItem:OnButtonPlayerClicked()
  if RankData.GetPlayerInfo(self.RoleId) and RankData.GetPlayerInfo(self.RoleId).rankInvisible ~= nil and 1 == RankData.GetPlayerInfo(self.RoleId).rankInvisible and self.RoleId ~= DataMgr.GetUserId() then
    ShowWaveWindow(self.InvisiblePlayerWaveWindowId)
    return
  end
  local MousePosition = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
  UIMgr:Show(ViewID.UI_ContactPersonOperateButtonPanel, nil, MousePosition, RankData.GetPlayerInfo(self.RoleId), EOperateButtonPanelSourceFromType.Rank)
end
function RankPlayerItem:InitPlayerItem(RoleId, PlayerName, Icon, bSelf, ParentWidget, rankInvisible)
  self.ParentWidget = ParentWidget
  self.RoleId = RoleId
  self.TextBlock_PlayerName:SetText(PlayerName)
  if nil ~= rankInvisible and 1 == rankInvisible and RoleId ~= DataMgr.GetUserId() then
    self.TextBlock_PlayerName:SetText(self.InvisibleName)
    Icon = 1
    self.InRank = false
  end
  self.WBP_PlayerInfoHeadIconItem:InitPlayerInfoHeadIconItem(Icon)
  if bSelf then
    self.TextBlock_PlayerName:SetColorAndOpacity(self.FontColor)
  else
    self.TextBlock_PlayerName:SetColorAndOpacity(self.FontColorDef)
  end
  if self.PlatformIconPanel then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo RankPlayerItem RoleId: %s", tostring(RoleId)))
    self.PlatformIconPanel:UpdateChannelInfo(RoleId)
  end
end
function RankPlayerItem:OnMouseButtonDown(MyGeometry, MouseEvent)
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.RightMouseButton then
    self:OnButtonPlayerClicked()
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
return RankPlayerItem
