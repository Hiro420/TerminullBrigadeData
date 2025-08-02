local WBP_GunItem_C = UnLua.Class()

function WBP_GunItem_C:Construct()
  self.Button_Selected.OnClicked:Add(self, WBP_GunItem_C.OnClicked_Button)
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnGunSlotClicked, WBP_GunItem_C.OnGunSlotClicked)
end

function WBP_GunItem_C:Destruct()
  self.Button_Selected.OnClicked:Remove(self, WBP_GunItem_C.OnClicked_Button)
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnGunSlotClicked, WBP_GunItem_C.OnGunSlotClicked, self)
end

function WBP_GunItem_C:UpdateGunItem(GunInfo)
  self.GunId = GunInfo.GunId
  self.TextBlock_GunName:SetText(tostring(GunInfo.Number))
  local tempId
  self.Image_GunElementType:SetVisibility(UE.ESlateVisibility.Collapsed)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if tonumber(GunInfo.BarrelId) > 0 then
    tempId = GunInfo.BarrelId
    local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(tempId), nil)
    if result and accessoryData.ElementEffectList:Length() > 0 then
      local find, outRow = GetDataLibraryObj():GetElementEffectRowInfo(tostring(accessoryData.ElementEffectList:Get(1)))
      print("accessoryData.ElementEffectList:Get(1)")
      print(accessoryData.ElementEffectList:Get(1))
      if find then
        local ElementAsset = UE.URGElementStatics.GetElementAsset(outRow.ElementType)
        if ElementAsset then
          local EIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ElementAsset.Icon)
          local EBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(EIconObj, 0, 0)
          self.Image_GunElementType:SetBrush(EBrush)
          self.Image_GunElementType:SetVisibility(UE.ESlateVisibility.Visible)
        else
          self.Image_GunElementType:SetVisibility(UE.ESlateVisibility.Collapsed)
        end
      end
    end
  else
    tempId = GunInfo.GunId
  end
  local ItemData
  ItemData = DTSubsystem:K2_GetItemTableRow(tempId, nil)
  local result, worldTypeData = DTSubsystem:GetWorldTypeTableRow(ItemData.WorldTypeId)
  if result then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(worldTypeData.GunSpriteIcon)
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.Image_GunWorldType:SetBrush(Brush)
    local backIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(worldTypeData.WeaponSlotBackSpriteIcon)
    if backIconObj then
      local backBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(backIconObj, 0, 0)
      self.Image_Back:SetBrush(backBrush)
    end
  end
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ItemData.CompleteGunIcon)
  local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
  self.Image_Gun:SetBrush(Brush)
  self.WBP_GunAccessorySlotItemBox:UpdateGunAccessorySlotItemBox(GunInfo.AccessoryNumber, ItemData.WorldTypeId)
end

function WBP_GunItem_C:OnGunSlotClicked(GunId)
  if GunId ~= self.GunId then
    self.Overlay_GunItem:SetRenderScale(UE.FVector2D(0.8, 0.8))
  else
    self.Overlay_GunItem:SetRenderScale(UE.FVector2D(1, 1))
  end
end

function WBP_GunItem_C:OnClicked_Button()
  EventSystem.Invoke(EventDef.GunDisplayPanel.OnGunSlotClicked, self.GunId)
end

return WBP_GunItem_C
