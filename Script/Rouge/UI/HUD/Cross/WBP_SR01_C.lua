local WBP_SR01_C = UnLua.Class()
function WBP_SR01_C:Construct()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC then
    PC.NotifyWeaponEnergy:Add(self, WBP_SR01_C.BindOnNotifyWeaponEnergy)
  end
end
function WBP_SR01_C:BindOnNotifyWeaponEnergy(Value)
  local GrayColor = UE.FLinearColor(0.088656, 0.088656, 0.088656, 1.0)
  local FillColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
  self.Img_ChargeFirstStep:SetColorAndOpacity(GrayColor)
  self.Img_ChargeSecondStep:SetColorAndOpacity(GrayColor)
  self.Img_ChargeThirdStep:SetColorAndOpacity(GrayColor)
  if Value >= 0.3333333333333333 then
    self.Img_ChargeFirstStep:SetColorAndOpacity(FillColor)
  end
  if Value >= 0.6666666666666666 then
    self.Img_ChargeSecondStep:SetColorAndOpacity(FillColor)
  end
  if Value >= 1 then
    self.Img_ChargeThirdStep:SetColorAndOpacity(FillColor)
  end
end
return WBP_SR01_C
