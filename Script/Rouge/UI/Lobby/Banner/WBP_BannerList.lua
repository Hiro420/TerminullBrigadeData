local WBP_BannerList = UnLua.Class()

function WBP_BannerList:Construct()
  self.CurSelectIndex = 1
  local Count = 0
  local AllChildren = self.ScrollBox_Main:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    if SingleItem:IsVisible() then
      Count = Count + 1
    end
  end
  self.WBP_Selector:InitSelector(Count, self.CurSelectIndex, function(Index)
    self.CurSelectIndex = Index
    self:UpdateBanner()
  end)
  self.WBP_BannerItem_Activity.OnClicked:Add(self, self.BindOnActivityItemClicked)
  self.WBP_BannerItem_MonthCard.OnClicked:Add(self, self.BindOnMonthCardItemClicked)
end

function WBP_BannerList:BindOnActivityItemClicked(...)
  FuncUtil.AddClickStatistics("ActivityMenu")
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.SEVEN_DAYS_AWARDS) then
    return
  end
  UIMgr:Show(ViewID.UI_ActivityPanel, true)
end

function WBP_BannerList:BindOnMonthCardItemClicked(...)
  local LobbyPanelTagName = LogicLobby.GetLabelTagNameByUIName("UI_MonthCardPanel")
  LogicLobby.ChangeLobbyPanelLabelSelected(LobbyPanelTagName)
end

function WBP_BannerList:OnMouseWheel(MyGeometry, MouseEvent)
  local Offset = UE.UKismetInputLibrary.PointerEvent_GetWheelDelta(MouseEvent)
  local CurSelectIndex = Offset < 0 and self.CurSelectIndex + 1 or self.CurSelectIndex - 1
  self.WBP_Selector:SetSelectByIndex(CurSelectIndex)
end

function WBP_BannerList:UpdateBanner()
  local TargetChild
  local AllChildren = self.ScrollBox_Main:GetAllChildren()
  local Index = 1
  for k, SingleItem in pairs(AllChildren) do
    if SingleItem:IsVisible() then
      if Index == self.CurSelectIndex then
        TargetChild = SingleItem
        break
      end
      Index = Index + 1
    end
  end
  if TargetChild then
    self.ScrollBox_Main:ScrollWidgetIntoView(TargetChild, true, UE.EDescendantScrollDestination.Center)
  end
end

return WBP_BannerList
