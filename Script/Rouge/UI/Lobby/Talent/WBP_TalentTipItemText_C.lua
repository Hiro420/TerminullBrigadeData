local WBP_TalentTipItemText_C = UnLua.Class()

function WBP_TalentTipItemText_C:Show(PreLevel, Level, Desc)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Text:SetText(Desc)
  local TextOpacity, IconColor
  if PreLevel + 1 == Level then
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    TextOpacity = self.PreUpgradeTextOpacity
    IconColor = self.PreUpgradeIconColor
  else
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    if Level < PreLevel + 1 then
      TextOpacity = self.UpgradeTextOpacity
      IconColor = self.UpgradedIconColor
    else
      TextOpacity = self.NotUpgradeTextOpacity
      IconColor = self.NotUpgradeIconColor
    end
  end
  self.Txt_Text:SetRenderOpacity(TextOpacity)
  self.Img_Flag:SetColorAndOpacity(IconColor)
end

return WBP_TalentTipItemText_C
