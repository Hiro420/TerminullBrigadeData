local BP_NPC_SpecificModifyBase_C = UnLua.Class()

function BP_NPC_SpecificModifyBase_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_SpecificModifyBase_C:ReceiveBeginPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
  if self.bIsEditorOnlyActor then
    return
  end
  self:StatusChanged()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Add(self, self.OnUIReady)
  end
  local SpecificModifyInteractCom = self:GetComponentByClass(UE.URGInteractComponent_SpecificModify:StaticClass())
  if SpecificModifyInteractCom then
    SpecificModifyInteractCom.OnActorFinishInteract:Add(self, self.FinishInteract)
    SpecificModifyInteractCom.StatusChangeDelegate:Remove(self, self.StatusChanged)
    SpecificModifyInteractCom.StatusChangeDelegate:Add(self, self.StatusChanged)
  end
end

function BP_NPC_SpecificModifyBase_C:OnUIReady(Widget)
  if Widget:Cast(UE.URGHUDWidget:StaticClass()) then
    self:StatusChanged()
  end
end

function BP_NPC_SpecificModifyBase_C:StatusChanged(RGInteractStatus)
  local SpecificModifyInteractCom = self:GetComponentByClass(UE.URGInteractComponent_SpecificModify:StaticClass())
  if SpecificModifyInteractCom and SpecificModifyInteractCom.InteractStatus == UE.ERGInteractStatus.Ready then
    self:NPCAppear(true)
  else
    self:NPCAppear(false)
  end
end

function BP_NPC_SpecificModifyBase_C:NPCAppear(bIsAppear)
  if not UE.UKismetSystemLibrary.IsServer(self) then
    if bIsAppear then
      if self.MarkId == nil or -1 == self.MarkId then
        self.MarkId = UE.URGBlueprintLibrary.TriggerMark(self, self, "Award")
        if -1 ~= self.MarkId then
          print("BP_NPC_SpecificModifyBase_C:NPCAppear!!!", self, self.MarkId, bIsAppear)
          LogicHUD:UpdateActiveAwardNpcNum(1)
        end
      end
    elseif not self.bFinished then
      LogicHUD:UpdateActiveAwardNpcNum(-1)
      UE.URGBlueprintLibrary.RemoveMarkById(self, self.MarkId)
      EventSystem.Invoke(EventDef.NPCAward.NPCAwardNumInteractFinish)
      print("BP_NPC_SpecificModifyBase_C:NPCAppear1!!!", self, self.MarkId, bIsAppear)
      self.MarkId = -1
      self.bFinished = true
    end
  end
end

function BP_NPC_SpecificModifyBase_C:FinishInteract(Target, Instigator)
  self:NPCAppear(false)
end

function BP_NPC_SpecificModifyBase_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_SpecificModifyBase_C:ReceiveEndPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
  if self.bIsEditorOnlyActor then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Remove(self, self.OnUIReady)
  end
  self:NPCAppear(false)
  local SpecificModifyInteractCom = self:GetComponentByClass(UE.URGInteractComponent_SpecificModify:StaticClass())
  if SpecificModifyInteractCom then
    SpecificModifyInteractCom.OnActorFinishInteract:Remove(self, self.FinishInteract)
    SpecificModifyInteractCom.StatusChangeDelegate:Remove(self, self.StatusChanged)
  end
end

return BP_NPC_SpecificModifyBase_C
