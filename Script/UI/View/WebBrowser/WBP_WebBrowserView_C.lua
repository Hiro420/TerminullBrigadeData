local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_WebBrowserView_C = Class(ViewBase)

function WBP_WebBrowserView_C:BindClickHandler()
end

function WBP_WebBrowserView_C:UnBindClickHandler()
end

function WBP_WebBrowserView_C:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_WebBrowserView_C:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_WebBrowserView_C:OnShow(URL)
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.ListenForEscInputAction)
  self.RGWebBrowser:LoadURL(URL)
  self.RGWebBrowser:RefreshInputMethod()
  self:SetUserFocus(self:GetOwningPlayer())
  self:ClearOnCloseEvent()
end

function WBP_WebBrowserView_C:OnHide()
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.ListenForEscInputAction)
  if self.OnCloseCallback and self.OnCloseTarget then
    self.OnCloseCallback()
  end
end

function WBP_WebBrowserView_C:ListenForEscInputAction()
  UIMgr:Hide(ViewID.UI_WebBrowserView, true)
end

function WBP_WebBrowserView_C:BindOnClose(Target, Callback)
  if Target then
    self.OnCloseCallback = Callback
    self.OnCloseTarget = Target
  end
end

function WBP_WebBrowserView_C:ClearOnCloseEvent()
  self.OnCloseCallback = nil
  self.OnCloseTarget = nil
end

return WBP_WebBrowserView_C
