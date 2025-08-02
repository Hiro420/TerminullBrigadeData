local WBP_GenericModifyAdditionNote_C = UnLua.Class()

function WBP_GenericModifyAdditionNote_C:InitGenericModifyAdditionNote(AdditionNoteInfo)
  UpdateVisibility(self, true)
  self.RGTextTitle:SetText(AdditionNoteInfo.ModNoteTitle)
  self.RGTextDesc:SetText(AdditionNoteInfo.ModAdditionalNote)
end

function WBP_GenericModifyAdditionNote_C:Hide()
  UpdateVisibility(self, false)
end

return WBP_GenericModifyAdditionNote_C
