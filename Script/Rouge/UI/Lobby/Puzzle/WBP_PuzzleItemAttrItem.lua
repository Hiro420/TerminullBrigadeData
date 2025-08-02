local WBP_PuzzleItemAttrItem = UnLua.Class()

function WBP_PuzzleItemAttrItem:Show(AttrId, AttrValue, IsRecommend)
  local Result, AttrModifyOp = GetRowData(DT.DT_AttributeModifyOp, tostring(AttrId))
  if not Result then
    return
  end
  UpdateVisibility(self, true)
  self.Txt_Desc:SetText(AttrModifyOp.Desc)
  local ValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(AttrValue, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit, AttrModifyOp.RateDisplayInUI)
  self.Txt_Value:SetText(ValueText)
  if IsRecommend then
    self.RGStateController:ChangeStatus("Recommend")
  else
    self.RGStateController:ChangeStatus("NotRecommend")
  end
end

function WBP_PuzzleItemAttrItem:Hide(...)
  UpdateVisibility(self, false)
end

return WBP_PuzzleItemAttrItem
