local WBP_WeaponComAttrItem_C = UnLua.Class()
function WBP_WeaponComAttrItem_C:InitAttributeInfo(Name, Value)
  self.RGTextAttrName:SetText(Name)
  self.RGTextAttrValue:SetText(Value)
  self:UpdateCompareStatus(0)
end
function WBP_WeaponComAttrItem_C:UpdateCompareStatus(Result)
  if 0 == Result then
    self.Img_CompareStatus:SetVisibility(UE.ESlateVisibility.Hidden)
    self.RGTextAttrValue:SetColorAndOpacity(self.CommonTextColor)
  elseif 1 == Result then
    self.RGTextAttrValue:SetColorAndOpacity(self.HighTextColor)
    self.Img_CompareStatus:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.HighSpriteIcon)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_CompareStatus:SetBrush(Brush)
    end
  else
    self.RGTextAttrValue:SetColorAndOpacity(self.LowTextColor)
    self.Img_CompareStatus:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.LowSpriteIcon)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_CompareStatus:SetBrush(Brush)
    end
  end
end
function WBP_WeaponComAttrItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_WeaponComAttrItem_C
