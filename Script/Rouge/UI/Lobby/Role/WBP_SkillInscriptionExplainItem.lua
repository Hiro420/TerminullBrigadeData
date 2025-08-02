local WBP_SkillInscriptionExplainItem = UnLua.Class()

function WBP_SkillInscriptionExplainItem:Show(Desc)
  UpdateVisibility(self, true)
  self.Txt_Desc:SetText(Desc)
end

function WBP_SkillInscriptionExplainItem:Hide(...)
  UpdateVisibility(self, false)
end

return WBP_SkillInscriptionExplainItem
