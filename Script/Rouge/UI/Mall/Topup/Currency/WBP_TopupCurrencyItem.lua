local WBP_TopupCurrencyItem = UnLua.Class()
local TopupHandler = require("Protocol.Topup.TopupHandler")
local TopupData = require("Modules.Topup.TopupData")

function WBP_TopupCurrencyItem:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  SetImageBrushBySoftObject(self.Img_Bottom, self.BottomIconSoftObj)
end

function WBP_TopupCurrencyItem:Show(ProductId, Index)
  if 1 == Index then
    UpdateVisibility(self, true)
    self:PlayAnimation(self.Ani_in)
  else
    local DelayInAnimTime = self.InAnimDelayTime * (Index - 1)
    UpdateVisibility(self, false, true, true)
    self.InAnimTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        UpdateVisibility(self, true)
        self:PlayAnimation(self.Ani_in)
      end
    }, DelayInAnimTime, false)
  end
  self.ProductId = ProductId
  local Result, PaymentRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMall, self.ProductId)
  if not Result then
    return
  end
  self.MidasProductId = PaymentRowInfo.MidasGoodsID
  local Result, LeftStr, RightStr = UE.UKismetStringLibrary.Split(PaymentRowInfo.MidasGoodsID, "_", nil, nil, UE.ESearchCase.IgnoreCase, UE.ESearchDir.FromStart)
  local Result, ResourceInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, tonumber(LeftStr))
  if Result then
    SetImageBrushByPath(self.Img_Icon, ResourceInfo.Icon, self.IconSize)
  end
  if self.Txt_Name then
    self.Txt_Name:SetText(PaymentRowInfo.Name)
  end
  local PriceStr = TopupData:GetProductDisplayPrice(ProductId)
  self.Txt_Price:SetText(PriceStr)
  local Result, MallCurrencyRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMallCurrency, self.ProductId)
  if Result then
    self.Txt_Num:SetText(MallCurrencyRowInfo.Quantity)
    local ContentStr = tostring(MallCurrencyRowInfo.PresentedContent)
    local IsEmptyContent = UE.UKismetStringLibrary.IsEmpty(ContentStr)
    UpdateVisibility(self.Overlay_SpecialDesc, not IsEmptyContent)
    if not IsEmptyContent then
      self.Txt_SpecialDesc:SetText(MallCurrencyRowInfo.PresentedContent)
    end
  else
    print("WBP_TopupCurrencyItem:Show PaymentMallCurrency not found ProductId = " .. tostring(self.ProductId))
    self.Txt_Num:SetText("0")
    UpdateVisibility(self.Overlay_SpecialDesc, false)
  end
end

function WBP_TopupCurrencyItem:BindOnMainButtonClicked(...)
  if not self.MidasProductId then
    return
  end
  local Result = TopupHandler:RequestBuyMisdasProduct(self.ProductId, 1)
  if not Result then
    print("RequestBuyMisdasProduct failed")
  end
end

function WBP_TopupCurrencyItem:BindOnMainButtonHovered(...)
  if self.IsBigItem then
    self:PlayAnimation(self.Ani_hover_mask2)
  else
    self:PlayAnimation(self.Ani_hover_mask1)
  end
end

function WBP_TopupCurrencyItem:BindOnMainButtonUnhovered(...)
  if self.IsBigItem then
    self:PlayAnimation(self.Ani_Unhover_mask2, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  else
    self:PlayAnimation(self.Ani_Unhover_mask1, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  end
end

function WBP_TopupCurrencyItem:Hide(...)
  UpdateVisibility(self, false)
  self.MidasProductId = nil
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.InAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.InAnimTimer)
  end
end

function WBP_TopupCurrencyItem:Destruct(...)
  self:Hide()
end

return WBP_TopupCurrencyItem
