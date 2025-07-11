local WBP_WeaponAccessorySlotItem_C = UnLua.Class()
function WBP_WeaponAccessorySlotItem_C:UpdateEmptyAccessorySlot()
  self.Image_AccessorySlot:SetColorAndOpacity(UE.FLinearColor(0.215861, 0.215861, 0.215861, 1.0))
end
function WBP_WeaponAccessorySlotItem_C:UpdateAccessorySlotByWorldTypeId(WorldTypeId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local result, worldTypeData = DTSubsystem:GetWorldTypeTableRow(WorldTypeId)
    if result then
      self.Image_AccessorySlot:SetColorAndOpacity(worldTypeData.AccessorySlotColor)
    end
  end
end
return WBP_WeaponAccessorySlotItem_C
