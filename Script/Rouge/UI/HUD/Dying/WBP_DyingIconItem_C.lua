local WBP_DyingIconItem_C = UnLua.Class()

function WBP_DyingIconItem_C:Construct()
  self.WBP_DyingMaterial.OnRescueRatioChangeEvent:Add(self, WBP_DyingIconItem_C.OnRescueStateChange)
end

function WBP_DyingIconItem_C:Destruct()
  self.WBP_DyingMaterial.OnRescueRatioChangeEvent:Remove(self, WBP_DyingIconItem_C.OnRescueStateChange)
end

function WBP_DyingIconItem_C:OnAnimationFinished(Animation)
  if Animation == self.ShowAni then
    self:PlayAnimation(self.Flushni, 0, 0)
  end
end

function WBP_DyingIconItem_C:OnRescueStateChange(Rescue, Ratio)
  if Rescue then
    if not self.CloseRange then
      self.Image_BackGround:SetVisibility(UE.ESlateVisibility.Hidden)
    end
    if self.Arrow then
    end
    SetImageBrushBySoftObject(self.Image_BG, self.Rescue)
  else
    if not self.CloseRange then
      self.Image_BackGround:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.Arrow then
    end
    SetImageBrushBySoftObject(self.Image_BG, self.NotRescue)
  end
end

return WBP_DyingIconItem_C
