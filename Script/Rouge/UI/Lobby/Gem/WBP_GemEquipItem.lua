local WBP_GemEquipItem = UnLua.Class()
local GemData = require("Modules.Gem.GemData")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
function WBP_GemEquipItem:Show(GemId, GemPackageInfo)
  self.GemId = GemId
  self.GemPackageInfo = GemPackageInfo
  UpdateVisibility(self.Img_Icon, 0 ~= GemId and "0" ~= GemId)
  if 0 == GemId or "0" == GemId then
    if self.HoverWidget and self.HoverWidget:IsValid() then
      self.HoverWidget:Hide()
      EventSystem.Invoke(EventDef.Gem.OnUpdateGemItemHoverStatus, false, self.GemId)
    end
  else
    if self.IsHoverItem then
      self:OnMouseEnter()
    end
    local ResourceId
    if self.GemPackageInfo then
      ResourceId = self.GemPackageInfo.resourceID
    else
      ResourceId = GemData:GetGemResourceIdByUId(GemId)
    end
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
    if Result then
      SetImageBrushByPath(self.Img_Icon, RowInfo.Icon)
    end
  end
end
function WBP_GemEquipItem:ChangeGemItemCanDragStatus(CanDrag)
  self.CanDrag = CanDrag
end
function WBP_GemEquipItem:OnDragDetected(MyGeometry, PointerEvent)
  if not self:CanDragItem() then
    return nil
  end
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  local DragOperation = PuzzleViewModel:GetGemDragOperation(self.GemId)
  EventSystem.Invoke(EventDef.Gem.OnGemDrag, self.GemId)
  return DragOperation
end
function WBP_GemEquipItem:OnDragCancelled(MyGeometry, PointerEvent)
  print("GemDragCancelled")
  EventSystem.Invoke(EventDef.Gem.OnGemDragCancel)
end
function WBP_GemEquipItem:CanDragItem(...)
  if not self.CanDrag then
    return false
  end
  if 0 == self.GemId or self.GemId == "0" then
    return false
  end
  return true
end
function WBP_GemEquipItem:OnMouseButtonDown(MyGeometry, MouseEvent)
  if not self:CanDragItem() then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  return UE.UWidgetBlueprintLibrary.DetectDragIfPressed(MouseEvent, self, self.LeftMouseKey)
end
function WBP_GemEquipItem:OnMouseEnter(...)
  print("WBP_GemEquipItem:OnMouseEnter")
  self.IsHoverItem = true
  if 0 == self.GemId or self.GemId == "0" then
    return
  end
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  self.HoverWidget = PuzzleViewModel:GetGemHoverWidget(nil, self)
  self.HoverWidget:Show(self.GemId, self.GemPackageInfo)
  if self.CanDrag then
    self.HoverWidget:ListenInputEvent(true)
  else
    self.HoverWidget:HideOperateTip()
  end
  EventSystem.Invoke(EventDef.Gem.OnUpdateGemItemHoverStatus, true, self.GemId, true)
end
function WBP_GemEquipItem:OnMouseLeave(...)
  print("WBP_GemEquipItem:OnMouseLeave")
  self.IsHoverItem = false
  if self.HoverWidget and self.HoverWidget:IsValid() then
    self.HoverWidget:Hide()
  end
  EventSystem.Invoke(EventDef.Gem.OnUpdateGemItemHoverStatus, false, self.GemId, true)
end
function WBP_GemEquipItem:PlayEquipGemAnim()
  self:PlayAnimation(self.Ani_xinpian_in)
end
return WBP_GemEquipItem
