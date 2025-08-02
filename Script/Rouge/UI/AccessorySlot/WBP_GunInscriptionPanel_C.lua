local WBP_GunInscriptionPanel_C = UnLua.Class()

function WBP_GunInscriptionPanel_C:Construct()
  self.wbp_GunInscriptionItemClass = UE.UClass.Load("/Game/Rouge/UI/AccessorySlot/WBP_GunInscriptionItem.WBP_GunInscriptionItem_C")
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnAccessorySlotHovered, WBP_GunInscriptionPanel_C.OnAccessorySlotHovered)
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnAccessorySlotUnHovered, WBP_GunInscriptionPanel_C.OnAccessorySlotUnHovered)
end

function WBP_GunInscriptionPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnAccessorySlotHovered, WBP_GunInscriptionPanel_C.OnAccessorySlotHovered, self)
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnAccessorySlotUnHovered, WBP_GunInscriptionPanel_C.OnAccessorySlotUnHovered, self)
end

function WBP_GunInscriptionPanel_C:UpdateInscriptionPanel(InscriptionIdList, Width)
  self.SizeBox_GunInscriptionPanel:SetWidthOverride(Width)
  local Number = #InscriptionIdList
  if Number > 0 then
    self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local padding = UE.FMargin()
  padding.Bottom = 5
  UpdateWidgetContainerByClass(self.ScrollBox_Inscriptions, Number, self.wbp_GunInscriptionItemClass, padding, self, self:GetOwningPlayer())
  local widgetArray = self.ScrollBox_Inscriptions:GetAllChildren()
  for key, inscriptionId in pairs(InscriptionIdList) do
    if widgetArray:IsValidIndex(key) then
      widgetArray:Get(key):UpdateInscriptionItem(inscriptionId)
      widgetArray:Get(key):SetTextWidthOverride(Width)
    end
  end
end

function WBP_GunInscriptionPanel_C:OnAccessorySlotHovered(AccessoryId, AccessoryRarity, InscriptionIdTable, Angle, Position)
  for key, value in pairs(self.ScrollBox_Inscriptions:GetAllChildren()) do
    if table.Contain(InscriptionIdTable, value.InscriptionId) then
      value:UpdateInscriptionDesOpacity(true)
    else
      value:UpdateInscriptionDesOpacity(false)
    end
  end
end

function WBP_GunInscriptionPanel_C:OnAccessorySlotUnHovered()
  for key, value in pairs(self.ScrollBox_Inscriptions:GetAllChildren()) do
    value:UpdateInscriptionDesOpacity(true)
  end
end

return WBP_GunInscriptionPanel_C
