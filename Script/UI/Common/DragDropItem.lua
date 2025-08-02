local UnLua = _G.UnLua
local DragDropItem = UnLua.Class()

function DragDropItem:Construct()
  self.Overridden.Construct(self)
  self.DropAvailable = nil
  self.DragOverAvailable = nil
  self.DragLeaveAvailable = nil
  self.DragAvailable = nil
  self.NormalColor = UE.FLinearColor(1, 1, 1, 1)
  self.selfDragObj = nil
  self.beDragObj = nil
  self.endDrag = nil
  self.selfDropObj = nil
  self.DragDropDataObj = nil
end

function DragDropItem:Destruct()
  self.DropAvailable = nil
  self.DragOverAvailable = nil
  self.DragLeaveAvailable = nil
  self.DragAvailable = nil
  self.NormalColor = UE.FLinearColor(1, 1, 1, 1)
  self.selfDragObj = nil
  self.beDragObj = nil
  self.endDrag = nil
  self.selfDropObj = nil
  self.DragDropDataObj = nil
  self.Overridden.Destruct(self)
end

function DragDropItem:BindDragDropData(dragDropDataObj)
  self.DragDropDataObj = dragDropDataObj
  local canvasSlotSelf = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self)
  if self.DragDropDataObj then
    local canvasSlotDragObj
    canvasSlotDragObj = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.DragDropDataObj)
    if not canvasSlotDragObj or canvasSlotSelf then
    end
    if self.DragDropDataObj.containerImg then
      self.NormalColor = UE.FLinearColor(1, 1, 1, 1)
    end
  else
    canvasSlotSelf:SetAnchors(UE.FAnchors(0))
    canvasSlotSelf:SetSize(UE.FVector2D(100, 100))
  end
end

local DragEnable = function(dragDropDataObj)
  if not dragDropDataObj then
    return false
  end
  return dragDropDataObj.bDragEnable
end

function DragDropItem:OnDragCancelled(PointerEvent, Operation)
  if not DragEnable(self.DragDropDataObj) then
    return
  end
  if self.endDrag then
    self.endDrag(self.selfDragObj, PointerEvent, Operation)
  end
end

function DragDropItem:OnDragDetected(MyGeometry, PointerEvent, Operation)
  if not DragEnable(self.DragDropDataObj) then
    return
  end
  if self.DragAvailable and not self.DragAvailable(self.selfDragObj, self, PointerEvent) then
    self:OnDragCancelled(self.selfDragObj, PointerEvent)
    return
  end
  local dragObj = self.beDragObj or self:GetParent()
  if not self.DragDropDataObj then
    self:BindDragDropData()
  end
  self.dragDropOperation = UE.UWidgetBlueprintLibrary.CreateDragDropOperation()
  self.dragDropOperation.DefaultDragVisual = dragObj
  self.dragDropOperation.Payload = self.DragDropDataObj or nil
  self.dragDropOperation.Tag = self.DragDropDataObj ~= nil and self.DragDropDataObj.Group or ""
  local offset = UE.FVector2D(0, 0)
  local pivot = UE.EDragPivot.CenterCenter
  self.dragDropOperation.Offset = offset
  self.dragDropOperation.Pivot = pivot
  return self.dragDropOperation
end

function DragDropItem:OnMouseButtonDown(myMouseButtonDown, mouseEvent)
  local reply = UE.FEventReply(false)
  if not DragEnable(self.DragDropDataObj) then
    return reply
  end
  reply = UE.UWidgetBlueprintLibrary.DetectDragIfPressed(mouseEvent, self, self.FKeyVar)
  if self.selfDragObj and UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(mouseEvent) == self.FKeyVar then
    self.selfDragObj:OnMouseButtonDown(myMouseButtonDown, mouseEvent)
  end
  return reply
end

function DragDropItem:SetDragAvailableCallback(selfDragObj, selfDragDropDataObj, beDragObj, dragAvailable, endDrag)
  if not DragEnable(self.DragDropDataObj) and not DragEnable(selfDragDropDataObj) then
    return
  end
  self.DragAvailable = dragAvailable
  self.selfDragObj = selfDragObj
  self.beDragObj = beDragObj
  self.endDrag = endDrag
  self:BindDragDropData(selfDragDropDataObj)
end

local DropEnable = function(dragDropDataObj)
  if not dragDropDataObj then
    return false
  end
  return dragDropDataObj.bDropEnable
end

function DragDropItem:OnDrop(MyGeometry, PointerEvent, Operation)
  if not DropEnable(self.DragDropDataObj) then
    return
  end
  if self.DragDropDataObj.containerImg then
    self.DragDropDataObj.containerImg:SetColorAndOpacity(self.NormalColor)
  end
  if self.DropAvailable then
    self.DropAvailable(self.selfDropObj, self, Operation.Payload, PointerEvent)
  end
end

function DragDropItem:SetDropAvailableCallback(selfDropObj, selfDragDropDataObj, DropAvailable, DragOverAvailable, DragLeaveAvailable)
  if not DropEnable(self.DragDropDataObj) and not DropEnable(selfDragDropDataObj) then
    return
  end
  self.DropAvailable = DropAvailable
  self.DragOverAvailable = DragOverAvailable
  self.DragLeaveAvailable = DragLeaveAvailable
  self.selfDropObj = selfDropObj
  self:BindDragDropData(selfDragDropDataObj)
end

function DragDropItem:OnDragEnter(PointerEvent, Operation)
  if not DropEnable(self.DragDropDataObj) then
    return
  end
  if self.DragDropDataObj.containerImg then
    self.DragDropDataObj.containerImg:SetColorAndOpacity(self.DragDropDataObj.HighLightColor)
  end
end

function DragDropItem:OnDragLeave(PointerEvent, Operation)
  if not DropEnable(self.DragDropDataObj) then
    return
  end
  if self.DragDropDataObj.containerImg then
    self.DragDropDataObj.containerImg:SetColorAndOpacity(self.NormalColor)
  end
  if self.DragLeaveAvailable then
    self.DragLeaveAvailable(self.selfDropObj, self, Operation, PointerEvent)
  end
end

function DragDropItem:OnDragOver(PointerEvent, Operation)
  if self.DragOverAvailable then
    self.DragOverAvailable(self.selfDropObj, self, Operation, PointerEvent)
  end
end

return DragDropItem
