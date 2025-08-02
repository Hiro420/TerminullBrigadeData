local WBP_RoleAttributeItem_C = UnLua.Class()
local FormatValue = function(value, AttributeDisplayType)
  if AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Default then
    return string.format("%.1f", value)
  elseif AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Integer then
    return string.format("%d", UE.UKismetMathLibrary.Round(value))
  elseif AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Percent then
    return string.format("%.1f%% ", value * 100)
  elseif AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Reciprocal then
    return string.format("%f", 1 / value)
  elseif AttributeDisplayType == UE.ERGAttributeDisplayType.DT_ReciprocalInteger then
    return string.format("%d", UE.UKismetMathLibrary.Round(1 / value))
  end
  return "0"
end

function WBP_RoleAttributeItem_C:Show(RowInfo, Value)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Name:SetText(RowInfo.DisplayNameInUI)
  self.Txt_Value:SetText(FormatValue(Value, RowInfo.AttributeDisplayType))
  self:PlayAnimationForward(self.Ani_in)
  SetImageBrushBySoftObject(self.Img_Icon, RowInfo.SpriteIcon, self.IconSize)
end

function WBP_RoleAttributeItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_RoleAttributeItem_C
