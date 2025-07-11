local WBP_SkillDetailDesc_C = UnLua.Class()
function WBP_SkillDetailDesc_C:Show(SkillDetailDescInfo)
  if SkillDetailDescInfo.key then
    self.Txt_DescName:SetText(SkillDetailDescInfo.key)
  end
  if SkillDetailDescInfo.value then
    self.Txt_DescValue:SetText(SkillDetailDescInfo.value)
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_SkillDetailDesc_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_SkillDetailDesc_C
