local WBP_EquippedAccessoryCard_C = UnLua.Class()

function WBP_EquippedAccessoryCard_C:PreConstruct(IsDesignTime)
  self:InitializeCard()
end

function WBP_EquippedAccessoryCard_C:Construct()
  self:GetWeaponCapture()
  self:InitializeCard()
  self.Button.OnClicked:Add(self, WBP_EquippedAccessoryCard_C.OnClicked_Button)
end

function WBP_EquippedAccessoryCard_C:InitializeCard()
  self.TypeText:SetText(self.TypeContext)
end

function WBP_EquippedAccessoryCard_C:OnClicked_Button()
  if self:IsAccessoryRotate() then
    return
  end
  if self.bSelected then
    self:CallUnSelectedBySelf()
    self:UnselectCard()
    self:OnEquippedAccessoryClicked(false)
  else
    self:SelectCard()
    self:OnEquippedAccessoryClicked(true)
  end
end

return WBP_EquippedAccessoryCard_C
