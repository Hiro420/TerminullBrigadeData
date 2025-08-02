local WBP_EquipSlotCore_C = UnLua.Class()

function WBP_EquipSlotCore_C:Construct()
  EventSystem.AddListener(self, EventDef.GamePokey.OnInscriptionHovered, WBP_EquipSlotCore_C.OnInscriptionHovered)
  EventSystem.AddListener(self, EventDef.GamePokey.OnInscriptionUnHovered, WBP_EquipSlotCore_C.OnInscriptionUnHovered)
  EventSystem.AddListener(self, EventDef.GamePokey.OnAccessorySlotClicked, WBP_EquipSlotCore_C.OnAccessorySlotClicked)
end

function WBP_EquipSlotCore_C:Destruct()
  EventSystem.RemoveListener(EventDef.GamePokey.OnInscriptionHovered, WBP_EquipSlotCore_C.OnInscriptionHovered)
  EventSystem.RemoveListener(EventDef.GamePokey.OnInscriptionUnHovered, WBP_EquipSlotCore_C.OnInscriptionUnHovered)
  EventSystem.RemoveListener(EventDef.GamePokey.OnAccessorySlotClicked, WBP_EquipSlotCore_C.OnAccessorySlotClicked)
end

function WBP_EquipSlotCore_C:OnMouseEnter(MyGeometry, MouseEvent)
  EventSystem.Invoke(EventDef.GamePokey.OnAccessorySlotHovered, self.AccessoryId)
  self:UpdateAccessoryInfoTip(true)
  self.TipTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_EquipSlotCore_C.UpdateAccessoryNoteTipFunc
  }, 0.05, false)
end

function WBP_EquipSlotCore_C:OnMouseLeave(MouseEvent)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TipTimer) then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TipTimer)
  end
  EventSystem.Invoke(EventDef.GamePokey.OnAccessorySlotUnHovered)
  self:UpdateAccessoryInfoTip(false)
  self:UpdateAccessoryNoteTip(false)
end

function WBP_EquipSlotCore_C:InitInfo(GamePokey, EquipSlot, AccessoryType)
  if GamePokey then
    self.GamePokey = GamePokey
    self.EquipSlot = EquipSlot
    self:InitToolTipInfo()
    self.AccessoryType = AccessoryType
    self:ClearButtonClicked()
    self:InitButton()
    self:InitImage()
  end
end

function WBP_EquipSlotCore_C:InitToolTipInfo()
  self.ToolWidget = self.GamePokey.WBP_GPAccessoryDisplayInfo
  self.ToolNoteWidget = self.GamePokey.WBP_GPExtraDescItemsPanel
  self.ToolWidgetSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ToolWidget)
  self.EquipWidgetSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.EquipSlot)
  self.ToolNoteWidgetSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ToolNoteWidget)
end

function WBP_EquipSlotCore_C:InitButton()
  if self.GamePokey then
    local accessoryComponent = self.GamePokey:GetAccessoryComp()
    if accessoryComponent then
      self.AccessoryId = accessoryComponent:GetAccessoryByType(self.AccessoryType)
      if accessoryComponent:HasAccessoryOfType(self.AccessoryType) then
        self:UpdateAccessoryNameByID(self.AccessoryId)
        self:UpdateEquipSlot(self.AccessoryId, false)
      else
        self:UpdateEquipSlot(self.AccessoryId, true)
      end
    end
  end
end

function WBP_EquipSlotCore_C:InitImage()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local result, accessoryTypeTableRow = DTSubsystem:GetAccessoryTypeTableRow(self.AccessoryType)
    if result then
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(accessoryTypeTableRow.SpriteIcon)
      if IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
        self.Image_AccessoryTypeIcon:SetBrush(Brush)
      end
    end
  end
end

function WBP_EquipSlotCore_C:InitAngle()
  self.Angle = true
  self.Overlay_EquipSlot:SetRenderTransformAngle(180)
  self.Text_AccessoryName:SetRenderTransformAngle(180)
end

function WBP_EquipSlotCore_C:GetInscriptions()
  local inscriptionIdArray = UE.TArray(0)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(self.AccessoryId)
    local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(configId))
    if result then
      local accessoryManager = UE.URGAccessoryStatics.GetAccessoryManager(self)
      if accessoryManager then
        local findValue = accessoryData.InscriptionMap:FindRef(accessoryManager:GetAccessory(self.AccessoryId).InnerData.ItemRarity)
        if findValue then
          for key, value in pairs(findValue.Inscriptions) do
            inscriptionIdArray:Add(value.InscriptionId)
          end
          return inscriptionIdArray
        end
      end
    end
  end
  return inscriptionIdArray
end

function WBP_EquipSlotCore_C:ClearButtonClicked()
  self.bButtonChoose = false
  self.Image_EquipChoose:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_EquipSlotCore_C:SetButtonClicked()
  self.bButtonChoose = true
  self.Image_EquipChoose:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_EquipSlotCore_C:CanClickedButton()
  if not self.GamePokey then
    return false
  else
    return not self:IsAccessoryRotate() and not self.bButtonChoose
  end
end

function WBP_EquipSlotCore_C:UnEquipAccessory()
  if self.bEquipped and self.GamePokey then
    if self.GamePokey:WillShowMessage(self.AccessoryId) then
      local waveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
      if waveManager then
        waveManager:ShowWaveWindow(1031)
      end
    else
      self:ConfirmUnEquip()
    end
  end
end

function WBP_EquipSlotCore_C:BoxConfirmUnEquip(Box)
  self:ConfirmUnEquip()
end

function WBP_EquipSlotCore_C:ConfirmUnEquip()
  if self.GamePokey then
    local accessoryComponent = self.GamePokey:GetAccessoryComp()
    if accessoryComponent then
      self:UpdateAccessoryInfoTip(false)
      self:UpdateAccessoryNoteTip(false)
      accessoryComponent:UnEquipAccessory(self.AccessoryId)
      self:ClearButtonClicked()
      self:ShowEmptyButton()
      if self.GamePokey.WeaponCapture then
        self.GamePokey.WeaponCapture:UnEquipAccessory(self.AccessoryId)
      end
    end
  end
end

function WBP_EquipSlotCore_C:UpdateEquipSlot(AccessoryId, Empty)
  self.AccessoryId = AccessoryId
  if Empty then
    self.Text_AccessoryName:SetText("")
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.EmptyBack)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Image_Back:SetBrush(Brush)
      self.Image_Back:SetColorAndOpacity(UE.FLinearColor(1.0, 1.0, 1.0, 0.3))
    end
    self.Image_AccessoryTypeIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Equipped:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.bEquipped = false
  else
    self:UpdateAccessoryNameByID(AccessoryId)
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem then
      local AccessoryData = UE.URGAccessoryStatics.GetAccessoryData(self, AccessoryId, nil)
      local itemBaseData = DTSubsystem:K2_GetItemTableRow(UE.URGAccessoryStatics.K2_GetAccessoryRow(self, self.AccessoryId).ConfigId)
      if itemBaseData then
        local SpriteIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(itemBaseData.SpriteIcon)
        if SpriteIconObj then
          local SpriteBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(SpriteIconObj, 0, 0)
          self.Image_Equipped:SetBrush(SpriteBrush)
          self.Image_AccessoryTypeIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
          self.Image_Equipped:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
          self.bEquipped = true
          local success, row = DTSubsystem:GetItemRarityTableRow(AccessoryData.InnerData.ItemRarity)
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

function WBP_EquipSlotCore_C:IsAccessoryRotate()
  if self.GamePokey then
    return self.GamePokey:IsAccessoryRotate()
  end
end

function WBP_EquipSlotCore_C:OnButtonClicked()
  if self:CanClickedButton() then
    self:SetButtonClicked()
    EventSystem.Invoke(EventDef.GamePokey.OnAccessorySlotClicked, self.AccessoryType)
    PlaySound2DEffect(30005, "")
  else
    self.GamePokey.Selected = nil
    self:ClearButtonClicked()
    self.GamePokey:RecoverAccessoriesPanel()
  end
end

function WBP_EquipSlotCore_C:UpdateAccessoryNameByID(AccessoryId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(AccessoryId)
    local itemData = DTSubsystem:K2_GetItemTableRow(configId)
    if itemData then
      self.Text_AccessoryName:SetText(itemData.Name)
    end
  end
end

function WBP_EquipSlotCore_C:UpdateAccessoryNameVisibility(Show)
  local visibility
  if Show then
    visibility = UE.ESlateVisibility.SelfHitTestInvisible
  else
    visibility = UE.ESlateVisibility.Collapsed
  end
  self.Text_AccessoryName:SetVisibility(visibility)
end

function WBP_EquipSlotCore_C:UpdateAccessoryInfoTip(Show)
  if not (self.ToolWidget and self.bEquipped and self.EquipWidgetSlot) or not self.ToolWidgetSlot then
    return
  end
  if Show then
    self.ToolWidget:InitInfo(self.AccessoryId, self.Angle)
    local Position = UE.FVector2D(0.0, 0.0)
    local Alignment = UE.FVector2D(0.0, 0.0)
    if self.Angle then
      Alignment = UE.FVector2D(0.0, 1.0)
    else
      Alignment = UE.FVector2D(0.0, 0.0)
    end
    self.ToolWidgetSlot:SetPosition(Position)
    self.ToolWidgetSlot:SetAlignment(Alignment)
    self.ToolWidgetSlot:SetAutoSize(true)
    local tempPosition = self.EquipWidgetSlot:GetPosition()
    if self.Angle then
      tempPosition.X = tempPosition.X - 47.3
      tempPosition.Y = tempPosition.Y + 93
    else
      tempPosition.X = tempPosition.X - 45.3
      tempPosition.Y = tempPosition.Y - 88
    end
    self.ToolWidgetSlot:SetPosition(tempPosition)
    self.ToolWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.ToolWidget:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function WBP_EquipSlotCore_C:UpdateAccessoryNoteTipFunc()
  self:UpdateAccessoryNoteTip(true)
end

function WBP_EquipSlotCore_C:UpdateAccessoryNoteTip(Show)
  if not (self.ToolNoteWidget and (self.ToolNoteWidgetSlot or self.bEquipped)) or not self.ToolWidgetSlot then
    return
  end
  if Show then
    self.ToolNoteWidget:UpdateInscriptionAdditions(self:GetInscriptions())
    local tempPosition = self.ToolWidgetSlot:GetPosition()
    local tempSize = UE.USlateBlueprintLibrary.GetLocalSize(self.ToolWidget:GetCachedGeometry())
    local viewportSize = UE.UWidgetLayoutLibrary.GetViewportSize(self)
    local halfX = viewportSize.X / 2
    local Alignment = UE.FVector2D(0.0, 0.0)
    if halfX > tempPosition.X then
      Alignment = UE.FVector2D(0.0, 0.0)
      tempPosition.X = tempPosition.X + tempSize.X - 6
    else
      Alignment = UE.FVector2D(1.0, 0.0)
      tempPosition.X = tempPosition.X + 5
    end
    if self.Angle then
      tempPosition.Y = tempPosition.Y - tempSize.Y + 5
    else
      tempPosition.Y = tempPosition.Y + 5
    end
    self.ToolNoteWidgetSlot:SetPosition(tempPosition)
    self.ToolNoteWidgetSlot:SetAlignment(Alignment)
    self.ToolNoteWidgetSlot:SetAutoSize(true)
  else
    self.ToolNoteWidget:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function WBP_EquipSlotCore_C:OnInscriptionHovered(InscriptionId)
  local insAry = self:GetInscriptions()
  for key, value in pairs(insAry) do
    if value == InscriptionId then
      self:UpdateAccessoryNameVisibility(true)
    end
  end
end

function WBP_EquipSlotCore_C:OnInscriptionUnHovered()
  self:UpdateAccessoryNameVisibility(false)
end

function WBP_EquipSlotCore_C:OnAccessorySlotClicked(AccessoryType)
  if self.AccessoryType ~= AccessoryType then
    self:ClearButtonClicked()
  end
end

return WBP_EquipSlotCore_C
