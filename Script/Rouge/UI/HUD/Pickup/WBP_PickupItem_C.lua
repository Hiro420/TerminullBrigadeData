local WBP_PickupItem_C = UnLua.Class()
function WBP_PickupItem_C:Construct()
  if not IsListeningForInputAction(self, self.ActionName) then
    ListenForInputAction(self.ActionName, UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_PickupItem_C.ListenForInteractInputAction
    })
  end
  self.Btn_Item.OnClicked:Add(self, WBP_PickupItem_C.BindOnItemBtnClicked)
end
function WBP_PickupItem_C:BindOnItemBtnClicked()
  if not self.PickupActor then
    return
  end
end
function WBP_PickupItem_C:SetIsSelected(IsSelected)
  self.IsSelected = self.PickupActor == LogicPickup.CurSelectPickupActor
  if self.IsSelected then
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_PickupItem_C:Show(PickupActor)
  self.PickupActor = PickupActor
  self:SetIsSelected(false)
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
  self.Txt_Name:SetText(ItemData.Name)
  self.Txt_World:SetText(self:GetWorldTypeName(ItemData.WorldTypeId))
  local RarityRowInfo = self:GetRarityRowInfo(self.PickupActor.AccessoryId)
  local AccessoryIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ItemData.SpriteIcon)
  if AccessoryIconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(AccessoryIconObj, 59, 64)
    self.Img_Icon:SetBrush(Brush)
  end
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(RarityRowInfo.SpriteIcon)
  if IconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.Img_IconBottom:SetBrush(Brush)
  end
  self:SetVisibility(UE.ESlateVisibility.Visible)
end
function WBP_PickupItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.PickupActor = nil
end
function WBP_PickupItem_C:ListenForInteractInputAction()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not InteractHandle then
    return
  end
  if self.IsSelected then
    InteractHandle:InteractWith(self.PickupActor)
  end
end
function WBP_PickupItem_C:Destruct()
  StopListeningForInputAction(self, self.ActionName, UE.EInputEvent.IE_Pressed)
end
return WBP_PickupItem_C
