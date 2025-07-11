local WBP_AccessoryDisplayInfo_C = UnLua.Class()
function WBP_AccessoryDisplayInfo_C:UpdateDisplayInfo(AccessoryId, AccessoryRarity, InscriptionIdList, Width)
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
  local ItemRowInfo = DTSubsystem:K2_GetItemTableRow(tostring(AccessoryId), nil)
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
  SetImageBrushBySoftObject(self.Img_QualityBottom, self.BottomIcon[AccessoryRarity])
  self.WBP_GunInscriptionPanel:UpdateInscriptionPanel(InscriptionIdList, Width)
end
return WBP_AccessoryDisplayInfo_C
