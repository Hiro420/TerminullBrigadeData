local WBP_PuzzleFilterView = UnLua.Class()

function WBP_PuzzleFilterView:Construct()
  self.Btn_Confirm.OnMainButtonClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Add(self, self.BindOnCancelButtonClicked)
  self.Btn_Reset.OnMainButtonClicked:Add(self, self.BindOnResetButtonClicked)
end

function WBP_PuzzleFilterView:InitWorldFilter(...)
  local PuzzleWorldTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPuzzleWorld)
  local WorldIdList = {}
  for WorldId, SingleItem in pairs(PuzzleWorldTable) do
    table.insert(WorldIdList, WorldId)
  end
  table.sort(WorldIdList, function(A, B)
    return A < B
  end)
  local Index = 1
  for i, WorldId in ipairs(WorldIdList) do
    local Item = GetOrCreateItem(self.WrapBox_World, Index, self.PuzzleFilterItemTemplate:StaticClass())
    Item:Show(WorldId, EPuzzleFilterType.World)
    Index = Index + 1
  end
  HideOtherItem(self.WrapBox_World, Index, true)
end

function WBP_PuzzleFilterView:InitQualityFilter(...)
  local AllRowNames = GetAllRowNames(DT.DT_ItemRarity)
  local Index = 1
  for i, SingleRowName in ipairs(AllRowNames) do
    local Item = GetOrCreateItem(self.WrapBox_Quality, Index, self.PuzzleFilterItemTemplate:StaticClass())
    Item:Show(SingleRowName, EPuzzleFilterType.Quality)
    Index = Index + 1
  end
  HideOtherItem(self.WrapBox_Quality, Index, true)
end

function WBP_PuzzleFilterView:InitSubAttrFilter(...)
  local AllRowNames = GetAllRowNames(DT.DT_AttributeModifyOp)
  local Index = 1
  for i, SingleRowName in ipairs(AllRowNames) do
    local Result, RowInfo = GetRowData(DT.DT_AttributeModifyOp, SingleRowName)
    if self.IsGem and RowInfo.IsShowInGemFilterList or not self.IsGem and RowInfo.IsShowInFilterList then
      local Item = GetOrCreateItem(self.WrapBox_SubAttr, Index, self.PuzzleFilterItemTemplate:StaticClass())
      Item:Show(SingleRowName, EPuzzleFilterType.SubAttr)
      Index = Index + 1
    end
  end
  HideOtherItem(self.WrapBox_SubAttr, Index, true)
end

function WBP_PuzzleFilterView:InitLockAndDiscardFilter()
  self.WBP_PuzzleFilterItem_Lock:Show(0, EPuzzleFilterType.Lock)
  self.WBP_PuzzleFilterItem_Discard:Show(0, EPuzzleFilterType.Discard)
end

function WBP_PuzzleFilterView:BindOnUpdatePuzzleFilterSelectStatus(Id, Type, IsSelected)
  if Type == EPuzzleFilterType.Lock then
    self.FilterLockSelected = IsSelected
  elseif Type == EPuzzleFilterType.Discard then
    self.FilterDiscardSelected = IsSelected
  elseif IsSelected then
    table.insert(self.FilterSelectStatus[Type], Id)
  else
    table.RemoveItem(self.FilterSelectStatus[Type], Id)
  end
end

function WBP_PuzzleFilterView:Show(TargetViewModel, IsGem)
  UpdateVisibility(self, true)
  self:PlayAnimation(self.Ani_in)
  self.TargetViewModel = TargetViewModel
  self.IsGem = IsGem
  self.FilterSelectStatus = nil
  if IsGem then
    self.FilterSelectStatus = DeepCopy(self.TargetViewModel:GetGemFilterSelectStatus())
  else
    self.FilterSelectStatus = DeepCopy(self.TargetViewModel:GetPuzzleFilterSelectStatus())
  end
  if not self.IsGem then
    self:InitWorldFilter()
    self:InitQualityFilter()
  end
  UpdateVisibility(self.Vertical_World, not self.IsGem)
  UpdateVisibility(self.Vertical_Quality, not self.IsGem)
  self:InitSubAttrFilter()
  self:InitLockAndDiscardFilter()
  self.FilterDiscardSelected = self.TargetViewModel:GetPuzzleFilterDiscardSelected()
  self.FilterLockSelected = self.TargetViewModel:GetPuzzleFilterLockSelected()
  self:RefreshItemSelectStatus()
  EventSystem.AddListenerNew(EventDef.Puzzle.UpdatePuzzleFilterSelectStatus, self, self.BindOnUpdatePuzzleFilterSelectStatus)
end

function WBP_PuzzleFilterView:Hide(...)
  UpdateVisibility(self, false)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.UpdatePuzzleFilterSelectStatus, self, self.BindOnUpdatePuzzleFilterSelectStatus)
end

function WBP_PuzzleFilterView:BindOnConfirmButtonClicked(...)
  if self.TargetViewModel.SetPuzzleFilterDiscardSelected then
    self.TargetViewModel:SetPuzzleFilterDiscardSelected(self.FilterDiscardSelected)
  end
  if self.TargetViewModel.SetPuzzleFilterLockSelected then
    self.TargetViewModel:SetPuzzleFilterLockSelected(self.FilterLockSelected)
  end
  if self.IsGem and self.TargetViewModel.SetGemFilterSelectStatus then
    self.TargetViewModel:SetGemFilterSelectStatus(self.FilterSelectStatus)
  else
    self.TargetViewModel:SetPuzzleFilterSelectStatus(self.FilterSelectStatus)
  end
  self:Hide()
end

function WBP_PuzzleFilterView:BindOnCancelButtonClicked(...)
  self:Hide()
end

function WBP_PuzzleFilterView:BindOnResetButtonClicked()
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {},
    [EPuzzleFilterType.World] = {}
  }
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
  self:RefreshItemSelectStatus()
end

function WBP_PuzzleFilterView:RefreshItemSelectStatus(...)
  local AllChildren = self.WrapBox_World:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshSelectStatus(self.FilterSelectStatus)
  end
  AllChildren = self.WrapBox_Quality:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshSelectStatus(self.FilterSelectStatus)
  end
  AllChildren = self.WrapBox_SubAttr:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshSelectStatus(self.FilterSelectStatus)
  end
  self.WBP_PuzzleFilterItem_Lock:RefreshSelectStatus(self.FilterLockSelected)
  self.WBP_PuzzleFilterItem_Discard:RefreshSelectStatus(self.FilterDiscardSelected)
end

function WBP_PuzzleFilterView:Destruct(...)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.UpdatePuzzleFilterSelectStatus, self, self.BindOnUpdatePuzzleFilterSelectStatus)
end

return WBP_PuzzleFilterView
