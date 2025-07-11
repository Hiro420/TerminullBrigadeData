local AppearanceToggle = UnLua.Class()
function AppearanceToggle:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Hover, true)
end
function AppearanceToggle:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Hover, false)
end
return AppearanceToggle
