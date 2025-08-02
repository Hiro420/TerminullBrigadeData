local WBP_GunMainPanel_C = UnLua.Class()

function WBP_GunMainPanel_C:Construct()
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnAccessorySlotHovered, WBP_GunMainPanel_C.OnAccessorySlotHovered)
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnAccessorySlotUnHovered, WBP_GunMainPanel_C.OnAccessorySlotUnHovered)
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnInscriptionHovered, WBP_GunMainPanel_C.OnInscriptionHovered)
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnInscriptionUnHovered, WBP_GunMainPanel_C.OnInscriptionUnHovered)
end

function WBP_GunMainPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnAccessorySlotHovered, WBP_GunMainPanel_C.OnAccessorySlotHovered, self)
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnAccessorySlotUnHovered, WBP_GunMainPanel_C.OnAccessorySlotUnHovered, self)
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnInscriptionHovered, WBP_GunMainPanel_C.OnInscriptionHovered, self)
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnInscriptionUnHovered, WBP_GunMainPanel_C.OnInscriptionUnHovered, self)
end

function WBP_GunMainPanel_C:OnAccessorySlotHovered(AccessoryId, AccessoryRarity, InscriptionIdTable, Angle, Position)
  self:UpdateAccessoryInfoTip(true, AccessoryId, AccessoryRarity, InscriptionIdTable, Angle, Position)
end

function WBP_GunMainPanel_C:OnAccessorySlotUnHovered()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TipTimer) then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TipTimer)
  end
  self:UpdateAccessoryInfoTip(false)
  self:UpdateAccessoryNoteTip(false)
end

function WBP_GunMainPanel_C:OnInscriptionHovered(InscriptionId)
  local InscriptionIdTable = {}
  table.insert(InscriptionIdTable, InscriptionId)
  self:UpdateAccessoryNoteTipForPanel(true, InscriptionIdTable)
end

function WBP_GunMainPanel_C:OnInscriptionUnHovered()
  self:UpdateAccessoryNoteTipForPanel(false)
end

function WBP_GunMainPanel_C:UpdateAccessorySlots(AccessoryDataTable)
  self.WBP_AccessorySlotPanel:UpdateAccessorySlots(AccessoryDataTable)
end

function WBP_GunMainPanel_C:UpdateGunDisplayPanel(GunId, GunLevel, AccessoryList, AttributeList, InscriptionIdList)
  self.WBP_GunDisplayPanel:UpdateGunDisplayPanel(GunId, GunLevel, AccessoryList, AttributeList, InscriptionIdList, self.LeftOrRight)
end

function WBP_GunMainPanel_C:UpdateAccessoryInfoTip(Show, AccessoryId, AccessoryRarity, InscriptionIdTable, Angle, Position)
  self.AccessorySlotItemAngle = Angle
  if Show then
    local alignment
    if Angle then
      alignment = UE.FVector2D(0.0, 1.0)
    else
      alignment = UE.FVector2D(0.0, 0.0)
    end
    local toolWidgetSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_AccessoryDisplayInfo)
    toolWidgetSlot:SetAlignment(alignment)
    toolWidgetSlot:SetAutoSize(true)
    local tempPosition = Position
    if Angle then
      tempPosition.X = Position.X - 47.3
      tempPosition.Y = Position.Y + 93
    else
      tempPosition.X = Position.X - 45.3
      tempPosition.Y = Position.Y - 88
    end
    toolWidgetSlot:SetPosition(tempPosition)
    self.CurrentInscriptionIdTable = InscriptionIdTable
    self.WBP_AccessoryDisplayInfo:UpdateDisplayInfo(AccessoryId, AccessoryRarity, self.CurrentInscriptionIdTable, 215)
    self.WBP_AccessoryDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.TipTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      WBP_GunMainPanel_C.UpdateAccessoryNoteTipFunc
    }, 0.05, false)
  else
    self.WBP_AccessoryDisplayInfo:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function WBP_GunMainPanel_C:UpdateAccessoryNoteTipFunc()
  self:UpdateAccessoryNoteTip(true)
end

function WBP_GunMainPanel_C:UpdateAccessoryNoteTip(Show)
  if Show then
    self.WBP_ExtraDescItemsPanel:UpdateInscriptionAdditions(self.CurrentInscriptionIdTable)
    local toolWidgetSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_AccessoryDisplayInfo)
    local tempPosition = toolWidgetSlot:GetPosition()
    local tempSize = UE.USlateBlueprintLibrary.GetLocalSize(self.WBP_AccessoryDisplayInfo:GetCachedGeometry())
    local viewportSize = UE.UWidgetLayoutLibrary.GetViewportSize(self)
    local halfX = viewportSize.X / 2
    local Alignment
    if halfX > tempPosition.X then
      Alignment = UE.FVector2D(0.0, 0.0)
      tempPosition.X = tempPosition.X + tempSize.X - 6
    else
      Alignment = UE.FVector2D(1.0, 0.0)
      tempPosition.X = tempPosition.X + 5
    end
    if self.AccessorySlotItemAngle then
      tempPosition.Y = tempPosition.Y - tempSize.Y + 5
    else
      tempPosition.Y = tempPosition.Y + 5
    end
    local toolNoteWidgetSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_ExtraDescItemsPanel)
    toolNoteWidgetSlot:SetPosition(tempPosition)
    toolNoteWidgetSlot:SetAlignment(Alignment)
    toolNoteWidgetSlot:SetAutoSize(true)
  else
    self.WBP_ExtraDescItemsPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function WBP_GunMainPanel_C:UpdateAccessorySlotsPosition(RowName, CenterTransform)
  self.WBP_AccessorySlotPanel:UpdateAccessorySlotsPosition(RowName, CenterTransform)
end

function WBP_GunMainPanel_C:UpdateAccessoryNoteTipForPanel(Show, InscriptionIdTable)
  if Show then
    self.WBP_ExtraDescItemsPanel:UpdateInscriptionAdditions(InscriptionIdTable)
    local toolWidgetSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GunDisplayPanel)
    local tempPosition = toolWidgetSlot:GetPosition()
    local tempSize = UE.USlateBlueprintLibrary.GetLocalSize(self.WBP_GunDisplayPanel.WBP_GunDisplayInfo:GetCachedGeometry())
    local viewportSize = UE.UWidgetLayoutLibrary.GetViewportSize(self)
    local alignment
    if self.LeftOrRight then
      alignment = UE.FVector2D(0.0, 0.0)
      tempPosition.X = viewportSize.X + tempPosition.X
    else
      alignment = UE.FVector2D(1.0, 0.0)
      tempPosition.X = viewportSize.X + tempPosition.X - tempSize.X
    end
    tempPosition.Y = tempPosition.Y + tempSize.Y + 8
    local toolNoteWidgetSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_ExtraDescItemsPanel)
    toolNoteWidgetSlot:SetPosition(tempPosition)
    toolNoteWidgetSlot:SetAlignment(alignment)
    toolNoteWidgetSlot:SetAutoSize(true)
  else
    self.WBP_ExtraDescItemsPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

return WBP_GunMainPanel_C
