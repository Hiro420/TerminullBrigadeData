local WBP_CommonAccessoryDisplayInfo_C = UnLua.Class()

function WBP_CommonAccessoryDisplayInfo_C:Construct()
end

function WBP_CommonAccessoryDisplayInfo_C:InitInfo(AccessoryId)
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
  if not self.BottomIcon then
    self.BottomIcon = {
      [UE.ERGItemRarity.EIR_Normal] = self.NormalBottom,
      [UE.ERGItemRarity.EIR_Excellent] = self.ExcellentBottom,
      [UE.ERGItemRarity.EIR_Rare] = self.RareBottom,
      [UE.ERGItemRarity.EIR_Epic] = self.EpicBottom,
      [UE.ERGItemRarity.EIR_Legend] = self.LegendBottom
    }
  end
  SetImageBrushBySoftObject(self.Img_QualityBottom, self.BottomIcon[ItemRarity])
  self:InitInscriptionList(AccessoryRowInfo, ItemRarity)
end

function WBP_CommonAccessoryDisplayInfo_C:InitInscriptionList(AccessoryRowInfo, ItemRarity)
  local AllChildren = self.InscriptionList:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local InscriptionList = AccessoryRowInfo.InscriptionMap:Find(ItemRarity)
  if InscriptionList then
    for i, SingleInscriptionInfo in pairs(InscriptionList.Inscriptions) do
      local Item = self.InscriptionList:GetChildAt(i - 1)
      if not Item then
        Item = UE.UWidgetBlueprintLibrary.Create(self, self.InscriptionItemTemplate:StaticClass())
        self.InscriptionList:AddChild(Item)
      end
      Item:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      Item:SetSizeBoxWidth(215)
      Item:InitInfo(SingleInscriptionInfo.InscriptionId, 0)
      Item:SetInscriptionNameColor(self.AccessoryTextColor)
    end
  end
end

return WBP_CommonAccessoryDisplayInfo_C
