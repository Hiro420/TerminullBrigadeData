local WBP_HeyncksPassiveSKill_C = UnLua.Class()
function WBP_HeyncksPassiveSKill_C:Construct()
  self:UpdateIconSize()
  self.Character = self:GetOwningPlayerPawn()
  local BuffComp = self.Character:GetComponentByClass(UE.UBuffComponent:StaticClass())
  if BuffComp then
    BuffComp.OnBuffAdded:Add(self, self.BindOnBuffAdded)
    BuffComp.OnBuffRemove:Add(self, self.BindOnBuffRemoved)
  end
end
function WBP_HeyncksPassiveSKill_C:OnDisplay()
  self:PlayAnimation(self.Ani_normal_in)
end
function WBP_HeyncksPassiveSKill_C:OnUnDisplay()
  self:PlayAnimation(self.Ani_normal_out)
end
function WBP_HeyncksPassiveSKill_C:BindOnBuffAdded(AddedBuff)
  if AddedBuff.ID == self.StrenghtenBuffID then
    self:PlayAnimation(self.Ani_strength_in)
  end
end
function WBP_HeyncksPassiveSKill_C:BindOnBuffRemoved(RemovedBuff)
  if RemovedBuff.ID == self.StrenghtenBuffID then
    self:PlayAnimation(self.Ani_strength_out)
  end
end
function WBP_HeyncksPassiveSKill_C:PlayAnimationByVisibility(Visibility)
  if Visibility == UE.ESlateVisibility.Visible or Visibility == UE.ESlateVisibility.SelfHitTestInvisible then
    self:SetVisibility(Visibility)
    self:PlayAnimation(self.Ani_normal_in)
  else
    self:PlayAnimation(self.Ani_normal_out)
  end
end
function WBP_HeyncksPassiveSKill_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_normal_out then
    UpdateVisibility(self, false)
  end
end
function WBP_HeyncksPassiveSKill_C:Destruct()
  local BuffComp = self.Character:GetComponentByClass(UE.UBuffComponent:StaticClass())
  if BuffComp then
    BuffComp.OnBuffAdded:Remove(self, self.BindOnBuffAdded)
    BuffComp.OnBuffRemove:Remove(self, self.BindOnBuffRemoved)
  end
  self.Character = nil
end
return WBP_HeyncksPassiveSKill_C
