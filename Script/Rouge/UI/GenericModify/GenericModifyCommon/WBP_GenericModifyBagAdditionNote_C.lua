local WBP_GenericModifyBagAdditionNote_C = UnLua.Class()

function WBP_GenericModifyBagAdditionNote_C:InitGenericModifyAdditionNote(AdditionNoteInfo)
  UpdateVisibility(self, true)
  self.RGTextTitle:SetText(string.format("[%s]", AdditionNoteInfo.ModNoteTitle))
  self.RGTextDesc:SetText(AdditionNoteInfo.ModAdditionalNote)
end

function WBP_GenericModifyBagAdditionNote_C:Hide()
  UpdateVisibility(self, false)
end

return WBP_GenericModifyBagAdditionNote_C
