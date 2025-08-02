local WBP_MainCross_C = UnLua.Class()
local CostAmmoPolicyPath = "/Game/Rouge/Gameplay/Weapon/Policy/BP_LaunchPolicy_CostAmmoCharge.BP_LaunchPolicy_CostAmmoCharge_C"

function WBP_MainCross_C:Construct()
  self.OwningCharacter = self:GetOwningPlayerPawn()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC then
    local DamageComp = PC:GetComponentByClass(UE.URGPlayerDamageComponent:StaticClass())
    if DamageComp then
      DamageComp.OnMakeDamage:Add(self, WBP_MainCross_C.BindOnMakeDamage)
    end
    PC.OnPawnAcknowledged:Add(self, WBP_MainCross_C.BindOnPawnAcknowledged)
  end
  local EquipmentComp = self.OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent:StaticClass())
  if EquipmentComp then
    EquipmentComp.OnCurrentWeaponChanged:Add(self, WBP_MainCross_C.BindOnCurrentWeaponChanged)
  end
  ListenForInputAction("NormalFire", UE.EInputEvent.IE_Pressed, false, {
    self,
    WBP_MainCross_C.BindOnNormalFirePressed
  })
  local LogicStateCom = self.OwningCharacter:GetComponentByClass(UE.URGLogicStateComponent:StaticClass())
  if LogicStateCom then
    LogicStateCom.PostAddCondition:Add(self, WBP_MainCross_C.BindOnPostAddCondition)
  end
  self.AmmoCountBarPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:BindOnCurrentWeaponChanged()
  self.LastWeaponsState = {}
  self.CostAmmoChargePolicy:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_QTEReloadingProgress:SetVisibility(UE.ESlateVisibility.Collapsed)
  ListenObjectMessage(nil, GMP.MSG_World_Weapon_OnInitReloadQTE, self, self.BindOnInitReloadQTE)
  ListenObjectMessage(nil, GMP.MSG_World_Weapon_OnReloadQTESucceed, self, self.BindOnReloadQTESucceed)
  ListenObjectMessage(nil, GMP.MSG_World_Weapon_OnReloadQTEFailed, self, self.BindOnReloadQTEFailed)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnEnterState, self, self.BindOnCharacterEnterState)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnExitState, self, self.BindOnCharacterExitState)
end

function WBP_MainCross_C:BindOnInitReloadQTE(TargetActor, OldPercent, NewPercent)
  if TargetActor ~= self.OwningCharacter then
    return
  end
  local OriginPercent = NewPercent - OldPercent
  self.QTEStartPercent = OldPercent + OriginPercent * self.QTEDisplaySectionReducePercent / 2
  self.QTEEndPercent = NewPercent - OriginPercent * self.QTEDisplaySectionReducePercent / 2
  print("WBP_MainCross_C:BindOnInitReloadQTE", OldPercent, NewPercent)
  self.Img_QTEReloadingProgress:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local Percent = self.QTEEndPercent - self.QTEStartPercent
  local DynamicMaterial = self.Img_QTEReloadingProgress:GetDynamicMaterial()
  if DynamicMaterial then
    DynamicMaterial:SetScalarParameterValue("percent", Percent)
  end
  local Angle = 360 * self.QTEStartPercent
  self.Img_QTEReloadingProgress:SetRenderTransformAngle(Angle)
  self.Img_QTEReloadingProgress:SetColorAndOpacity(self.QTEReloadSuccessColor)
end

function WBP_MainCross_C:BindOnReloadQTESucceed(TargetActor)
  if TargetActor ~= self.OwningCharacter then
    return
  end
  print("WBP_MainCross_C:BindOnReloadQTESucceed")
  self.Img_QTEReloadingProgress:SetColorAndOpacity(self.QTEReloadSuccessColor)
  self:PlayAnimationForward(self.Ani_QTE_succeed)
end

function WBP_MainCross_C:BindOnReloadQTEFailed(TargetActor)
  if TargetActor ~= self.OwningCharacter then
    return
  end
  print("WBP_MainCross_C:BindOnReloadQTEFailed")
  self.Img_QTEReloadingProgress:SetColorAndOpacity(self.QTEReloadFailColor)
  self:PlayAnimationForward(self.Ani_QTE_defeat)
end

function WBP_MainCross_C:BindOnCharacterEnterState(TargetActor, Tag)
  if TargetActor ~= self.OwningCharacter then
    return
  end
end

function WBP_MainCross_C:BindOnCharacterExitState(TargetActor, Tag, bBlocked)
  if TargetActor ~= self.OwningCharacter then
    return
  end
  if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(Tag, self.ReloadStateTag) then
    self.Img_QTEReloadingProgress:SetVisibility(UE.ESlateVisibility.Collapsed)
    if self:IsAnimationPlaying(self.Ani_QTE_succeed) then
      self:StopAnimation(self.Ani_QTE_succeed)
    end
    if self:IsAnimationPlaying(self.Ani_QTE_defeat) then
      self:StopAnimation(self.Ani_QTE_defeat)
    end
  end
end

function WBP_MainCross_C:BindOnPostAddCondition(InCondition)
  local WantReloadTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag("State.Condition.WantReload")
  if UE.UBlueprintGameplayTagLibrary.MatchesTag(InCondition, WantReloadTag, true) then
    self.bWantReload = true
  else
    self.bWantReload = false
  end
end

function WBP_MainCross_C:BindOnNormalFirePressed()
  if self.bWantReload then
    LogicAudio.OnGunShotDry()
  end
end

function WBP_MainCross_C:OnAnimationFinished(InAnimation)
  if InAnimation == self.ShowNormalHitAnim then
    self:BindOnNormalHitAnimFinished()
  elseif InAnimation == self.ShowLuckyShotHitAnim then
    self:BindOnLuckyShotAnimFinished()
  end
end

function WBP_MainCross_C:BindOnNormalHitAnimFinished()
  self.HitAnimPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_MainCross_C:BindOnLuckyShotAnimFinished()
  self.LuckyShotAnimPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_MainCross_C:BindOnMakeDamage(SourceActor, TargetActor, Params)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character ~= SourceActor then
    return
  end
  local IsDot = UE.URGDamageStatics.IsDot(Params)
  local IsWeakHit = UE.URGDamageStatics.IsWeakHit(Params)
  local IsKill = UE.URGDamageStatics.IsKill(Params)
  local IsLuckyShot = UE.URGDamageStatics.IsLuckyShot(Params)
  if not IsDot then
    self:PlayHitAnimation(IsWeakHit, IsLuckyShot)
    if IsKill and TargetActor and TargetActor:IsValid() and not TargetActor:Cast(UE.ARGMechanism) then
      self:ShowKillFeedbackAnim()
    end
  end
end

function WBP_MainCross_C:BindOnPawnAcknowledged(InPawn)
  self.OwningCharacter = InPawn
  local EquipmentComp = self.OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent:StaticClass())
  if EquipmentComp then
    EquipmentComp.OnCurrentWeaponChanged:Add(self, WBP_MainCross_C.BindOnCurrentWeaponChanged)
  end
end

function WBP_MainCross_C:BindOnCurrentWeaponChanged(OldWeapon, NewWeapon)
  print("CurrentWeaponChanged")
  local EquipmentComp = self.OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurWeapon = EquipmentComp:GetCurrentWeapon()
  if not CurWeapon then
    return
  end
  self:InitChargePolicyUI()
  self:InitAmmoCountBar(CurWeapon:GetItemId())
  self:SetCanShowReloadingPanel(true)
end

function WBP_MainCross_C:InitChargePolicyUI()
  local EquipmentComp = self.OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurWeapon = EquipmentComp:GetCurrentWeapon()
  if not CurWeapon then
    return
  end
  local ChargePolicyClass = UE.UClass.Load(CostAmmoPolicyPath)
  local Result, WeaponRowInfo = GetRowData(DT.DT_Weapon, CurWeapon:GetItemId())
  if not Result then
    return
  end
  local LaunchAsset
  if WeaponRowInfo.ShoulderFiringConfig.bChangeLaunchPolicy then
    LaunchAsset = WeaponRowInfo.ShoulderFiringConfig.LaunchConfig.LaunchAsset
  else
    LaunchAsset = WeaponRowInfo.LaunchConfig.LaunchAsset
  end
  local Policy = LaunchAsset:GetLaunchPolicy()
  self.IsShowCostAmmoPolicy = ChargePolicyClass == UE.UGameplayStatics.GetObjectClass(Policy)
  if self.IsShowCostAmmoPolicy then
  end
end

function WBP_MainCross_C:InitAmmoCountBar(Id)
  self.AmmoCountBarPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowInfo = GetDataLibraryObj().GetWeaponRowInfoById(Id, nil)
  if not Result then
    return
  end
  if not RowInfo.HasAmmoCountBar then
    self.RGImageReloadingProgress:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  self.RGImageReloadingProgress:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.AmmoCountBarPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local TargetClass = UE.URGAssetManager.GetAssetByPath(RowInfo.AmmoCountBarWidgetClass, true)
  if not UE.UKismetSystemLibrary.IsValidClass(TargetClass) then
    TargetClass = self.DefaultAmmoCountBarWidgetClass
  end
  local IsNeedCreate = true
  local AllChildren = self.AmmoCountBarPanel:GetAllChildren()
  for key, SingleWidget in pairs(AllChildren) do
    if UE.UGameplayStatics.GetObjectClass(SingleWidget) == TargetClass then
      self.AmmoCountBar = SingleWidget
      IsNeedCreate = false
    end
    SingleWidget:Hide()
  end
  if IsNeedCreate then
    self.AmmoCountBar = UE.UWidgetBlueprintLibrary.Create(self, TargetClass)
    local Slot = self.AmmoCountBarPanel:AddChild(self.AmmoCountBar)
    local Anchors = UE.FAnchors()
    Anchors.Minimum = UE.FVector2D(0.0, 0.0)
    Anchors.Maximum = UE.FVector2D(1.0, 1.0)
    Slot:SetAnchors(Anchors)
    local Margin = UE.FMargin()
    Margin.Bottom = 0.0
    Margin.Left = 0.0
    Margin.Right = 0.0
    Margin.Top = 0.0
    Slot:SetOffsets(Margin)
    self.AmmoCountBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.AmmoCountBar then
    self.AmmoCountBar:InitInfo()
  end
end

function WBP_MainCross_C:ShowKillFeedbackAnim()
  self:HideNormalHit()
  self:HideBloodHit()
  self.WBP_KillFeedbackCross:StopHitAnim()
  self.WBP_KillFeedbackCross:SetVisibility(UE.ESlateVisibility.Visible)
  self.WBP_KillFeedbackCross:PlayHitAnim(self.AnimSpeed)
end

function WBP_MainCross_C:SetAnimImageColor(Brush)
  local AllChildren = self.HitAnimPanel:GetAllChildren()
  local SlateBrush = UE.FSlateBrush()
  SlateBrush.ResourceObject = Brush
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetRenderScale(UE.FVector2D(1.0, 1.0))
    SingleItem:SetBrush(SlateBrush)
  end
end

function WBP_MainCross_C:HideNormalHit()
  self.HitAnimPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.LuckyShotAnimPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_MainCross_C:HideBloodHit()
  self.WBP_BloodHitCross:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_MainCross_C:HideKillHit()
  self.WBP_KillFeedbackCross:StopHitAnim()
  self.WBP_KillFeedbackCross:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_MainCross_C:PlayHitAnimation(IsWeakHit, IsLuckyShot)
  if IsWeakHit then
    self:HideNormalHit()
    self:HideKillHit()
    self.WBP_BloodHitCross:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WBP_BloodHitCross:PlayHitAnimation(IsLuckyShot, self.AnimSpeed)
  else
    self.WBP_BloodHitCross:StopAllHitAnimations()
    if IsLuckyShot then
      if not self:IsAnimationPlaying(self.ShowLuckyShotHitAnim) then
        self.LuckyShotAnimPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self:PlayAnimationForward(self.ShowLuckyShotHitAnim, self.AnimSpeed)
      end
    else
      if not self:IsAnimationPlaying(self.ShowNormalHitAnim) then
        self:SetAnimImageColor(self.NormalHitBrushes)
        self.HitAnimPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
      self:StopAnimation(self.ShowNormalHitAnim)
      self:PlayAnimationForward(self.ShowNormalHitAnim, self.AnimSpeed)
    end
  end
end

function WBP_MainCross_C:Destruct()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC then
    local DamageComp = PC:GetComponentByClass(UE.URGPlayerDamageComponent:StaticClass())
    if DamageComp then
      DamageComp.OnMakeDamage:Remove(self, WBP_MainCross_C.BindOnMakeDamage)
    end
    PC.OnPawnAcknowledged:Remove(self, WBP_MainCross_C.BindOnPawnAcknowledged)
  end
  local EquipmentComp = self.OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent:StaticClass())
  if EquipmentComp then
    EquipmentComp.OnCurrentWeaponChanged:Remove(self, WBP_MainCross_C.BindOnCurrentWeaponChanged)
  end
  UnListenObjectMessage(GMP.MSG_World_Weapon_OnInitReloadQTE, self)
  UnListenObjectMessage(GMP.MSG_World_Weapon_OnReloadQTESucceed, self)
  UnListenObjectMessage(GMP.MSG_World_Weapon_OnReloadQTEFailed, self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnEnterState, self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnExitState, self)
end

return WBP_MainCross_C
