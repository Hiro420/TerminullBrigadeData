local BP_NPC_HeartModifyBase_C = UnLua.Class()

function BP_NPC_HeartModifyBase_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_HeartModifyBase_C:ReceiveBeginPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
  if self.bIsEditorOnlyActor then
    return
  end
  self:NPCAppear(true)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Add(self, self.OnUIReady)
  end
  if self.RGInteractComponent_ApplyBuff then
    self.RGInteractComponent_ApplyBuff.OnActorFinishInteract:Add(self, self.FinishInteract)
  end
end

function BP_NPC_HeartModifyBase_C:OnUIReady(Widget)
  if Widget:Cast(UE.URGHUDWidget:StaticClass()) then
    self:NPCAppear(true)
  end
end

function BP_NPC_HeartModifyBase_C:NPCAppear(bIsAppear)
  if not UE.UKismetSystemLibrary.IsServer(self) then
    if bIsAppear then
      if self.MarkId == nil or -1 == self.MarkId then
        self.MarkId = UE.URGBlueprintLibrary.TriggerMark(self, self, "Award")
        if -1 ~= self.MarkId then
          LogicHUD:UpdateActiveAwardNpcNum(1)
        end
      end
    elseif not self.bFinished then
      LogicHUD:UpdateActiveAwardNpcNum(-1)
      EventSystem.Invoke(EventDef.NPCAward.NPCAwardNumInteractFinish)
      UE.URGBlueprintLibrary.RemoveMarkById(self, self.MarkId)
      self.MarkId = -1
      self.bFinished = true
    end
  end
end

function BP_NPC_HeartModifyBase_C:FinishInteract(Target, Instigator)
  self:NPCAppear(false)
end

function BP_NPC_HeartModifyBase_C:PlayHeartModifyUIEffect()
  ShowWaveWindow(self.UseWaveId, {})
  local HUD = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
  if HUD and HUD.WBP_HUDInfo then
    HUD.WBP_HUDInfo:PlayHeartModifyAnim()
  end
end

function BP_NPC_HeartModifyBase_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_HeartModifyBase_C:ReceiveBeginPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
  if self.bIsEditorOnlyActor then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Remove(self, self.OnUIReady)
  end
  self:NPCAppear(false)
  if self.RGInteractComponent_ApplyBuff then
    self.RGInteractComponent_ApplyBuff.OnActorFinishInteract:Remove(self, self.FinishInteract)
  end
end

return BP_NPC_HeartModifyBase_C
