local WBP_HitEffect_C = UnLua.Class()

function WBP_HitEffect_C:Show(SourceActor, Ratio, IsHealthDamage)
  self:Hide()
  self:ShowDamageAnim()
  self.SourceActor = SourceActor
  self.Ratio = math.clamp(Ratio, self.MinAngle / 360, self.MaxAngle / 360)
  self:UpdateCircularValue()
  self:UpdateCircularAngle()
  local AllTime = self.Ratio / 12 * 5
  self.PlayTime = AllTime / self.TimebackSpeed
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self:BindToAnimationFinished(self.FadeOutDamageIndicator, {
    self,
    WBP_HitEffect_C.BindAnimFinish
  })
  local LocalPlayer = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not LocalPlayer then
    return
  end
  local CoreComp = LocalPlayer.CoreComponent
  if not CoreComp then
    return
  end
  self:UpdateCircularColor(IsHealthDamage)
end

function WBP_HitEffect_C:UpdateCircularValue()
  local DynamicMaterial = self.Img_CircularArc:GetDynamicMaterial()
  if not DynamicMaterial then
    return
  end
  DynamicMaterial:SetScalarParameterValue("Degree", 360 * self.Ratio)
end

function WBP_HitEffect_C:UpdateCircularColor(IsHealthDamage)
  local DynamicMaterial = self.Img_CircularArc:GetDynamicMaterial()
  if not DynamicMaterial then
    return
  end
  if IsHealthDamage then
    DynamicMaterial:SetVectorParameterValue("CircleColor", self.HealthColor)
  else
    DynamicMaterial:SetVectorParameterValue("CircleColor", self.ShieldColor)
  end
end

function WBP_HitEffect_C:IsSameSourceActor(SourceActor)
  return self.SourceActor == SourceActor
end

function WBP_HitEffect_C:BindAnimFinish()
  self.ListContainer:HideItem(self)
end

function WBP_HitEffect_C:Hide()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CircularTimeHandle) then
    UE.UKismetSystemLibrary.K2_PauseTimerHandle(self, self.CircularTimeHandle)
  end
  if UE.UKismetSystemLibrary.K2_IsTimerActiveHandle(self, self.CircularTipTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CircularTipTimer)
  end
  self:UnbindFromAnimationFinished(self.FadeOutDamageIndicator, {
    self,
    WBP_HitEffect_C.BindAnimFinish
  })
  self.SourceActor = nil
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_HitEffect_C
