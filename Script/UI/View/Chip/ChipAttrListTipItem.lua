local ChipAttrListTipItem = UnLua.Class()

function ChipAttrListTipItem:Construct()
end

function ChipAttrListTipItem:Destruct()
end

function ChipAttrListTipItem:InitChipAttrListTipItem(Value, Desc, RowOp, ChipAttrType)
  UpdateVisibility(self, true)
  local viewModel = UIModelMgr:Get("ChipViewModel")
  local showValue = viewModel:GetShowAttrValue(Value, RowOp)
  self.RGTextValue:SetText(showValue)
  self.RGTextDesc:SetText(Desc)
  SetImageBrushBySoftObject(self.Icon_Skill, RowOp.Icon)
  self.StateCtrl_AttrType:ChangeStatus(ChipAttrType)
end

function ChipAttrListTipItem:Hide()
  UpdateVisibility(self, false)
end

return ChipAttrListTipItem
