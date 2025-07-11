require("UnLua")
local WBP_WeaponList_C = Class()
function WBP_WeaponList_C:Construct()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  self:BindCharacterDelegate(Character)
  EventSystem.AddListener(self, EventDef.Battle.OnControlledPawnChanged, WBP_WeaponList_C.BindOnControlledPawnChanged)
  ListenObjectMessage(nil, GMP.MSG_Hero_Dying, self, self.OnHeroDying)
  ListenObjectMessage(nil, GMP.MSG_Hero_NotifyRescue, self, self.OnHeroRescue)
end
function WBP_WeaponList_C:BindOnControlledPawnChanged(ControlledPawn)
  self:BindCharacterDelegate(ControlledPawn)
end
function WBP_WeaponList_C:BindCharacterDelegate(ControlledPawn)
  self.ControlledPawn = ControlledPawn
  if not ControlledPawn then
    return
  end
  local EquipmentComp = ControlledPawn:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if EquipmentComp then
    EquipmentComp.OnEquipmentChanged:Add(self, WBP_WeaponList_C.BindOnEquipmentChanged)
    self:BindOnEquipmentChanged()
  end
  local EquipmentComp = ControlledPawn:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if EquipmentComp then
    EquipmentComp.OnCurrentWeaponChanged:Add(self, WBP_WeaponList_C.BindOnCurrentWeaponChanaged)
  end
end
function WBP_WeaponList_C:BindOnEquipmentChanged()
  print("WBP_WeaponList_C:BindOnEquipmentChanged")
  self:BindOnCurrentWeaponChanaged()
end
function WBP_WeaponList_C:BindOnCurrentWeaponChanaged(OldWeapon, NewWeapon)
  print("WBP_WeaponList_C:BindOnCurrentWeaponChanaged")
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurWeapon = EquipmentComp:GetCurrentWeapon()
  if not CurWeapon then
    print("WBP_WeaponList_C:BindOnCurrentWeaponChanaged Invalid CurWeapon")
    return
  end
  local AllWeaponItems = self.WeaponList:GetAllChildren()
  for k, SingleWeaponItem in pairs(AllWeaponItems) do
    SingleWeaponItem:RefreshInfo(CurWeapon)
    print("WBP_WeaponList_C:BindOnCurrentWeaponChanaged RefreshWeapon", CurWeapon)
  end
  local Result, RowInfo = GetRowData(DT.DT_Weapon, CurWeapon:GetItemId())
  if not Result then
    return
  end
  local AbilityClass = RowInfo.AbilityConfig.AbilityClasses:Find(self.WeaponSkillCoolDown.SkillType)
  if not UE.UKismetSystemLibrary.IsValidClass(AbilityClass) then
    self.WeaponSkillCoolDown:SetSkillIcon(RowInfo.UnSkillDefaultIcon)
  end
  self.WeaponSkillCoolDown:RefreshInfo(AbilityClass)
  local VAbilityClass = RowInfo.AbilityConfig.AbilityClasses:Find(self.WeaponVSkillCoolDown.SkillType)
  if not UE.UKismetSystemLibrary.IsValidClass(VAbilityClass) then
    self.VSkillPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.VSkillPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WeaponVSkillCoolDown:RefreshInfo(VAbilityClass)
  end
  EventSystem.Invoke(EventDef.HUD.UpdateSkillPanelPosXByWeaponVSkill, UE.UKismetSystemLibrary.IsValidClass(VAbilityClass))
end
function WBP_WeaponList_C:OnHeroDying(Target)
  if Target == UE.UGameplayStatics.GetPlayerCharacter(self, 0) then
    UpdateVisibility(self, false)
  end
end
function WBP_WeaponList_C:OnHeroRescue(Target)
  if Target == UE.UGameplayStatics.GetPlayerCharacter(self, 0) then
    UpdateVisibility(self, true)
  end
end
function WBP_WeaponList_C:FocusInput()
end
function WBP_WeaponList_C:Destruct()
  EventSystem.RemoveListener(EventDef.Battle.OnControlledPawnChanged, WBP_WeaponList_C.BindOnControlledPawnChanged, self)
  if self.ControlledPawn:IsValid() then
    local EquipmentComp = self.ControlledPawn:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
    if EquipmentComp then
      EquipmentComp.OnEquipmentChanged:Remove(self, WBP_WeaponList_C.BindOnEquipmentChanged)
    end
    local EquipmentComp = self.ControlledPawn:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
    if EquipmentComp then
      EquipmentComp.OnCurrentWeaponChanged:Remove(self, WBP_WeaponList_C.BindOnCurrentWeaponChanaged)
    end
  end
  UnListenObjectMessage(GMP.MSG_Hero_Dying, self)
  UnListenObjectMessage(GMP.MSG_Hero_NotifyRescue, self)
end
return WBP_WeaponList_C
