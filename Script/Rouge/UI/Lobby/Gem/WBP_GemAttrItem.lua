local WBP_GemAttrItem = UnLua.Class()
function WBP_GemAttrItem:Show(IsEmpty, AttrId, Value, MutationType)
  UpdateVisibility(self, true)
  UpdateVisibility(self.Img_AttrIcon, not IsEmpty)
  UpdateVisibility(self.Txt_Desc, not IsEmpty)
  UpdateVisibility(self.Txt_EmptyDesc, IsEmpty)
  UpdateVisibility(self.Txt_Value, not IsEmpty)
  UpdateVisibility(self.Img_EmptyIcon, IsEmpty)
  UpdateVisibility(self.Overlay_MutationAttr, false)
  UpdateVisibility(self.Img_NegMutation, MutationType == EMutationType.NegaMutation)
  if IsEmpty then
    return
  end
  local Result, AttrModifyOp = GetRowData(DT.DT_AttributeModifyOp, tostring(AttrId))
  if not Result then
    return
  end
  SetImageBrushBySoftObject(self.Img_AttrIcon, AttrModifyOp.Icon, self.IconSize)
  self.Txt_Desc:SetText(AttrModifyOp.Desc)
  local CurValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(Value, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit, AttrModifyOp.RateDisplayInUI)
  self.Txt_Value:SetText(CurValueText)
end
function WBP_GemAttrItem:ShowMutationAttr(AttrId, Value)
  UpdateVisibility(self.Overlay_MutationAttr, true)
  local Result, AttrModifyOp = GetRowData(DT.DT_AttributeModifyOp, tostring(AttrId))
  if not Result then
    return
  end
  self.Txt_MutationDesc:SetText(AttrModifyOp.Desc)
  local CurValueText = UE.URGBlueprintLibrary.GetAttributeDisplayText(Value, AttrModifyOp.AttributeDisplayType, AttrModifyOp.Unit, AttrModifyOp.RateDisplayInUI)
  self.Txt_MutationValue:SetText(CurValueText)
end
function WBP_GemAttrItem:PlaySlotInAnim(DelayTime)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.SlotInAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.SlotInAnimTimer)
  end
  if 0 == DelayTime then
    self:PlayAnimation(self.Anim_Refactoring_Slot_IN)
  else
    self.SlotInAnimTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        self:PlayAnimation(self.Anim_Refactoring_Slot_IN)
      end
    }, DelayTime, false)
  end
end
function WBP_GemAttrItem:Hide(...)
  UpdateVisibility(self, false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.SlotInAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.SlotInAnimTimer)
  end
end
function WBP_GemAttrItem:Destruct()
  self:Hide()
end
return WBP_GemAttrItem
