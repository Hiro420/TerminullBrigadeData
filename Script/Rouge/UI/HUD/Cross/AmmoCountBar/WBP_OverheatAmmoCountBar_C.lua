local CommonAmmoCountBar = require("Rouge.UI.HUD.Cross.AmmoCountBar.WBP_CommonAmmoCountBar_C")
local WBP_OverheatAmmoCountBar_C = UnLua.Class(CommonAmmoCountBar)
function WBP_OverheatAmmoCountBar_C:InitInfo()
  self.Super.InitInfo(self)
  self.LastWeaponsState = {}
  self.OwningCharacter = self:GetOwningPlayerPawn()
  local EquipmentComp = self.OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurWeapon = EquipmentComp:GetCurrentWeapon()
  if not CurWeapon then
    return
  end
  local CurReloadPolicy = CurWeapon:GetCurrentReloadPolicy()
  CurReloadPolicy = CurReloadPolicy and CurReloadPolicy:Cast(UE.URGGunReloadPolicy_Overheat:StaticClass())
  if CurReloadPolicy then
    self:BindOnOverHeatReloadStateChanged()
    CurReloadPolicy.OnStateChanged:Add(self, WBP_OverheatAmmoCountBar_C.BindOnOverHeatReloadStateChanged)
  end
end
function WBP_OverheatAmmoCountBar_C:UpdateAmmoProgress(ClipAmmo)
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
  self.Progress_Ammo:SetPercent(ClipAmmo / CurWeapon:GetMaxClipAmmo())
end
function WBP_OverheatAmmoCountBar_C:BindOnOverHeatReloadStateChanged()
  local EquipmentComp = self.OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurWeapon = EquipmentComp:GetCurrentWeapon()
  if not CurWeapon then
    return
  end
  self.Img_Overheat:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Recover:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_OverheatBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Progress_Ammo:SetFillColorAndOpacity(self.RecoverColor)
  self.Progress_Ammo_Anim:SetFillColorAndOpacity(self.RecoverColor)
  self.Img_Line:SetColorAndOpacity(self.NormalColor)
  local CurReloadPolicy = CurWeapon:GetCurrentReloadPolicy():Cast(UE.URGGunReloadPolicy_Overheat:StaticClass())
  local LastWeaponState = self.LastWeaponsState[CurWeapon]
  if LastWeaponState and LastWeaponState == UE.ERGOverheatReloadingState.Overheating then
    self.Img_Overheat:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_Line:SetColorAndOpacity(self.OverheatLineColor)
    self:PlayOrStopOverheatAnim(true)
  end
  self.LastWeaponsState[CurWeapon] = CurReloadPolicy.State
  if CurReloadPolicy.State == UE.ERGOverheatReloadingState.Overheating then
    self.Img_Overheat:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_Line:SetColorAndOpacity(self.OverheatLineColor)
    self:PlayOrStopOverheatAnim(true)
  elseif CurReloadPolicy.State == UE.ERGOverheatReloadingState.Recovering then
    self.Img_Recover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Progress_Ammo:SetFillColorAndOpacity(self.RecoverColor)
    self.Progress_Ammo_Anim:SetFillColorAndOpacity(self.RecoverColor)
  elseif CurReloadPolicy.State == UE.ERGOverheatReloadingState.None then
    self.Img_OverheatBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:PlayOrStopOverheatAnim(false)
  end
end
function WBP_OverheatAmmoCountBar_C:PlayOrStopOverheatAnim(IsPlay)
  if not self.ChargeWarning then
    return
  end
  if IsPlay then
    if not self:IsAnimationPlaying(self.ChargeWarning) then
      self:PlayAnimation(self.ChargeWarning, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0)
    end
    if not self:IsAnimationPlaying(self.RecoverAmmoAnim) then
      self:PlayAnimationForward(self.RecoverAmmoAnim)
    end
  else
    if self:IsAnimationPlaying(self.ChargeWarning) then
      self:StopAnimation(self.ChargeWarning)
    end
    if self:IsAnimationPlaying(self.RecoverAmmoAnim) then
      self:StopAnimation(self.RecoverAmmoAnim)
    end
  end
end
function WBP_OverheatAmmoCountBar_C:OnAnimationFinished(InAnimation)
  if InAnimation == self.RecoverAmmoAnim then
    UpdateVisibility(self.Progress_Ammo, true)
    UpdateVisibility(self.Progress_Ammo_Anim, false)
  end
end
function WBP_OverheatAmmoCountBar_C:Destruct()
  self.Super.Destruct(self)
  self:PlayOrStopOverheatAnim(false)
  local EquipmentComp = self.OwningCharacter:GetComponentByClass(UE.URGEquipmentComponent:StaticClass())
  if EquipmentComp then
    local CurWeapon = EquipmentComp:GetCurrentWeapon()
    local CurReloadPolicy = CurWeapon:GetCurrentReloadPolicy():Cast(UE.URGGunReloadPolicy_Overheat:StaticClass())
    if CurReloadPolicy then
      CurReloadPolicy.OnStateChanged:Remove(self, WBP_OverheatAmmoCountBar_C.BindOnOverHeatReloadStateChanged)
    end
  end
end
return WBP_OverheatAmmoCountBar_C
