local WBP_CommonBg_Style2 = UnLua.Class()
function WBP_CommonBg_Style2:Construct()
  local widgetTree = self:GetOuter()
  if widgetTree then
    local parentWidget = widgetTree:GetOuter()
    if parentWidget then
      parentWidget.OnVisibilityChanged:Add(self, self.BindOnVisibilityChanged)
    end
  end
  self:PlayAnimation(self.Ani_in)
end
function WBP_CommonBg_Style2:BindOnVisibilityChanged(InVisibility)
  if InVisibility == UE.ESlateVisibility.Visible or InVisibility == UE.ESlateVisibility.HitTestInvisible or InVisibility == UE.ESlateVisibility.SelfHitTestInvisible then
    self:PlayAnimation(self.Ani_in)
  else
    self:StopAnimation(self.Ani_in)
  end
end
function WBP_CommonBg_Style2:Destruct(...)
  self:StopAnimation(self.Ani_in)
  local widgetTree = self:GetOuter()
  if widgetTree then
    local parentWidget = widgetTree:GetOuter()
    if parentWidget then
      parentWidget.OnVisibilityChanged:Remove(self, self.BindOnVisibilityChanged)
    end
  end
end
return WBP_CommonBg_Style2
