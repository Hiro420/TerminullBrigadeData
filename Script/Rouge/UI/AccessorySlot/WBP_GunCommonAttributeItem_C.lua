local WBP_GunCommonAttributeItem_C = UnLua.Class()

function WBP_GunCommonAttributeItem_C:InitAttributeInfo(Name, Value)
  self.Txt_Name:SetText(Name)
  self.Txt_Value:SetText(Value)
  self:UpdateCompareStatus(0)
end

function WBP_GunCommonAttributeItem_C:UpdateCompareStatus(Result)
  if 0 == Result then
    self.Img_CompareStatus:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_Value:SetColorAndOpacity(self.CommonTextColor)
  elseif 1 == Result then
    self.Txt_Value:SetColorAndOpacity(self.HighTextColor)
    self.Img_CompareStatus:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.HighSpriteIcon)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_CompareStatus:SetBrush(Brush)
    end
  else
    self.Txt_Value:SetColorAndOpacity(self.LowTextColor)
    self.Img_CompareStatus:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.LowSpriteIcon)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_CompareStatus:SetBrush(Brush)
    end
  end
end

return WBP_GunCommonAttributeItem_C
