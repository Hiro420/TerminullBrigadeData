local WBP_GenericModifyTag_C = UnLua.Class()

function WBP_GenericModifyTag_C:InitGenericModifyTag(Tag)
  UpdateVisibility(self, true)
  self.RGTextDesc:SetText(Tag)
end

function WBP_GenericModifyTag_C:Hide()
  UpdateVisibility(self, false)
end

return WBP_GenericModifyTag_C
