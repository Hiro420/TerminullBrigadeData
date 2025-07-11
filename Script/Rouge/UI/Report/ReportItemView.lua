local ReportItemView = UnLua.Class()
function ReportItemView:Construct()
  self.Button_Main.OnClicked:Add(self, ReportItemView.OnItemClicked)
end
function ReportItemView:Destruct()
  self.Button_Main.OnClicked:Remove(self, ReportItemView.OnItemClicked)
end
function ReportItemView:OnItemClicked()
  if self.bSel then
    self.List:BP_SetItemSelection(self.Item, false)
    return
  end
  if 3 == self.List:BP_GetNumItemsSelected() then
    ShowWaveWindow(303006)
  end
  self.List:BP_SetItemSelection(self.Item, true)
end
function ReportItemView:OnListItemObjectSet(ListItemObj)
  if ListItemObj then
    self.Item = ListItemObj
    self.List = UE.UUserListEntryLibrary.GetOwningListView(self)
    self.Txt_Content:SetText(ListItemObj.Name)
  end
  self.bSel = UE.UUserListEntryLibrary.IsListItemSelected(self)
  UpdateVisibility(self.Overlay_Hov, false)
  UpdateVisibility(self.Overlay_Sel, self.bSel)
  UpdateVisibility(self.Overlay_Nor, not self.bSel)
end
function ReportItemView:BP_OnItemSelectionChanged(IsSelected)
  self.bSel = IsSelected
  UpdateVisibility(self.Overlay_Sel, self.bSel)
  UpdateVisibility(self.Overlay_Nor, not self.bSel)
end
function ReportItemView:OnMouseEnter(MyGeometry, MouseEvent)
  if self.bSel then
    return
  end
  UpdateVisibility(self.Overlay_Hov, true)
  UpdateVisibility(self.Overlay_Sel, false)
  UpdateVisibility(self.Overlay_Nor, false)
end
function ReportItemView:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hov, false)
  UpdateVisibility(self.Overlay_Sel, self.bSel)
  UpdateVisibility(self.Overlay_Nor, not self.bSel)
end
function ReportItemView:OnMouseButtonDown(MyGeometry, MouseEvent)
end
function ReportItemView:OnMouseButtonUp(MyGeometry, MouseEvent)
  return UE.UWidgetBlueprintLibrary.Handled()
end
function ReportItemView:DoCustomNavigation_Left()
  local UI_ReportView = UIMgr:GetLuaFromActiveView(ViewID.UI_ReportView)
  if UI_ReportView then
    return UI_ReportView:GetReprotItemLeft(self.Item)
  end
  return nil
end
function ReportItemView:DoCustomNavigation_Right()
  local UI_ReportView = UIMgr:GetLuaFromActiveView(ViewID.UI_ReportView)
  if UI_ReportView then
    return UI_ReportView:GetReprotItemRight(self.Item)
  end
  return nil
end
function ReportItemView:DoCustomNavigation_Up()
  local UI_ReportView = UIMgr:GetLuaFromActiveView(ViewID.UI_ReportView)
  if UI_ReportView then
    return UI_ReportView:GetReprotItemUp(self.Item)
  end
  return nil
end
function ReportItemView:DoCustomNavigation_Down()
  local UI_ReportView = UIMgr:GetLuaFromActiveView(ViewID.UI_ReportView)
  if UI_ReportView then
    return UI_ReportView:GetReprotItemDown(self.Item)
  end
  return nil
end
return ReportItemView
