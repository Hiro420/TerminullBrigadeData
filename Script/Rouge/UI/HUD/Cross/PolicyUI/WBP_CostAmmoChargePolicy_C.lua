local WBP_CostAmmoChargePolicy_C = UnLua.Class()
function WBP_CostAmmoChargePolicy_C:Construct()
  ListenObjectMessage(nil, GMP.MSG_World_Weapon_OnChargeTimeDelta, self, self.BindOnChargeTimeUpdate)
  local DynamicMaterial = self.URGImage_Charge:GetDynamicMaterial()
  if DynamicMaterial then
    DynamicMaterial:SetScalarParameterValue("ProgressPercent", 0)
  end
end
function WBP_CostAmmoChargePolicy_C:BindOnChargeTimeUpdate(MaxPercent, Progress, RatioAdd)
  local DynamicMaterial = self.URGImage_Charge:GetDynamicMaterial()
  if DynamicMaterial then
    DynamicMaterial:SetScalarParameterValue("ProgressPercent", Progress)
    DynamicMaterial:SetScalarParameterValue("MaxPercent", MaxPercent)
  end
  if MaxPercent < 1 then
    if NearlyEquals(Progress, MaxPercent, 0.1) then
      self.Zidan:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Zidan_Red:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    else
      self.Zidan:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      self.Zidan_Red:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  else
    self.Zidan:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Zidan_Red:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.TextDamage:SetText("+" .. tostring(RatioAdd) .. "%")
end
function WBP_CostAmmoChargePolicy_C:Destruct()
  UnListenObjectMessage(GMP.MSG_World_Weapon_OnChargeTimeUpdate, self)
end
return WBP_CostAmmoChargePolicy_C
