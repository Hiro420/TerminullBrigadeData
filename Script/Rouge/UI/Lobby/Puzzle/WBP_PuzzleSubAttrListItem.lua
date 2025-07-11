local WBP_PuzzleSubAttrListItem = UnLua.Class()
function WBP_PuzzleSubAttrListItem:Show(AttrId, AttrValue, CompareValue, IsGodAttr, MutationType, InRangeValue)
  self.AttrId = AttrId
  self.AttrValue = AttrValue
  self.MutationType = MutationType
  local Result, AttrModifyOp = GetRowData(DT.DT_AttributeModifyOp, tostring(AttrId))
  if not Result then
    return
  end
  UpdateVisibility(self, true)
  if MutationType == EMutationType.Normal then
    self.RGStateController_Mutation:ChangeStatus("Normal")
  elseif MutationType == EMutationType.PosMutation then
    self.RGStateController_Mutation:ChangeStatus("PositiveMutation")
  elseif MutationType == EMutationType.NegaMutation then
    self.RGStateController_Mutation:ChangeStatus("NegativeMutation")
  end
  UpdateVisibility(self.Txt_RangeValue, nil ~= InRangeValue)
  if InRangeValue then
    local MinValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(InRangeValue.MinValue, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit)
    local MaxValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(InRangeValue.MaxValue, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit)
    self.Txt_RangeValue:SetText(UE.FTextFormat(self.RangeValueText, MinValueText, MaxValueText))
  end
  self.Txt_Desc:SetText(AttrModifyOp.Desc)
  local ValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(AttrValue, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit)
  self.Txt_Value:SetText(ValueText)
  UpdateVisibility(self.Overlay_GodAttr, IsGodAttr)
  if self.RGStateController_GodAttr then
    if MutationType == EMutationType.NegaMutation then
      self.RGStateController_GodAttr:ChangeStatus("NegativeMutation")
    elseif IsGodAttr then
      self.RGStateController_GodAttr:ChangeStatus("GodAttr")
    elseif MutationType == EMutationType.PosMutation then
      self.RGStateController_GodAttr:ChangeStatus("PositiveMutation")
    else
      self.RGStateController_GodAttr:ChangeStatus("Normal")
    end
  end
  UpdateVisibility(self.HorizontalBox_Compare, nil ~= CompareValue)
  local CurValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(AttrValue, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit, AttrModifyOp.RateDisplayInUI)
  if CompareValue then
    self.Txt_CurValue:SetText(CurValueText)
    local CompareValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(CompareValue, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit, AttrModifyOp.RateDisplayInUI)
    self.Txt_Value:SetText(CompareValueText)
    if AttrValue < CompareValue then
      if AttrModifyOp.IsInverseRatio then
        self.Txt_Value:SetColorAndOpacity(self.ResetColor)
        self.Img_Arrow:SetColorAndOpacity(self.ResetColor.SpecifiedColor)
      else
        self.Txt_Value:SetColorAndOpacity(self.UpgradeColor)
        self.Img_Arrow:SetColorAndOpacity(self.UpgradeColor.SpecifiedColor)
      end
    elseif CompareValue < AttrValue then
      if AttrModifyOp.IsInverseRatio then
        self.Txt_Value:SetColorAndOpacity(self.UpgradeColor)
        self.Img_Arrow:SetColorAndOpacity(self.UpgradeColor.SpecifiedColor)
      else
        self.Txt_Value:SetColorAndOpacity(self.ResetColor)
        self.Img_Arrow:SetColorAndOpacity(self.ResetColor.SpecifiedColor)
      end
    else
      self.Txt_Value:SetColorAndOpacity(self.NormalColor)
      self.Img_Arrow:SetColorAndOpacity(self.NormalColor.SpecifiedColor)
    end
  else
    self.Txt_Value:SetText(CurValueText)
    if not self.RGStateController_GodAttr then
      self.Txt_Value:SetColorAndOpacity(self.NormalColor)
    end
  end
end
function WBP_PuzzleSubAttrListItem:PlayRefactorAnim(AttrId, NewValue, MutationType)
  if AttrId ~= self.AttrId then
    self:PlayAnimation(self.Anim_Attribute_IN)
  else
    local Result, AttrModifyOp = GetRowData(DT.DT_AttributeModifyOp, tostring(AttrId))
    if not Result then
      return
    end
    local IsAdd = AttrModifyOp.IsInverseRatio and NewValue < self.AttrValue or NewValue > self.AttrValue
    local IsReduce = AttrModifyOp.IsInverseRatio and NewValue > self.AttrValue or NewValue < self.AttrValue
    if IsAdd then
      self:PlayAnimation(self.Anim_Numerical_Add)
    end
    if IsReduce then
      self:PlayAnimation(self.Anim_Numerical_Reduce)
    end
  end
end
function WBP_PuzzleSubAttrListItem:PlayMutationAnim(MutationType)
  if self.MutationType == EMutationType.Normal then
    if MutationType == EMutationType.NegaMutation then
      self:PlayAnimation(self.Anim_Mutation_Bad)
      self:PlayAnimation(self.Anim_Attribute_IN)
    elseif MutationType == EMutationType.PosMutation then
      self:PlayAnimation(self.Anim_Mutation_Good)
      self:PlayAnimation(self.Anim_Attribute_IN)
    end
  end
end
function WBP_PuzzleSubAttrListItem:RegisitMarkArea(ResourceIdList)
  self.WBP_PuzzleRefactorMarkArea:RegisitMarkArea(ResourceIdList)
end
function WBP_PuzzleSubAttrListItem:ShowPuzzleRefactorMarkArea()
  UpdateVisibility(self.WBP_PuzzleRefactorMarkArea, true)
end
function WBP_PuzzleSubAttrListItem:ChangeArrowColor(InColor)
  self.Img_Arrow:SetColorAndOpacity(InColor)
end
function WBP_PuzzleSubAttrListItem:PlaySwitchAnim(...)
  self:PlayAnimation(self.Ani_switch)
end
function WBP_PuzzleSubAttrListItem:PlayUpgradeSuccessAnim(...)
  self:PlayAnimation(self.Ani_upgrade_succeed)
end
function WBP_PuzzleSubAttrListItem:Hide(...)
  UpdateVisibility(self, false)
  self:StopAllAnimations()
  self.MutationType = EMutationType.Normal
end
function WBP_PuzzleSubAttrListItem:Destruct()
  self:Hide()
end
return WBP_PuzzleSubAttrListItem
