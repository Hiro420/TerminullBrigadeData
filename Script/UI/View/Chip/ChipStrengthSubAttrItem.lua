local EStateControllerRandAttr = {Attr = 1, RandTip = 2}
local ChipStrengthSubAttrItem = UnLua.Class()
function ChipStrengthSubAttrItem:Construct()
end
function ChipStrengthSubAttrItem:Destruct()
end
function ChipStrengthSubAttrItem:InitChipStrengthSubAttrItem(mainAttrGrowth, bHaveRandAttrChange, bIsNew)
  UpdateVisibility(self, true)
  if bIsNew then
    self:PlayAnimation(self.Ani_add_property)
  end
  if bHaveRandAttrChange then
    self.RGStateControllerRandom:ChangeStatus(tostring(EStateControllerRandAttr.RandTip))
  else
    self.RGStateControllerRandom:ChangeStatus(tostring(EStateControllerRandAttr.Attr))
    local result, row = GetRowData(DT.DT_AttributeModifyOp, tostring(mainAttrGrowth.attrID))
    if result then
      self.RGTextAttrDesc:SetText(row.Desc)
      local viewModel = UIModelMgr:Get("ChipViewModel")
      local showNewValue = viewModel:GetShowAttrValue(mainAttrGrowth.value, row)
      self.RGTextAttrOldValue:SetText(showNewValue)
    end
  end
end
function ChipStrengthSubAttrItem:Hide()
  UpdateVisibility(self, false)
end
return ChipStrengthSubAttrItem
