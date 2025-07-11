local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local PandoraData = require("Modules.Pandora.PandoraData")
local WBP_PandoraRootPanel = Class(ViewBase)
function WBP_PandoraRootPanel:BindClickHandler()
end
function WBP_PandoraRootPanel:UnBindClickHandler()
end
function WBP_PandoraRootPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_PandoraRootPanel:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_PandoraRootPanel:OnRollback()
  self:SetEnhancedInputActionBlocking(true)
  self:SetEnhancedInputActionPriority(2)
end
function WBP_PandoraRootPanel:OnHideByOther()
  self:SetEnhancedInputActionBlocking(false)
  self:SetEnhancedInputActionPriority(0)
end
function WBP_PandoraRootPanel:OnShow(PandoraWidget, AppId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.AppId = AppId
  local PandoraWidgetSlot = self.PandoraWidgetPanel:AddChild(PandoraWidget)
  if PandoraWidgetSlot then
    local Anchors = UE.FAnchors()
    Anchors.Minimum = UE.FVector2D(0, 0)
    Anchors.Maximum = UE.FVector2D(1.0, 1.0)
    PandoraWidgetSlot:SetAnchors(Anchors)
    local Offsets = UE.FMargin()
    PandoraWidgetSlot:SetOffsets(Offsets)
  end
  if PandoraWidget and PandoraWidget:IsValid() then
    self.CtrlWidget = PandoraWidget:GetCtrlWidget()
    self.CtrlWidget:SetUserFocus(self:GetOwningPlayer())
    self.CtrlWidget:ForceVolatile(true)
  end
  self.OpenTimestamp = UE.UKismetSystemLibrary.GetGameTimeInSeconds(self)
  print("Current Timestamp:", self.OpenTimestamp)
  self:SetEnhancedInputActionBlocking(true)
  self:SetEnhancedInputActionPriority(0)
end
function WBP_PandoraRootPanel:RemovePandoraWidget()
  self.PandoraWidgetPanel:ClearChildren()
end
function WBP_PandoraRootPanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if self.timer_set_focus then
    GlobalTimer.DeleteDelayCallback(self.timer_set_focus)
    self.timer_set_focus = nil
  end
  self:RemovePandoraWidget()
  self:InvalidDisruptiveUI()
  self.OpenTimestamp = nil
  EventSystem.Invoke(EventDef.Pandora.pandoraOnCloseRootPanel, self.AppId)
  self:SetEnhancedInputActionBlocking(false)
end
function WBP_PandoraRootPanel:OnBackShow()
  self.timer_set_focus = GlobalTimer.DelayCallback(0.3, function()
    self.timer_set_focus = nil
    if self.CtrlWidget then
      self.CtrlWidget:SetUserFocus(self:GetOwningPlayer())
    end
  end)
end
function WBP_PandoraRootPanel:InvalidDisruptiveUI()
  if self.AppId and self.OpenTimestamp then
    if not PandoraData:IsDisruptiveUI(self.AppId) then
      return
    end
    if UE.UKismetSystemLibrary.GetGameTimeInSeconds(self) - self.OpenTimestamp <= 0.3 then
      print("WBP_PandoraRootPanel \230\139\141\232\132\184\230\151\160\230\149\136\239\188\140\229\176\134\229\156\168\228\184\139\230\172\161\229\144\136\233\128\130\230\151\182\230\156\186\233\135\141\230\150\176\230\139\141\232\132\184", self.AppId)
    end
  end
end
return WBP_PandoraRootPanel
