local WBP_SingleInscription_C = UnLua.Class()
function WBP_SingleInscription_C:PreConstruct(IsDesignTime)
  self.SizeBox_Text:SetMaxDesiredWidth(InMaxDesiredWidth)
end
function WBP_SingleInscription_C:InitInscription(String, InMaxDesiredWidth)
  self.TextBlock_Info:SetText(String)
  self.InMaxDesiredWidth = InMaxDesiredWidth
  self.SizeBox_Text:SetMaxDesiredWidth(InMaxDesiredWidth)
end
return WBP_SingleInscription_C
