local AchievementBadgeTip = UnLua.Class()
function AchievementBadgeTip:Construct()
end
function AchievementBadgeTip:Destruct()
end
function AchievementBadgeTip:InitAchievementBadgeTip(tbGenralData)
  if not tbGenralData then
    return
  end
  self:StopAnimation(self.Ani_out)
  UpdateVisibility(self, true)
  SetImageBrushByPath(self.URGImageIcon, tbGenralData.Icon)
  self.RGTextName:SetText(tbGenralData.Name)
  self.RGTextDesc:SetText(tbGenralData.Desc)
  local result, row = GetRowData(DT.DT_ItemRarity, tostring(tbGenralData.Rare))
  if result then
    self.RGTextRare:SetText(row.DisplayName)
    self.RGTextRare:SetColorAndOpacity(row.DisplayNameColor)
  end
  self:PlayAnimation(self.Ani_in)
end
function AchievementBadgeTip:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end
function AchievementBadgeTip:Hide()
  SetHitTestInvisible(self)
  self:PlayAnimation(self.Ani_out)
end
return AchievementBadgeTip
