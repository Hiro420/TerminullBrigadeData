local WBP_BossBarItem_C = UnLua.Class()
function WBP_BossBarItem_C:InitItem(Index, Num)
  UpdateVisibility(self.Image_On_up, false)
  UpdateVisibility(self.Image_On_down, true)
  UpdateVisibility(self.Image_Off_up, false)
  UpdateVisibility(self.Image_Off_down, true)
  self.Off = false
  local ImageSoftPath = self.IconArray:Get(Num - Index + 1)
  if ImageSoftPath then
    SetImageBrushBySoftObject(self.Image_On_down, ImageSoftPath)
  end
  ImageSoftPath = self.IconArrayOff:Get(Num - Index + 1)
  if ImageSoftPath then
    SetImageBrushBySoftObject(self.Image_Off_down, ImageSoftPath)
  end
end
function WBP_BossBarItem_C:PlayAddAnimation()
  if not self.Off then
    return
  end
  if self.Up then
    self:PlayAnimation(self.Ani_up_add)
  else
    self:PlayAnimation(self.Ani_down_add)
  end
  PlaySound2DEffect(10050, "WBP_BossBarItem_C,PlayAddAnimation")
  self.Off = false
end
function WBP_BossBarItem_C:PlayDecreaseAnimation()
  if self.Off then
    return
  end
  self:PlayAnimation(self.Ani_transition_gray)
  PlaySound2DEffect(10049, "WBP_BossBarItem_C,PlayDecreaseAnimation")
  self.Off = true
end
function WBP_BossBarItem_C:ShowSubBar(bShow)
  if self.Up then
    UpdateVisibility(self.SubBarUp, bShow)
  else
    UpdateVisibility(self.SubBarDown, bShow)
  end
end
function WBP_BossBarItem_C:OnInvincible(Invincible)
  if self.Off == true or self.Off == nil then
    return
  end
  if Invincible then
    self:PlayAnimation(self.Ani_invincible_in)
  else
    self:PlayAnimation(self.Ani_invincible_out)
  end
end
return WBP_BossBarItem_C
