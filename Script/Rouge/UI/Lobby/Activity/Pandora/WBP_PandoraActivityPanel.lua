local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local pandoramodule = require("Modules.Pandora.PandoraModule")
local PandoraHandler = require("Protocol.Pandora.PandoraHandler")
local WBP_PandoraActivityPanel = Class(ViewBase)

function WBP_PandoraActivityPanel:BindClickHandler()
end

function WBP_PandoraActivityPanel:UnBindClickHandler()
end

function WBP_PandoraActivityPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_PandoraActivityPanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_PandoraActivityPanel:OnShow(AppId)
  self.AppId = AppId
  self.RootPanel:ClearChildren()
  EventSystem.AddListener(self, EventDef.Pandora.pandoraWidgetCreated, self.OnWidgetCreated)
  EventSystem.AddListener(self, EventDef.Activity.OnPandoraActivityRefresh, self.OnPandoraActivityRefresh)
end

function WBP_PandoraActivityPanel:OnWidgetCreated(Widget, AppId, appPage)
  print("WBP_PandoraActivityPanel:OnWidgetCreated")
  if AppId == self.AppId then
    UpdateVisibility(Widget, true)
    local PandoraWidgetSlot = self.RootPanel:AddChild(Widget)
    if PandoraWidgetSlot then
      local Anchors = UE.FAnchors()
      Anchors.Minimum = UE.FVector2D(0, 0)
      Anchors.Maximum = UE.FVector2D(1.0, 1.0)
      PandoraWidgetSlot:SetAnchors(Anchors)
      local Offsets = UE.FMargin()
      PandoraWidgetSlot:SetOffsets(Offsets)
      if Widget.GetCtrlWidget and Widget:GetCtrlWidget() then
        Widget:GetCtrlWidget():SetUserFocus(self:GetOwningPlayer())
        Widget:GetCtrlWidget():ForceVolatile(true)
      end
    end
  end
end

function WBP_PandoraActivityPanel:OnPandoraActivityRefresh(AppId)
end

function WBP_PandoraActivityPanel:OnHide()
  self:SetEnhancedInputActionBlocking(false)
  self.RootPanel:ClearChildren()
  EventSystem.RemoveListener(EventDef.Pandora.pandoraWidgetCreated, self.OnWidgetCreated, self)
end

function WBP_PandoraActivityPanel:OnMouseLeave(MyGeometry, MouseEvent)
  if pandoramodule.TipsWidget then
    UpdateVisibility(pandoramodule.TipsWidget)
  end
  PandoraHandler.SendGameEventToPandora(PandoraGameEventType.PandoraActivityPanel_OnMouseLeave, self.AppId)
end

function WBP_PandoraActivityPanel:OnMouseEnter(MyGeometry, MouseEvent)
  print("OnMouseEnter")
  PandoraHandler.SendGameEventToPandora(PandoraGameEventType.PandoraActivityPanel_OnMouseEnter, self.AppId)
end

return WBP_PandoraActivityPanel
