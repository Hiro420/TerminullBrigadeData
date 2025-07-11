local WBP_ScrollSetNumItem_C = UnLua.Class()
function WBP_ScrollSetNumItem_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_ScrollSetNumItem_C:InitSetNumItem(CurLevel, selfLevel, MaxLevel, bHaveEffect)
  if selfLevel == MaxLevel and MaxLevel <= CurLevel then
    self:SetIsEnabled(true)
  else
    self:SetIsEnabled(selfLevel == CurLevel)
  end
  self.RGTextNum:SetText(selfLevel)
  if MaxLevel <= CurLevel and MaxLevel <= selfLevel then
    self.RGTextNum:SetColorAndOpacity(self.MaxLevelColor)
  else
    self.RGTextNum:SetColorAndOpacity(self.NormalLevelColor)
  end
  UpdateVisibility(self.RGTextNum, bHaveEffect)
  UpdateVisibility(self.URGImageTag, not bHaveEffect)
end
function WBP_ScrollSetNumItem_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_ScrollSetNumItem_C:Destruct()
end
return WBP_ScrollSetNumItem_C
