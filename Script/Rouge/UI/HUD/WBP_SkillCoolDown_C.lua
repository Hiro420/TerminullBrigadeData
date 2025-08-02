local WBP_SkillCoolDown_C = UnLua.Class()
local SkillStatus = {
  Normal = 0,
  CoolDown = 1,
  NoCount = 2
}

function WBP_SkillCoolDown_C:Construct()
  self.WBP_CustomKeyName:SetCustomKeyDisplayInfo(self.CustomKeyDisplayInfo)
  self:ListenPressedInputEvent(true)
  self:InitAbilityClass()
  self.CoolDownTagContainer = self:GetCoolDownTagContainer()
  self:SetSkillBasicInfo()
  self.Img_DisableSkillIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Disable:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:InitSkillStyle()
  self:RefreshLockPanelVis()
  self:InitSkillUnNormalState()
  self.Img_Disable:SetRenderScale(UE.FVector2D(0.8, 0.8))
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    Character.OnGameplayEffectDurationChangedDelegate:Add(self, WBP_SkillCoolDown_C.BindOnGameplayEffectDurationChangedDelegate)
    local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
    if CoreComp then
      self.IsUpdateAttributeCache = CoreComp:HasAttributeCacheModify(self.SkillCountAttribute)
    end
  end
  ListenObjectMessage(nil, GMP.MSG_OnAbilityTagUpdate, self, self.BindOnAbilityTagUpdate)
  ListenObjectMessage(nil, GMP.MSG_Interact_ClientPickup, self, self.BindOnClientPickupNotice)
  self:ListenChangeSkillAdditionalSlotVis(true)
  ListenObjectMessage(nil, GMP.MSG_World_Input_OnForbiddenUpdated, self, self.BindOnInputForbiddenUpdated)
  ListenObjectMessage(nil, GMP.MSG_Hero_Dying, self, self.OnHeroDying)
  ListenObjectMessage(nil, GMP.MSG_Hero_NotifyRescue, self, self.OnHeroRescue)
  ListenObjectMessage(nil, GMP.MSG_World_OnAttributeModifyCacheAdded, self, self.OnAttributeModifyCacheAdded)
  ListenObjectMessage(nil, GMP.MSG_World_OnAttributeModifyCacheRemove, self, self.OnAttributeModifyCacheRemove)
  ListenObjectMessage(Character, GMP.MSG_CharacterSkill_BeginWaitSkillRetrigger, self, self.BindOnBeginWaitSkillRetrigger)
  ListenObjectMessage(Character, GMP.MSG_CharacterSkill_OnSkillRetrigger, self, self.BindOnSkillRetrigger)
  ListenObjectMessage(Character, GMP.MSG_CharacterSkill_EndWaitSkillRetrigger, self, self.BindOnEndWaitSkillRetrigger)
  ListenObjectMessage(nil, GMP.MSG_World_Skill_OnSkillCoolDownRemaining, self, self.BindOnSkillCoolDownRemaining)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnEnterState, self, self.BindOnCharacterEnterState)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnExitState, self, self.BindOnCharacterExitState)
  local Status = self.IsDown and "Down" or "Up"
  UpdateVisibility(self.FX_SkillComplete.up, not self.IsDown)
  UpdateVisibility(self.FX_SkillComplete.down, self.IsDown)
  self.RGStateController_Location:ChangeStatus(Status)
end

function WBP_SkillCoolDown_C:InitSkillUnNormalState(...)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local ASCComp = Character:GetComponentByClass(UE.UAbilitySystemComponent:StaticClass())
  if not ASCComp then
    return
  end
  for key, SingleTag in pairs(self.ForbiddenSkillTagContainer.GameplayTags) do
    if ASCComp:HasMatchingGameplayTag(SingleTag) then
      if not self.ForbiddenSkillTagList then
        self.ForbiddenSkillTagList = {}
      end
      self.ForbiddenSkillTagList[UE.UBlueprintGameplayTagLibrary.GetTagName(SingleTag)] = true
    end
  end
  self:RefreshUnNomalState()
end

function WBP_SkillCoolDown_C:BindOnBeginWaitSkillRetrigger(SkillType, MaxWaitTime)
  if self.SkillType ~= SkillType then
    return
  end
  print("WBP_SkillCoolDown_C:BindOnBeginWaitSkillRetrigger")
  self.IsInSkillRetrigger = true
  self.SkillRetriggerStartTime = UE.UKismetSystemLibrary.GetGameTimeInSeconds(self)
  self.SkillRetriggerMaxWaitTime = MaxWaitTime
  UpdateVisibility(self.Img_SkillRetrigger, true)
  self:PlayAnimation(self.Ani_SkillRetrigger_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end

function WBP_SkillCoolDown_C:BindOnSkillRetrigger(SkillType)
  if self.SkillType ~= SkillType then
    return
  end
  print("WBP_SkillCoolDown_C:BindOnSkillRetrigger")
  self:EndSkillRetrigger()
end

function WBP_SkillCoolDown_C:EndSkillRetrigger()
  self.IsInSkillRetrigger = false
  UpdateVisibility(self.Img_SkillRetrigger, false)
  if self:IsAnimationPlaying(self.Ani_SkillRetrigger_loop) then
    self:StopAnimation(self.Ani_SkillRetrigger_loop)
  end
end

function WBP_SkillCoolDown_C:BindOnEndWaitSkillRetrigger(SkillType)
  if self.SkillType ~= SkillType then
    return
  end
  print("WBP_SkillCoolDown_C:BindOnEndWaitSkillRetrigger")
  self:EndSkillRetrigger()
end

function WBP_SkillCoolDown_C:BindOnSkillCoolDownRemaining(Tag, DeltaDuration)
  if self.SkillCostType == UE.ESkillCostType.CostSkillEnergy then
  elseif self.SkillCostType == UE.ESkillCostType.CostSkillCount then
    if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(self.RecoverySkillTag, Tag) then
      print("WBP_SkillCoolDown_C:BindOnSkillCoolDownRemaining")
      self:PlayAnimationForward(self.Ani_SkillCooldown_Reduce)
    end
  elseif self.SkillCostType == UE.ESkillCostType.SkillCountAndEnergy then
    if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(self.RecoverySkillTag, Tag) then
      print("WBP_SkillCoolDown_C:BindOnSkillCoolDownRemaining")
      self:PlayAnimationForward(self.Ani_SkillCooldown_Reduce)
    end
  elseif UE.UBlueprintGameplayTagLibrary.HasTag(self.CoolDownTagContainer, Tag, false) then
    print("WBP_SkillCoolDown_C:BindOnSkillCoolDownRemaining")
    self:PlayAnimationForward(self.Ani_SkillCooldown_Reduce)
  end
end

function WBP_SkillCoolDown_C:OnHeroDying(Target)
  if Target == UE.UGameplayStatics.GetPlayerCharacter(self, 0) then
    UpdateVisibility(self, false)
  end
end

function WBP_SkillCoolDown_C:OnHeroRescue(Target)
  if Target == UE.UGameplayStatics.GetPlayerCharacter(self, 0) then
    UpdateVisibility(self, true)
  end
end

function WBP_SkillCoolDown_C:OnAttributeModifyCacheAdded(AttributeCacheModifyData)
  if UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.SkillCountAttribute) or UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.MaxSkillCountAttribute) then
    local TempTable = {
      Data = AttributeCacheModifyData,
      StartTime = os.clock()
    }
    self.AttributeModifyCacheList:Add(AttributeCacheModifyData.ModifyID, AttributeCacheModifyData)
    self.AttributeModifyCacheStartTime:Add(AttributeCacheModifyData.ModifyID, GetCurrentUTCTimestamp())
    self.IsUpdateAttributeCache = true
  end
end

function WBP_SkillCoolDown_C:OnAttributeModifyCacheRemove(AttributeCacheModifyData)
  if UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.SkillCountAttribute) or UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.MaxSkillCountAttribute) then
    if not self.AttributeModifyCacheList then
      self.AttributeModifyCacheList = {}
    end
    self.AttributeModifyCacheList:Remove(AttributeCacheModifyData.ModifyID)
    self.AttributeModifyCacheStartTime:Remove(AttributeCacheModifyData.ModifyID)
    self.IsUpdateAttributeCache = self.AttributeModifyCacheList:Length() > 0
    if not self.IsUpdateAttributeCache then
      local CurAttributeValue = self:GetSkillCountAttributeValue()
      self.CurrentSkillCountAttributeValue = CurAttributeValue
    end
  end
end

function WBP_SkillCoolDown_C:BindOnInputForbiddenUpdated(Owner, InputId, IsForbidden)
  if InputId == self.SkillType then
    self.IsForbidden = IsForbidden
    self:RefreshLockPanelVis()
    if not IsForbidden then
      self:SetCoolingStatus(self.RealCoolingStatus)
    end
  end
end

function WBP_SkillCoolDown_C:RefreshLockPanelVis()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  local InputComp = Character:GetComponentByClass(UE.URGActorInputHandle:StaticClass())
  if not InputComp then
    return
  end
  if InputComp:IsInputForbidden(self.SkillType) then
    self.LockPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:UpdateSkillPanelVisByMaxCount()
    self.RealCoolingStatus = self.CurState
    self:SetCoolingStatus(UE.ERGAbilityStateType.InCoolDown)
  else
    self.LockPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:UpdateSkillPanelVisByMaxCount()
  end
end

function WBP_SkillCoolDown_C:RefreshInfo(AbilityClass)
  self.AbilityClass = AbilityClass
  if UE.UKismetSystemLibrary.IsValidClass(AbilityClass) then
    self.CoolDownTagContainer = self:GetCoolDownTagContainer()
  end
  self:SetSkillBasicInfo()
  self.Img_DisableSkillIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Disable:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:InitSkillStyle()
  self:SetCoolingStatus(UE.ERGAbilityStateType.None)
end

function WBP_SkillCoolDown_C:SetSkillIcon(SpecialSkillIcon)
  SetImageBrushBySoftObject(self.Img_SkillIcon, SpecialSkillIcon)
  SetImageBrushBySoftObject(self.Img_DisableSkillIcon, SpecialSkillIcon)
end

function WBP_SkillCoolDown_C:BindOnAbilityTagUpdate(Tag, bTagExist, TargetActor)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if TargetActor ~= Character then
    return
  end
  local CharacterSettings = UE.URGCharacterSettings.GetSettings()
  if not CharacterSettings then
    return
  end
  if CharacterSettings.AbnormalStateTags:Contains(Tag) then
    self.IsInFreezeSkill = bTagExist
    self:RefreshUnNomalState()
  end
end

function WBP_SkillCoolDown_C:RefreshUnNomalState()
  self.IsInUnNormalState = self.IsInFreezeSkill or self.ForbiddenSkillTagList and table.count(self.ForbiddenSkillTagList) > 0
  if self.IsInUnNormalState then
    self.Img_Disable:SetVisibility(UE.ESlateVisibility.Visible)
    self.Img_DisableSkillIcon:SetVisibility(UE.ESlateVisibility.Visible)
    self.Img_DisableBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_SkillIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.RGStateController_Disable:ChangeStatus("Disable")
  else
    self.Img_Disable:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_DisableSkillIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_DisableBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_SkillIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.RGStateController_Disable:ChangeStatus("Able")
  end
  self:UpdateOperateOpacity()
end

function WBP_SkillCoolDown_C:BindOnCharacterEnterState(TargetActor, Tag)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if TargetActor ~= Character then
    return
  end
  if not UE.UBlueprintGameplayTagLibrary.HasTag(self.ForbiddenSkillTagContainer, Tag, true) then
    return
  end
  if not self.ForbiddenSkillTagList then
    self.ForbiddenSkillTagList = {}
  end
  self.ForbiddenSkillTagList[UE.UBlueprintGameplayTagLibrary.GetTagName(Tag)] = true
  self:RefreshUnNomalState()
end

function WBP_SkillCoolDown_C:BindOnCharacterExitState(TargetActor, Tag, IsBlocked)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if TargetActor ~= Character then
    return
  end
  if not UE.UBlueprintGameplayTagLibrary.HasTag(self.ForbiddenSkillTagContainer, Tag, true) then
    return
  end
  self.ForbiddenSkillTagList[UE.UBlueprintGameplayTagLibrary.GetTagName(Tag)] = nil
  self:RefreshUnNomalState()
end

function WBP_SkillCoolDown_C:BindOnClientPickupNotice(Pickup)
end

function WBP_SkillCoolDown_C:SetSkillBasicInfo()
  self.SkillId = self:GetSkillId()
  self:InitSkillCostValue()
  self:InitHasPersistentState()
  local Result, SkillRowInfo = GetRowData(DT.DT_Skill, self.SkillId)
  if not Result then
    return
  end
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SkillRowInfo.Icon)
  if IconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.Img_SkillIcon:SetBrush(Brush)
    self.Img_DisableSkillIcon:SetBrush(Brush)
  end
end

function WBP_SkillCoolDown_C:InitAbilityClass()
  local Character = self:GetOwningPlayerPawn()
  if not Character then
    return
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if not ASC then
    return
  end
  self.AbilityClass = ASC:GetAbilityClassByInputId(self.SkillType)
end

function WBP_SkillCoolDown_C:InitSkillStyle()
  self.SkillCostType = self:GetSkillCostType()
  if self.SkillCostType == UE.ESkillCostType.CostSkillEnergy then
    self.SkillCountPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:InitEnergyCostSkill()
  elseif self.SkillCostType == UE.ESkillCostType.CostSkillCount then
    self.EnergyBar:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:InitCountCostSkill()
    UpdateVisibility(self.SkillCountPanel, self:GetMaxSkillCountAttributeValue() > 1)
  elseif self.SkillCostType == UE.ESkillCostType.SkillCountAndEnergy then
    self:InitEnergyCostSkill()
    self:InitCountCostSkill()
    self.SkillCountPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self.SkillCountPanel, self:GetMaxSkillCountAttributeValue() > 1)
  else
    self.SkillCountPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.EnergyBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_SkillCoolDown_C:InitEnergyCostSkill()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      self.EnergyBar:InitInfo(Character)
      self.EnergyBar:UpdateBarGrid(75.0, 9.0)
      self.EnergyBar:SetVisibility(UE.ESlateVisibility.Visible)
    end
  }, 0.1, false)
end

function WBP_SkillCoolDown_C:InitCountCostSkill()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if ASC then
    self.RecoveryCountTime = self:GetRecoveryCountTimeAttributeValue()
    self:SetSkillCountValue()
    self:UpdateSkillPanelVisByMaxCount()
  end
  self.OldSkillCount = self:GetSkillCountAttributeValue()
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if CoreComp and not self.IsBoundAttribute then
    CoreComp:BindAttributeChanged(self.SkillCountAttribute, {
      self,
      self.BindOnSkillCountAttributeChanged
    })
    CoreComp:BindAttributeChanged(self.MaxSkillCountAttribute, {
      self,
      self.BindOnSkillCountAttributeChanged
    })
    CoreComp:BindAttributeChanged(self.EnergyAttribute, {
      self,
      self.BindOnEnergyAttributeChanged
    })
    CoreComp:BindAttributeChanged(self.MaxEnergyAttribute, {
      self,
      self.BindOnEnergyAttributeChanged
    })
    self.IsBoundAttribute = true
  end
end

function WBP_SkillCoolDown_C:SetSkillCountValue()
  local SkillCountValue = self:GetSkillCountAttributeValue()
  local RealSkillCount = SkillCountValue
  if 0.0 == self.SkillCostValue then
    print("WBP_SkillCoolDown_C:SetSkillCountValue SkillCostValue is 0!")
  else
    RealSkillCount = math.floor(SkillCountValue / self.SkillCostValue)
  end
  self.Txt_SkillCount:SetText(tostring(RealSkillCount))
end

function WBP_SkillCoolDown_C:BindOnAbilityDataRecovery(TargetAttribute, ServerStartTime)
  if not UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(TargetAttribute, self.SkillCountAttribute) then
    return
  end
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return
  end
  local CurWorldTime = GS:GetServerWorldTimeSeconds()
  self.RecoveryTime = math.clamp(CurWorldTime - ServerStartTime, 0.0, self.RecoveryCountTime)
  self:UpdateRecoverySkillCount()
end

function WBP_SkillCoolDown_C:UpdateSkillPanelVisByMaxCount()
  local MaxSkillCountValue = self:GetMaxSkillCountAttributeValue()
  if 0.0 ~= self.SkillCostValue then
    MaxSkillCountValue = math.floor(MaxSkillCountValue / self.SkillCostValue)
  end
  local SkillCount = self:GetSkillCountAttributeValue()
  if SkillCount >= 1 and self.SkillCostType ~= UE.ESkillCostType.None and not self.IsForbidden then
    self:UpdateCoolDownVis(false)
    self.IsShowSkillNumPanel = true
  else
    self.IsShowSkillNumPanel = false
  end
  UpdateVisibility(self.SkillCountPanel, MaxSkillCountValue > 1)
end

function WBP_SkillCoolDown_C:BindOnSkillCountAttributeChanged(NewValue, OldValue)
  self.CurrentSkillCountAttributeValue = self:GetSkillCountAttributeValue()
  self:SetSkillCountValue()
  self:UpdateSkillPanelVisByMaxCount()
  if self:GetSkillCountAttributeValue() == self:GetMaxSkillCountAttributeValue() then
    self:EndUpdateRecoveryCountTime()
    self.RGStateController_CountCoolDown:ChangeStatus("FullCount")
  else
    self.RGStateController_CountCoolDown:ChangeStatus("UnFullCount")
  end
  if math.floor(NewValue / self.SkillCostValue) > math.floor(self.OldSkillCount / self.SkillCostValue) and self.CurType ~= SkillStatus.NoCount then
    self.FX_SkillComplete:PlayAnimationForward(self.FX_SkillComplete.SkillComplete_0)
    LogicAudio.OnSkillActivation()
  end
  self.OldSkillCount = NewValue
  if self.IsShowSkillNumPanel then
    self:UpdateNoCDCoolDownVis()
  else
    self:UpdateCoolDownVis(true)
  end
end

function WBP_SkillCoolDown_C:BindOnEnergyAttributeChanged(NewValue, OldValue)
  local EnergyValue = self:GetAttributeValue(self.EnergyAttribute)
  local MaxEnergyValue = self:GetAttributeValue(self.MaxEnergyAttribute)
  local TargetValue = 0.0
  if 0 ~= MaxEnergyValue then
    TargetValue = EnergyValue / MaxEnergyValue
  end
  self:UpdateCoolDownMaterial(math.clamp(TargetValue, 0.0, 1.0))
end

function WBP_SkillCoolDown_C:GetRecoveryCountTimeAttributeValue()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return 0
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if not ASC then
    return 0
  end
  local AttributeValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, self.RecoveryCountTimeAttribute, nil)
  return AttributeValue
end

function WBP_SkillCoolDown_C:UpdateRecoverySkillCount()
  self.IsRecovery = true
  self:UpdateCoolDownMaterial(1.0)
  self.Progress_CoolDown:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.RecoveryCountTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_SkillCoolDown_C.OnUpdateRecoveryCountTime
  }, 0.1, true)
end

function WBP_SkillCoolDown_C:EndUpdateRecoveryCountTime()
  self.IsRecovery = false
  self.RecoveryTime = 0
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RecoveryCountTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RecoveryCountTimer)
  end
end

function WBP_SkillCoolDown_C:OnUpdateRecoveryCountTime()
  self.RecoveryTime = self.RecoveryTime + 0.1
  if self.RecoveryTime >= self.RecoveryCountTime then
    self:EndUpdateRecoveryCountTime()
  else
    self:UpdateCoolDownMaterial(self.RecoveryTime / self.RecoveryCountTime)
  end
end

function WBP_SkillCoolDown_C:BindOnGameplayEffectDurationChangedDelegate(TagContainer)
end

function WBP_SkillCoolDown_C:SetCoolingStatus(State)
  if self:IsSkillForbidden() then
    State = UE.ERGAbilityStateType.InCoolDown
  end
  if self.CurState and self.CurState == State then
    return
  end
  self.CurState = State
  if not self.IsInUnNormalState then
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_SkillIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  if State == UE.ERGAbilityStateType.None then
    self.Img_Bottom:SetBrush(self.NormalBottom)
    self.Img_SkillIcon:SetColorAndOpacity(self.NormalIconColor)
    self.WBP_CustomKeyName:SetBottomOpacity(self.NormalOperateBottomOpacity)
    self.WBP_CustomKeyName:SetTextOpacity(self.NormalOperateTextOpacity)
  elseif State == UE.ERGAbilityStateType.Activated then
    self.Img_Bottom:SetBrush(self.ActivedBottom)
    self.Img_SkillIcon:SetColorAndOpacity(self.ActivedIconColor)
    self.WBP_CustomKeyName:SetBottomOpacity(self.NormalOperateBottomOpacity)
    self.WBP_CustomKeyName:SetTextOpacity(self.NormalOperateTextOpacity)
    self:PlayAniInAnimation()
  elseif State == UE.ERGAbilityStateType.InCoolDown then
    self.Img_Bottom:SetBrush(self.CoolDownBottom)
    self.Img_SkillIcon:SetColorAndOpacity(self.CoolDownIconColor)
    self.WBP_CustomKeyName:SetBottomOpacity(self.NotCountOperateBottomOpacity)
    self.WBP_CustomKeyName:SetTextOpacity(self.NotCountOperateTextOpacity)
    self:PlayAniInAnimation()
  end
  self:PlayAniOutAnimation()
  self:UpdateOperateOpacity()
end

function WBP_SkillCoolDown_C:PlayAniInAnimation()
  self:PlayAnimationForward(self.Ani_In)
  self.IsInPressState = true
end

function WBP_SkillCoolDown_C:PlayAniOutAnimation()
  if not self.IsInPressState then
    return
  end
  if self.CurState == UE.ERGAbilityStateType.Activated or self.CurState == UE.ERGAbilityStateType.InCoolDown then
    return
  end
  self:PlayAnimationForward(self.Ani_Out)
  self.IsInPressState = false
end

function WBP_SkillCoolDown_C:UpdateOperateOpacity()
  if self.IsInUnNormalState or self.CurState == UE.ERGAbilityStateType.InCoolDown then
    self.WBP_CustomKeyName:SetBottomOpacity(self.NotCountOperateBottomOpacity)
    self.WBP_CustomKeyName:SetTextOpacity(self.NotCountOperateTextOpacity)
  else
    self.WBP_CustomKeyName:SetBottomOpacity(self.NormalOperateBottomOpacity)
    self.WBP_CustomKeyName:SetTextOpacity(self.NormalOperateTextOpacity)
  end
end

function WBP_SkillCoolDown_C:UpdateCoolDownVis(IsShow)
  if self.CurCoolDownVisState ~= nil and self.CurCoolDownVisState == IsShow then
    return
  end
  self.CurCoolDownVisState = IsShow
  if IsShow then
    if self.IsShowSkillNumPanel then
    else
      self.CoolDownPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif self.IsShowSkillNumPanel then
  else
    self.CoolDownPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.RGTextCountDown:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_SkillCoolDown_C:Destruct()
  self:ListenPressedInputEvent(false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RecoveryCountTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RecoveryCountTimer)
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  Character.OnGameplayEffectDurationChangedDelegate:Remove(self, WBP_SkillCoolDown_C.BindOnGameplayEffectDurationChangedDelegate)
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if CoreComp then
    CoreComp:UnBindAttributeChanged(self.SkillCountAttribute, {
      self,
      self.BindOnSkillCountAttributeChanged
    })
    CoreComp:UnBindAttributeChanged(self.MaxSkillCountAttribute, {
      self,
      self.BindOnSkillCountAttributeChanged
    })
    CoreComp:UnBindAttributeChanged(self.EnergyAttribute, {
      self,
      self.BindOnEnergyAttributeChanged
    })
    CoreComp:UnBindAttributeChanged(self.MaxEnergyAttribute, {
      self,
      self.BindOnEnergyAttributeChanged
    })
    self.IsBoundAttribute = false
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if ASC then
    ASC.EventOnAbilityDataRecovery:Remove(self, WBP_SkillCoolDown_C.BindOnAbilityDataRecovery)
  end
  if self:IsAnimationPlaying(self.Ani_SkillRetrigger_loop) then
    self:StopAnimation(self.Ani_SkillRetrigger_loop)
  end
  UnListenObjectMessage(GMP.MSG_OnAbilityTagUpdate, self)
  UnListenObjectMessage(GMP.MSG_Interact_ClientPickup, self)
  self:ListenChangeSkillAdditionalSlotVis(false)
  UnListenObjectMessage(GMP.MSG_World_Input_OnForbiddenUpdated, self)
  UnListenObjectMessage(GMP.MSG_Hero_Dying, self)
  UnListenObjectMessage(GMP.MSG_Hero_NotifyRescue, self)
  UnListenObjectMessage(GMP.MSG_World_OnAttributeModifyCacheAdded, self)
  UnListenObjectMessage(GMP.MSG_World_OnAttributeModifyCacheRemove, self)
  UnListenObjectMessage(GMP.MSG_CharacterSkill_BeginWaitSkillRetrigger, self)
  UnListenObjectMessage(GMP.MSG_CharacterSkill_OnSkillRetrigger, self)
  UnListenObjectMessage(GMP.MSG_CharacterSkill_EndWaitSkillRetrigger, self)
  UnListenObjectMessage(GMP.MSG_World_Skill_OnSkillCoolDownRemaining, self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnEnterState, self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnExitState, self)
end

return WBP_SkillCoolDown_C
