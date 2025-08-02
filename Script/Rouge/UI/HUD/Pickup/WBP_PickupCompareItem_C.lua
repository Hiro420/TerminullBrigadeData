local WBP_PickupCompareItem_C = UnLua.Class()

function WBP_PickupCompareItem_C:Construct()
end

function WBP_PickupCompareItem_C:IsEqualWorld(PickupActor, Weapon)
  local PickupWeapon = PickupActor:Cast(UE.ARGPickup_Weapon)
  if not PickupWeapon then
    return false
  end
  local PickupWorldId = PickupWeapon:GetWorldId()
  local WeaponWorldId = Weapon:GetWorldId()
  return PickupWorldId == WeaponWorldId
end

function WBP_PickupCompareItem_C:InitInfo(PickupActor, IsWeapon)
  self.PickupActor = PickupActor
  self.IsWeapon = IsWeapon
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local AllWeapons = EquipmentComp:GetAllWeapons(nil)
  local Weapon
  if self.IsWeapon then
    for i, SingleWeapon in pairs(AllWeapons) do
      if self:IsEqualWorld(self.PickupActor, SingleWeapon) then
        Weapon = SingleWeapon
        self.SlotId = Weapon:GetSlotId()
        break
      end
    end
    if not Weapon then
      print("\230\178\161\230\156\137\230\137\190\229\136\176\231\155\184\229\144\140\228\184\150\231\149\140\231\154\132\230\173\166\229\153\168")
      self:SetVisibility(UE.ESlateVisibility.Collapsed)
      return
    end
    self:SetVisibility(UE.ESlateVisibility.Visible)
    self.WidgetSwitcher:SetActiveWidgetIndex(0)
    self.WeaponDisplayInfo:InitInfo(Weapon, false)
  else
    self:SetVisibility(UE.ESlateVisibility.Visible)
    self.WidgetSwitcher:SetActiveWidgetIndex(1)
    local AccessoryRowInfo = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, self.PickupActor.AccessoryId, nil)
    for i, SingleWeapon in pairs(AllWeapons) do
      if SingleWeapon:GetWorldId() == AccessoryRowInfo.WorldId then
        Weapon = SingleWeapon
        self.SlotId = Weapon:GetSlotId()
        break
      end
    end
    if not Weapon then
      print("\230\178\161\230\156\137\230\137\190\229\136\176\231\155\184\229\144\140\228\184\150\231\149\140\231\154\132\230\173\166\229\153\168\233\133\141\228\187\182")
      self:SetVisibility(UE.ESlateVisibility.Collapsed)
      return
    end
    local AccessoryComp = Weapon.AccessoryComponent
    if not AccessoryComp then
      return
    end
    if AccessoryComp:HasAccessoryOfType(AccessoryRowInfo.AccessoryType) then
      local CurrentAccessoryId = AccessoryComp:GetAccessoryByType(AccessoryRowInfo.AccessoryType)
      self.AccessoryDisplayInfo:InitInfo(CurrentAccessoryId, false, false, nil, -1)
      self.UnEquipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.AccessoryDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UnEquipPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.AccessoryDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  if 1 == self.SlotId then
    self.Txt_Name:SetText("\230\173\166\229\153\168\228\184\128")
  else
    self.Txt_Name:SetText("\230\173\166\229\153\168\228\186\140")
  end
end

function WBP_PickupCompareItem_C:BindOnReplaceButtonClicked()
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local Weapon = EquipmentComp:FindEquipment(self.SlotId)
  local AccessoryComp = Weapon.AccessoryComponent
  if not AccessoryComp then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local MiscHelper = PC.MiscHelper
  if self.IsWeapon then
    MiscHelper:SelectSlotAndEquipWeapon(self.PickupActor, self.SlotId)
  else
    if not AccessoryComp:CanPickupOrBuyAccessory(self.PickupActor.AccessoryId) then
      return
    end
    MiscHelper:SelectSlotAndEquipAccessory(self.PickupActor, self.SlotId)
  end
end

function WBP_PickupCompareItem_C:Destruct()
end

return WBP_PickupCompareItem_C
