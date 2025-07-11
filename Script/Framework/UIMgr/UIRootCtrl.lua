local ViewBase = require("Framework.UIMgr.ViewBase")
local UWidgetLayoutLibrary = UE.UWidgetLayoutLibrary
local UGlobalTimer = UE.URGGlobalTimer
local FVector2D = UE.FVector2D
local UIUtil = require("Framework.UIMgr.UIUtil")
local UILayer = require("Framework.UIMgr.UILayer")
local UnLua = _G.UnLua
local FuncUtil = require("Framework.Utils.FuncUtil")
local UIRootCtrl = Class(ViewBase)
function UIRootCtrl:OnInit()
  self._layer2ObjectMap = {}
  for _, layer in pairs(UILayer) do
    if layer == UILayer.Game then
      self._layer2ObjectMap[layer] = self.Game
    elseif layer == UILayer.Window then
      self._layer2ObjectMap[layer] = self.Window
    elseif layer == UILayer.Menu then
      self._layer2ObjectMap[layer] = self.Menu
    elseif layer == UILayer.HighWindow then
      self._layer2ObjectMap[layer] = self.HighWindow
    elseif layer == UILayer.Modal then
      self._layer2ObjectMap[layer] = self.Modal
    elseif layer == UILayer.Guide then
      self._layer2ObjectMap[layer] = self.Guide
    elseif layer == UILayer.KoreaAge then
      self._layer2ObjectMap[layer] = self.KoreaAge
    end
  end
  self._lastUIEnableValue = true
end
function UIRootCtrl:GetLayerObject(layer)
  if self._layer2ObjectMap == nil then
    return nil
  end
  return self._layer2ObjectMap[layer]
end
function UIRootCtrl:SetUIActive(value)
  if self.contain == nil then
    UnLua.UnLua.LogError("UIRootCtrl:SetUIActive contain is nil")
    return
  end
  UIUtil.SetVisibility(self.contain, value)
end
function UIRootCtrl:SetUIEnable(value)
  if self._lastUIEnableValue == value then
    return
  end
  self._lastUIEnableValue = value
  local visible = not value
  UIUtil.SetVisibilityNoHidden(self.enableMask, visible, false)
end
function UIRootCtrl:ShowAll()
  print("UIRootCtrl:ShowAll()")
  for _, layerObject in pairs(self._layer2ObjectMap) do
    UIUtil.SetVisibility(layerObject, true)
  end
end
function UIRootCtrl:HideAll()
  print("UIRootCtrl:HideAll()")
  for _, layerObject in pairs(self._layer2ObjectMap) do
    UIUtil.SetVisibility(layerObject, false)
  end
  local topestLayerObjectReconnect = self:GetLayerObject(UILayer.ReconnectWindow)
  if nil ~= topestLayerObjectReconnect then
    UIUtil.SetVisibility(topestLayerObjectReconnect, true)
  end
end
function UIRootCtrl:ShowLayerOnly(layer)
  self:HideAll()
  print("UIRootCtrl:ShowLayerOnly() - layer:", layer)
  local layerObject = self:GetLayerObject(layer)
  if nil ~= layerObject then
    UIUtil.SetVisibility(layerObject, true)
  end
  local topestLayerObject = self:GetLayerObject(UILayer.Topest)
  if nil ~= topestLayerObject then
    UIUtil.SetVisibility(topestLayerObject, true)
  end
  local topestLayerObjectReconnect = self:GetLayerObject(UILayer.ReconnectWindow)
  if nil ~= topestLayerObjectReconnect then
    UIUtil.SetVisibility(topestLayerObjectReconnect, true)
  end
end
function UIRootCtrl:UIModelOnShow()
  self:HideLayer(UILayer.Low)
  self:HideLayer(UILayer.Dock)
end
function UIRootCtrl:UIModelOnHide()
  UIMgr.UIRoot:ShowLayer(UILayer.Low)
  UIMgr.UIRoot:ShowLayer(UILayer.Dock)
end
function UIRootCtrl:DieStateOnShow()
  self:HideLayer(UILayer.Low)
end
function UIRootCtrl:DieStateOnHide()
  UIMgr.UIRoot:ShowLayer(UILayer.Low)
end
function UIRootCtrl:HideLayer(layer)
  print("UIRootCtrl:HideLayer() - layer:", layer)
  local layerObject = self:GetLayerObject(layer)
  if nil ~= layerObject then
    UIUtil.SetVisibility(layerObject, false)
  end
end
function UIRootCtrl:ShowLayer(layer)
  print("UIRootCtrl:ShowLayer() - layer:", layer)
  local layerObject = self:GetLayerObject(layer)
  if nil ~= layerObject then
    UIUtil.SetVisibility(layerObject, true)
  end
end
function UIRootCtrl:ShowLayerOnlyWithTips(layer)
  self:HideAll()
  print("UIRootCtrl:ShowLayerOnlyWithTips() - layer:", layer)
  local layerObject = self:GetLayerObject(layer)
  if nil ~= layerObject then
    UIUtil.SetVisibility(layerObject, true)
  end
  local errorTipsLayerObject = self:GetLayerObject(UILayer.ErrorTips)
  if nil ~= errorTipsLayerObject then
    UIUtil.SetVisibility(errorTipsLayerObject, true)
  end
  local tipsLayerObject = self:GetLayerObject(UILayer.Tips)
  if nil ~= tipsLayerObject then
    UIUtil.SetVisibility(tipsLayerObject, true)
  end
  local topestLayerObject = self:GetLayerObject(UILayer.Topest)
  if nil ~= topestLayerObject then
    UIUtil.SetVisibility(topestLayerObject, true)
  end
  local topestLayerObjectReconnect = self:GetLayerObject(UILayer.ReconnectWindow)
  if nil ~= topestLayerObjectReconnect then
    UIUtil.SetVisibility(topestLayerObjectReconnect, true)
  end
end
function UIRootCtrl:ShowLayerCustom(layerList, bHideOther)
  if nil == bHideOther or true == bHideOther then
    self:HideAll()
  end
  print("UIRootCtrl:ShowLayerCustom() - layerList:", table.concat(layerList, ","), "bHideOther", bHideOther)
  for _, layer in pairs(layerList) do
    local layerObject = self:GetLayerObject(layer)
    if nil ~= layerObject then
      UIUtil.SetVisibility(layerObject, true)
    end
  end
end
function UIRootCtrl:RootAddChild(object, layer)
  if nil == object then
    UnLua.LogError(" UIRootCtrl:RootAddChild object is nil")
    return
  end
  local layerObject = self:GetLayerObject(layer)
  if nil == layerObject then
    UnLua.LogError("UIRootCtrl:RootAddChild layerObject is nil, layer:", layer)
    return
  end
  layerObject:AddChild(object)
  self:SetUIRectOffset(object)
end
function UIRootCtrl:SetUIRectOffset(object)
  local slotCanvas = UWidgetLayoutLibrary.SlotAsCanvasSlot(object)
  if nil ~= slotCanvas then
    local anchor = slotCanvas:GetAnchors()
    anchor.Minimum = FVector2D(0, 0)
    anchor.Maximum = FVector2D(1, 1)
    slotCanvas:SetAnchors(anchor)
    local offset = slotCanvas:GetOffsets()
    offset.Left = 0
    offset.Top = 0
    offset.Right = 0
    offset.Bottom = 0
    slotCanvas:SetOffsets(offset)
  end
end
function UIRootCtrl:RootRemoveChild(object, layer)
  if nil == object then
    UnLua.LogError("object is nil")
    return
  end
  local layerObject = self:GetLayerObject(layer)
  if nil == layerObject then
    UnLua.LogError("layerObject is nil, layer:", layer)
    return
  end
  local bSuccess = layerObject:RemoveChild(object)
  if not bSuccess then
    if UE.RGUtil.IsUObjectValid(object) then
      UnLua.LogWarn("UIRootCtrl:RootRemoveChild Failed: " .. object:GetName())
    end
    for _, layerObj in pairs(self._layer2ObjectMap) do
      if layerObj ~= layerObject and layerObj:RemoveChild(object) then
        return
      end
    end
  end
end
function UIRootCtrl:Construct()
  print("=====UIRootCtrl:Construct=====")
  EventSystem.AddListenerNew(EventDef.KoreaCompliance.ShowAgePic, self, self.BindOnShowAgePic)
end
function UIRootCtrl:BindOnShowAgePic()
  UpdateVisibility(self.KoreaAge, true, false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      UpdateVisibility(self.KoreaAge, false, false)
    end
  }, 3, false)
end
function UIRootCtrl:Destruct()
  if self.GetName then
    print("=====UIRootCtrl:Destruct ", self:GetName())
  else
    print("=====UIRootCtrl:Destruct nil.")
  end
  xpcall(function()
    UIMgr:Clear()
  end, FuncUtil.ErrPrint)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  EventSystem.RemoveListenerNew(EventDef.KoreaCompliance.ShowAgePic, self, self.BindOnShowAgePic)
end
return UIRootCtrl
