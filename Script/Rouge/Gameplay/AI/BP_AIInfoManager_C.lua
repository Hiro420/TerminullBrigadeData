local BP_AIInfoManager_C = UnLua.Class()

function BP_AIInfoManager_C:ClientBeginPlay()
  self.Overridden.ClientBeginPlay(self)
  self:BindBossHealthChangedDelegate()
  self:InitVirusInfo()
  ListenObjectMessage(self.OwnerActor, GMP.MSG_Pawn_OnDeath, self, self.BindOnPawnDeath)
  ListenObjectMessage(self.OwnerActor, GMP.MSG_UI_AIInfo_ForceChangeAIInfoVis, self, self.BindOnForceChangeAIInfoVis)
  ListenObjectMessage(nil, GMP.MSG_GM_ChangeAllUIVis, self, self.BindOnChangeAllUIVis)
  ListenObjectMessage(nil, GMP.MSG_OnEnemyAICountChange, self, self.BindOnEnemyAICountChange)
  ListenObjectMessage(nil, GMP.MSG_UI_HUD_OnCreate, self, self.BindOnCreateHUD)
end

function BP_AIInfoManager_C:BindBossHealthChangedDelegate()
  if not (self.OwnerActor and self.OwnerActor.IsBossAI) or not self.OwnerActor:IsBossAI() then
    return
  end
  local CoreComponent = self.OwnerActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if CoreComponent then
    CoreComponent.ClientHealthChanged:Add(self, self.BindOnHealthAttributeChanged)
  end
end

function BP_AIInfoManager_C:BindOnHealthAttributeChanged(NewValue, OldValue)
  local TypeId = self.OwnerActor:GetTypeID()
  local CoreComponent = self.OwnerActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  local HealthPercent = CoreComponent:GetHealthPercent()
  BattleData.SetBossHealthInfo(TypeId, HealthPercent)
end

function BP_AIInfoManager_C:BindChangeAIInfoVisFunction()
  self.Overridden.BindChangeAIInfoVisFunction(self)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    Character.OnNotifyCurAimTargetPartIndex:Add(self, self.BindOnNotifyCurAimTargetPartIndex)
  end
end

function BP_AIInfoManager_C:BindOnNotifyCurAimTargetPartIndex(CurAimTarget, PartIndex)
  if CurAimTarget ~= self.OwnerActor then
    return
  end
  LogicBodyPart.ShowOrHidePartInfo(CurAimTarget, PartIndex)
end

function BP_AIInfoManager_C:BindOnPawnDeath()
  self.IsDeath = true
  self:ShowOrHideInfoWidget(false)
  if -1 ~= self.AppearMarkId then
    self:ClearMarkTimer()
    self:RemoveAppearMark()
  end
end

function BP_AIInfoManager_C:BindOnEnemyAICountChange(Count)
  if self.IsBeginPlayMark then
    return
  end
  if self.IsPermanentMark then
    return
  end
  local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
  if Count <= RGGlobalSettings.MonsterMarkCount then
    if -1 == self.AppearMarkId and not self.IsDeath and self.IsShowAppearMark and not self.IsEnd then
      self:ShowAppearMark()
    end
  elseif -1 ~= self.AppearMarkId then
    self:ClearMarkTimer()
    self:RemoveAppearMark()
  end
end

function BP_AIInfoManager_C:BindOnForceChangeAIInfoVis(IsShow)
  self.IsForceHideAIInfo = not IsShow
  self:ShowOrHideInfoWidget(IsShow)
end

function BP_AIInfoManager_C:BindOnChangeAllUIVis(IsHide, IsShowDamageNumber)
  self.IsHideByGM = IsHide
  if self.IsHideByGM then
    self:ShowOrHideInfoWidget(false)
  end
  LogicBodyPart.SetCanShowBodyPartWidget(IsHide)
end

function BP_AIInfoManager_C:GetWidgetComponent()
  local TargetWidgetComp
  if self.OwnerActor.InfoWidgetComp then
    TargetWidgetComp = self.OwnerActor.InfoWidgetComp
  else
    local AllWidgetComponents = self.OwnerActor:K2_GetComponentsByClass(UE.UWidgetComponent:StaticClass())
    local PartWidegtComponents = self:GetPartInfoWidgets():Values()
    if AllWidgetComponents then
      for key, SingleWidgetComp in pairs(AllWidgetComponents) do
        if not PartWidegtComponents:Contains(SingleWidgetComp) then
          TargetWidgetComp = SingleWidgetComp
        end
      end
    end
  end
  return TargetWidgetComp
end

function BP_AIInfoManager_C:ShowOrHideInfoWidget(IsShow)
  self.Overridden.ShowOrHideInfoWidget(self, IsShow)
  self.IsShowInfoWidget = false
  local WidgetCom = self:GetWidgetComponent()
  if not WidgetCom then
    return
  end
  if self.IsHideByGM then
    WidgetCom:SetHiddenInGame(true)
    return
  end
  local Widget = WidgetCom:GetWidget()
  if not Widget then
    WidgetCom:SetHiddenInGame(true)
    return
  end
  if self.IsForceHideAIInfo then
    WidgetCom:SetHiddenInGame(true)
    return
  end
  if Widget.bNeedOverrideHideFunc then
    if IsShow then
      Widget:ShowPanel()
    else
      Widget:HidePanel()
    end
  elseif self.OwnerActor.IsEliteAI and self.OwnerActor:IsEliteAI() or self.IsResidentShowWidget then
    WidgetCom:SetHiddenInGame(false)
    if self.IsResidentShowName and Widget.ShowAIInfoName then
      Widget:ShowAIInfoName()
    end
  elseif self.IsResidentShowName and Widget.ShowAIInfoName then
    WidgetCom:SetHiddenInGame(false)
    Widget:HidePanel()
    Widget:ShowAIInfoName()
  elseif IsShow then
    Widget:ShowPanel()
    WidgetCom:SetHiddenInGame(false)
  else
    WidgetCom:SetHiddenInGame(true)
  end
  if UE.URGBlueprintLibrary.IsDead(self.OwnerActor) then
    IsShow = false
    WidgetCom:SetHiddenInGame(true)
  end
  self.IsShowInfoWidget = not WidgetCom.bHiddenInGame
end

function BP_AIInfoManager_C:ShowAppearMark(IsBeginPlayMark)
  local Quality = BattleUIScalability:GetAIInfoScalability()
  if Quality == UIQuality.LOW then
    return
  end
  if not self:CanShowAppearMark() then
    return
  end
  local hud = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
  if not hud then
    self.IsNeedTriggerMark = true
    self.IsBeginPlayMark = IsBeginPlayMark
    return
  end
  self:DoShowAppearMark(IsBeginPlayMark)
end

function BP_AIInfoManager_C:DoShowAppearMark(IsBeginPlayMark)
  local ActorId = self.OwnerActor.GetActorId and self.OwnerActor:GetActorId() or 0
  local MarkRowName = self.DefaultMarkRowName
  local Result, RowInfo = GetRowData(DT.DT_Monster, tostring(ActorId))
  if Result and RowInfo.MarkRowName ~= "None" then
    MarkRowName = RowInfo.MarkRowName
  end
  self.IsBeginPlayMark = IsBeginPlayMark
  self.AppearMarkId = UE.URGBlueprintLibrary.TriggerMark(self.OwnerActor, self.OwnerActor, MarkRowName, UE.FVector())
  self.AppearMarkTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.OnFinishAppearMarkTimer
  }, self.AppearMarkDuration, false)
end

function BP_AIInfoManager_C:OnFinishAppearMarkTimer()
  self.IsBeginPlayMark = nil
  if self.IsPermanentMark then
    if self.IsDeath or not self.IsInPermanentMarkDistance then
      self:ClearMarkTimer()
      self:RemoveAppearMark()
    end
  else
    local Count = UE.URGBlueprintLibrary.GetLittleMonsterCount(self)
    local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
    if Count > RGGlobalSettings.MonsterMarkCount then
      self:ClearMarkTimer()
      self:RemoveAppearMark()
    elseif self.IsDeath then
      self:ClearMarkTimer()
      self:RemoveAppearMark()
    end
  end
end

function BP_AIInfoManager_C:BindOnCreateHUD()
  if self.IsNeedTriggerMark then
    self:DoShowAppearMark(self.IsBeginPlayMark)
    self.IsNeedTriggerMark = nil
  end
end

function BP_AIInfoManager_C:OnBuffAdded_Event_0(AddedBuff)
  self.Overridden.OnBuffAdded_Event_0(self, AddedBuff)
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local WidgetCom = self:GetWidgetComponent()
  if not WidgetCom then
    return
  end
  local Widget = WidgetCom:GetWidget()
  if not Widget then
    return
  end
  if self:CanShowAIInfo() then
    local BuffData = BuffDataSubsystem:GetDataFormID(AddedBuff.ID)
    if not BuffData.IsPositiveBuff then
      self.CurBuffIds:Add(AddedBuff.ID)
      self.CanHideInfoByDebuff = false
      self:ShowOrHideInfoWidget(true)
    elseif Widget.bNeedOverrideHideFunc then
      self.CanHideInfoByDebuff = false
      self:ShowOrHideInfoWidget(true)
    end
  end
end

function BP_AIInfoManager_C:OnBuffRemove_Event_0(AddedBuff)
  self.Overridden.OnBuffRemove_Event_0(self, AddedBuff)
  local WidgetCom = self:GetWidgetComponent()
  if not WidgetCom then
    return
  end
  local Widget = WidgetCom:GetWidget()
  if not Widget then
    return
  end
  self.CurBuffIds:Remove(AddedBuff.ID)
  if not self:IsHasPositiveBuff() then
    self.CanHideInfoByDebuff = true
    self:HideAIInfo()
  elseif Widget.bNeedOverrideHideFunc then
    self.CanHideInfoByDebuff = true
    self:HideAIInfo()
  end
end

function BP_AIInfoManager_C:ShowOrHidePartInfoWidget(DamageParams)
  LogicBodyPart.ShowOrHidePartInfo(self.OwnerActor, UE.URGDamageStatics.GetPartIndex(DamageParams))
end

function BP_AIInfoManager_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    Character.OnNotifyCurAimTargetPartIndex:Remove(self, self.BindOnNotifyCurAimTargetPartIndex)
  end
  if self.OwnerActor then
    local CoreComponent = self.OwnerActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
    if CoreComponent then
      CoreComponent.ClientHealthChanged:Remove(self, self.BindOnHealthAttributeChanged)
    end
  end
  UnListenObjectMessage(GMP.MSG_Pawn_OnDeath, self)
  UnListenObjectMessage(GMP.MSG_UI_AIInfo_ForceChangeAIInfoVis, self)
  UnListenObjectMessage(GMP.MSG_GM_ChangeAllUIVis, self)
end

function BP_AIInfoManager_C:InitVirusInfo()
  if self.OwnerActor == nil or nil == self.OwnerActor.CurrentColor then
    return
  end
  local WidgetCom = self:GetWidgetComponent()
  if not WidgetCom then
    return
  end
  local Widget = WidgetCom:GetWidget()
  Widget:InitInfo(self.OwnerActor)
  ListenObjectMessage(nil, GMP.MSG_Level_LevelAffix_VirusColor, self, self.BindOnVirusColorChange)
end

function BP_AIInfoManager_C:BindOnVirusColorChange(Character, ColorProgress)
  local ownerCharacter = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if ownerCharacter ~= Character then
    return
  end
  local WidgetCom = self:GetWidgetComponent()
  if not WidgetCom then
    return
  end
  local Widget = WidgetCom:GetWidget()
  Widget:OnVirusColorChange(ColorProgress)
end

function BP_AIInfoManager_C:ReceiveTick(DeltaSeconds)
  self.Overridden.ReceiveTick(self, DeltaSeconds)
  if not self.OwnerActor then
    return
  end
  if not self.IsPermanentMark then
    return
  end
  if not self.IsShowAppearMark then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local Distance = Character:GetDistanceTo(self.OwnerActor)
  self.IsInPermanentMarkDistance = Distance / 100 < self.PermanentMarkDistance
  if self.IsInPermanentMarkDistance then
    if -1 == self.AppearMarkId and not self.IsDeath then
      self:ShowAppearMark()
    end
  elseif -1 ~= self.AppearMarkId then
    self:ClearMarkTimer()
    self:RemoveAppearMark()
  end
end

function BP_AIInfoManager_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  self.IsEnd = true
end

function BP_AIInfoManager_C:ClearMarkTimer()
  if self.AppearMarkTimer then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.AppearMarkTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.AppearMarkTimer)
    end
    self.AppearMarkTimer = nil
  end
end

return BP_AIInfoManager_C
