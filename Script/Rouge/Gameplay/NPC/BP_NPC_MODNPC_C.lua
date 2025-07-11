local BP_NPC_MODNPC_C = UnLua.Class()
function BP_NPC_MODNPC_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_MODNPC_C:ReceiveBeginPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
  if self.bIsEditorOnlyActor then
    return
  end
  self:NPCAppear(true)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Add(self, self.OnUIReady)
  end
  local modComponent = self.RGWidget:GetWidget():GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass())
  if modComponent then
    modComponent.OnMODResultDelegate:Add(self, self.OnMODResultDelegate)
  end
end
function BP_NPC_MODNPC_C:OnUIReady(Widget)
  if Widget:Cast(UE.URGHUDWidget:StaticClass()) then
    self:NPCAppear(true)
    local modComponent = self.RGWidget:GetWidget():GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass())
    if modComponent then
      modComponent.OnMODResultDelegate:Remove(self, self.OnMODResultDelegate)
      modComponent.OnMODResultDelegate:Add(self, self.OnMODResultDelegate)
    end
  end
end
function BP_NPC_MODNPC_C:NPCAppear(bIsAppear)
  if not UE.UKismetSystemLibrary.IsServer(self) then
    if bIsAppear then
      if self.MarkId == nil or -1 == self.MarkId then
        self.MarkId = UE.URGBlueprintLibrary.TriggerMark(self, self, "Award")
        print("BP_NPC_MODNPC_C:NPCAppear!!!", self, self.MarkId, bIsAppear)
        if -1 ~= self.MarkId then
          LogicHUD:UpdateActiveAwardNpcNum(1)
        end
      end
    elseif not self.bFinished then
      LogicHUD:UpdateActiveAwardNpcNum(-1)
      EventSystem.Invoke(EventDef.NPCAward.NPCAwardNumInteractFinish)
      UE.URGBlueprintLibrary.RemoveMarkById(self, self.MarkId)
      print("BP_NPC_MODNPC_C:NPCAppear!!!", self, self.MarkId, bIsAppear)
      self.MarkId = -1
      self.bFinished = true
    end
  end
end
function BP_NPC_MODNPC_C:OnMODResultDelegate(NPC, Result)
  if Result then
    print("BP_NPC_MODNPC_C:\230\168\161\231\187\132\233\128\137\230\139\169\230\136\144\229\138\159!!!!!!!", NPC, self)
    if NPC == self then
      print("BP_NPC_MODNPC_C:\230\168\161\231\187\132\233\128\137\230\139\169\232\135\170\232\186\171\230\136\144\229\138\159!!!!!!!")
      self:NPCAppear(false)
    end
  else
    print("BP_NPC_MODNPC_C:\230\168\161\231\187\132\233\128\137\230\139\169\229\164\177\232\180\165!!!!!!!")
  end
end
function BP_NPC_MODNPC_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_MODNPC_C:ReceiveEndPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
  if self.bIsEditorOnlyActor then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Remove(self, self.OnUIReady)
  end
  self:NPCAppear(false)
  local modComponent = self.RGWidget:GetWidget():GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass())
  if modComponent then
    modComponent.OnMODResultDelegate:Remove(self, self.OnMODResultDelegate)
  end
end
return BP_NPC_MODNPC_C
