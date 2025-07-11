local WBP_InteractRescueWidget_C = UnLua.Class()
function WBP_InteractRescueWidget_C:UpdateInteractInfo(InteractTipRow, Character)
  self.Txt_InteractTip:SetText(InteractTipRow.Info)
end
function WBP_InteractRescueWidget_C:OnRescueRatioChange(Character, Ratio)
  local Pawn = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  local InteractHandle = Pawn:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  local HeroCharacterCls = UE.ARGHeroCharacterBase:StaticClass()
  local AllHeroCharacter = UE.UGameplayStatics.GetAllActorsOfClass(self, HeroCharacterCls, nil)
  for i, v in iterator(AllHeroCharacter) do
    local InteractRescueCom = v:GetComponentByClass(UE.URGInteractComponent_Rescue:StaticClass())
    if InteractHandle and InteractRescueCom and InteractRescueCom:IsRescuer(InteractHandle) then
      self:SetRenderOpacity(0)
      return
    end
  end
  self:SetRenderOpacity(1)
end
function WBP_InteractRescueWidget_C:HideWidget()
  UpdateVisibility(self, false)
end
return WBP_InteractRescueWidget_C
