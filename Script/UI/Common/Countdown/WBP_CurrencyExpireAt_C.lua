local WBP_CurrencyExpireAt_C = UnLua.Class()
function WBP_CurrencyExpireAt_C:InitCurrencyExpireAt(CurrencyInfo)
  self.CurrencyId = CurrencyInfo.currencyId or CurrencyInfo.id
  self.ExpireAt = CurrencyInfo.expireAt
  self.Number = CurrencyInfo.number or CurrencyInfo.amount
  self.Txt_Num:SetText(self.Number)
  local RowInfo = LogicOutsidePackback.GetResourceInfoById(self.CurrencyId)
  if not RowInfo then
    print("Invalid Currency Num")
    return
  end
  local SoftObjRef = MakeStringToSoftObjectReference(RowInfo.Icon)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjRef) then
    local obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjRef)
    local iconObj
    if obj then
      iconObj = obj:Cast(UE.UPaperSprite)
    end
    if iconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(iconObj, 0, 0)
      self.Img_CurrencyIcon:SetBrush(Brush)
    end
  end
  self.WBP_CommonExpireAt:InitCommonExpireAt(self.ExpireAt)
end
return WBP_CurrencyExpireAt_C
