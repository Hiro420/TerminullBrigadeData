local WBP_GunAccessorySlotItem_C = UnLua.Class()

function WBP_GunAccessorySlotItem_C:Construct()
  self.Image_AccessorySlot:SetColorAndOpacity(UE.FLinearColor(0.215861, 0.215861, 0.215861, 1.0))
end

function WBP_GunAccessorySlotItem_C:UpdateGunAccessorySlotItem(Light, WorldTypeId)
  if Light then
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem then
      local result, worldTypeData = DTSubsystem:GetWorldTypeTableRow(WorldTypeId)
      if result then
        self.Image_AccessorySlot:SetColorAndOpacity(worldTypeData.AccessorySlotColor)
      end
    end
  else
    self.Image_AccessorySlot:SetColorAndOpacity(UE.FLinearColor(0.215861, 0.215861, 0.215861, 1.0))
  end
end

return WBP_GunAccessorySlotItem_C
