local WBP_HUDInfo_ShedBlood_C = UnLua.Class()

function WBP_HUDInfo_ShedBlood_C:PlayReduceAnim(ReduceAnimName)
  if not ReduceAnimName then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local TargetAnimation = self[ReduceAnimName]
  if TargetAnimation then
    self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimationForward(TargetAnimation)
  else
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

return WBP_HUDInfo_ShedBlood_C
