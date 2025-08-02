local UITestActorPath = "/Game/Rouge/UI/NewUITest/BP_UITestActor.BP_UITestActor_C"
local WBP_UITestView_C = UnLua.Class()

function WBP_UITestView_C:Construct()
  print("ccc222333444")
  self.EscActionName = "PauseGame"
  self.Overridden.Construct(self)
end

function WBP_UITestView_C:Destruct()
  self.Overridden.Destruct(self)
end

function WBP_UITestView_C:FocusInput()
  self.Overridden.FocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  if not IsListeningForInputAction(self, self.EscActionName) then
    ListenForInputAction(self.EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_UITestView_C.ListenForEscInputAction
    })
  end
end

function WBP_UITestView_C:UnFocusInput()
  self.Overridden.UnFocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  UE.UGameplayStatics.GetPlayerController(self, 0):SetIgnoreWidgetInput(false)
  if not IsListeningForInputAction(self, self.EscActionName) then
    ListenForInputAction(self.EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_UITestView_C.ListenForEscInputAction
    })
  end
end

function WBP_UITestView_C:ListenForEscInputAction()
  RGUIMgr:HideUI(UIConfig.WBP_UITestView_C.UIName)
end

function WBP_UITestView_C:OnDisplay()
  print("ccc222333444")
  self.Overridden.OnDisplay(self)
  if not self.UITestActor then
    local World = self:GetWorld()
    local ActorClass = UE.UClass.Load(UITestActorPath)
    if World then
      local Transform = UE.FTransform()
      local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
      if CameraManager then
        local CameraLocation = CameraManager:GetTargetCameraLocation()
        local CameraRotation = CameraManager:GetTargetCameraRotation()
        local RoleLocation = self:GetOwningPlayerPawn():K2_GetActorLocation() + self:GetOwningPlayerPawn():GetActorForwardVector() * -20 + UE.FVector(0, 0, 67)
        RoleLocation = RoleLocation + self:GetOwningPlayerPawn():GetActorRightVector() * -70
        local RoleRotation = self:GetOwningPlayerPawn():K2_GetActorRotation() + UE.FRotator(0, 30, 0)
        Transform.Translation = CameraLocation
        Transform.Rotation = CameraRotation + UE.FRotator(0, -100, 0)
        self.UITestActor = World:SpawnActor(ActorClass, Transform)
        local Result = UE.FHitResult()
        self.UITestActor:K2_SetActorLocation(RoleLocation, true, Result, true)
        self.UITestActor:K2_SetActorRotation(RoleRotation, true)
      end
    end
  else
    local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
    if CameraManager then
      local CameraLocation = CameraManager:GetTargetCameraLocation() + UE.FVector(100, 0, -20)
      local CameraRotation = CameraManager:GetTargetCameraRotation() + UE.FRotator(10, -30, 0)
      local RoleLocation = self:GetOwningPlayerPawn():K2_GetActorLocation() + self:GetOwningPlayerPawn():GetActorForwardVector() * -20 + UE.FVector(0, 0, 67)
      RoleLocation = RoleLocation + self:GetOwningPlayerPawn():GetActorRightVector() * -70
      local RoleRotation = self:GetOwningPlayerPawn():K2_GetActorRotation() + UE.FRotator(0, 30, 0)
      local Result = UE.FHitResult()
      self.UITestActor:K2_SetActorLocation(RoleLocation, true, Result, true)
      self.UITestActor:K2_SetActorRotation(RoleRotation, true)
    end
  end
  print("ccc222333")
  self.UITestActor:OnDisplay()
end

function WBP_UITestView_C:OnUnDisplay()
  if self.UITestActor then
    self.UITestActor:OnUnDisplay()
  end
  self.Overridden.OnUnDisplay(self, true)
end

function WBP_UITestView_C:OnClose()
  if self.UITestActor then
    self.UITestActor:OnClose()
  end
  self.Overridden.OnClose(self)
end

return WBP_UITestView_C
