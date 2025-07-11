local WBP_MonthCardItem = UnLua.Class()
local MonthCardData = require("Modules.MonthCard.MonthCardData")
local TopupData = require("Modules.Topup.TopupData")
local TopupHandler = require("Protocol.Topup.TopupHandler")
function WBP_MonthCardItem:Construct()
  self.Btn_Buy.OnClicked:Add(self, self.BindOnBuyButtonClicked)
end
function WBP_MonthCardItem:Show(ProductId)
  self.ProductId = ProductId
  local ProductId = self.ProductId
  local Result, PaymentRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMall, ProductId)
  if not Result then
    print("WBP_MonthCardItem:Show ProductId not found", ProductId)
    self:Hide()
    return
  end
  if not PaymentRowInfo.IsShow then
    self:Hide()
    return
  end
  UpdateVisibility(self, true)
  local ResourceId = tonumber(PaymentRowInfo.MidasGoodsID)
  self.WBP_Item:InitItem(ResourceId)
  self.WBP_Item:ShowOrHideLoopAnimWidget(true)
  local PriceStr = TopupData:GetProductDisplayPrice(ProductId)
  self.Txt_Price:SetText(PriceStr)
  local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    print("WBP_MonthCardItem:Show ResourceRowInfo not found", ResourceId)
    return
  end
  self.Txt_Name:SetText(ResourceRowInfo.Name)
  local Result, MonthCardResourceInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMonthCard, ResourceId)
  if not Result then
    print("WBP_MonthCardItem:Show MonthCardResourceInfo not found", ResourceId)
    return
  end
  local MonthCardInfo = MonthCardData:GetMonthCardInfoByRoleId(DataMgr.GetUserId())
  if MonthCardInfo then
    local EndTime = MonthCardInfo[tostring(MonthCardResourceInfo.MonthCardID)] and tonumber(MonthCardInfo[tostring(MonthCardResourceInfo.MonthCardID)])
    local CurTime = GetLocalTimestampByServerTimeZone()
    if EndTime and EndTime > CurTime then
      UpdateVisibility(self.Overlay_RemainTime, true)
      self.Txt_Buy:SetText(self.RenewText)
      local RemainTime = EndTime - GetLocalTimestampByServerTimeZone()
      local Day = math.floor(RemainTime / 86400)
      local Hour = math.floor(RemainTime % 86400 / 3600)
      local Minute = math.floor(RemainTime % 3600 / 60)
      self.RGStateController_TimeLimit:ChangeStatus("Normal")
      local RemainTimeStr
      if Day >= 999 then
        RemainTimeStr = NSLOCTEXT("MonthCardItem", "OverDayStr", "999+\229\164\169")
      elseif Day >= 1 then
        RemainTimeStr = UE.FTextFormat(NSLOCTEXT("MonthCardItem", "DayHourMinuteStr", "{0}\229\164\169{1}\229\176\143\230\151\182{2}\229\136\134\233\146\159"), Day, Hour, Minute)
      elseif Hour >= 1 then
        RemainTimeStr = UE.FTextFormat(NSLOCTEXT("MonthCardItem", "HourMinuteStr", "{0}\229\176\143\230\151\182{1}\229\136\134\233\146\159"), Hour, Minute)
      else
        RemainTimeStr = UE.FTextFormat(NSLOCTEXT("MonthCardItem", "MinuteStr", "{0}\229\136\134\233\146\159"), Minute)
        self.RGStateController_TimeLimit:ChangeStatus("LessThan")
      end
      self.Txt_RemainTime:SetText(RemainTimeStr)
      self.RGStateController_Have:ChangeStatus("Have")
    else
      UpdateVisibility(self.Overlay_RemainTime, false)
      self.Txt_Buy:SetText(self.BuyText)
      self.RGStateController_Have:ChangeStatus("UnHave")
    end
  else
    UpdateVisibility(self.Overlay_RemainTime, false)
    self.Txt_Buy:SetText(self.BuyText)
    self.RGStateController_Have:ChangeStatus("UnHave")
  end
end
function WBP_MonthCardItem:BindOnBuyButtonClicked(...)
  TopupHandler:RequestBuyMisdasProduct(self.ProductId, 1)
end
function WBP_MonthCardItem:GetToolTipWidget()
  return self.WBP_Item:GetToolTipWidget()
end
function WBP_MonthCardItem:Hide(...)
  UpdateVisibility(self, false)
end
function WBP_MonthCardItem:Destruct(...)
  self.Btn_Buy.OnClicked:Remove(self, self.BindOnBuyButtonClicked)
end
return WBP_MonthCardItem
