local BP_MultiLayerCameraRender_C = UnLua.Class()
function BP_MultiLayerCameraRender_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  EventSystem.Invoke(EventDef.Heirloom.MultiLayerCameraBeginPlay, self)
end
function BP_MultiLayerCameraRender_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
end
return BP_MultiLayerCameraRender_C
