local WBP_GenericModifyBagTag_C = UnLua.Class()

function WBP_GenericModifyBagTag_C:InitGenericModifyTag(Tag)
  UpdateVisibility(self, true)
  self.RGTextDesc:SetText(Tag)
end

function WBP_GenericModifyBagTag_C:Hide()
  UpdateVisibility(self, false)
end

return WBP_GenericModifyBagTag_C
