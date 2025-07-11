local WBP_PuzzleComboItem = UnLua.Class()
function WBP_PuzzleComboItem:Show(Text)
  UpdateVisibility(self, true, true)
  self.Txt_Name:SetText(Text)
end
return WBP_PuzzleComboItem
