local PuzzleData = require("Modules.Puzzle.PuzzleData")
local WBP_PuzzleCoreAttrListItem = UnLua.Class()
function WBP_PuzzleCoreAttrListItem:Show(AttrId, AttrValue, CompareValue, MutationType)
  self.AttrId = AttrId
  self.AttrValue = AttrValue
  self.MutationType = MutationType or EMutationType.Normal
  local Result, AttrModifyOp = GetRowData(DT.DT_AttributeModifyOp, tostring(AttrId))
  if not Result then
    return
  end
  UpdateVisibility(self, true)
  SetImageBrushBySoftObject(self.Img_AttrIcon, AttrModifyOp.Icon, self.IconSize)
  self.Txt_Desc:SetText(AttrModifyOp.Desc)
  self.Img_Bottom:SetColorAndOpacity(self.BottomColor)
  self.Txt_Desc:SetColorAndOpacity(self.DescTextColor)
  self.Txt_CurValue:SetColorAndOpacity(self.DescTextColor)
  self.Img_AttrIcon:SetColorAndOpacity(self.DescTextColor.SpecifiedColor)
  self.Img_Arrow:SetColorAndOpacity(self.ArrowColor)
  UpdateVisibility(self.HorizontalBox_Compare, nil ~= CompareValue)
  local CurValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(AttrValue, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit, AttrModifyOp.RateDisplayInUI)
  if CompareValue then
    self.Txt_CurValue:SetText(CurValueText)
    local CompareValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(CompareValue, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit, AttrModifyOp.RateDisplayInUI)
    self.Txt_Value:SetText(CompareValueText)
    if AttrValue < CompareValue then
      self.Txt_Value:SetColorAndOpacity(self.ValueTextColor)
    elseif CompareValue < AttrValue then
      self.Txt_Value:SetColorAndOpacity(self.ResetColor)
    else
      self.Txt_Value:SetColorAndOpacity(self.NormalColor)
    end
  else
    self.Txt_Value:SetText(CurValueText)
    self.Txt_Value:SetColorAndOpacity(self.NormalColor)
  end
  if not MutationType or MutationType == EMutationType.Normal then
    self.RGStateController_Mutation:ChangeStatus("Normal")
  elseif MutationType == EMutationType.PosMutation then
    self.RGStateController_Mutation:ChangeStatus("PositiveMutation")
  elseif MutationType == EMutationType.NegaMutation then
    self.RGStateController_Mutation:ChangeStatus("NegativeMutation")
  end
end
function WBP_PuzzleCoreAttrListItem:ChangeArrowColor(InColor)
  self.Img_Arrow:SetColorAndOpacity(InColor)
end
function WBP_PuzzleCoreAttrListItem:PlaySwitchAnim(...)
  self:PlayAnimation(self.Ani_switch)
end
function WBP_PuzzleCoreAttrListItem:PlayUpgradeSuccessAnim(...)
  self:PlayAnimation(self.Anim_Numerical_Add)
end
function WBP_PuzzleCoreAttrListItem:PlayMutationAnim(MutationType)
  if self.MutationType == EMutationType.Normal then
    if MutationType == EMutationType.NegaMutation then
      self:PlayAnimation(self.Anim_Mutation_Bad)
      self:PlayAnimation(self.Anim_Numerical_reduce)
    end
    self:PlayAnimation(self.Anim_Attribute_IN)
  end
end
function WBP_PuzzleCoreAttrListItem:Hide(...)
  UpdateVisibility(self, false)
  self:StopAllAnimations()
  self.MutationType = EMutationType.Normal
end
return WBP_PuzzleCoreAttrListItem
