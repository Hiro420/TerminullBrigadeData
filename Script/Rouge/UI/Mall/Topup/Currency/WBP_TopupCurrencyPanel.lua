local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local UIConsoleUtil = require("Framework.UIMgr.UIConsoleUtil")
local TopupData = require("Modules.Topup.TopupData")
local WBP_TopupCurrencyPanel = Class(ViewBase)
function WBP_TopupCurrencyPanel:BindClickHandler()
end
function WBP_TopupCurrencyPanel:UnBindClickHandler()
end
function WBP_TopupCurrencyPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_TopupCurrencyPanel:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_TopupCurrencyPanel:OnShow(...)
  self:RefreshCurrencyList()
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateTopupProductInfo, self, self.BindOnTouupCurrencyChanged)
  UIConsoleUtil.UpdateConsoleStoreUIVisible(true)
end
function WBP_TopupCurrencyPanel:BindOnTouupCurrencyChanged(...)
  self:RefreshCurrencyList()
end
function WBP_TopupCurrencyPanel:RefreshCurrencyList()
  local ProductIdList = TopupData:GetProductIdListByShelfId(self.ShelfId)
  local Index = 1
  for i, SingleProductId in ipairs(ProductIdList) do
    local Item = GetOrCreateItem(self.WrapBox_CurrencyList, Index, self.WBP_TopupCurrencyItem:StaticClass())
    Item:Show(SingleProductId, Index)
    Index = Index + 1
  end
  HideOtherItem(self.WrapBox_CurrencyList, Index, true)
end
function WBP_TopupCurrencyPanel:OnHide()
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateTopupProductInfo, self, self.BindOnTouupCurrencyChanged)
  UIConsoleUtil.UpdateConsoleStoreUIVisible(false)
end
return WBP_TopupCurrencyPanel
