local WBP_WeaponCard_C = UnLua.Class()

function WBP_WeaponCard_C:Construct()
  self.Button.OnClicked:Add(self, WBP_WeaponCard_C.OnClicked_Button)
end

function WBP_WeaponCard_C:UpdateCard()
  if self.WeaponActor then
    local RGDataTableSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGDataTableSubsystem:StaticClass())
    if RGDataTableSubsystem then
      local itemData = RGDataTableSubsystem:K2_GetItemTableRow(self.WeaponActor.ItemId)
      self.NameText:SetText(itemData.Name)
      if self.bCompaion then
        self.InfoText:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.InfoText:SetText("\228\188\153\228\188\180\232\163\133\229\164\135")
      elseif self.WeaponActor:InActiveSlot() then
        self.InfoText:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        local equipmentComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
        if equipmentComponent and equipmentComponent:GetCurrentWeapon() == self.WeaponActor then
          self.InfoText:SetText("\229\189\147\229\137\141\232\163\133\229\164\135")
        end
      else
        self.InfoText:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    end
  end
end

function WBP_WeaponCard_C:InitializeUpdate(WeaponActor, Compaion)
  self.WeaponActor = WeaponActor
  self.bCompaion = Compaion
  self:UpdateCard()
end

function WBP_WeaponCard_C:OnClicked_Button()
  if self.bSelected then
    self:UnselectCard()
  else
    self:SelectCard()
  end
end

return WBP_WeaponCard_C
