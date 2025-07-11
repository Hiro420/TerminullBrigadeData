local WBP_WeaponSkillItem_C = UnLua.Class()
function WBP_WeaponSkillItem_C:Construct()
  self.WeaponSkillId = -1
  self.SkillGroupId = -1
end
function WBP_WeaponSkillItem_C:OnMouseEnter()
  self:BindOnMainButtonHovered()
end
function WBP_WeaponSkillItem_C:OnMouseLeave()
  self:BindOnMainButtonUnhovered()
end
function WBP_WeaponSkillItem_C:RefreshInfo(WeaponSkillData, index, bIsInverse)
  self.WeaponSkillData = WeaponSkillData
  SetImageBrushBySoftObject(self.Image_Icon, WeaponSkillData.SkillIcon)
  if bIsInverse then
    if 0 == index % 2 then
      self.Image_Icon:SetRenderTransformAngle(0)
      self:SetRenderTransformAngle(0)
    else
      self.Image_Icon:SetRenderTransformAngle(180)
      self:SetRenderTransformAngle(180)
    end
  elseif 0 == index % 2 then
    self.Image_Icon:SetRenderTransformAngle(180)
    self:SetRenderTransformAngle(180)
  else
    self.Image_Icon:SetRenderTransformAngle(0)
    self:SetRenderTransformAngle(0)
  end
end
function WBP_WeaponSkillItem_C:BindOnMainButtonHovered()
  UpdateVisibility(self.Image_Hover, true)
  UpdateVisibility(self.Image_Hover1, true)
  EventSystem.Invoke(EventDef.Weapon.WeaponSkillTip, true, self.WeaponSkillData, self.Name, self)
end
function WBP_WeaponSkillItem_C:BindOnMainButtonUnhovered()
  UpdateVisibility(self.Image_Hover, false)
  UpdateVisibility(self.Image_Hover1, false)
  EventSystem.Invoke(EventDef.Weapon.WeaponSkillTip, false)
end
function WBP_WeaponSkillItem_C:SetBottomColorAndOpacity(InColorAndOpacity)
  self.Image_dI:SetColorAndOpacity(InColorAndOpacity)
end
function WBP_WeaponSkillItem_C:SetIsInHeirloomLevel(IsInHeirloomLevel)
  if IsInHeirloomLevel then
    self.Image_Icon:SetColorAndOpacity(self.HeirloomIconColor)
  else
    self.Image_Icon:SetColorAndOpacity(self.DefaultIconColor)
  end
end
function WBP_WeaponSkillItem_C:Hide()
  UpdateVisibility(self, false)
end
return WBP_WeaponSkillItem_C
