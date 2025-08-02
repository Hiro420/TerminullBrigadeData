local WBP_PuzzleFilterItem = UnLua.Class()

function WBP_PuzzleFilterItem:Construct()
  self.CheckBox.OnCheckStateChanged:Add(self, self.BindOnCheckStateChanged)
end

function WBP_PuzzleFilterItem:Show(Id, Type)
  UpdateVisibility(self, true)
  self.Id = Id
  self.Type = Type
  if self.Type == EPuzzleFilterType.World then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleWorld, self.Id)
    if not Result then
      return
    end
    self.Txt_Desc:SetText(RowInfo.Name)
    self.SizeBox_Filter:ClearWidthOverride()
  elseif self.Type == EPuzzleFilterType.Quality then
    local Result, RowInfo = GetRowData(DT.DT_ItemRarity, self.Id)
    if not Result then
      return
    end
    self.Txt_Desc:SetText(RowInfo.DisplayName)
    self.SizeBox_Filter:ClearWidthOverride()
  elseif self.Type == EPuzzleFilterType.SubAttr then
    local Result, RowInfo = GetRowData(DT.DT_AttributeModifyOp, self.Id)
    if not Result then
      return
    end
    self.Txt_Desc:SetText(RowInfo.Desc)
    self.SizeBox_Filter:SetWidthOverride(self.SizeBox_Filter.WidthOverride)
  elseif Type == EPuzzleFilterType.Lock or Type == EPuzzleFilterType.Discard then
    self.Txt_Desc:SetText(self.Desc)
    self.SizeBox_Filter:ClearWidthOverride()
  end
  self:RefreshSelectStatus()
end

function WBP_PuzzleFilterItem:RefreshSelectStatus(SelectStatusList)
  local IsChecked = false
  if self.Type == EPuzzleFilterType.Lock then
    IsChecked = nil ~= SelectStatusList and SelectStatusList or false
  elseif self.Type == EPuzzleFilterType.Discard then
    IsChecked = nil ~= SelectStatusList and SelectStatusList or false
  else
    if not SelectStatusList then
      local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
      SelectStatusList = PuzzleViewModel:GetPuzzleFilterSelectStatus()
    end
    IsChecked = SelectStatusList[self.Type] and table.Contain(SelectStatusList[self.Type], self.Id)
  end
  UpdateVisibility(self.Img_NotSelected, not IsChecked)
  UpdateVisibility(self.Img_Selected, IsChecked)
  self.CheckBox:SetIsChecked(IsChecked)
end

function WBP_PuzzleFilterItem:BindOnCheckStateChanged(IsChecked)
  UpdateVisibility(self.Img_NotSelected, not IsChecked)
  UpdateVisibility(self.Img_Selected, IsChecked)
  EventSystem.Invoke(EventDef.Puzzle.UpdatePuzzleFilterSelectStatus, self.Id, self.Type, IsChecked)
end

function WBP_PuzzleFilterItem:Hide(...)
  UpdateVisibility(self, false)
end

return WBP_PuzzleFilterItem
