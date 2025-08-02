local WBP_SimplePickupTip_C = UnLua.Class()

function WBP_SimplePickupTip_C:RefreshInfo(PickupActor)
  self.PickupActor = PickupActor
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ItemData = DTSubsystem:K2_GetItemTableRow(self.PickupActor:GetItemId(), nil)
  if ItemData.ArticleType == UE.EArticleDataType.Weapon then
    local PickWeapon = self.PickupActor:GetWeapon()
    if PickWeapon then
      local AccessoryComp = PickWeapon.AccessoryComponent
      if AccessoryComp and AccessoryComp:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel) then
        local ArticleId = AccessoryComp:GetAccessoryByType(UE.ERGAccessoryType.EAT_Barrel)
        local ItemId = UE.URGArticleStatics.GetConfigId(ArticleId)
        ItemData = DTSubsystem:K2_GetItemTableRow(ItemId, nil)
      end
    end
  end
  self:RefreshPanelInfo()
  self.Txt_Name:SetText(ItemData.Name)
  self.Txt_WorldType:SetText(self:GetWorldTypeName(ItemData.WorldTypeId))
  local RarityRowInfo = self:GetRarityRowInfo(self.PickupActor.AccessoryId)
  local AccessoryIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ItemData.SpriteIcon)
  if AccessoryIconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(AccessoryIconObj, 59, 64)
    self.Img_Icon:SetBrush(Brush)
  end
  self.Txt_Quality:SetText(RarityRowInfo.DisplayName)
  self.Txt_Quality:SetColorAndOpacity(RarityRowInfo.DisplayNameColor)
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(RarityRowInfo.SpriteIcon)
  if IconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.Img_QualityBottom:SetBrush(Brush)
  end
end

function WBP_SimplePickupTip_C:RefreshPanelInfo()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ItemData = DTSubsystem:K2_GetItemTableRow(self.PickupActor:GetItemId(), nil)
  if ItemData.ArticleType == UE.EArticleDataType.Weapon then
    self:InitWeaponInfo()
  else
    self:InitAccessoryInfo()
  end
end

function WBP_SimplePickupTip_C:InitWeaponInfo()
  self.DisablePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CanUseTipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_CompareQuality:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_SimplePickupTip_C:InitAccessoryInfo()
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurWeapon = EquipmentComp:GetCurrentWeapon()
  if not CurWeapon then
    return
  end
  local AccessoryComp = CurWeapon.AccessoryComponent
  if not AccessoryComp then
    return
  end
  self.DisablePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  if AccessoryComp:CanPickupOrBuyAccessory(self.PickupActor.AccessoryId) then
    self.DisablePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.CanUseTipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  local AllWeapons = EquipmentComp:GetAllWeapons(nil)
  for i, SingleWeapon in iterator(AllWeapons) do
    local AccessoryComp = SingleWeapon.AccessoryComponent
    if AccessoryComp and AccessoryComp:CanPickupOrBuyAccessory(self.PickupActor.AccessoryId) then
      if CurWeapon ~= SingleWeapon then
        self.Txt_Tip:SetText("\230\143\144\231\164\186: \230\173\166\229\153\168" .. tostring(EquipmentComp:GetWeaponSlotId(SingleWeapon)) .. "\229\143\175\228\189\191\231\148\168")
        self.CanUseTipPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
      local RarityRowInfo = self:GetRarityRowInfo(self.PickupActor.AccessoryId)
      local AccessoryRowInfo = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, self.PickupActor.AccessoryId, nil)
      local CurrentAccessory = AccessoryComp:GetAccessoryByType(AccessoryRowInfo.AccessoryType)
      local CurrentRarityRowInfo = self:GetRarityRowInfo(CurrentAccessory)
      self.Img_CompareQuality:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      if RarityRowInfo.ItemRarity > CurrentRarityRowInfo.ItemRarity then
        do
          local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.HighSprite)
          if IconObj then
            local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
            self.Img_CompareQuality:SetBrush(Brush)
          end
        end
        break
      end
      if RarityRowInfo.ItemRarity == CurrentRarityRowInfo.ItemRarity then
        self.Img_CompareQuality:SetVisibility(UE.ESlateVisibility.Collapsed)
        break
      end
      do
        local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.LowSprite)
        if IconObj then
          local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
          self.Img_CompareQuality:SetBrush(Brush)
        end
      end
      break
    end
  end
end

return WBP_SimplePickupTip_C
