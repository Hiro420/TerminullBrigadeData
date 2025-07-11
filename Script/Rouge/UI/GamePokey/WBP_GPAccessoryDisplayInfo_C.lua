local WBP_GPAccessoryDisplayInfo_C = UnLua.Class()
function WBP_GPAccessoryDisplayInfo_C:InitInfo(AccessoryId, Angle)
  self.BottomIcon = {
    [UE.ERGItemRarity.EIR_Normal] = self.NormalBottom,
    [UE.ERGItemRarity.EIR_Excellent] = self.ExcellentBottom,
    [UE.ERGItemRarity.EIR_Rare] = self.RareBottom,
    [UE.ERGItemRarity.EIR_Epic] = self.EpicBottom,
    [UE.ERGItemRarity.EIR_Legend] = self.LegendBottom
  }
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  self.AccessoryId = AccessoryId
  local AccessoryData = UE.URGAccessoryStatics.GetAccessoryData(self, AccessoryId, nil)
  local AccessoryRowInfo = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, AccessoryId, nil)
  local ItemRarity = AccessoryData.InnerData.ItemRarity
  local ItemRowInfo = DTSubsystem:K2_GetItemTableRow(tostring(AccessoryRowInfo.ConfigId), nil)
  self.Txt_GunName:SetText(ItemRowInfo.Name)
  SetImageBrushBySoftObject(self.Img_Icon, ItemRowInfo.SpriteIcon)
  local result, WorldRowInfo = DTSubsystem:GetWorldTypeTableRow(ItemRowInfo.WorldTypeId)
  if result then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WorldRowInfo.GunSpriteIcon)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 56, 64)
      self.Img_World:SetBrush(Brush)
    end
    local backIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WorldRowInfo.AccessoryTipsBackSpriteIcon)
    if backIconObj then
      self:SetTipBack(backIconObj)
    end
  end
  SetImageBrushBySoftObject(self.Img_QualityBottom, self.BottomIcon[ItemRarity])
  self:InitInscriptionList(AccessoryRowInfo, ItemRarity)
end
function WBP_GPAccessoryDisplayInfo_C:InitInscriptionList(AccessoryRowInfo, ItemRarity)
  local AllChildren = self.InscriptionList:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local InscriptionList = AccessoryRowInfo.InscriptionMap:Find(ItemRarity)
  if InscriptionList then
    for i, SingleInscriptionInfo in pairs(InscriptionList.Inscriptions) do
      if SingleInscriptionInfo and SingleInscriptionInfo.bIsShowInUI then
        local Item = self.InscriptionList:GetChildAt(i - 1)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, self.InscriptionItemTemplate:StaticClass())
          self.InscriptionList:AddChild(Item)
        end
        Item:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
        Item:SetTextWidthOverride(215)
        Item:UpdateInscriptionDes(SingleInscriptionInfo.InscriptionId, 0)
      end
    end
  end
end
function WBP_GPAccessoryDisplayInfo_C:UpdateAnchors(Angle)
  local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.VerticalBox_Info)
  local Anchors = UE.FAnchors()
  local Position = UE.FVector2D(0.0, 0.0)
  local Alignment = UE.FVector2D(0.0, 0.0)
  Anchors.Minimum = UE.FVector2D(1.0, 1.0)
  Anchors.Maximum = UE.FVector2D(1.0, 1.0)
  if Angle then
    Anchors.Minimum = UE.FVector2D(0.0, 1.0)
    Anchors.Maximum = UE.FVector2D(0.0, 1.0)
    Alignment = UE.FVector2D(0.0, 1.0)
  else
    Anchors.Minimum = UE.FVector2D(0.0, 0.0)
    Anchors.Maximum = UE.FVector2D(0.0, 0.0)
    Alignment = UE.FVector2D(0.0, 0.0)
  end
  Slot:SetAnchors(Anchors)
  Slot:SetPosition(Position)
  Slot:SetAlignment(Alignment)
  Slot:SetAutoSize(true)
end
return WBP_GPAccessoryDisplayInfo_C
