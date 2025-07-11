local WBP_PuzzleSortRuleComboBox = UnLua.Class()
function WBP_PuzzleSortRuleComboBox:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.MainToggleGroup.OnCheckStateChanged:Add(self, self.BindOnCheckStateChanged)
  UpdateVisibility(self, false)
end
function WBP_PuzzleSortRuleComboBox:Show(ParentView, IsGem)
  UpdateVisibility(self, true)
  UpdateVisibility(self.Overlay_Expand, false, true, true)
  self.ParentView = ParentView
  self.IsGem = IsGem
  self.MainToggleGroup:ClearGroup()
  self.TargetSortRuleList = IsGem and self.GemSortRuleText:ToTable() or self.PuzzleSortRuleText:ToTable()
  local SortIndexList = {}
  for SortIndex, SingleRuleText in pairs(self.TargetSortRuleList) do
    table.insert(SortIndexList, SortIndex)
  end
  table.sort(SortIndexList, function(A, B)
    return A < B
  end)
  local Index = 1
  local MinSortIndex = 9999
  for i, SortIndex in ipairs(SortIndexList) do
    local Item = GetOrCreateItem(self.ScrollList_Combo, Index, self.WBP_PuzzleComboItem:StaticClass())
    local SingleRuleText = self.TargetSortRuleList[SortIndex]
    Item:Show(SingleRuleText)
    self.MainToggleGroup:AddToGroup(SortIndex, Item)
    Index = Index + 1
    if SortIndex > MinSortIndex then
      MinSortIndex = SortIndex
    end
  end
  HideOtherItem(self.ScrollList_Combo, Index)
  local DefaultIndex = IsGem and self.DefaultGemSortRule or self.DefaultPuzzleSortRule
  if not self.TargetSortRuleList[DefaultIndex] then
    DefaultIndex = MinSortIndex
  end
  self.MainToggleGroup:SelectId(DefaultIndex)
end
function WBP_PuzzleSortRuleComboBox:BindOnMainButtonClicked(...)
  UpdateVisibility(self.Overlay_Expand, not self.Overlay_Expand:IsVisible())
end
function WBP_PuzzleSortRuleComboBox:HideExpandList(...)
  UpdateVisibility(self.Overlay_Expand, false)
end
function WBP_PuzzleSortRuleComboBox:BindOnCheckStateChanged(Id)
  if not self.ParentView then
    return
  end
  self.Txt_CurSelect:SetText(self.TargetSortRuleList[Id])
  self.ParentView:BindOnSortRuleSelectionChanged(Id, self.IsGem)
  UpdateVisibility(self.Overlay_Expand, false)
end
return WBP_PuzzleSortRuleComboBox
