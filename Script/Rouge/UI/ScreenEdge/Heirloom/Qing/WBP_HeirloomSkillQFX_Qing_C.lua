local WBP_HeirloomSkillQFX_Qing_C = UnLua.Class()
function WBP_HeirloomSkillQFX_Qing_C:StartPlayAnimation()
  self:InitPanel()
  self.IsForceStopAnimation = false
  self:PlayAnimationForward(self.Anim_FX_yelinna_begin)
end
function WBP_HeirloomSkillQFX_Qing_C:OnAnimationFinished(Animation)
  if self.IsForceStopAnimation then
    return
  end
  if Animation == self.Anim_FX_yelinna_Begin then
    self:PlayAnimationForward(self.Anim_FX_yelinna_Loop)
  elseif Animation == self.Anim_FX_yelinna_Loop then
    self:PlayAnimationForward(self.Anim_FX_yelinna_Death)
  elseif Animation == self.Anim_FX_yelinna_Death then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_HeirloomSkillQFX_Qing_C:InitPanel()
  self.IsForceStopAnimation = true
  self:StopAllAnimations()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.LoopAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.LoopAnimTimer)
  end
end
function WBP_HeirloomSkillQFX_Qing_C:Destruct()
  self:InitPanel()
end
return WBP_HeirloomSkillQFX_Qing_C
