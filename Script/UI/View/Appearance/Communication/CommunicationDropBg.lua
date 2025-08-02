local CommunicationDropBg = UnLua.Class()
local SlotDropAvailable = function(self, DragDropItem, DragTarget, PointerEvent)
  if DragTarget.SlotId ~= nil then
    local CommunicationViewModel = UIModelMgr:Get("CommunicationViewModel")
    CommunicationViewModel:UnequipCommBySlotId(DragTarget.SlotId)
    print(self, DragDropItem, DragTarget, PointerEvent)
  end
end

function CommunicationDropBg:Construct()
  self.Overridden.Construct(self)
end

function CommunicationDropBg:InitDrop()
  self.WBP_DragDropItem:SetDropAvailableCallback(self, self, SlotDropAvailable)
end

function CommunicationDropBg:Destruct()
end

return CommunicationDropBg
