local WBP_DamageFactor_C = UnLua.Class()

function WBP_DamageFactor_C:Construct()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  if not PC.DamageComponent then
    return
  end
  PC.DamageComponent.OnDebugParams:Add(self, WBP_DamageFactor_C.BindOnDebugParams)
end

function WBP_DamageFactor_C:BindOnDebugParams(SourceActor, TargetActor, Params)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character or Character ~= SourceActor and Character ~= TargetActor then
    return
  end
  self.Txt_TargetName:SetText(UE.UKismetSystemLibrary.GetDisplayName(TargetActor))
  local CoreComp = TargetActor.CoreComponent
  if CoreComp then
    self.Health:UpdateNotAttributeInfo(string.format("%.2f", CoreComp:GetHealth()))
    self.MaxHealth:UpdateNotAttributeInfo(string.format("%.2f", CoreComp:GetMaxHealth()))
  end
  self.BodyIndex:UpdateNotAttributeInfo(tostring(Params.PartIndex))
  self.ElementDamageCoefficient:UpdateNotAttributeInfo(string.format("%.2f", Params.SourceElementalDamage))
  self.ElementReduce:UpdateNotAttributeInfo(string.format("%.2f", Params.ElementalReduce))
  self.ElementPartRatio:UpdateNotAttributeInfo(string.format("%.2f", Params.ElementalBodyPartRatio))
  self.BodyPartRatio:UpdateNotAttributeInfo(string.format("%.2f", Params.BodyPartRatio))
  self.BodyPartArmorReduce:UpdateNotAttributeInfo(string.format("%.2f", Params.BodyPartArmorReduce))
  self.IsWeakHit:UpdateNotAttributeInfo(tostring(Params.IsWeakHit))
  self.WeakHitCoefficient:UpdateNotAttributeInfo(string.format("%.2f", Params.WeakHit))
  self.PartDamageType:UpdateNotAttributeInfo(tostring(Params.PartDamageType))
  self.LuckyShot:UpdateNotAttributeInfo(tostring(Params.LuckyShot))
  self.SourceDamageRatio:UpdateNotAttributeInfo(string.format("%.2f", Params.SourceDamageRatio))
  self.TargetDamageReduce:UpdateNotAttributeInfo(string.format("%.2f", Params.TargetDamageReduce))
  self.ShieldReduce:UpdateNotAttributeInfo(string.format("%.2f", Params.ShieldReduce))
  self.FinalDamage:UpdateNotAttributeInfo(string.format("%.2f", Params.FinalDamage))
  self.TrapDamage:UpdateNotAttributeInfo(string.format("%.2f", Params.TrapDamage))
  self.WeaponDamage:UpdateNotAttributeInfo(string.format("%.2f", Params.WeaponDamage))
  self.SkillDamage:UpdateNotAttributeInfo(string.format("%.2f", Params.SkillDamage))
  self.ElementType:UpdateNotAttributeInfo(tostring(Params.ElementType))
  self.FireElementalChance:UpdateNotAttributeInfo(string.format("%.2f", Params.FireElementalChance))
  self.IceElementalChance:UpdateNotAttributeInfo(string.format("%.2f", Params.IceElementalChance))
  self.ElectricElementalChance:UpdateNotAttributeInfo(string.format("%.2f", Params.ElectricElementalChance))
  self.PoisonElementalChance:UpdateNotAttributeInfo(string.format("%.2f", Params.PoisonElementalChance))
  self.ExplodeRatio:UpdateNotAttributeInfo(string.format("%.2f", Params.ExplodeRatio))
  self.DistanceRatio:UpdateNotAttributeInfo(string.format("%.2f", Params.DistanceRatio))
end

return WBP_DamageFactor_C
