local BP_NPC_GenericModifyBase_C = UnLua.Class()

function BP_NPC_GenericModifyBase_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_GenericModifyBase_C:ReceiveBeginPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
  if self.bIsEditorOnlyActor then
    return
  end
  self:StatusChanged()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Add(self, self.OnUIReady)
  end
  local GenericModifyInteractCom = self:GetComponentByClass(UE.URGInteractComponent_GenericModify:StaticClass())
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem and GenericModifyInteractCom then
    local Result, GenericModifyGroupRow = DTSubsystem:GetGenericModifyGroupDataByName(GenericModifyInteractCom.GroupId, nil)
    if Result then
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(GenericModifyGroupRow.Icon)
      if IconObj then
      end
    end
  end
  if self.RGInteractComponent_GenericModify then
    self.RGInteractComponent_GenericModify.OnActorFinishInteract:Add(self, self.FinishInteract)
    self.RGInteractComponent_GenericModify.StatusChangeDelegate:Remove(self, self.StatusChanged)
    self.RGInteractComponent_GenericModify.StatusChangeDelegate:Add(self, self.StatusChanged)
  end
end

function BP_NPC_GenericModifyBase_C:StatusChanged(RGInteractStatus)
  if self.RGInteractComponent_GenericModify and self.RGInteractComponent_GenericModify.InteractStatus == UE.ERGInteractStatus.Ready then
    self:NPCAppear(true)
  else
    self:NPCAppear(false)
  end
end

function BP_NPC_GenericModifyBase_C:OnUIReady(Widget)
  if Widget:Cast(UE.URGHUDWidget:StaticClass()) and self.bNeedShowMark then
    self:StatusChanged()
  end
end

function BP_NPC_GenericModifyBase_C:NPCAppear(bIsAppear)
  if not UE.UKismetSystemLibrary.IsServer(self) then
    if bIsAppear then
      local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGGameLevelSystem:StaticClass())
      if self.MarkId == nil or -1 == self.MarkId then
        self.MarkId = UE.URGBlueprintLibrary.TriggerMark(self, self, "Award")
        if -1 ~= self.MarkId then
          print("BP_NPC_GenericModifyBase_C:NPCAppear!!!", self, self.MarkId, bIsAppear)
          LogicHUD:UpdateActiveAwardNpcNum(1)
        end
      end
    elseif not self.bFinished then
      LogicHUD:UpdateActiveAwardNpcNum(-1)
      UE.URGBlueprintLibrary.RemoveMarkById(self, self.MarkId)
      EventSystem.Invoke(EventDef.NPCAward.NPCAwardNumInteractFinish)
      print("BP_NPC_GenericModifyBase_C:NPCAppear1!!!", self, self.MarkId, bIsAppear)
      self.MarkId = -1
      self.bFinished = true
    end
  end
end

function BP_NPC_GenericModifyBase_C:FinishInteract(Target, Instigator)
  self:NPCAppear(false)
end

function BP_NPC_GenericModifyBase_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_GenericModifyBase_C:ReceiveEndPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
  if self.bIsEditorOnlyActor then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Remove(self, self.OnUIReady)
  end
  self:NPCAppear(false)
  if self.RGInteractComponent_GenericModify then
    self.RGInteractComponent_GenericModify.OnActorFinishInteract:Remove(self, self.FinishInteract)
    self.RGInteractComponent_GenericModify.StatusChangeDelegate:Remove(self, self.StatusChanged)
  end
end

return BP_NPC_GenericModifyBase_C
