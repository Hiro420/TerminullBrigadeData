local WBP_SingleModNote_C = UnLua.Class()
function WBP_SingleModNote_C:UpdateInfo(ModAdditionalNoteRow)
  self.TextBlock_Title:SetText(ModAdditionalNoteRow.ModNoteTitle)
  self.TextBlock_Des:SetText(ModAdditionalNoteRow.ModAdditionalNote)
end
return WBP_SingleModNote_C
