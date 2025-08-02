local WBP_WeaponAccessorySlotPanel_C = UnLua.Class()

function WBP_WeaponAccessorySlotPanel_C:Destruct()
  self:BindOnOnAccessoryChanged(false)
  self.AccessoryComponent = nil
end

function WBP_WeaponAccessorySlotPanel_C:InitAccessorySlot(Weapon)
  if not Weapon:IsValid() then
    print("Weapon is nil.")
    return
  end
  self.AccessoryComponent = Weapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
  self:BindOnOnAccessoryChanged(true)
  self:UpdateAccessorySlotNum()
end

function WBP_WeaponAccessorySlotPanel_C:UpdateAccessorySlotNum()
  local widgetPath = "/Game/Rouge/UI/HUD/Weapon/WBP_WeaponAccessorySlotItem.WBP_WeaponAccessorySlotItem_C"
  local padding = UE.FMargin()
  padding.Right = 2.5
  UpdateWidgetContainer(self.HorizontalBox_AccessorySlot, 8, widgetPath, padding, self, self:GetOwningPlayer())
  self:UpdateAccessorySlot()
end

function WBP_WeaponAccessorySlotPanel_C:UpdateAccessorySlot()
  if self.AccessoryComponent:IsValid() then
    if self.AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel) then
      local ArticleId = self.AccessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Barrel)
      local itemId = UE.URGArticleStatics.GetConfigId(ArticleId)
      local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGDataTableSubsystem:StaticClass())
      if DTSubsystem then
        local ItemData
        ItemData = DTSubsystem:K2_GetItemTableRow(itemId, nil)
        local currentNum = self:GetAccessoryNum()
        for key, value in pairs(self.HorizontalBox_AccessorySlot:GetAllChildren()) do
          if currentNum >= key then
            value:UpdateAccessorySlotByWorldTypeId(ItemData.WorldTypeId)
          else
            value:UpdateEmptyAccessorySlot()
          end
        end
      end
    else
      for key, value in pairs(self.HorizontalBox_AccessorySlot:GetAllChildren()) do
        value:UpdateEmptyAccessorySlot()
      end
    end
  else
    print("self.AccessoryComponent is nil.")
  end
end

function WBP_WeaponAccessorySlotPanel_C:BindOnOnAccessoryChanged(Bind)
  if self.AccessoryComponent and self.AccessoryComponent:IsValid() then
    if Bind then
      self.AccessoryComponent.OnAccessoryChanged:Add(self, WBP_WeaponAccessorySlotPanel_C.BindOnAccessoryChanged)
    else
      self.AccessoryComponent.OnAccessoryChanged:Remove(self, WBP_WeaponAccessorySlotPanel_C.BindOnAccessoryChanged)
    end
  end
end

function WBP_WeaponAccessorySlotPanel_C:BindOnAccessoryEquip(Bind)
  if self.AccessoryComponent:IsValid() then
    if Bind then
      self.AccessoryComponent.OnAccessoryEquip:Add(self, WBP_WeaponAccessorySlotPanel_C.OnAccessoryEquip)
    else
      self.AccessoryComponent.OnAccessoryEquip:Remove(self, WBP_WeaponAccessorySlotPanel_C.OnAccessoryEquip)
    end
  end
end

function WBP_WeaponAccessorySlotPanel_C:BindOnAccessoryUnEquip(Bind)
  if self.AccessoryComponent:IsValid() then
    if Bind then
      self.AccessoryComponent.OnAccessoryUnEquip:Add(self, WBP_WeaponAccessorySlotPanel_C.OnAccessoryUnEquip)
    else
      self.AccessoryComponent.OnAccessoryUnEquip:Remove(self, WBP_WeaponAccessorySlotPanel_C.OnAccessoryUnEquip)
    end
  end
end

function WBP_WeaponAccessorySlotPanel_C:BindOnAccessoryChanged()
  self:UpdateAccessorySlotNum()
end

function WBP_WeaponAccessorySlotPanel_C:OnAccessoryEquip(AccessoryId, AccessoryType)
  self:UpdateAccessorySlotNum()
end

function WBP_WeaponAccessorySlotPanel_C:OnAccessoryUnEquip(AccessoryId, AccessoryType)
  self:UpdateAccessorySlotNum()
end

function WBP_WeaponAccessorySlotPanel_C:GetAccessoryNum()
  local num = 0
  if self.AccessoryComponent:IsValid() then
    if self.AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Butt) then
      num = num + 1
    end
    if self.AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Grip) then
      num = num + 1
    end
    if self.AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Magazine) then
      num = num + 1
    end
    if self.AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Muzzle) then
      num = num + 1
    end
    if self.AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Part) then
      num = num + 1
    end
    if self.AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Pendant) then
      num = num + 1
    end
    if self.AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Sight) then
      num = num + 1
    end
    if self.AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Coating) then
      num = num + 1
    end
  end
  return num
end

return WBP_WeaponAccessorySlotPanel_C
