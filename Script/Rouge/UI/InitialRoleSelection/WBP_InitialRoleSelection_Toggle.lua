local WBP_InitialRoleSelection_Toggle = UnLua.Class()
function WBP_InitialRoleSelection_Toggle:Construct()
end
function WBP_InitialRoleSelection_Toggle:InitRoleSelectionToggle(HeroMonsterRow)
  UpdateVisibility(self, true, true)
  self.Txt_RoleName_UnSelect:SetText(HeroMonsterRow.NickName)
  self.Txt_RoleName_Select:SetText(HeroMonsterRow.NickName)
  SetImageBrushByPath(self.Img_RoleIcon_UnSelect, HeroMonsterRow.ActorIcon)
  SetImageBrushByPath(self.Img_RoleIcon_Select, HeroMonsterRow.ActorIcon)
end
function WBP_InitialRoleSelection_Toggle:Hide()
  UpdateVisibility(self, false)
end
function WBP_InitialRoleSelection_Toggle:Destruct()
end
return WBP_InitialRoleSelection_Toggle
