local WBP_MainSkillCoolDown_C = UnLua.Class()
function WBP_MainSkillCoolDown_C:Construct()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if CoreComp then
    CoreComp:BindAttributeChanged(self.EnergyAttribute, {
      self,
      self.BindOnEnergyAttributeChanged
    })
    CoreComp:BindAttributeChanged(self.MaxEnergyAttribute, {
      self,
      self.BindOnEnergyAttributeChanged
    })
  end
  self:InitAbilityClass()
  self:SetSkillBasicInfo()
  self:RefreshLockPanelVis()
  self:InitSkillUnNormalState()
  local DynamicMaterial = self.Img_CoolDown:GetDynamicMaterial()
  if DynamicMaterial then
    DynamicMaterial:SetScalarParameterValue("CirclePrecent", 0)
  end
  self:UpdateSkillCoolDownPercent()
  self:ListenPressedInputEvent(true)
  ListenObjectMessage(nil, GMP.MSG_OnAbilityTagUpdate, self, self.BindOnAbilityTagUpdate)
  ListenObjectMessage(nil, GMP.MSG_World_Input_OnForbiddenUpdated, self, self.BindOnInputForbiddenUpdated)
  ListenObjectMessage(nil, GMP.MSG_Hero_Dying, self, self.OnHeroDying)
  ListenObjectMessage(nil, GMP.MSG_Hero_NotifyRescue, self, self.OnHeroRescue)
  ListenObjectMessage(Character, GMP.MSG_CharacterSkill_BeginWaitSkillRetrigger, self, self.BindOnBeginWaitSkillRetrigger)
  ListenObjectMessage(Character, GMP.MSG_CharacterSkill_EndWaitSkillRetrigger, self, self.BindOnEndWaitSkillRetrigger)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnEnterState, self, self.BindOnCharacterEnterState)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnExitState, self, self.BindOnCharacterExitState)
end
function WBP_MainSkillCoolDown_C:InitSkillUnNormalState(...)
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
function WBP_MainSkillCoolDown_C:BindOnBeginWaitSkillRetrigger(SkillType, MaxWaitTime)
  if self.SkillType ~= SkillType then
    return
  end
  print("WBP_MainSkillCoolDown_C:BindOnBeginWaitSkillRetrigger")
  self.IsInSkillRetrigger = true
  self.SkillRetriggerStartTime = UE.UKismetSystemLibrary.GetGameTimeInSeconds(self)
  self.SkillRetriggerMaxWaitTime = MaxWaitTime
  UpdateVisibility(self.Img_SkillRetrigger, true)
  UpdateVisibility(self.CanvasPanel_SkillRetrigger, true)
  self:PlayAnimation(self.Ani_SkillRetrigger_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end
function WBP_MainSkillCoolDown_C:EndSkillRetrigger()
  self.IsInSkillRetrigger = false
  UpdateVisibility(self.Img_SkillRetrigger, false)
  UpdateVisibility(self.CanvasPanel_SkillRetrigger, false)
  if self:IsAnimationPlaying(self.Ani_SkillRetrigger_loop) then
    self:StopAnimation(self.Ani_SkillRetrigger_loop)
  end
end
function WBP_MainSkillCoolDown_C:BindOnEndWaitSkillRetrigger(SkillType)
  if self.SkillType ~= SkillType then
    return
  end
  print("WBP_SkillCoolDown_C:BindOnEndWaitSkillRetrigger")
  self:EndSkillRetrigger()
end
function WBP_MainSkillCoolDown_C:OnHeroDying(Target)
  if Target == UE.UGameplayStatics.GetPlayerCharacter(self, 0) then
    UpdateVisibility(self, false)
  end
end
function WBP_MainSkillCoolDown_C:OnHeroRescue(Target)
  if Target == UE.UGameplayStatics.GetPlayerCharacter(self, 0) then
    UpdateVisibility(self, true)
  end
end
function WBP_MainSkillCoolDown_C:BindOnInputForbiddenUpdated(Owner, InputId, IsForbidden)
  if InputId == self.SkillType then
    self.IsForbidden = IsForbidden
    self:UpdateSkillPercentPanelVis()
    self:RefreshLockPanelVis()
    if not IsForbidden and self.RealCoolDownState ~= nil and not self.RealCoolDownState then
      self:PlayAnimationForward(self.Full_Ani)
      self:ChangeSkillStatus(self.RealCoolDownState)
    end
  end
end
function WBP_MainSkillCoolDown_C:RefreshLockPanelVis()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  local InputComp = Character:GetComponentByClass(UE.URGActorInputHandle:StaticClass())
  if not InputComp then
    return
  end
  if InputComp:IsInputForbidden(self.SkillType) then
    self.LockPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:ChangeSkillStatus(true)
  else
    self.LockPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_MainSkillCoolDown_C:BindOnEnergyAttributeChanged(NewValue, OldValue)
  self:UpdateSkillCoolDownPercent()
  if not self.IsCoolDown and LogicHUD.OldMainSkillEnergyValue and LogicHUD.OldMainSkillMaxEnergyValue and LogicHUD.OldMainSkillEnergyValue < LogicHUD.OldMainSkillMaxEnergyValue then
    local HUD = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
    if HUD then
      HUD:ChangeMainSkillReadyWindowVis(true)
    end
    NotifyObjectMessage(nil, GMP.MSG_Voice_ActivateMainSkill)
  end
  LogicHUD.OldMainSkillEnergyValue = self:GetAttributeValue(self.EnergyAttribute)
  LogicHUD.OldMainSkillMaxEnergyValue = self:GetAttributeValue(self.MaxEnergyAttribute)
end
function WBP_MainSkillCoolDown_C:BindOnAbilityTagUpdate(Tag, bTagExist, TargetActor)
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
function WBP_MainSkillCoolDown_C:RefreshUnNomalState(...)
  self.IsInUnNormalState = self.IsInFreezeSkill or self.ForbiddenSkillTagList and table.count(self.ForbiddenSkillTagList) > 0
  self:ChangeProhibitVis(self.IsInUnNormalState)
end
function WBP_MainSkillCoolDown_C:BindOnCharacterEnterState(TargetActor, Tag)
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
function WBP_MainSkillCoolDown_C:BindOnCharacterExitState(TargetActor, Tag, IsBlocked)
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
function WBP_MainSkillCoolDown_C:ChangeProhibitVis(IsInProhibitState)
  if IsInProhibitState then
    self.Img_Disable:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Disable:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_MainSkillCoolDown_C:GetAttributeValue(Attribute)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return 0
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if not ASC then
    return 0
  end
  local AttributeValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, Attribute, nil)
  return AttributeValue
end
function WBP_MainSkillCoolDown_C:UpdateSkillCoolDownPercent()
  local EnergyValue = self:GetAttributeValue(self.EnergyAttribute)
  local MaxEnergyValue = self:GetAttributeValue(self.MaxEnergyAttribute)
  local TargetValue = 0.0
  if 0 ~= MaxEnergyValue then
    TargetValue = EnergyValue / MaxEnergyValue
  end
  self:ChangeSkillStatus(EnergyValue < MaxEnergyValue)
  self.Txt_Percent:SetText(math.floor(TargetValue * 100))
  local DynamicMaterial = self.Img_CoolDown:GetDynamicMaterial()
  if DynamicMaterial then
    DynamicMaterial:SetScalarParameterValue("CirclePrecent", TargetValue)
  end
end
function WBP_MainSkillCoolDown_C:UpdateSkillPercentPanelVis()
  if not self.IsCoolDown or self.IsForbidden then
    self.SkillPercentPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.SkillPercentPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_MainSkillCoolDown_C:ChangeSkillStatus(IsCoolDown)
  if self:IsSkillForbidden() then
    self.RealCoolDownState = IsCoolDown
    IsCoolDown = true
  end
  if self.IsCoolDown ~= nil and self.IsCoolDown == IsCoolDown then
    return
  end
  self.IsCoolDown = IsCoolDown
  self.Img_Icon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Img_Icon_touying:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Img_HollowOut:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:UpdateSkillPercentPanelVis()
  if IsCoolDown then
    self.Img_Bottom:SetRenderOpacity(self.CoolDownBottomOpacity)
    self.KeyNameItem:SetBottomOpacity(self.CoolDownOperateBottomOpacity)
    self.KeyNameItem:SetTextOpacity(self.CoolDownOperateTextOpacity)
    self.Img_Icon:SetRenderOpacity(self.CoolDownIconOpacity)
    self.Img_Icon_touying:SetRenderOpacity(self.CoolDownIconOpacity)
    self.Img_Icon:SetColorAndOpacity(self.CoolDownIconColor)
    if self:IsAnimationPlaying(self.loop_Ani) then
      self:StopAnimation(self.loop_Ani)
    end
    if self:IsAnimationPlaying(self.Full_Ani) then
      self:StopAnimation(self.Full_Ani)
    end
    self:PlayAnimationForward(self.click_Ani)
    self:PlayAniInAnimation()
    LogicHUD.IsMainSkillCoolDown = true
  else
    self.Img_Bottom:SetRenderOpacity(self.NormalBottomOpacity)
    self.KeyNameItem:SetBottomOpacity(self.NormalOperateBottomOpacity)
    self.KeyNameItem:SetTextOpacity(self.NormalOperateTextOpacity)
    self.Img_Icon:SetRenderOpacity(self.NormalIconOpacity)
    self.Img_Icon_touying:SetRenderOpacity(self.NormalIconOpacity)
    self.Img_Icon:SetColorAndOpacity(self.NormalIconColor)
    self:PlayAnimationForward(self.Full_Ani)
    self:PlayAnimation(self.loop_Ani, 0.0, 0, UE.EUMGSequencePlayMode.Forward)
    if self.CanShowHollowOutIcon then
      self.Img_HollowOut:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Img_HollowOut:SetRenderOpacity(self.NormalIconOpacity)
      self.Img_Icon:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Img_Icon_touying:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    self:PlayAniOutAnimation()
  end
end
function WBP_MainSkillCoolDown_C:PlayAniInAnimation()
  self:PlayAnimationForward(self.Ani_Press)
  self.IsInPressState = true
  local HUD = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
  if HUD then
    HUD:ChangeMainSkillReadyWindowVis(false)
  end
end
function WBP_MainSkillCoolDown_C:PlayAniOutAnimation()
  if not self.IsInPressState then
    return
  end
  if self.IsCoolDown then
    return
  end
  self:PlayAnimationForward(self.Ani_loosen)
  self.IsInPressState = false
end
function WBP_MainSkillCoolDown_C:SetSkillBasicInfo()
  self.SkillId = self:GetSkillId()
  self.CanShowHollowOutIcon = false
  local Result, SkillRowInfo = GetRowData(DT.DT_Skill, self.SkillId)
  if Result then
    SetImageBrushBySoftObject(self.Img_Icon, SkillRowInfo.Icon)
    SetImageBrushBySoftObject(self.Img_Icon_touying, SkillRowInfo.Icon)
    if UE.UKismetSystemLibrary.IsValidSoftObjectReference(SkillRowInfo.HollowOutIcon) then
      self.CanShowHollowOutIcon = true
      SetImageBrushBySoftObject(self.Img_HollowOut, SkillRowInfo.HollowOutIcon)
    end
  end
end
function WBP_MainSkillCoolDown_C:InitAbilityClass()
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
function WBP_MainSkillCoolDown_C:Destruct()
  UnListenObjectMessage(GMP.MSG_OnAbilityTagUpdate, self)
  UnListenObjectMessage(GMP.MSG_World_Input_OnForbiddenUpdated, self)
  UnListenObjectMessage(GMP.MSG_Hero_Dying, self)
  UnListenObjectMessage(GMP.MSG_Hero_NotifyRescue, self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnEnterState, self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnExitState, self)
  self:ListenPressedInputEvent(false)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if CoreComp then
    CoreComp:UnBindAttributeChanged(self.EnergyAttribute, {
      self,
      self.BindOnEnergyAttributeChanged
    })
    CoreComp:UnBindAttributeChanged(self.MaxEnergyAttribute, {
      self,
      self.BindOnEnergyAttributeChanged
    })
  end
end
return WBP_MainSkillCoolDown_C
