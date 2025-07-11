local WBP_RedWarning_C = UnLua.Class()
function WBP_RedWarning_C:ShowRedWarning()
  local Quality = BattleUIScalability:GetRedWarningScalability()
  if Quality == UIQuality.LOW then
    return
  end
  local CurrentAnimTime = LogicHUD.BeingAttackList[1]
  if not CurrentAnimTime then
    return
  end
  local AnimStartTime = self.Ani_aim:GetStartTime()
  local AnimEndTime = self.Ani_aim:GetEndTime()
  local TargetAnimTime = UE.UGameplayStatics.GetTimeSeconds(self) - CurrentAnimTime
  if TargetAnimTime >= AnimEndTime - AnimStartTime then
    print("\232\182\133\232\191\135\230\156\128\229\164\167\231\158\132\229\135\134\229\138\168\231\148\187\230\151\182\233\151\180")
    return
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimationTimeRange(self.Ani_aim, TargetAnimTime, AnimEndTime, 1, UE.EUMGSequencePlayMode.Forward)
end
function WBP_RedWarning_C:HideRedWarning()
  local Quality = BattleUIScalability:GetRedWarningScalability()
  if Quality == UIQuality.LOW then
    return
  end
  if self:IsAnimationPlaying(self.Ani_aim) then
    self:StopAnimation(self.Ani_aim)
  end
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_RedWarning_C
