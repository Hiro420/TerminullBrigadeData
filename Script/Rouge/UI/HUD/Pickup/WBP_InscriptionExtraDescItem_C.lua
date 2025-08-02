local WBP_InscriptionExtraDescItem_C = UnLua.Class()

function WBP_InscriptionExtraDescItem_C:InitInfo(RowInfo)
  self.Txt_Title:SetText(RowInfo.ModNoteTitle)
  self.Txt_Desc:SetText(RowInfo.ModAdditionalNote)
end

return WBP_InscriptionExtraDescItem_C
