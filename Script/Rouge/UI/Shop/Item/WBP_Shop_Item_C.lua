local WBP_Shop_Item_C = UnLua.Class()
function WBP_Shop_Item_C:Construct()
  self:AddBtnEvent()
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.OnBagChanged:Add(self, WBP_Shop_Item_C.OnBagChanged)
  end
end
function WBP_Shop_Item_C:OnBagChanged()
  if self.ItemInfo ~= nil then
    self:RefreshRefreshCountInfo()
  end
end
function WBP_Shop_Item_C:OnClose()
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.OnBagChanged:Remove(self, WBP_Shop_Item_C.OnBagChanged)
  end
end
function WBP_Shop_Item_C:RefreshRefreshCountInfo()
  local CostItemId, CostNum = UE.URGBlueprintLibrary.GetRefreshCost(self, LogicShop.GetCurRefreshCount() + 1, nil, nil)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local BagComp = PC:GetComponentByClass(UE.URGBagComponent:StaticClass())
  if not BagComp then
    return
  end
  local BagItemStack = BagComp:GetItemByConfigId(CostItemId)
  local Color = UE.FSlateColor()
  Color.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  if BagItemStack.Stack > self.ItemInfo.CashCost then
    Color.SpecifiedColor = UE.FLinearColor(0.89, 0.89, 0.89, 1)
  else
    Color = self.PriceColor
  end
  self.Txt_Price:SetColorAndOpacity(Color)
end
function WBP_Shop_Item_C:InitItemInfo(ItemInfo)
  if self.ItemInfo == ItemInfo then
    return
  end
  self.ItemInfo = ItemInfo
  local ItemRowInfo = LogicShop.GetItemInfoByInstanceId(self.ItemInfo.InstanceId)
  local PreviewModifyList = LogicShop.GetShopPreviewModifyList()
  local bSelected = ItemInfo.bSoldOut
  if PreviewModifyList and PreviewModifyList.InstanceId == self.ItemInfo.InstanceId then
    if PreviewModifyList.bSelected then
      bSelected = not PreviewModifyList.bAbandoned
    else
      bSelected = PreviewModifyList.bAbandoned
    end
    UpdateVisibility(self.BG_NotUse, not PreviewModifyList.bSelected and not PreviewModifyList.bAbandoned)
    if not PreviewModifyList.bSelected and not PreviewModifyList.bAbandoned then
      LogicShop:OpenGenericModifyChoosePanel(PreviewModifyList)
    end
  end
  UpdateVisibility(self.BG_NotAvailable, self:HaveGenericModify(self.ItemInfo.InstanceId))
  UpdateVisibility(self.BG_NotRarityUpAvailable, self:HaveRarityUpGenericModify(self.ItemInfo.InstanceId))
  UpdateVisibility(self.TxtX3, false)
  if ItemRowInfo.ItemAsset and ItemRowInfo.ItemAsset and ItemRowInfo.ItemAsset.ItemConfig and ItemRowInfo.ItemAsset.ItemConfig.NpcType == UE.ERGNpcType.NT_UpgradeModify and ItemRowInfo.ItemAsset.ItemConfig.UpgradeLevel > 1 then
    UpdateVisibility(self.TxtX3, true)
  end
  local IconSizeTable = {X = 60, Y = 60}
  SetImageBrushBySoftObject(self.Img_Item, ItemRowInfo.SpriteIcon)
  self.ItemName:SetText(ItemRowInfo.Name)
  self.Txt_Price:SetText(ItemInfo.CashCost)
  UpdateVisibility(self.Overlay, not bSelected)
  UpdateVisibility(self.sellout, bSelected)
  if bSelected then
    self.Border_0:SetContentColorAndOpacity(self.ContentColor)
    self.Img_Item:SetColorAndOpacity(self.IcoColor)
    self.ItemName:SetColorAndOpacity(self.TxtColor)
  else
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return nil
  end
  if ItemInfo.ItemType == UE.ERGShopItemType.AttributeModify then
    local Result, ModifyRowInfo = DTSubsystem:GetAttributeModifyDataById(ItemInfo.AttributeInfo.ModifyId, nil)
    if not Result then
      print("[LJS]:\228\184\141\230\152\175ModifyRowInfo")
      return
    end
    UpdateVisibility(self.BG_prop, false)
    UpdateVisibility(self.BG_Collection_Excellent, false)
    UpdateVisibility(self.BG_Collection_Rare, false)
    UpdateVisibility(self.BG_Collection_Epic, false)
    UpdateVisibility(self.BG_Collection_Legend, false)
    if ModifyRowInfo.Rarity <= UE.ERGItemRarity.EIR_Excellent then
      UpdateVisibility(self.BG_Collection_Excellent, true, false)
    elseif ModifyRowInfo.Rarity == UE.ERGItemRarity.EIR_Rare then
      UpdateVisibility(self.BG_Collection_Rare, true, false)
    elseif ModifyRowInfo.Rarity == UE.ERGItemRarity.EIR_Epic then
      UpdateVisibility(self.BG_Collection_Epic, true, false)
    elseif ModifyRowInfo.Rarity == UE.ERGItemRarity.EIR_Legend then
      UpdateVisibility(self.BG_Collection_Legend, true, false)
    else
      UpdateVisibility(self.BG_prop, true, false)
    end
  end
  local CostItemId, CostNum = UE.URGBlueprintLibrary.GetRefreshCost(self, LogicShop.GetCurRefreshCount() + 1, nil, nil)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local BagComp = PC:GetComponentByClass(UE.URGBagComponent:StaticClass())
  if not BagComp then
    return
  end
  local SlateColor = UE.FSlateColor()
  SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
  RGUIMgr:GetUI("WBP_Shop_C").WBP_Shop_Item_Details.Price:SetColorAndOpacity(SlateColor)
  local BagItemStack = BagComp:GetItemByConfigId(CostItemId)
  if BagItemStack.Stack < self.ItemInfo.CashCost then
    self.Txt_Price:SetColorAndOpacity(self.PriceColor)
    RGUIMgr:GetUI("WBP_Shop_C").WBP_Shop_Item_Details.Price:SetColorAndOpacity(self.PriceColor)
  end
end
function WBP_Shop_Item_C:AddBtnEvent()
  self.Btn_Main.OnHovered:Clear()
  self.Btn_Main.OnHovered:Add(self, function()
    LogicShop.OnPreselectionItem(self.ItemInfo, self)
  end)
  self.Btn_Main.OnClicked:Clear()
  self.Btn_Main.OnClicked:Add(self, function()
    if self.ItemInfo and self.ItemInfo.InstanceId then
      LogicShop.BuyShopItem(self.ItemInfo.InstanceId)
    end
  end)
  EventSystem.AddListener(self, EventDef.Shop.OnNavigationChange, function(Target, Row, Line)
    if Row == self.SelRow and Line == self.SelLine then
      LogicShop.OnPreselectionItem(self.ItemInfo, self)
      self.Btn_Main:SetKeyboardFocus()
    end
  end)
end
function WBP_Shop_Item_C:SetHovered(bHovered)
  UpdateVisibility(self.Img_Hover, bHovered)
  if bHovered then
    local CostItemId, CostNum = UE.URGBlueprintLibrary.GetRefreshCost(self, LogicShop.GetCurRefreshCount() + 1, nil, nil)
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if not PC then
      return
    end
    local BagComp = PC:GetComponentByClass(UE.URGBagComponent:StaticClass())
    if not BagComp then
      return
    end
    local SlateColor = UE.FSlateColor()
    SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
    SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
    RGUIMgr:GetUI("WBP_Shop_C").WBP_Shop_Item_Details.Price:SetColorAndOpacity(SlateColor)
    local BagItemStack = BagComp:GetItemByConfigId(CostItemId)
    if BagItemStack.Stack < self.ItemInfo.CashCost then
      RGUIMgr:GetUI("WBP_Shop_C").WBP_Shop_Item_Details.Price:SetColorAndOpacity(self.PriceColor)
    end
  end
end
function WBP_Shop_Item_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  print("LJS", UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent), self.LeftMouseButton)
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.LeftMouseButton then
    LogicShop.BuyShopItem(self.ItemInfo.InstanceId)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
function WBP_Shop_Item_C:HaveGenericModify(InstanceId)
  local Pawn = self:GetOwningPlayerPawn()
  local GenericModifyComponent = Pawn:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not GenericModifyComponent or GenericModifyComponent:HasCandidateModifies() then
    return false
  end
  local ItemRowInfo = LogicShop.GetItemInfoByInstanceId(InstanceId)
  if not (ItemRowInfo and ItemRowInfo.ItemAsset) or not ItemRowInfo.ItemAsset.ItemCategory then
    return false
  end
  if UE.UBlueprintGameplayTagLibrary.MatchesTag(ItemRowInfo.ItemAsset.ItemCategory, LogicShop.PowerUp, false) and ItemRowInfo.ItemAsset.ItemConfig and 3 == ItemRowInfo.ItemAsset.ItemConfig.NpcType then
    return true
  end
  return false
end
function WBP_Shop_Item_C:HaveRarityUpGenericModify(InstanceId)
  local Pawn = self:GetOwningPlayerPawn()
  local GenericModifyComponent = Pawn:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not GenericModifyComponent or GenericModifyComponent:HasCandidateRarityUpModifies() then
    return false
  end
  local ItemRowInfo = LogicShop.GetItemInfoByInstanceId(InstanceId)
  if not (ItemRowInfo and ItemRowInfo.ItemAsset) or not ItemRowInfo.ItemAsset.ItemCategory then
    return false
  end
  if UE.UBlueprintGameplayTagLibrary.MatchesTag(ItemRowInfo.ItemAsset.ItemCategory, LogicShop.PowerUp, false) and ItemRowInfo.ItemAsset.ItemConfig and ItemRowInfo.ItemAsset.ItemConfig.NpcType == UE.ERGNpcType.NT_RarityUpModify then
    return true
  end
  return false
end
return WBP_Shop_Item_C
