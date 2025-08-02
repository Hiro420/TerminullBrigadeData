local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local TopupHandler = require("Protocol.Topup.TopupHandler")
local WBP_MidasPayPanel = Class(ViewBase)

function WBP_MidasPayPanel:BindClickHandler()
end

function WBP_MidasPayPanel:UnBindClickHandler()
end

function WBP_MidasPayPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_MidasPayPanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_MidasPayPanel:OnShow(URL)
  self.IsNeedRequestPaymentCurrency = true
  self.RGWebBrowser:LoadURL(URL)
  self.RGWebBrowser:RefreshInputMethod()
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.ListenForEscInputAction)
  self:SetEnhancedInputActionBlocking(true)
end

function WBP_MidasPayPanel:ListenForEscInputAction()
  UIMgr:Hide(ViewID.UI_MidasPayPanel)
end

function WBP_MidasPayPanel:OnHide()
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.ListenForEscInputAction)
  self:SetEnhancedInputActionBlocking(false)
  if self.IsNeedRequestPaymentCurrency then
    self.IsNeedRequestPaymentCurrency = false
    TopupHandler:RequestPaymentCurrencyAfterPay()
  end
end

function WBP_MidasPayPanel:Destruct()
  self:OnHide()
end

return WBP_MidasPayPanel
