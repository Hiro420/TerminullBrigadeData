local WBP_InitialRoleSelection_Tag = UnLua.Class()

function WBP_InitialRoleSelection_Tag:Construct()
end

function WBP_InitialRoleSelection_Tag:InitRoleSelectionTag(TagTxt)
  UpdateVisibility(self, true)
  self.Txt_Tag:SetText(TagTxt)
end

function WBP_InitialRoleSelection_Tag:Hide()
  UpdateVisibility(self, false)
end

function WBP_InitialRoleSelection_Tag:Destruct()
end

return WBP_InitialRoleSelection_Tag
