local WBP_MonthCardDescItem = UnLua.Class()
local MonthCardData = require("Modules.MonthCard.MonthCardData")

function WBP_MonthCardDescItem:Show(ProductId)
  self.ProductId = ProductId
  UpdateVisibility(self, true)
  local Result, PaymentRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMall, ProductId)
  if not Result then
    print("WBP_MonthCardDescItem:Show TBPaymentMall not found", ProductId)
    return
  end
  local ResourceId = tonumber(PaymentRowInfo.MidasGoodsID)
  local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    print("WBP_MonthCardDescItem:Show ResourceRowInfo not found", ResourceId)
    return
  end
  self.Txt_Name:SetText(ResourceRowInfo.Name)
  self.Txt_Desc:SetText(ResourceRowInfo.Desc)
  SetImageBrushByPath(self.Img_Icon, ResourceRowInfo.Icon, self.IconSize)
  local Result, MonthCardRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMonthCard, ResourceId)
  if not Result then
    print("WBP_MonthCardDescItem:Show TBMonthCard not found", ResourceId)
    return
  end
  local IsActive = not MonthCardData:IsMonthCardExpired(DataMgr.GetUserId(), MonthCardRowInfo.MonthCardID)
  if IsActive then
    self.RGStateController_Status:ChangeStatus("Active")
  else
    self.RGStateController_Status:ChangeStatus("InActive")
  end
end

function WBP_MonthCardDescItem:Hide(...)
  UpdateVisibility(self, false)
end

return WBP_MonthCardDescItem
