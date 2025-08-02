local PlayerInfoMainToggle = UnLua.Class()

function PlayerInfoMainToggle:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Hover, true)
end

function PlayerInfoMainToggle:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Hover, false)
end

return PlayerInfoMainToggle
