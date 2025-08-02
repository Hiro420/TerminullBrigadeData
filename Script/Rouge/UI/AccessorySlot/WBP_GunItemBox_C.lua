local WBP_GunItemBox_C = UnLua.Class()

function WBP_GunItemBox_C:Construct()
  self.wbp_GunItemClass = UE.UClass.Load("/Game/Rouge/UI/AccessorySlot/WBP_GunItem.WBP_GunItem_C")
end

function WBP_GunItemBox_C:UpdateGunItemBox(GunInfoTable)
  local number = #GunInfoTable
  local padding = UE.FMargin()
  padding.Right = 0
  UpdateWidgetContainerByClass(self.HorizontalBox_GunItemBox, number, self.wbp_GunItemClass, padding, self, self:GetOwningPlayer())
  local widgetArray = self.HorizontalBox_GunItemBox:GetAllChildren()
  for key, gunInfo in pairs(GunInfoTable) do
    if widgetArray:IsValidIndex(key) then
      gunInfo.Number = key
      widgetArray:Get(key):UpdateGunItem(gunInfo)
      if 1 == key then
        widgetArray:Get(key):OnClicked_Button()
      end
    end
  end
end

return WBP_GunItemBox_C
