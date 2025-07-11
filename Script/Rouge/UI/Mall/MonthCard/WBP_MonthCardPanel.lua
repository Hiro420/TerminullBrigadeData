local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local UIConsoleUtil = require("Framework.UIMgr.UIConsoleUtil")
local TopupData = require("Modules.Topup.TopupData")
local MonthCardData = require("Modules.MonthCard.MonthCardData")
local TopupHandler = require("Protocol.Topup.TopupHandler")
local WBP_MonthCardPanel = Class(ViewBase)
function WBP_MonthCardPanel:BindClickHandler()
  self.Btn_MonthCardPack.OnClicked:Add(self, self.BindOnMonthCardPackButtonClicked)
  self.Btn_MonthCardPack.OnHovered:Add(self, self.BindOnMonthCardPackButtonHovered)
  self.Btn_MonthCardPack.OnUnhovered:Add(self, self.BindOnMonthCardPackButtonUnhovered)
end
function WBP_MonthCardPanel:UnBindClickHandler()
  self.Btn_MonthCardPack.OnClicked:Remove(self, self.BindOnMonthCardPackButtonClicked)
  self.Btn_MonthCardPack.OnHovered:Remove(self, self.BindOnMonthCardPackButtonHovered)
  self.Btn_MonthCardPack.OnUnhovered:Remove(self, self.BindOnMonthCardPackButtonUnhovered)
end
function WBP_MonthCardPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_MonthCardPanel:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_MonthCardPanel:OnShow(...)
  self:PlayAnimationForward(self.Ani_in)
  self:RefreshMonthCardItem()
  self:RefreshMonthCardDescList()
  EventSystem.AddListenerNew(EventDef.MonthCard.OnUpdateRolesMonthCardInfo, self, self.BindOnUpdateRolesMonthCardInfo)
  UIConsoleUtil.UpdateConsoleStoreUIVisible(true)
  local RegionId = GetRegionId()
  if RegionId and "" ~= RegionId then
    self.RGStateController_Region:ChangeStatus(RegionId)
  else
    self.RGStateController_Region:ChangeStatus("default")
  end
end
function WBP_MonthCardPanel:RefreshMonthCardItem(...)
  local AllProductIdList = MonthCardData:GetMonthCardProductIdList()
  table.sort(AllProductIdList, function(a, b)
    return a < b
  end)
  local Index = 1
  for i, SingleProductId in ipairs(AllProductIdList) do
    local Item = GetOrCreateItem(self.WrapBox_MonthCard, Index, self.WBP_MonthCardItem:StaticClass())
    Item:Show(SingleProductId)
    Index = Index + 1
  end
  HideOtherItem(self.WrapBox_MonthCard, Index)
  local MonthCardPackId = MonthCardData:GetMonthCardPackId()
  local Result, PaymentRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMall, MonthCardPackId)
  if Result then
    local ResourceId = tonumber(PaymentRowInfo.MidasGoodsID)
    local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
    if Result and self.Txt_MonthPackName then
      self.Txt_MonthPackName:SetText(ResourceRowInfo.Name)
    end
  end
  local MonthCardPackPriceStr = TopupData:GetProductDisplayPrice(MonthCardPackId)
  self.Txt_MonthPackCurrentPrice:SetText(MonthCardPackPriceStr)
end
function WBP_MonthCardPanel:RefreshMonthCardDescList(...)
  local AllProductIdList = MonthCardData:GetMonthCardProductIdList()
  local MonthCardInfo = MonthCardData:GetMonthCardInfoByRoleId(DataMgr.GetUserId())
  if MonthCardInfo then
    table.sort(AllProductIdList, function(a, b)
      local AResult, PaymentRowInfoA = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMall, a)
      local BResult, PaymentRowInfoB = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMall, b)
      local ARResult, MonthCardRowInfoA = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMonthCard, tonumber(PaymentRowInfoA.MidasGoodsID))
      local BRResult, MonthCardRowInfoB = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMonthCard, tonumber(PaymentRowInfoB.MidasGoodsID))
      return MonthCardInfo[tostring(MonthCardRowInfoA.MonthCardID)] and not MonthCardInfo[tostring(MonthCardRowInfoB.MonthCardID)]
    end)
  end
  local Index = 1
  for i, SingleProductId in ipairs(AllProductIdList) do
    local Item = GetOrCreateItem(self.Scroll_MonthCardList, Index, self.WBP_MonthCardDescItem:StaticClass())
    Item:Show(SingleProductId)
    Index = Index + 1
  end
  HideOtherItem(self.Scroll_MonthCardList, Index)
end
function WBP_MonthCardPanel:BindOnMonthCardPackButtonClicked(...)
  local MonthCardPackId = MonthCardData:GetMonthCardPackId()
  print("WBP_MonthCardPanel:BindOnMonthCardPackButtonClicked MonthCardPackId:", MonthCardPackId)
  if 0 == MonthCardPackId then
    return
  end
  TopupHandler:RequestBuyMisdasProduct(MonthCardPackId, 1)
end
function WBP_MonthCardPanel:BindOnMonthCardPackButtonHovered(...)
end
function WBP_MonthCardPanel:BindOnMonthCardPackButtonUnhovered(...)
end
function WBP_MonthCardPanel:BindOnUpdateRolesMonthCardInfo(RoleIdList)
  if not table.Contain(RoleIdList, DataMgr.GetUserId()) then
    return
  end
  self:RefreshMonthCardItem()
  self:RefreshMonthCardDescList()
end
function WBP_MonthCardPanel:OnHide()
  EventSystem.RemoveListenerNew(EventDef.MonthCard.OnUpdateRolesMonthCardInfo, self, self.BindOnUpdateRolesMonthCardInfo)
  UIConsoleUtil.UpdateConsoleStoreUIVisible(false)
end
return WBP_MonthCardPanel
