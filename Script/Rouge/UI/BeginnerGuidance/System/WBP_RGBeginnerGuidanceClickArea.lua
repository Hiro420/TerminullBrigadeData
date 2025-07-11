local WBP_RGBeginnerGuidanceClickArea = UnLua.Class()
function WBP_RGBeginnerGuidanceClickArea:Show(...)
  UpdateVisibility(self, true)
end
function WBP_RGBeginnerGuidanceClickArea:Hide(...)
  UpdateVisibility(self, false)
  self:StopAllAnimations()
end
function WBP_RGBeginnerGuidanceClickArea:PlayInAnim()
  if not self:IsAnimationPlaying(self.Ani_in) then
    self:PlayAnimation(self.Ani_in)
  end
end
function WBP_RGBeginnerGuidanceClickArea:SetClickAreaType(ClickAreaType)
  if "Normal" == ClickAreaType then
    UpdateVisibility(self.Image_CanClickArea, true)
  elseif "Hide" == ClickAreaType then
    UpdateVisibility(self.Image_CanClickArea, false)
  end
end
return WBP_RGBeginnerGuidanceClickArea
