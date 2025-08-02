local WBP_AttributeModifySet_Item_C = UnLua.Class()

function WBP_AttributeModifySet_Item_C:OnListItemObjectSet(ListItemObj)
  self.Data = ListItemObj.Data
  local Result = false
  local RowInfo = UE.FRGAttributeModifySetTableRow
  Result, RowInfo = GetRowData(DT.DT_AttributeModifySet, ListItemObj.Data.Id)
  if Result then
    SetImageBrushBySoftObject(self.Img_Icon, RowInfo.SetIcon)
  end
end

function WBP_AttributeModifySet_Item_C:HaveYouObtained()
end

function WBP_AttributeModifySet_Item_C:SetQuality()
end

function WBP_AttributeModifySet_Item_C:BP_OnItemSelectionChanged(IsSelected)
  UpdateVisibility(self.Img_Select, IsSelected)
end

function WBP_AttributeModifySet_Item_C:BP_OnEntryReleased()
  UpdateVisibility(self.Img_Select, false)
end

function WBP_AttributeModifySet_Item_C:SetSelect(bSelect)
end

function WBP_AttributeModifySet_Item_C:SetCover(bCover)
end

function WBP_AttributeModifySet_Item_C:OnMouseEnter(MyGeometry, MouseEvent)
  EventSystem.Invoke(EventDef.IllustratedGuide.AttributeModifyHoveredTip, self, self.Data.Id, true)
end

function WBP_AttributeModifySet_Item_C:OnMouseLeave(MyGeometry, MouseEvent)
  EventSystem.Invoke(EventDef.IllustratedGuide.AttributeModifyHoveredTip, self, self.Data.Id, false)
end

return WBP_AttributeModifySet_Item_C
