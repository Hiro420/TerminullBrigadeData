local WBP_PuzzleResetItem = UnLua.Class()

function WBP_PuzzleResetItem:Show(ResourceId, Num)
  UpdateVisibility(self, true)
  self.WBP_Item:InitItem(ResourceId, Num)
end

return WBP_PuzzleResetItem
