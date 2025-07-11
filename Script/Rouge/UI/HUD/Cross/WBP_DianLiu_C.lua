local WBP_DianLiu_C = UnLua.Class()
function WBP_DianLiu_C:Construct()
  self:InitChargeBarInfo()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC and PC.NotifyWeaponEnergy then
    PC.NotifyWeaponEnergy:Add(self, WBP_DianLiu_C.BindOnNotifyWeaponEnergy)
  end
end
function WBP_DianLiu_C:BindOnNotifyWeaponEnergy(Value)
  self:UpdateChargeBar(Value)
end
function WBP_DianLiu_C:InitChargeBarInfo()
  local AllChildren = self.LeftChargePanel:GetAllChildren()
  for i, SingleWidget in iterator(AllChildren) do
    SingleWidget:InitInfo((i - 1) * 0.25, i * 0.25)
    local RightWidget = self.RightChargePanel:GetChildAt(i - 1)
    if RightWidget then
      RightWidget:InitInfo((i - 1) * 0.25, i * 0.25)
    end
  end
end
function WBP_DianLiu_C:UpdateChargeBar(Value)
  local AllChildren = self.LeftChargePanel:GetAllChildren()
  for i, SingleWidget in iterator(AllChildren) do
    SingleWidget:UpdateProgressBar(Value)
    local RightWidget = self.RightChargePanel:GetChildAt(i - 1)
    if RightWidget then
      RightWidget:UpdateProgressBar(Value)
    end
  end
end
function WBP_DianLiu_C:Destruct()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC then
    PC.NotifyWeaponEnergy:Remove(self, WBP_DianLiu_C.BindOnNotifyWeaponEnergy)
  end
end
return WBP_DianLiu_C
