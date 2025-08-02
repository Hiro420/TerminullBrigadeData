local WBP_AccessorySlotItem_C = UnLua.Class()

function WBP_AccessorySlotItem_C:Construct()
  self.Image_EquipChoose:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnInscriptionHovered, WBP_AccessorySlotItem_C.OnInscriptionHovered)
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnInscriptionUnHovered, WBP_AccessorySlotItem_C.OnInscriptionUnHovered)
end

function WBP_AccessorySlotItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnInscriptionHovered, WBP_AccessorySlotItem_C.OnInscriptionHovered, self)
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnInscriptionUnHovered, WBP_AccessorySlotItem_C.OnInscriptionUnHovered, self)
end

function WBP_AccessorySlotItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.bHasAccessory then
    local accessorySlotBoxSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.AccessorySlotBox)
    local position = accessorySlotBoxSlot:GetPosition()
    EventSystem.Invoke(EventDef.GunDisplayPanel.OnAccessorySlotHovered, self.AccessoryId, self.AccessoryRarity, GetInscriptionIdTable(self.AccessoryId, self.AccessoryRarity), self.Angle, position)
  end
end

function WBP_AccessorySlotItem_C:OnMouseLeave(MouseEvent)
  EventSystem.Invoke(EventDef.GunDisplayPanel.OnAccessorySlotUnHovered)
end

function WBP_AccessorySlotItem_C:UpdateAngle()
  self.Angle = true
  self.Overlay_AccessorySlot:SetRenderTransformAngle(180)
  self.Text_AccessoryName:SetRenderTransformAngle(180)
end

function WBP_AccessorySlotItem_C:UpdateAccessorySlotItem(HasAccessory, AccessoryId, AccessoryRarity, AccessoryType, AccessorySlotBox)
  self.AccessorySlotBox = AccessorySlotBox
  self.AccessoryId = AccessoryId
  self.AccessoryRarity = AccessoryRarity
  if not HasAccessory then
    self.Text_AccessoryName:SetText("")
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.EmptyBack)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Image_Back:SetBrush(Brush)
      self.Image_Back:SetColorAndOpacity(UE.FLinearColor(1.0, 1.0, 1.0, 0.3))
    end
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem then
      local result, accessoryTypeTableRow = DTSubsystem:GetAccessoryTypeTableRow(AccessoryType)
      if result then
        local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(accessoryTypeTableRow.SpriteIcon)
        if IconObj then
          local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
          self.Image_AccessoryTypeIcon:SetBrush(Brush)
          self.Image_AccessoryTypeIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
    self.Image_Equipped:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.bHasAccessory = false
  else
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem then
      local itemData = DTSubsystem:K2_GetItemTableRow(AccessoryId)
      if itemData then
        self.Text_AccessoryName:SetText(itemData.Name)
        local SpriteIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(itemData.SpriteIcon)
        if SpriteIconObj then
          local SpriteBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(SpriteIconObj, 0, 0)
          self.Image_Equipped:SetBrush(SpriteBrush)
          self.Image_AccessoryTypeIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
          self.Image_Slot:SetVisibility(UE.ESlateVisibility.Collapsed)
          self.Image_Equipped:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
          self.bHasAccessory = true
          local success, row = DTSubsystem:GetItemRarityTableRow(AccessoryRarity)
          if success then
            local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(row.SpriteIcon)
            if IconObj then
              local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
              self.Image_Back:SetBrush(Brush)
              self.Image_Back:SetColorAndOpacity(UE.FLinearColor(1.0, 1.0, 1.0, 1.0))
            end
          end
        end
      end
    end
  end
end

function WBP_AccessorySlotItem_C:UpdateAccessoryNameVisibility(Show)
  local visibility
  if Show then
    visibility = UE.ESlateVisibility.SelfHitTestInvisible
  else
    visibility = UE.ESlateVisibility.Collapsed
  end
  self.Text_AccessoryName:SetVisibility(visibility)
end

function WBP_AccessorySlotItem_C:OnInscriptionHovered(InscriptionId)
  for key, value in pairs(GetInscriptionIdTable(self.AccessoryId, self.AccessoryRarity)) do
    if value == InscriptionId then
      self:UpdateAccessoryNameVisibility(true)
    end
  end
end

function WBP_AccessorySlotItem_C:OnInscriptionUnHovered()
  self:UpdateAccessoryNameVisibility(false)
end

return WBP_AccessorySlotItem_C
