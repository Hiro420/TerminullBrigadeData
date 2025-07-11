local WeaponSkillTypeName = {
  "",
  NSLOCTEXT("WeaponMainView", "WeaponSkillTypeName", "\227\128\144\232\162\171\229\138\168\227\128\145{0}")
}
local WBP_WeaponTipsSkillItem_C = UnLua.Class()
function WBP_WeaponTipsSkillItem_C:Construct()
  self.WeaponSkillId = -1
  self.SkillGroupId = -1
end
function WBP_WeaponTipsSkillItem_C:RefreshWeaponTipsSkillItemInfo(WeaponSkillData, index, IsNewType)
  self.WeaponSkillData = WeaponSkillData
  self.IsNewType = IsNewType
  UpdateVisibility(self.Weapon_Info, not IsNewType)
  UpdateVisibility(self.Skill_Incline, IsNewType)
  UpdateVisibility(self.RGTextName, not IsNewType)
  if IsNewType then
    self.WBP_WeaponSkillItem_1:RefreshInfo(WeaponSkillData, index, true)
    local skillName = WeaponSkillData.SkillName
    if "" == WeaponSkillTypeName[index] then
      skillName = string.format("%s", skillName)
    else
      skillName = UE.FTextFormat(WeaponSkillTypeName[index](), skillName)
    end
    self.RGTextName_1:SetText(skillName)
    self.RGTextDesc_1:SetText(WeaponSkillData.Desc)
  else
    self.WBP_WeaponSkillItem:RefreshInfo(WeaponSkillData, index, true)
    local skillName = WeaponSkillData.SkillName
    if "" == WeaponSkillTypeName[index] then
      skillName = string.format("%s", skillName)
    else
      skillName = UE.FTextFormat(WeaponSkillTypeName[index](), skillName)
    end
    self.RGTextName:SetText(skillName)
    self.RGTextDesc:SetText(WeaponSkillData.Desc)
  end
end
function WBP_WeaponTipsSkillItem_C:SetNameColorAndOpacity(InColorAndOpacity)
  if self.IsNewType then
    self.RGTextName_1:SetColorAndOpacity(InColorAndOpacity)
  else
    self.RGTextName:SetColorAndOpacity(InColorAndOpacity)
  end
end
function WBP_WeaponTipsSkillItem_C:SetDescColorAndOpacity(InColorAndOpacity)
  if self.IsNewType then
    self.RGTextDesc_1:SetDefaultColorAndOpacity(InColorAndOpacity)
  else
    self.RGTextDesc:SetDefaultColorAndOpacity(InColorAndOpacity)
  end
end
function WBP_WeaponTipsSkillItem_C:SetBottomColorAndOpacity(InColorAndOpacity)
  if self.IsNewType then
    self.WBP_WeaponSkillItem_1:SetBottomColorAndOpacity(InColorAndOpacity)
  else
    self.WBP_WeaponSkillItem:SetBottomColorAndOpacity(InColorAndOpacity)
  end
end
function WBP_WeaponTipsSkillItem_C:SetIsInHeirloomLevel(IsInHeirloomLevel)
  if self.IsNewType then
    self.WBP_WeaponSkillItem_1:SetIsInHeirloomLevel(IsInHeirloomLevel)
  else
    self.WBP_WeaponSkillItem:SetIsInHeirloomLevel(IsInHeirloomLevel)
  end
end
function WBP_WeaponTipsSkillItem_C:Hide()
  UpdateVisibility(self, false)
end
return WBP_WeaponTipsSkillItem_C
