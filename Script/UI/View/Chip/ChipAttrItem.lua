local ChipAttrItem = UnLua.Class()
function ChipAttrItem:Construct()
end
function ChipAttrItem:Destruct()
end
function ChipAttrItem:InitChipAttrItem(Desc, Value, ChangeState, AttrID, ChangeAniState)
  UpdateVisibility(self, true)
  self.RGTextDesc:SetText(Desc)
  local resultCur, rowCur = GetRowData(DT.DT_AttributeModifyOp, tostring(AttrID))
  if resultCur then
    if rowCur.Icon and rowCur.Icon:IsValid() then
      SetImageBrushBySoftObject(self.Img_AttrIcon, rowCur.Icon)
    end
    local viewModel = UIModelMgr:Get("ChipViewModel")
    local showValue = viewModel:GetShowAttrValue(Value, rowCur)
    self.RGTextValue:SetText(showValue)
  end
  if self.RGStateControllerChange then
    self.RGStateControllerChange:ChangeStatus(tostring(ChangeState))
  end
  if ChangeAniState and ChangeAniState == EChipAttrAniChange.New then
    self:PlayAnimation(self.Ani_add_property)
  elseif ChangeAniState and ChangeAniState == EChipAttrAniChange.Add then
    self:PlayAnimation(self.Ani_add_number)
  end
end
function ChipAttrItem:Hide()
  UpdateVisibility(self, false)
end
return ChipAttrItem
