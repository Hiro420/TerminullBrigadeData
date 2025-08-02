local ChipFilterTips = UnLua.Class()

function ChipFilterTips:Construct()
end

function ChipFilterTips:Destruct()
end

function ChipFilterTips:InitChipFilterTips(ChipFilterTipsFrom)
  self.RGToggleGroupFilterRule.OnCheckStateChanged:Add(self, self.OnFilterRuleChanged)
  self.RGToggleGroupFilterType.OnCheckStateChanged:Add(self, self.OnFilterTypeChanged)
  self.BP_ButtonWithSoundReset.OnClicked:Add(self, self.ResetClick)
  self.BP_ButtonWithSoundConfirm.OnClicked:Add(self, self.ConfirmClick)
  self.BP_ButtonWithSoundMask.OnClicked:Add(self, self.CloseClick)
  self.BP_ButtonWithSoundClose.OnClicked:Add(self, self.CloseClick)
  self:PlayAnimation(self.Ani_in)
  self.ChipFilterTipsFrom = ChipFilterTipsFrom
  self.viewModel = UIModelMgr:Get("ChipViewModel")
  UpdateVisibility(self, true)
  UpdateVisibility(self.AutoLoadPanel, true)
  self.RGStateControllerFrom:ChangeStatus(ChipFilterTipsFrom)
  if self.ChipFilterTipsFrom == EChipViewState.Normal then
    local normalFilterDataRef = self.viewModel:GetNormalFilterDataRef()
    self.CurFilterData = DeepCopy(normalFilterDataRef)
  elseif self.ChipFilterTipsFrom == EChipViewState.Strength then
    local strengthFilterDataRef = self.viewModel:GetStrengthFilterDataRef()
    self.CurFilterData = DeepCopy(strengthFilterDataRef)
  end
  self:UpdateAttrFilterList()
  self.RGToggleGroupFilterRule:SelectId(self.CurFilterData.RuleFilter)
  self.RGToggleGroupFilterType:SelectId(self.CurFilterData.TypeFilter)
end

function ChipFilterTips:UpdateAttrFilterList()
  local names = GetAllRowNames(DT.DT_AttributeModifyOp)
  local idxMain = 1
  local idxSub = 1
  for k, v in pairs(names) do
    local result, row = GetRowData(DT.DT_AttributeModifyOp, k)
    if result and (row.AttributeType == UE.EAttributeType.MainAttr or row.AttributeType == UE.EAttributeType.All) then
      local itemMain = GetOrCreateItem(self.VerticalBoxMainAttr, idxMain, self.WBP_ChipFilterMainAttrItem:GetClass())
      local bSelect = false
      if self.CurFilterData.MainAttrFilter then
        bSelect = self.CurFilterData.MainAttrFilter[k]
      end
      local selectIdx = self:GetMainAttrFilterSelectIdx(k)
      itemMain:InitChipFilterMainAttrItem(tonumber(k), row.Desc, bSelect, self, selectIdx)
      idxMain = idxMain + 1
    end
    if result and (row.AttributeType == UE.EAttributeType.SubAttr or row.AttributeType == UE.EAttributeType.All) then
      local itemSub = GetOrCreateItem(self.VerticalBoxSubAttr, idxSub, self.WBP_ChipFilterSubAttrItem:GetClass())
      local bSelect = false
      if self.CurFilterData.SubAttrFilter then
        bSelect = self.CurFilterData.SubAttrFilter[k]
      end
      local selectIdx = self:GetSubAttrFilterSelectIdx(k)
      itemSub:InitChipFilterMainAttrItem(tonumber(k), row.Desc, bSelect, self, selectIdx)
      idxSub = idxSub + 1
    end
  end
  HideOtherItem(self.VerticalBoxMainAttr, idxMain)
  HideOtherItem(self.VerticalBoxSubAttr, idxSub)
end

function ChipFilterTips:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
    UpdateVisibility(self.AutoLoadPanel, false)
  end
end

function ChipFilterTips:Hide(bNotFadeOut)
  if bNotFadeOut then
    UpdateVisibility(self, false)
    UpdateVisibility(self.AutoLoadPanel, false)
  else
    self:StopAnimation(self.Ani_in)
    self:PlayAnimation(self.Ani_out)
  end
  self.RGToggleGroupFilterRule.OnCheckStateChanged:Remove(self, self.OnFilterRuleChanged)
  self.RGToggleGroupFilterType.OnCheckStateChanged:Remove(self, self.OnFilterTypeChanged)
  self.BP_ButtonWithSoundReset.OnClicked:Remove(self, self.ResetClick)
  self.BP_ButtonWithSoundConfirm.OnClicked:Remove(self, self.ConfirmClick)
  self.BP_ButtonWithSoundMask.OnClicked:Remove(self, self.CloseClick)
  self.BP_ButtonWithSoundClose.OnClicked:Remove(self, self.CloseClick)
  self.viewModel = nil
end

function ChipFilterTips:OnFilterRuleChanged(SelectId)
  self.CurFilterData.RuleFilter = SelectId
end

function ChipFilterTips:OnFilterTypeChanged(SelectId)
  self.CurFilterData.TypeFilter = SelectId
end

function ChipFilterTips:ConfirmClick()
  if self.viewModel then
    if self.ChipFilterTipsFrom == EChipViewState.Normal then
      self.viewModel:ConfirmNormalFilter(self.CurFilterData)
    elseif self.ChipFilterTipsFrom == EChipViewState.Strength then
      self.viewModel:ConfirmStrengthFilter(self.CurFilterData)
    end
    self:Hide()
  end
end

function ChipFilterTips:ResetClick()
  if self.viewModel then
    if self.ChipFilterTipsFrom == EChipViewState.Normal then
      self.viewModel:ResetNormalFilter()
    elseif self.ChipFilterTipsFrom == EChipViewState.Strength then
      self.viewModel:ResetStrengthFilter()
    end
    self:Hide()
  end
end

function ChipFilterTips:CloseClick()
  self:Hide()
end

function ChipFilterTips:SelectMainAttrFilter(bSelect, AttrId)
  if bSelect then
    local filterNum = 0
    for k, v in pairs(self.CurFilterData.MainAttrFilter) do
      filterNum = filterNum + 1
    end
    if filterNum < self.viewModel:GetMaxMainAttrFilterNum() then
      self.CurFilterData.MainAttrFilter[AttrId] = filterNum + 1
    else
      ShowWaveWindow(1179)
      return false
    end
  else
    local unSelectIdx = self.CurFilterData.MainAttrFilter[AttrId]
    self.CurFilterData.MainAttrFilter[AttrId] = nil
    for k, v in pairs(self.CurFilterData.MainAttrFilter) do
      if v > unSelectIdx then
        self.CurFilterData.MainAttrFilter[k] = self.CurFilterData.MainAttrFilter[k] - 1
      end
    end
    self:UpdateAttrFilterList()
    return false
  end
  return true
end

function ChipFilterTips:SelectSubAttrFilter(bSelect, AttrId)
  if bSelect then
    local filterNum = 0
    for k, v in pairs(self.CurFilterData.SubAttrFilter) do
      filterNum = filterNum + 1
    end
    if filterNum < self.viewModel:GetMaxMainAttrFilterNum() then
      self.CurFilterData.SubAttrFilter[AttrId] = filterNum + 1
    else
      ShowWaveWindow(1179)
      return false
    end
  else
    local unSelectIdx = self.CurFilterData.SubAttrFilter[AttrId]
    self.CurFilterData.SubAttrFilter[AttrId] = nil
    for k, v in pairs(self.CurFilterData.SubAttrFilter) do
      if v > unSelectIdx then
        self.CurFilterData.SubAttrFilter[k] = self.CurFilterData.SubAttrFilter[k] - 1
      end
    end
    self:UpdateAttrFilterList()
    return false
  end
  return true
end

function ChipFilterTips:GetMainAttrFilterSelectIdx(AttrId)
  if self.CurFilterData.MainAttrFilter and self.CurFilterData.MainAttrFilter[AttrId] then
    return self.CurFilterData.MainAttrFilter[AttrId]
  end
  return nil
end

function ChipFilterTips:GetSubAttrFilterSelectIdx(AttrId)
  if self.CurFilterData.SubAttrFilter and self.CurFilterData.SubAttrFilter[AttrId] then
    return self.CurFilterData.SubAttrFilter[AttrId]
  end
  return nil
end

return ChipFilterTips
