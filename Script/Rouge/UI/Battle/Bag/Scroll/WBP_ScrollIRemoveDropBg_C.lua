local WBP_ScrollRemoveDropBg_C = UnLua.Class()
local SlotDropAvailable = function(self, DragDropItem, DragTarget, PointerEvent)
  Logic_Scroll.ShareModify(DragTarget.ScrollId)
  UpdateVisibility(self, false)
end
function WBP_ScrollRemoveDropBg_C:Construct()
  self.Overridden.Construct(self)
  self.ScrollId = -1
end
function WBP_ScrollRemoveDropBg_C:InitScrollRemoveDropBg()
  self.WBP_DragDropItem:SetDropAvailableCallback(self, self, SlotDropAvailable)
end
function WBP_ScrollRemoveDropBg_C:Destruct()
  self.ParentView = nil
end
return WBP_ScrollRemoveDropBg_C
