local WBP_PuzzleViewAttrItem = UnLua.Class()
function WBP_PuzzleViewAttrItem:Show(AttrIdStr, AttrValue)
  local Result, AttrModifyOp = GetRowData(DT.DT_AttributeModifyOp, AttrIdStr)
  if not Result then
    return
  end
  UpdateVisibility(self, true)
  SetImageBrushBySoftObject(self.Img_AttrIcon, AttrModifyOp.Icon, self.IconSize)
  self.Txt_Desc:SetText(AttrModifyOp.Desc)
  local ValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(AttrValue, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit, AttrModifyOp.RateDisplayInUI)
  self.Txt_Value:SetText(ValueText)
end
return WBP_PuzzleViewAttrItem
