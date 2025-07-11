local WBP_WeaponAttrItem_C = UnLua.Class()
function WBP_WeaponAttrItem_C:InitAttributeInfo(Name, Value, Unit)
  self.RGTextAttrValue:SetText(Value)
  self.RGTextAttrValueUnit:SetText(Unit)
  self.RGTextAttrName:SetText(Name)
  self:UpdateCompareStatus(0)
end
function WBP_WeaponAttrItem_C:UpdateCompareStatus(Result, oldDisplayValue, newDisplayValue, Unit)
  if 0 == Result then
    UpdateVisibility(self.HorizontalCompareStatus, false)
  elseif 1 == Result then
    self.RGTextAttrValue:SetText(oldDisplayValue)
    self.RGTextAttrValueUnit:SetText(Unit)
    self.RGTextRightAttrValue:SetText(newDisplayValue)
    self.RGTextRightAttrValue:SetColorAndOpacity(self.HighTextColor)
    self.RGTextRightAttrValueUnit:SetText(Unit)
    self.RGTextRightAttrValueUnit:SetColorAndOpacity(self.HighTextColor)
    UpdateVisibility(self.RGTextRightAttrValueUnit, true)
    self.Img_LeftCompareStatus_1:SetColorAndOpacity(self.HighTextColor.SpecifiedColor)
    self.Img_LeftCompareStatus_2:SetColorAndOpacity(self.HighTextColor.SpecifiedColor)
    self.HorizontalCompareStatus:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.RGTextAttrValue:SetText(oldDisplayValue)
    self.RGTextAttrValueUnit:SetText(Unit)
    self.RGTextRightAttrValue:SetText(newDisplayValue)
    self.RGTextRightAttrValue:SetColorAndOpacity(self.LowTextColor)
    self.RGTextRightAttrValueUnit:SetText(Unit)
    self.RGTextRightAttrValueUnit:SetColorAndOpacity(self.LowTextColor)
    UpdateVisibility(self.RGTextRightAttrValueUnit, true)
    self.Img_LeftCompareStatus_1:SetColorAndOpacity(self.LowTextColor.SpecifiedColor)
    self.Img_LeftCompareStatus_2:SetColorAndOpacity(self.LowTextColor.SpecifiedColor)
    self.HorizontalCompareStatus:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  end
end
return WBP_WeaponAttrItem_C
