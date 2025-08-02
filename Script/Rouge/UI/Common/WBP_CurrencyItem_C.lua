local WBP_CurrencyItem_C = UnLua.Class()

function WBP_CurrencyItem_C:Construct()
  if self.ItemId <= 0 then
    return
  end
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.OnBagChanged:Add(self, WBP_CurrencyItem_C.UpdateCurrencyNum)
  end
  self:UpdateCurrencyNum()
  self:UpdateCurrencyIcon()
end

function WBP_CurrencyItem_C:UpdateCurrencyNum()
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if not BagComp then
    return
  end
  self.Txt_Price:SetText(tostring(BagComp:GetItemByConfigId(self.ItemId).Stack))
end

function WBP_CurrencyItem_C:UpdateCurrencyIcon()
  local Result, RowInfo = GetDataLibraryObj().GetItemRowInfoById(self.ItemId)
  if not Result then
    return
  end
  SetImageBrushBySoftObject(self.Img_CurrencyIcon, RowInfo.SpriteIcon)
end

function WBP_CurrencyItem_C:GetToolTipWidget()
  if self.ToolTip and self.ToolTip:IsValid() then
    return self.ToolTip
  end
  local TipClassObj = UE.UClass.Load("/Game/Rouge/UI/Common/WBP_CurrencyItemTip.WBP_CurrencyItemTip_C")
  self.ToolTip = UE.UWidgetBlueprintLibrary.Create(self, TipClassObj)
  self.ToolTip:InitInfo(self.ItemId)
  return self.ToolTip
end

function WBP_CurrencyItem_C:RemoveEvent()
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.OnBagChanged:Remove(self, WBP_CurrencyItem_C.UpdateCurrencyNum)
  end
end

return WBP_CurrencyItem_C
