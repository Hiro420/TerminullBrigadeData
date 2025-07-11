local BP_NPC_UpgradeRarityModifyBase_C = UnLua.Class()
function BP_NPC_UpgradeRarityModifyBase_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_UpgradeRarityModifyBase_C:ReceiveBeginPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
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
        self.Billboard:SetSprite(IconObj)
      end
    end
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character then
    self:OnUpdateCanUpgrade()
    local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
    if RGGenericModifyComponent then
      RGGenericModifyComponent.OnAddModify:Add(self, self.OnUpdateCanUpgrade)
      RGGenericModifyComponent.OnUpgradeModify:Add(self, self.OnUpdateCanUpgrade)
      RGGenericModifyComponent.OnRemoveModify:Add(self, self.OnUpdateCanUpgrade)
    end
  end
  if self.RGInteractComponent_UpgradeRarityModify then
    self.RGInteractComponent_UpgradeRarityModify.OnActorFinishInteract:Add(self, self.FinishInteract)
    self.RGInteractComponent_UpgradeRarityModify.StatusChangeDelegate:Remove(self, self.StatusChanged)
    self.RGInteractComponent_UpgradeRarityModify.StatusChangeDelegate:Add(self, self.StatusChanged)
  end
end
function BP_NPC_UpgradeRarityModifyBase_C:OnUpdateCanUpgrade()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character then
    local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
    if RGGenericModifyComponent and not RGGenericModifyComponent:HasCandidateRarityUpModifies() then
      UpdateVisibility(self.RGWidget:GetWidget().CanvasPanelNoUpgrade, true)
    else
      UpdateVisibility(self.RGWidget:GetWidget().CanvasPanelNoUpgrade, false)
    end
  end
end
function BP_NPC_UpgradeRarityModifyBase_C:OnUIReady(Widget)
  if Widget:Cast(UE.URGHUDWidget:StaticClass()) then
    self:StatusChanged()
  end
end
function BP_NPC_UpgradeRarityModifyBase_C:StatusChanged(RGInteractStatus)
  if self.RGInteractComponent_UpgradeRarityModify and self.RGInteractComponent_UpgradeRarityModify.InteractStatus == UE.ERGInteractStatus.Ready then
    self:NPCAppear(true)
  else
    self:NPCAppear(false)
  end
end
function BP_NPC_UpgradeRarityModifyBase_C:NPCAppear(bIsAppear)
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
      UE.URGBlueprintLibrary.RemoveMarkById(self, self.MarkId)
      EventSystem.Invoke(EventDef.NPCAward.NPCAwardNumInteractFinish)
      self.MarkId = -1
      self.bFinished = true
    end
  end
end
function BP_NPC_UpgradeRarityModifyBase_C:FinishInteract(Target, Instigator)
  print("BP_NPC_UpgradeRarityModifyBase_C:FinishInteract", self, Target, Instigator)
  self:NPCAppear(false)
end
function BP_NPC_UpgradeRarityModifyBase_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_NPC_UpgradeRarityModifyBase_C:ReceiveEndPlay bIsEditorOnlyActor", self, self.bIsEditorOnlyActor)
  if self.bIsEditorOnlyActor then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Remove(self, self.OnUIReady)
  end
  self:NPCAppear(false)
  if self.RGInteractComponent_UpgradeRarityModify then
    self.RGInteractComponent_UpgradeRarityModify.OnActorFinishInteract:Remove(self, self.FinishInteract)
    self.RGInteractComponent_UpgradeRarityModify.StatusChangeDelegate:Remove(self, self.StatusChanged)
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character then
    local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
    if RGGenericModifyComponent then
      RGGenericModifyComponent.OnAddModify:Remove(self, self.OnUpdateCanUpgrade)
      RGGenericModifyComponent.OnUpgradeModify:Remove(self, self.OnUpdateCanUpgrade)
      RGGenericModifyComponent.OnRemoveModify:Remove(self, self.OnUpdateCanUpgrade)
    end
  end
end
return BP_NPC_UpgradeRarityModifyBase_C
