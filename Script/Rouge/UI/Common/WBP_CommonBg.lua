local WBP_CommonBg = UnLua.Class()

function WBP_CommonBg:Construct()
  local widgetTree = self:GetOuter()
  if widgetTree then
    local parentWidget = widgetTree:GetOuter()
    if parentWidget then
      parentWidget.OnVisibilityChanged:Add(self, self.BindOnVisibilityChanged)
    end
  end
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0, 0)
  self:SetCustomZOrder(99999)
  self.ShowAnimation = true
end

function WBP_CommonBg:BindOnVisibilityChanged(InVisibility)
  if not self.ShowAnimation then
    return
  end
  if InVisibility == UE.ESlateVisibility.Visible or InVisibility == UE.ESlateVisibility.HitTestInvisible or InVisibility == UE.ESlateVisibility.SelfHitTestInvisible then
    self:PlayAnimation(self.Ani_in)
    self:PlayAnimation(self.Ani_loop, 0, 0)
    self:SetCustomZOrder(99999)
  else
    self:StopAnimation(self.Ani_in)
    self:StopAnimation(self.Ani_loop)
    self:SetCustomZOrder(-1)
  end
end

function WBP_CommonBg:OnAnimationFinished(Ani)
  if Ani == self.Ani_in then
    self:SetCustomZOrder(-1)
  end
end

function WBP_CommonBg:Destruct(...)
  self:StopAnimation(self.Ani_in)
  self:StopAnimation(self.Ani_loop)
  local widgetTree = self:GetOuter()
  if widgetTree then
    local parentWidget = widgetTree:GetOuter()
    if parentWidget then
      parentWidget.OnVisibilityChanged:Remove(self, self.BindOnVisibilityChanged)
    end
  end
end

function WBP_CommonBg:AnimationToEnd()
  local EndTime = self.Ani_in:GetEndTime()
  self:PlayAnimationTimeRange(self.Ani_in, EndTime, EndTime, 1, UE.EUMGSequencePlayMode.Forward, 1.0)
end

return WBP_CommonBg
