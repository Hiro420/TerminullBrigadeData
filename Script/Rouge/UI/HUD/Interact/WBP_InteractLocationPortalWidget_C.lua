local WBP_InteractLocationPortalWidget_C = UnLua.Class()
function WBP_InteractLocationPortalWidget_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_InteractLocationPortalWidget_C:Destruct()
end
function WBP_InteractLocationPortalWidget_C:UpdateInteractInfo(InteractTipRow, TargetActor)
  if not UE.RGUtil.IsUObjectValid(TargetActor) then
    return
  end
  self:InitInteractItem(TargetActor, InteractTipRow.Info)
end
function WBP_InteractLocationPortalWidget_C:InitInteractItem(TargetActor, Info)
  if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TickStatusTimer) then
    self.TickStatusTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.UpdateStatus
    }, 0.2, true)
  end
  UpdateVisibility(self.CanvasPanelRoot, true)
  self.TargetActor = TargetActor
  self:UpdateStatus()
  if self.Ani_in then
    self:PlayAnimation(self.Ani_in)
  end
  if self.Ani_loop then
    self:PlayAnimation(self.Ani_loop, 0, 0)
  end
end
function WBP_InteractLocationPortalWidget_C:UpdateStatus()
  if UE.RGUtil.IsUObjectValid(self.TargetActor) then
    local validPortal = UE.AVotePortal.GetVotePortal(self)
    local bIsValid = validPortal == self.TargetActor
    if not UE.RGUtil.IsUObjectValid(validPortal) then
      bIsValid = true
    end
    UpdateVisibility(self.RGTextCantInteract, not bIsValid)
    UpdateVisibility(self.RGTextLevelName, bIsValid)
    UpdateVisibility(self.CanvasPanelInteract, bIsValid)
    UpdateVisibility(self.CanvasPanelInteract, bIsValid)
    if bIsValid and self.TargetActor then
      self.RGTextLevelName:SetText(self.TargetActor.TargetPosName)
    end
  end
end
function WBP_InteractLocationPortalWidget_C:UpdateItemNative(MarkInfoParam, bIsInScreenParam)
  self.Overridden.UpdateItemNative(self, MarkInfoParam, bIsInScreenParam)
  if not UE.RGUtil.IsUObjectValid(self.TargetActor) then
    return
  end
  self:UpdateStatus()
end
function WBP_InteractLocationPortalWidget_C:HideWidget()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TickStatusTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TickStatusTimer)
  end
  UpdateVisibility(self.CanvasPanelRoot, false)
  self.TargetActor = nil
end
return WBP_InteractLocationPortalWidget_C
