local WBP_BloodHitCross_C = UnLua.Class()
function WBP_BloodHitCross_C:OnAnimationFinished(Animation)
  if Animation == self.ShowWeaknessHitAnim then
    self.HitAnimPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.IsPlayShowWeaknessHitAnim = false
  elseif Animation == self.ShowLuckyShotHitAnim then
    self.LuckyShotHitAnimPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.IsPlayLuckyShotAnim = false
  end
end
function WBP_BloodHitCross_C:PlayHitAnimation(IsLuckyShot, PlaybackSpeed)
  if IsLuckyShot then
    if not self.IsPlayLuckyShotAnim then
      self.IsPlayLuckyShotAnim = true
      self.LuckyShotHitAnimPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:PlayAnimationForward(self.ShowLuckyShotHitAnim, PlaybackSpeed)
    end
  elseif not self.IsPlayShowWeaknessHitAnim then
    self.IsPlatShowWeaknessHitAnim = true
    self.HitAnimPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimationForward(self.ShowWeaknessHitAnim, PlaybackSpeed)
  end
end
function WBP_BloodHitCross_C:StopAllHitAnimations()
  self.HitAnimPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.IsPlayShowWeaknessHitAnim = false
  self.LuckyShotHitAnimPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.IsPlayLuckyShotAnim = false
end
return WBP_BloodHitCross_C
