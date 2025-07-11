local WBP_WeaponAttributeItem_C = UnLua.Class()
function WBP_WeaponAttributeItem_C:InitAttributeInfo(Name, Value, IsRight)
  self.IsRight = IsRight
  self.LeftPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.RightPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  if IsRight then
    self.RightPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_RightNum:SetText(Value)
  else
    self.LeftPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_LeftNum:SetText(Value)
  end
  self.Txt_Name:SetText(Name)
  self:UpdateCompareStatus(0)
end
function WBP_WeaponAttributeItem_C:UpdateCompareStatus(Result)
  local TargetNum, TargetCompareStatus
  if self.IsRight then
    TargetNum = self.Txt_RightNum
    TargetCompareStatus = self.Img_RightCompareStatus
  else
    TargetNum = self.Txt_LeftNum
    TargetCompareStatus = self.Img_LeftCompareStatus
  end
  if 0 == Result then
    TargetCompareStatus:SetVisibility(UE.ESlateVisibility.Hidden)
    TargetNum:SetColorAndOpacity(self.CommonTextColor)
  elseif 1 == Result then
    TargetNum:SetColorAndOpacity(self.HighTextColor)
    TargetCompareStatus:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.HighSpriteIcon)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      TargetCompareStatus:SetBrush(Brush)
    end
  else
    TargetNum:SetColorAndOpacity(self.LowTextColor)
    TargetCompareStatus:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.LowSpriteIcon)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      TargetCompareStatus:SetBrush(Brush)
    end
  end
end
return WBP_WeaponAttributeItem_C
