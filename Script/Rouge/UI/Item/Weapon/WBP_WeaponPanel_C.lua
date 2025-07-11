local WBP_WeaponPanel_C = UnLua.Class()
function WBP_WeaponPanel_C:Construct()
  self.WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Item/Weapon/WBP_WeaponCard.WBP_WeaponCard_C")
  self.EquipButton.OnClicked:Add(self, WBP_WeaponPanel_C.OnClicked_EquipButton)
  self.DiscardButton.OnClicked:Add(self, WBP_WeaponPanel_C.OnClicked_DiscardButton)
  self.CompanionEquipButton.OnClicked:Add(self, WBP_WeaponPanel_C.OnClicked_CompanionEquipButton)
end
function WBP_WeaponPanel_C:OnOpenPanel()
  local equipmentComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if equipmentComponent then
    equipmentComponent.OnEquipmentChanged:Add(self, WBP_WeaponPanel_C.OnEquipmentChanged)
    equipmentComponent.OnCurrentWeaponChanged:Add(self, WBP_WeaponPanel_C.OnCurrentWeaponChanged)
    local companionComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.UCompanionComponent.StaticClass())
    if companionComponent then
      local ai = companionComponent:GetCompanionAI()
      if ai then
        local aiequipmentComponent = ai:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
        if aiequipmentComponent then
          aiequipmentComponent.OnEquipmentChanged:Add(self, WBP_WeaponPanel_C.OnEquipmentChanged)
          aiequipmentComponent.OnCurrentWeaponChanged:Add(self, WBP_WeaponPanel_C.OnCurrentWeaponChanged)
        end
      end
    end
  end
end
function WBP_WeaponPanel_C:OnLoadPanel()
  self:UpdateAll()
end
function WBP_WeaponPanel_C:OnCardSelect(WBP_BaseCard)
  print("OnCardSelect")
  if WBP_BaseCard:GetClass() == self.WidgetClass then
    self.CurrentSelected = WBP_BaseCard
    if self.CurrentSelected then
      self:LoadWeaponInfo(self.CurrentSelected.WeaponActor)
      local Childrens = self.ItemGridPanel:GetAllChildren()
      local length = Childrens:Length()
      local element
      for i = 1, length do
        element = Childrens:Get(i)
        if element ~= self.CurrentSelected and element:GetClass() == self.WidgetClass then
          element:UnselectCard()
        end
      end
    end
  end
end
function WBP_WeaponPanel_C:OnCardUnselect(WBP_BaseCard)
end
function WBP_WeaponPanel_C:OnEquipmentChanged()
  self:UpdateAll()
end
function WBP_WeaponPanel_C:OnCurrentWeaponChanged(OldWeapon, NewWeapon)
  self:UpdateAll()
end
function WBP_WeaponPanel_C:OnClicked_EquipButton()
  local weaponActor = self.CurrentSelected.WeaponActor
  if weaponActor then
    local equipmentComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
    if equipmentComponent and equipmentComponent:HasEquipment(weaponActor) then
      equipmentComponent:EquipWeapon(weaponActor)
    end
  end
end
function WBP_WeaponPanel_C:OnClicked_DiscardButton()
  local weaponActor = self.CurrentSelected.WeaponActor
  if weaponActor then
    local equipmentComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
    if equipmentComponent and equipmentComponent:HasEquipment(weaponActor) then
      equipmentComponent:DiscardEquipment(weaponActor)
    end
  end
end
function WBP_WeaponPanel_C:OnClicked_CompanionEquipButton()
  local weaponActor = self.CurrentSelected.WeaponActor
  if weaponActor then
    local companionComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.UCompanionComponent.StaticClass())
    if companionComponent then
      local ai = companionComponent:GetCompanionAI()
      if ai then
        local aiequipmentComponent = ai:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
        if aiequipmentComponent then
          local equipmentComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
          if equipmentComponent then
            equipmentComponent:ReplaceWeaponWith(weaponActor, aiequipmentComponent, aiequipmentComponent:GetCurrentWeapon())
          end
        end
      end
    end
  end
end
function WBP_WeaponPanel_C:UpdateAll()
  coroutine.resume(coroutine.create(function(duration)
    self.ItemGridPanel:ClearChildren()
    self:LoadWeaponsFromPlayer()
    self:LoadWeaponsFromCompanion()
    self:LoadAmmoInfo()
  end), 0.1)
end
function WBP_WeaponPanel_C:LoadWeaponInfo(Weapon)
  self.WBP_WeaponViewer:LoadWeaponView(Weapon)
  self.WBP_WeaponInfoBox:LoadWeaponInfo(Weapon)
end
function WBP_WeaponPanel_C:LoadWeaponsFromPlayer()
  local equipmentComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if equipmentComponent then
    local equipments = equipmentComponent:GetAllEquipments()
    local Length = equipments:Length()
    local element
    local index = 0
    local wbp_WeaponCard
    for i = 1, Length do
      element = equipments:Get(i)
      local rGGun = element:Cast(UE.ARGGun)
      if rGGun then
        wbp_WeaponCard = UE.UWidgetBlueprintLibrary.Create(self, self.WidgetClass, self:GetOwningPlayer())
        if wbp_WeaponCard then
          wbp_WeaponCard:InitializeUpdate(rGGun, false)
          self.ItemGridPanel:AddChildToUniformGrid(wbp_WeaponCard, UE.UKismetMathLibrary.FTrunc(index / 2), UE.UKismetMathLibrary.FTrunc(index % 2))
          wbp_WeaponCard.OnCardSelect:Add(self, WBP_WeaponPanel_C.OnCardSelect)
          wbp_WeaponCard.OnCardUnselect:Add(self, WBP_WeaponPanel_C.OnCardUnselect)
          index = index + 1
          if wbp_WeaponCard.WeaponActor == equipmentComponent:GetCurrentWeapon() then
            wbp_WeaponCard:SelectCard()
          end
        end
      end
    end
  end
end
function WBP_WeaponPanel_C:LoadWeaponsFromCompanion()
  local index = self.ItemGridPanel:GetChildrenCount()
  local companionComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.UCompanionComponent.StaticClass())
  if companionComponent then
    local ai = companionComponent:GetCompanionAI()
    if ai then
      local aiequipmentComponent = ai:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
      if aiequipmentComponent then
        local aiWeapon = aiequipmentComponent:GetCurrentWeapon()
        local rGGun = aiWeapon:Cast(UE.ARGGun)
        if rGGun then
          local wbp_WeaponCard = UE.UWidgetBlueprintLibrary.Create(self, self.WidgetClass, self:GetOwningPlayer())
          if wbp_WeaponCard then
            wbp_WeaponCard:InitializeUpdate(rGGun, true)
            wbp_WeaponCard.OnCardSelect:Add(self, WBP_WeaponPanel_C.OnCardSelect)
            wbp_WeaponCard.OnCardUnselect:Add(self, WBP_WeaponPanel_C.OnCardUnselect)
            index = index + 1
          end
        end
      end
    end
  end
end
function WBP_WeaponPanel_C:LoadAmmoInfo()
  self:LoadSmallAmmoInfo()
  self:LoadMiddleAmmoInfo()
  self:LoadLargeAmmoInfo()
end
function WBP_WeaponPanel_C:LoadSmallAmmoInfo()
  local bagComponent = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent.StaticClass())
  if bagComponent then
  end
end
function WBP_WeaponPanel_C:LoadMiddleAmmoInfo()
  local bagComponent = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent.StaticClass())
  if bagComponent then
  end
end
function WBP_WeaponPanel_C:LoadLargeAmmoInfo()
  local bagComponent = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent.StaticClass())
  if bagComponent then
  end
end
return WBP_WeaponPanel_C
