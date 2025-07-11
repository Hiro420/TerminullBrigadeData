local SprayItem = UnLua.Class()
local RedDotData = require("Modules.RedDot.RedDotData")
local SlotDragAvailable = function(self, SlotItem, PointerEvent)
  if not self.DataObj.bIsUnlocked then
    return false
  end
  EventSystem.Invoke(EventDef.Communication.OnRouletteStartDrag, self)
  return true
end
local EndDrag = function(self)
  EventSystem.Invoke(EventDef.Communication.OnRouletteEndDrag, self)
end
function SprayItem:Construct()
  EventSystem.AddListenerNew(EventDef.Communication.OnCommSelectChanged, self, self.BindOnCommSelectChanged)
end
function SprayItem:Destruct()
  EventSystem.RemoveListenerNew(EventDef.Communication.OnCommSelectChanged, self, self.BindOnCommSelectChanged)
end
function SprayItem:OnListItemObjectSet(ListItemObj)
  self.DataObj = ListItemObj
  local DataObjTemp = ListItemObj
  if not DataObjTemp then
    return
  end
  self.WBP_Item:InitItem(DataObjTemp.CommId)
  self.Img_DragIcon:SetBrush(self.WBP_Item.Img_Icon.Brush)
  UpdateVisibility(self.Canvas_Lock, not DataObjTemp.bIsUnlocked)
  self.WBP_Item:SetLock(not DataObjTemp.bIsUnlocked)
  UpdateVisibility(self.Canvas_Equip, DataObjTemp.bIsEquiped)
  UpdateVisibility(self.URGImageSelect, self.DataObj.bIsSelected)
  self.WBP_Item:SetSel(self.DataObj.bIsSelected)
  self.WBP_Item:SetTargetExpirationTime(self.DataObj.expireAt)
  self.WBP_DragDropItem:SetDragAvailableCallback(self, self, self.Img_DragIcon, SlotDragAvailable, EndDrag)
  self.WBP_RedDotView:ChangeRedDotIdByTag(DataObjTemp.CommId)
end
function SprayItem:BP_OnEntryReleased()
  self.WBP_RedDotView:ChangeRedDotId("")
  self.DataObj = nil
  self.WBP_Item:SetSel(false)
end
function SprayItem:OnMouseEnter()
  self.WBP_Item.MainBtn:OnSlateHandleHovered()
end
function SprayItem:OnMouseLeave()
  self.WBP_Item.MainBtn:OnSlateHandleUnHovered()
end
function SprayItem:OnMouseButtonDown(MyGeometry, MouseEvent)
  if not UE.RGUtil.IsUObjectValid(self.DataObj) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  local CommunicationTb = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  if not CommunicationTb or not CommunicationTb[self.DataObj.CommId] then
    return
  end
  self.WBP_RedDotView:SetNum(0)
  self.DataObj.ParentView:SelectSpray(self.DataObj.CommId)
  return UE.UWidgetBlueprintLibrary.Handled()
end
function SprayItem:BindOnCommSelectChanged(CommId)
  if not self.DataObj then
    return
  end
  self.DataObj.bIsSelected = self.DataObj.CommId == CommId
  self.WBP_Item:SetSel(self.DataObj.bIsSelected)
  UpdateVisibility(self.Img_Selected, self.DataObj.bIsSelected)
end
return SprayItem
