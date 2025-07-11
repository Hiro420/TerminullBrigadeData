local WBP_EquipSlot_C = UnLua.Class()
function WBP_EquipSlot_C:PreConstruct(IsDesignTime)
  self:InitAngle()
end
function WBP_EquipSlot_C:Construct()
  EventSystem.AddListener(self, EventDef.GamePokey.OnInscriptionHovered, WBP_EquipSlot_C.OnInscriptionHovered)
  EventSystem.AddListener(self, EventDef.GamePokey.OnInscriptionUnHovered, WBP_EquipSlot_C.OnInscriptionUnHovered)
end
function WBP_EquipSlot_C:Destruct()
  EventSystem.RemoveListener(EventDef.GamePokey.OnInscriptionHovered, WBP_EquipSlot_C.OnInscriptionHovered)
  EventSystem.RemoveListener(EventDef.GamePokey.OnInscriptionUnHovered, WBP_EquipSlot_C.OnInscriptionUnHovered)
  self:BindOnAccessoryEquip(false)
  self:BindOnAccessoryUnEquip(false)
end
function WBP_EquipSlot_C:InitInfo(GamePokey)
  if GamePokey then
    self.GamePokey = GamePokey
    self.WBP_EquipSlotCore:InitInfo(GamePokey, self, self.AccessoryType)
    self:InitLine()
    self:BindOnAccessoryEquip(true)
    self:BindOnAccessoryUnEquip(true)
  end
end
function WBP_EquipSlot_C:InitAngle()
  if self.InitRenderAngle then
    self:SetRenderTransformAngle(180)
    self.WBP_EquipSlotCore:InitAngle()
  end
end
function WBP_EquipSlot_C:InitLine()
  if self.GamePokey then
    local accessoryComponent = self.GamePokey:GetAccessoryComp()
    if accessoryComponent then
      if accessoryComponent:HasAccessoryOfType(self.AccessoryType) then
        self:ShowLine(true)
      else
        self:ShowLine(false)
      end
    end
  end
end
function WBP_EquipSlot_C:BindOnAccessoryEquip(Bind)
  if self.GamePokey then
    local accessoryComponent = self.GamePokey:GetAccessoryComp()
    if accessoryComponent then
      if Bind then
        accessoryComponent.OnAccessoryEquip:Add(self, WBP_EquipSlot_C.OnAccessoryEquip)
      else
        accessoryComponent.OnAccessoryEquip:Remove(self, WBP_EquipSlot_C.OnAccessoryEquip)
      end
    end
  end
end
function WBP_EquipSlot_C:BindOnAccessoryUnEquip(Bind)
  if self.GamePokey then
    local accessoryComponent = self.GamePokey:GetAccessoryComp()
    if accessoryComponent then
      if Bind then
        accessoryComponent.OnAccessoryUnEquip:Add(self, WBP_EquipSlot_C.OnAccessoryUnEquip)
      else
        accessoryComponent.OnAccessoryUnEquip:Remove(self, WBP_EquipSlot_C.OnAccessoryUnEquip)
      end
    end
  end
end
function WBP_EquipSlot_C:OnAccessoryEquip(AccessoryId, AccessoryType)
  if AccessoryType == self.AccessoryType then
    self.WBP_EquipSlotCore:UpdateEquipSlot(AccessoryId, false)
    self:ShowLine(true)
    if self.GamePokey then
      self.GamePokey:InterpolationCameraWeapon(true, true, self.AccessoryId)
    end
  end
end
function WBP_EquipSlot_C:OnAccessoryUnEquip(AccessoryId, AccessoryType)
  if AccessoryType == self.AccessoryType then
    self.WBP_EquipSlotCore:UpdateEquipSlot(AccessoryId, true)
    self:ShowLine(false)
    if self.GamePokey then
      self.GamePokey:InterpolationCameraWeapon(false, true, self.AccessoryId)
    end
  end
end
function WBP_EquipSlot_C:ShowLine(Show)
  if Show then
    self.Image_Line:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Image_LineEnd:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Line:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Image_LineEnd:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
return WBP_EquipSlot_C
