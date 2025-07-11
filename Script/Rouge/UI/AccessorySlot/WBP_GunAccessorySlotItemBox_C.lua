local WBP_GunAccessorySlotItemBox_C = UnLua.Class()
function WBP_GunAccessorySlotItemBox_C:Construct()
  self.wbp_GunAccessorySlotItemClass = UE.UClass.Load("/Game/Rouge/UI/AccessorySlot/WBP_GunAccessorySlotItem.WBP_GunAccessorySlotItem_C")
end
function WBP_GunAccessorySlotItemBox_C:UpdateGunAccessorySlotItemBox(AccessoryNumber, WorldTypeId)
  local number = 8
  local padding = UE.FMargin()
  padding.Right = 5
  UpdateWidgetContainerByClass(self.HorizontalBox_AccessorySlot, number, self.wbp_GunAccessorySlotItemClass, padding, self, self:GetOwningPlayer())
  local widgetArray = self.HorizontalBox_AccessorySlot:GetAllChildren()
  for key, value in pairs(widgetArray) do
    if AccessoryNumber >= key then
      widgetArray:Get(key):UpdateGunAccessorySlotItem(true, WorldTypeId)
    else
      widgetArray:Get(key):UpdateGunAccessorySlotItem(false, WorldTypeId)
    end
  end
end
return WBP_GunAccessorySlotItemBox_C
