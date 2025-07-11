local WBP_SkillAdditionSlot_C = UnLua.Class()
function WBP_SkillAdditionSlot_C:InitInfo()
  self:ChangeFillVis(false)
end
function WBP_SkillAdditionSlot_C:ChangeFillVis(IsShow)
  if IsShow then
    self.Img_Fill:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Fill:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
return WBP_SkillAdditionSlot_C
