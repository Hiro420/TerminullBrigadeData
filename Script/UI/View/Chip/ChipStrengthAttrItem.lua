local EStateControllerLvUp = {LvUp = 1, Normal = 2}
local ChipStrengthAttrItem = UnLua.Class()

function ChipStrengthAttrItem:Construct()
end

function ChipStrengthAttrItem:Destruct()
end

function ChipStrengthAttrItem:InitChipStrengthAttrItem(levelUPMainAttrGrowth, ChipBagItemData, oldLevel, newLv, bIsUpgrade)
  UpdateVisibility(self, true)
  if bIsUpgrade then
    self:PlayAnimation(self.Ani_number_hoist)
  end
  local result, row = GetRowData(DT.DT_AttributeModifyOp, tostring(ChipBagItemData.TbChipData.AttrID))
  if not result then
    error("Please Check Attr Is Valid id:", ChipBagItemData.TbChipData.AttrID)
    return
  end
  self.RGTextAttrDesc:SetText(row.Desc)
  SetImageBrushBySoftObject(self.Icon_Skill, row.Icon)
  local viewModel = UIModelMgr:Get("ChipViewModel")
  if oldLevel == newLv then
    self.RGStateControllerLvUp:ChangeStatus(tostring(EStateControllerLvUp.Normal))
    local attrId, mainAttrValue = viewModel:GetMainAttrValueByChipBagItemData(ChipBagItemData)
    local showValue = viewModel:GetShowAttrValue(mainAttrValue, row)
    self.RGTextAttrOldValue:SetText(showValue)
  else
    self.RGStateControllerLvUp:ChangeStatus(tostring(EStateControllerLvUp.LvUp))
    local attrId, mainAttrValue = viewModel:GetMainAttrValueByChipBagItemData(ChipBagItemData)
    local showOldValue = viewModel:GetShowAttrValue(mainAttrValue, row)
    self.RGTextAttrOldValue:SetText(showOldValue)
    local newAttr = levelUPMainAttrGrowth.y * (newLv - oldLevel) + mainAttrValue
    local showNewValue = viewModel:GetShowAttrValue(newAttr, row)
    self.RGTextAttrNewValue:SetText(showNewValue)
  end
end

function ChipStrengthAttrItem:Hide()
  UpdateVisibility(self, false)
end

return ChipStrengthAttrItem
