local BP_UITestActor_C = UnLua.Class()

function BP_UITestActor_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  self:UpdateActived(false)
end

function BP_UITestActor_C:FocusInput()
  self:UpdateActived(true)
end

function BP_UITestActor_C:OnDisplay()
  local UITest = self.RGWidget:GetWidget()
  if UITest then
    UITest:Init()
  end
  self:UpdateActived(true)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC then
    PC:SetViewTargetwithBlend(self.ChildActor.ChildActor, 0.4)
  end
end

function BP_UITestActor_C:UnfocusInput()
  self:UpdateActived(false)
end

function BP_UITestActor_C:OnUnDisplay()
  self:UpdateActived(false)
end

function BP_UITestActor_C:OnClose()
  self:Destroy()
end

function BP_UITestActor_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if self.GenericModifyActor then
    self.GenericModifyActor:Destroy()
    self.GenericModifyActor = nil
  end
end

function BP_UITestActor_C:UpdateActived(bIsActived)
  self:SetActorHiddenInGame(not bIsActived)
  if bIsActived then
    self:EnableInput(UE.UGameplayStatics.GetPlayerController(self.RGWidget:GetWidget(), 0))
  else
    self:DisableInput(UE.UGameplayStatics.GetPlayerController(self.RGWidget:GetWidget(), 0))
    local Result = UE.FHitResult()
    self:K2_SetActorLocation(UE.FVector(0, 0, -10000000), true, Result, true)
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      PC:SetViewTargetwithBlend(self.RGWidget:GetWidget():GetOwningPlayerPawn())
    end
  end
end

return BP_UITestActor_C
