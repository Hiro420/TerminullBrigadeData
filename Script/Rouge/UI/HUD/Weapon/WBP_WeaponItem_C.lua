local WBP_WeaponItem_C = UnLua.Class()

function WBP_WeaponItem_C:Construct()
  EventSystem.AddListener(self, EventDef.Battle.OnPickupWeaponSelected, WBP_WeaponItem_C.BindOnPickupWeaponSelected)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    local CoreComp = Character.CoreComponent
    if CoreComp then
      CoreComp:BindAttributeChanged(self.MagazineAttribute, {
        self,
        self.BindOnMagazineAttributeChanged
      })
    end
  end
  self:ChangeProhibitVis(false)
  ListenObjectMessage(nil, GMP.MSG_OnAbilityTagUpdate, self, self.BindOnAbilityTagUpdate)
  ListenObjectMessage(nil, GMP.MSG_World_Weapon_OnChargeTimeUpdate, self, self.BindOnChargeTimeUpdate)
end

function WBP_WeaponItem_C:BindOnMagazineAttributeChanged(NewValue, OldValue)
  self:ChangeReverseAmmo()
end

function WBP_WeaponItem_C:BindOnWeaponPolicyChanged()
  self:SetAmmoInfo()
  self:ChangeReverseAmmo()
end

function WBP_WeaponItem_C:ChangeReverseAmmo()
  local LocalPlayer = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not LocalPlayer then
    return
  end
  local CurrentWeapon = LocalPlayer:GetCurrentWeapon()
  if not CurrentWeapon then
    return
  end
  local MagazineTemp = CurrentWeapon:GetDisplayMaxClipAmmo()
  local MagazineTempStr = tostring(UE.UKismetMathLibrary.FCeil(tonumber(string.format("%.2f", MagazineTemp))))
  self.Txt_ReverseAmmo:SetText(MagazineTempStr)
  self.Txt_ReverseAmmo_touying:SetText(MagazineTempStr)
  self.Txt_ReverseAmmo_touming_1:SetText(MagazineTempStr)
  self.Txt_ReverseAmmo_touming_2:SetText(MagazineTempStr)
  self.Txt_UnReverseAmmo:SetText(MagazineTempStr)
end

function WBP_WeaponItem_C:BindOnPickupWeaponSelected(IsShow, CurWeapon)
  self.IsShowCompareWeapon = IsShow
  self.CurShowCompareWeapon = CurWeapon
  if IsShow then
    if not self:IsAnimationPlaying(self.Loop) then
      self:PlayAnimation(self.loop, 0.0, 999, UE.EUMGSequencePlayMode.Forward, 1.0)
    end
    if self.CurSlotWeapon == CurWeapon then
    else
    end
  elseif self:IsAnimationPlaying(self.Loop) then
    self:StopAnimation(self.Loop)
  end
end

function WBP_WeaponItem_C:BindOnAbilityTagUpdate(Tag, bTagExist, TargetActor)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if TargetActor ~= Character then
    return
  end
  local CharacterSettings = UE.URGCharacterSettings.GetSettings()
  if not CharacterSettings then
    return
  end
  if CharacterSettings.AbnormalStateTags:Contains(Tag) then
    self:ChangeProhibitVis(bTagExist)
  end
end

function WBP_WeaponItem_C:BindOnChargeTimeUpdate(MaxTime, CurrentTime)
  self.CurrentTime = CurrentTime
  
  function self:GetOtherAmmoCost()
    local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
    if not EquipmentComp then
      return 0
    end
    local CurWeapon = EquipmentComp:GetCurrentWeapon()
    if not CurWeapon then
      return 0
    end
    local Result, WeaponRowInfo = GetRowData(DT.DT_Weapon, CurWeapon:GetItemId())
    if not Result then
      return 0
    end
    local LaunchAsset
    if WeaponRowInfo.ShoulderFiringConfig.bChangeLaunchPolicy then
      LaunchAsset = WeaponRowInfo.ShoulderFiringConfig.LaunchConfig.LaunchAsset
    else
      LaunchAsset = WeaponRowInfo.LaunchConfig.LaunchAsset
    end
    if not LaunchAsset then
      return 0
    end
    local Policy = LaunchAsset:GetLaunchPolicy()
    if not Policy then
      return 0
    end
    if not Policy.ChargeAmmoCost then
      return 0
    end
    return Policy.ChargeAmmoCost * self.CurrentTime
  end
  
  self:SetAmmoInfo()
end

function WBP_WeaponItem_C:ChangeProhibitVis(IsShow)
  self.Img_Prohibit:SetVisibility(UE.ESlateVisibility.Hidden)
  self.AmmoNumPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if IsShow then
    self:SetRenderOpacity(self.CanNotUseOpacity)
  else
    self:SetRenderOpacity(self.CanUseOpacity)
  end
end

function WBP_WeaponItem_C:RefreshInfo(CurWeapon)
  if not CurWeapon then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if self.CurSlotWeapon then
    self.CurSlotWeapon.OnNotifyAmmoChanged:Remove(self, WBP_WeaponItem_C.BindOnClipAmmoChangedNotice)
  end
  self.CurSlotWeapon = CurWeapon
  self.CurSlotWeapon.OnNotifyAmmoChanged:Add(self, WBP_WeaponItem_C.BindOnClipAmmoChangedNotice)
  self.CurSlotWeapon.OnWeaponPolicyChanged:Add(self, WBP_WeaponItem_C.BindOnWeaponPolicyChanged)
  self:SetSlotGunStatus(UE.UKismetSystemLibrary.IsValid(self.CurSlotWeapon))
  if not UE.UKismetSystemLibrary.IsValid(self.CurSlotWeapon) then
    print("WBP_WeaponItem_C:RefreshInfo Invalid SlotWeapon")
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self:ChangeReverseAmmo()
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.Txt_SlotId:SetText(tostring(self.CurSlotWeapon:GetSlotId()))
  self:SetAmmoInfo()
  self:RefreshWeaponIcon()
  self:StopAllAnimations()
  self:SetSelectedStatus(EquipmentComp:GetCurrentWeapon() == self.CurSlotWeapon)
  self:PlaySelectAnimation(EquipmentComp:GetCurrentWeapon() == self.CurSlotWeapon)
  if self.CurSlotWeapon.AccessoryComponent then
    self.CurSlotWeapon.AccessoryComponent.OnAccessoryChanged:Add(self, WBP_WeaponItem_C.BindOnAccessoryChanged)
  end
  if self.IsShowCompareWeapon then
    self:BindOnPickupWeaponSelected(self.IsShowCompareWeapon, self.CurShowCompareWeapon)
  end
end

function WBP_WeaponItem_C:BindOnAccessoryChanged()
  self:RefreshWeaponIcon()
end

function WBP_WeaponItem_C:RefreshWeaponIcon()
  local AccessoryComp = self.CurSlotWeapon.AccessoryComponent
  if not AccessoryComp then
    return
  end
  local ItemId = 0
  if AccessoryComp:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel) then
    local ArticleId = AccessoryComp:GetAccessoryByType(UE.ERGAccessoryType.EAT_Barrel)
    ItemId = UE.URGArticleStatics.GetConfigId(ArticleId)
  else
    ItemId = self.CurSlotWeapon:GetItemId()
  end
  if 0 == ItemId then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local ItemData
    ItemData = DTSubsystem:K2_GetItemTableRow(ItemId, nil)
    SetImageBrushBySoftObject(self.Img_Weapon, ItemData.CompleteGunIcon)
    SetImageBrushBySoftObject(self.Img_Weapon_yinying, ItemData.ProjectionCompleteGunIcon)
  end
end

function WBP_WeaponItem_C:SetSelectedStatus(IsSelect)
  if IsSelect then
    self:SetColorAndOpacity(UE.FLinearColor(1, 1, 1, 1))
    local Font = self.Txt_SlotId.Font
    Font.Size = 24
    self.Txt_SlotId:SetFont(Font)
    self.WeaponPanel:SetRenderScale(UE.FVector2D(1.0, 1.0))
    self.SelectAmmoPanel:SetVisibility(UE.ESlateVisibility.Visible)
    self.UnSelectAmmoPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self:SetColorAndOpacity(UE.FLinearColor(1, 1, 1, 0.6))
    local Font = self.Txt_SlotId.Font
    Font.Size = 19
    self.Txt_SlotId:SetFont(Font)
    self.WeaponPanel:SetRenderScale(UE.FVector2D(0.8, 0.8))
    self.SelectAmmoPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.UnSelectAmmoPanel:SetVisibility(UE.ESlateVisibility.Visible)
  end
end

function WBP_WeaponItem_C:BindOnClipAmmoChangedNotice()
  self:SetAmmoInfo()
end

function WBP_WeaponItem_C:SetAmmoInfo()
  if self.CurSlotWeapon then
    local Ammo = self.CurSlotWeapon:GetDisplayClipAmmo()
    if self.GetOtherAmmoCost then
      Ammo = Ammo - self:GetOtherAmmoCost()
    end
    local AmmoStr = tostring(UE.UKismetMathLibrary.FCeil(tonumber(string.format("%.2f", Ammo))))
    self.Txt_ClipAmmo:SetText(AmmoStr)
    self.Txt_ClipAmmo_touying:SetText(AmmoStr)
    self.Txt_ClipAmmo_touming_1:SetText(AmmoStr)
    self.Txt_ClipAmmo_touming_2:SetText(AmmoStr)
    self.Txt_UnClipAmmo:SetText(AmmoStr)
  end
end

function WBP_WeaponItem_C:SetSlotGunStatus(IsHaveGun)
  if IsHaveGun then
    self.Img_Weapon:SetVisibility(UE.ESlateVisibility.Visible)
    self.Txt_ReverseAmmo:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self.Img_Weapon:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_ReverseAmmo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_WeaponItem_C:Destruct()
  if self.CurSlotWeapon then
    self.CurSlotWeapon.OnNotifyAmmoChanged:Remove(self, WBP_WeaponItem_C.BindOnClipAmmoChangedNotice)
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    local CoreComp = Character.CoreComponent
    if CoreComp then
      CoreComp:UnBindAttributeChanged(self.MagazineAttribute, {
        self,
        self.BindOnMagazineAttributeChanged
      })
    end
  end
  EventSystem.RemoveListener(EventDef.Battle.OnPickupWeaponSelected, WBP_WeaponItem_C.BindOnPickupWeaponSelected, self)
  UnListenObjectMessage(GMP.MSG_OnAbilityTagUpdate, self)
  UnListenObjectMessage(GMP.MSG_World_Weapon_OnChargeTimeUpdate, self)
end

return WBP_WeaponItem_C
