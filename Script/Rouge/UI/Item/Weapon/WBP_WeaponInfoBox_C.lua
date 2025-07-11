local WBP_WeaponInfoBox_C = UnLua.Class()
function WBP_WeaponInfoBox_C:LoadWeaponInfo(Weapon)
  local RGDataTableSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGDataTableSubsystem:StaticClass())
  if RGDataTableSubsystem then
    local itemData = RGDataTableSubsystem:K2_GetItemTableRow(Weapon.ItemId)
    self.ItemNameText:SetText(itemData.Name)
    self:LoadWeaponAttribute(Weapon)
  end
end
function WBP_WeaponInfoBox_C:LoadWeaponAttribute(Weapon)
  self.WeaponAttributeBox:ClearChildren()
  local results_stringArray = Weapon:GetWeaponInfo()
  local length = results_stringArray:Length()
  local element, wbp_AttributeBox
  for i = 1, length do
    element = results_stringArray:Get(i)
    wbp_AttributeBox = UE.UWidgetBlueprintLibrary.Create(self, UE4.UClass.Load("WidgetBlueprint'/Game/Rouge/UI/Item/WBP_AttributeBox.WBP_AttributeBox_C'"), self:GetOwningPlayer())
    if wbp_AttributeBox then
      wbp_AttributeBox:UpdateBox(UE.UKismetTextLibrary.Conv_StringToText(element))
      self.WeaponAttributeBox:AddChildToVerticalBox(wbp_AttributeBox)
    end
  end
end
return WBP_WeaponInfoBox_C
