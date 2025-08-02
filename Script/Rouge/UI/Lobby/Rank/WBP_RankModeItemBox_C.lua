local WBP_RankModeItemBox_C = UnLua.Class()

function WBP_RankModeItemBox_C:Construct()
  EventSystem.AddListener(self, EventDef.LobbyRankPanel.OnModeChange, WBP_RankModeItemBox_C.OnModeChange)
  self.wbp_rankModeItemClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Rank/WBP_RankModeItem.WBP_RankModeItem_C")
end

function WBP_RankModeItemBox_C:Destruct()
  EventSystem.RemoveListener(EventDef.LobbyRankPanel.OnModeChange, WBP_RankModeItemBox_C.OnModeChange, self)
end

function WBP_RankModeItemBox_C:OnModeChange(Index)
  for key, value in pairs(self.HorizontalBox_Mode:GetAllChildren()) do
    if value.Index ~= Index then
      value.SelectIndex = Index
      value:UpdateButtonStatus(false)
    end
  end
end

function WBP_RankModeItemBox_C:UpdateRankModeItemBox()
  local padding = UE.FMargin()
  padding.Right = 10
  UpdateWidgetContainerByClass(self.HorizontalBox_Mode, 4, self.wbp_rankModeItemClass, padding, self, self:GetOwningPlayer())
  local widgetArray = self.HorizontalBox_Mode:GetAllChildren()
  for key, value in pairs(widgetArray) do
    if widgetArray:IsValidIndex(key) then
      widgetArray:Get(key):UpdateRankModeItem(key)
    end
  end
end

return WBP_RankModeItemBox_C
