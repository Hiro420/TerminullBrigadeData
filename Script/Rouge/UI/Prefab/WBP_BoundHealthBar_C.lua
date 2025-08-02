local WBP_BoundHealthBar_C = UnLua.Class()

function WBP_BoundHealthBar_C:InitWidgetInfo(OwningActor)
  self.OwningActor = OwningActor
  self.HealthBar:InitInfo(self.OwningActor)
end

return WBP_BoundHealthBar_C
