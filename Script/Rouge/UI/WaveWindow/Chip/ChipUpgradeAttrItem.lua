local EChipUpgradeAttrNew = {New = "1", Normal = "2"}
local ChipUpgradeAttrItem = UnLua.Class()

function ChipUpgradeAttrItem:InitUpgradeSuccConfirm(CurAttr, OldAttr, bIsMainAttr)
  UpdateVisibility(self, true)
  local resultCur, rowCur = GetRowData(DT.DT_AttributeModifyOp, tostring(CurAttr.attrID))
  if resultCur then
    local viewModel = UIModelMgr:Get("ChipViewModel")
    local desc = rowCur.Desc
    self.RGTextDesc:SetText(desc)
    local showNewValue = viewModel:GetShowAttrValue(CurAttr.value, rowCur)
    self.RGTextDescNewValue:SetText(showNewValue)
    if OldAttr then
      local showOldValue = viewModel:GetShowAttrValue(OldAttr.value, rowCur)
      self.RGTextDescOldValue:SetText(showOldValue)
      self.RGStateControllerNew:ChangeStatus(EChipUpgradeAttrNew.Normal)
    else
      local showOldValue = viewModel:GetShowAttrValue(0, rowCur)
      self.RGTextDescOldValue:SetText(showOldValue)
      self.RGStateControllerNew:ChangeStatus(EChipUpgradeAttrNew.New)
    end
    if rowCur.Icon and rowCur.Icon:IsValid() then
      SetImageBrushBySoftObject(self.URGImageIcon, rowCur.Icon)
    end
  end
  if bIsMainAttr then
    self.StateCtrl_IsMainAttr:ChangeStatus("MainAttr")
  else
    self.StateCtrl_IsMainAttr:ChangeStatus("SubAttr")
  end
end

function ChipUpgradeAttrItem:Hide()
  UpdateVisibility(self, false)
end

return ChipUpgradeAttrItem
