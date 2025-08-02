local PlayerInfoChangeTipsItem = Class()

function PlayerInfoChangeTipsItem:Construct()
  self.Overridden.Construct(self)
end

function PlayerInfoChangeTipsItem:Hide()
  UpdateVisibility(self, false)
end

function PlayerInfoChangeTipsItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end

function PlayerInfoChangeTipsItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end

return PlayerInfoChangeTipsItem
