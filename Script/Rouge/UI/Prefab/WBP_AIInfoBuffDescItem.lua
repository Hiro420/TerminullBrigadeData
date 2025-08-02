local WBP_AIInfoBuffDescItem = UnLua.Class()

function WBP_AIInfoBuffDescItem:Show(Name, IsEliteAI)
  UpdateVisibility(self, true)
  self.Txt_InscriptionName:SetText(Name)
  if IsEliteAI then
    self.Txt_InscriptionName:SetColorAndOpacity(self.EliteAIColorAndOpacity)
  else
    self.Txt_InscriptionName:SetColorAndOpacity(self.NormalAIColorAndOpacity)
  end
end

function WBP_AIInfoBuffDescItem:Hide(...)
  UpdateVisibility(self, false)
end

return WBP_AIInfoBuffDescItem
