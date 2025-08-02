local WBP_PuzzleRefactorMatItem = UnLua.Class()

function WBP_PuzzleRefactorMatItem:Show(ResourceId)
  UpdateVisibility(self, true)
  self.ResourceId = ResourceId
  self.WBP_Item:InitItem(ResourceId, LogicOutsidePackback.GetResourceNumById(ResourceId), false)
  self.WBP_Item:BindOnMainButtonClicked(self.BindOnMainButtonClicked, self)
  self:BindOnPuzzleRefactorMaterialSelected()
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleRefactorMaterialSelected, self, self.BindOnPuzzleRefactorMaterialSelected)
end

function WBP_PuzzleRefactorMatItem:RefreshNum()
  self.WBP_Item:InitItem(self.ResourceId, LogicOutsidePackback.GetResourceNumById(self.ResourceId), false)
end

function WBP_PuzzleRefactorMatItem:BindOnPuzzleRefactorMaterialSelected(ResourceId)
  self.WBP_Item:SetSel(ResourceId == self.ResourceId)
end

function WBP_PuzzleRefactorMatItem:BindOnMainButtonClicked()
  print("BindOnMainButtonClicked", self.ResourceId)
  EventSystem.Invoke(EventDef.Puzzle.OnPuzzleRefactorMaterialSelected, self.ResourceId)
end

function WBP_PuzzleRefactorMatItem:Hide()
  UpdateVisibility(self, false)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleRefactorMaterialSelected, self, self.BindOnPuzzleRefactorMaterialSelected)
end

return WBP_PuzzleRefactorMatItem
