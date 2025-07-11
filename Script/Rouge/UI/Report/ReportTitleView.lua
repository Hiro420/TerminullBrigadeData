local ReportTitleView = UnLua.Class()
function ReportTitleView:Construct()
  self.Button_Main.OnClicked:Add(self, ReportTitleView.OnItemClicked)
  self.Overlay_Nor:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
end
function ReportTitleView:Destruct()
  self.Button_Main.OnClicked:Remove(self, ReportTitleView.OnItemClicked)
end
function ReportTitleView:OnItemClicked()
  local CurIndex = self.List:GetIndexForItem(self.Item)
  self.List:SetSelectedIndex(CurIndex)
end
function ReportTitleView:OnMouseEnter(MyGeometry, MouseEvent)
  self.Overlay_Horver:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
end
function ReportTitleView:OnMouseLeave(MyGeometry, MouseEvent)
  self.Overlay_Horver:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function ReportTitleView:OnListItemObjectSet(ListItemObj)
  if ListItemObj then
    self.Item = ListItemObj
    self.List = UE.UUserListEntryLibrary.GetOwningListView(self)
    self.Content:SetText(ListItemObj.Name)
    self.Content_Sel:SetText(ListItemObj.Name)
    self.Content_Horver:SetText(ListItemObj.Name)
  end
  local UI_ReportView = UIMgr:GetLuaFromActiveView(ViewID.UI_ReportView)
  if UI_ReportView then
    UI_ReportView:OnTitleItemCreated()
  end
end
function ReportTitleView:BP_OnItemSelectionChanged(IsSelected)
  self.bSel = IsSelected
  if self.bSel then
    self.Overlay_Sel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Overlay_Nor:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Overlay_Sel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Overlay_Nor:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  end
end
function ReportTitleView:DoCustomNavigation_Left()
  local UI_ReportView = UIMgr:GetLuaFromActiveView(ViewID.UI_ReportView)
  if UI_ReportView then
    return UI_ReportView:GetReprotTitleLeft(self.Item)
  end
  return nil
end
function ReportTitleView:DoCustomNavigation_Right()
  local UI_ReportView = UIMgr:GetLuaFromActiveView(ViewID.UI_ReportView)
  if UI_ReportView then
    return UI_ReportView:GetReprotTitleRight(self.Item)
  end
  return nil
end
function ReportTitleView:DoCustomNavigation_Up()
  local UI_ReportView = UIMgr:GetLuaFromActiveView(ViewID.UI_ReportView)
  if UI_ReportView then
    return UI_ReportView.BP_ButtonCancel
  end
  return nil
end
function ReportTitleView:DoCustomNavigation_Down()
  local UI_ReportView = UIMgr:GetLuaFromActiveView(ViewID.UI_ReportView)
  if UI_ReportView then
    return UI_ReportView:DoCustomNavigation_ContentFirst()
  end
  return nil
end
return ReportTitleView
