local WBP_CommonAmmoCountBar_C = UnLua.Class()

function WBP_CommonAmmoCountBar_C:InitInfo()
  self:ChangeWidgetVis()
  local OwningCharacter = self:GetOwningPlayerPawn()
  if not OwningCharacter then
    return
  end
  local EquipmentComp = OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if EquipmentComp then
    local CurWeapon = EquipmentComp:GetCurrentWeapon()
    if CurWeapon then
      CurWeapon.OnNotifyAmmoChanged:Add(self, WBP_CommonAmmoCountBar_C.BindOnNotifyAmmoChanged)
      self:UpdateAmmoProgress(CurWeapon:GetClipAmmo())
    end
  end
  local LogicStateComp = OwningCharacter:GetComponentByClass(UE.URGLogicStateComponent:StaticClass())
  if not LogicStateComp then
    return
  end
  LogicStateComp.PostEnterState:Add(self, WBP_CommonAmmoCountBar_C.BindOnPostEnterState)
  LogicStateComp.PostExitState:Add(self, WBP_CommonAmmoCountBar_C.BindOnPostExitState)
end

function WBP_CommonAmmoCountBar_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  local OwningCharacter = self:GetOwningPlayerPawn()
  if OwningCharacter then
    local LogicStateComp = OwningCharacter:GetComponentByClass(UE.URGLogicStateComponent:StaticClass())
    if LogicStateComp then
      LogicStateComp.PostEnterState:Remove(self, WBP_CommonAmmoCountBar_C.BindOnPostEnterState)
      LogicStateComp.PostExitState:Remove(self, WBP_CommonAmmoCountBar_C.BindOnPostExitState)
    end
    local EquipmentComp = OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
    if EquipmentComp then
      local CurWeapon = EquipmentComp:GetCurrentWeapon()
      if CurWeapon then
        CurWeapon.OnNotifyAmmoChanged:Remove(self, WBP_CommonAmmoCountBar_C.BindOnNotifyAmmoChanged)
      end
    end
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ShowWidgetTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ShowWidgetTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ReloadAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ReloadAnimTimer)
  end
end

function WBP_CommonAmmoCountBar_C:BindOnNotifyAmmoChanged(ClipAmmo)
  self:UpdateAmmoProgress(ClipAmmo)
  self:ClearReloadAnimTimer()
end

function WBP_CommonAmmoCountBar_C:UpdateAmmoProgress(ClipAmmo)
  local OwningCharacter = self:GetOwningPlayerPawn()
  if not OwningCharacter then
    return
  end
  local EquipmentComp = OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurWeapon = EquipmentComp:GetCurrentWeapon()
  if not CurWeapon then
    return
  end
  local DynamicMaterial = self.Img_Progress:GetDynamicMaterial()
  if DynamicMaterial then
    local Percent = (1 - ClipAmmo / CurWeapon:GetMainAttributeListAmmoWithAccessories()) / 4
    DynamicMaterial:SetScalarParameterValue("percent", Percent)
  end
end

function WBP_CommonAmmoCountBar_C:BindOnPostEnterState(State)
  if not UE.UBlueprintGameplayTagLibrary.HasTag(self.AffectVisStateList, State, true) then
    return
  end
  self:ChangeWidgetVis()
  if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(self.ReloadState, State) then
    self:PlayReloadAmmoAnimation()
  end
end

function WBP_CommonAmmoCountBar_C:PlayReloadAmmoAnimation()
  local OwningCharacter = self:GetOwningPlayerPawn()
  if not OwningCharacter then
    return
  end
  local EquipmentComp = OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurWeapon = EquipmentComp:GetCurrentWeapon()
  if not CurWeapon then
    return
  end
  self.CurClipAmmoForAnim = CurWeapon:GetClipAmmo()
  local MaxAmmo = CurWeapon:GetMainAttributeListAmmoWithAccessories()
  if 0 == self.ReloadAnimDuration then
    return
  end
  self:ClearReloadAnimTimer()
  local PerReloadCount = self.ReloadAmmoAnimFrequency / self.ReloadAnimDuration * (MaxAmmo - self.CurClipAmmoForAnim)
  self.ReloadAnimTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      self.CurClipAmmoForAnim = self.CurClipAmmoForAnim + PerReloadCount
      self:UpdateAmmoProgress(self.CurClipAmmoForAnim)
      if self.CurClipAmmoForAnim >= MaxAmmo then
        self:ClearReloadAnimTimer()
      end
    end
  }, self.ReloadAmmoAnimFrequency, true)
end

function WBP_CommonAmmoCountBar_C:ClearReloadAnimTimer()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ReloadAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ReloadAnimTimer)
  end
end

function WBP_CommonAmmoCountBar_C:ChangeWidgetVis()
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if self:IsAnimationPlaying(self.Ani_out) then
    self:StopAnimation(self.Ani_out)
  end
  self:PlayAnimationForward(self.Ani_in)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ShowWidgetTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ShowWidgetTimer)
  end
  self.ShowWidgetTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self:PlayAnimationForward(self.Ani_out)
    end
  }, self.Duration, false)
end

function WBP_CommonAmmoCountBar_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_CommonAmmoCountBar_C:BindOnPostExitState(State, bBlocked)
end

function WBP_CommonAmmoCountBar_C:Destruct()
  self:Hide()
end

return WBP_CommonAmmoCountBar_C
