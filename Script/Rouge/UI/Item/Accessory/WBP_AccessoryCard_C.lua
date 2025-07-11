local WBP_AccessoryCard_C = UnLua.Class()
function WBP_AccessoryCard_C:Construct()
  self.Button.OnClicked:Add(self, WBP_AccessoryCard_C.OnClicked_Button)
  self:GetWeaponCapture()
end
function WBP_AccessoryCard_C:UpdateCard(InAccessoryId)
  self.AccessoryId = InAccessoryId
  local accessoryManager = UE.URGAccessoryStatics.GetAccessoryManager(self)
  if accessoryManager then
    local outAccessory = accessoryManager:GetAccessory(self.AccessoryId)
    local RGDataTableSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGDataTableSubsystem:StaticClass())
    if RGDataTableSubsystem then
      local itemData = RGDataTableSubsystem:K2_GetItemTableRow(outAccessory.InnerData.ConfigId)
      local id_int = UE.URGArticleStatics.GetInstanceId(self.AccessoryId)
      self.NameText:SetText(UE.UKismetTextLibrary.Conv_StringToText(UE.UKismetStringLibrary.Concat_StrStr(UE.UKismetTextLibrary.Conv_TextToString(itemData.Name), UE.UKismetStringLibrary.Conv_IntToString(id_int))))
      local equipmentComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
      if equipmentComponent then
        local currentWeapon = equipmentComponent:GetCurrentWeapon()
        if currentWeapon then
          local accessoryComponent = currentWeapon:GetComponentByClass(UE.URGAccessoryComponent.StaticClass())
          local canequip, cannotReason_string = accessoryComponent:CanEquipAccessory(self.AccessoryId)
          if canequip then
          else
            self.InfoText:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
            if "No_Slot" == cannotReason_string then
              self.InfoText:SetText("\230\178\161\230\156\137\230\167\189\228\189\141")
            end
          end
        end
      end
    end
  end
end
function WBP_AccessoryCard_C:OnClicked_Button()
  if self:IsAccessoryRotate() then
    return
  end
  if self.bSelected then
    self:UnselectCard()
    self:OnAccessoryClicked(false)
  else
    self:SelectCard()
    self:OnAccessoryClicked(true)
  end
end
return WBP_AccessoryCard_C
