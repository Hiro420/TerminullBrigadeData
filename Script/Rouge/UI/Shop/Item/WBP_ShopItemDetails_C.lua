local WBP_ShopItemDetails_C = UnLua.Class()

function WBP_ShopItemDetails_C:RefreshItemDetails(ItemInfo)
  if nil == ItemInfo then
    return
  end
  if ItemInfo == self.ItemInfo then
    return
  end
  self.ItemInfo = ItemInfo
  UpdateVisibility(self.Tip, false)
  UpdateVisibility(self.CanvasPanelScrollDuplicated, false)
  self.AttributeModifySet2:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.AttributeModifySet1:SetVisibility(UE.ESlateVisibility.Collapsed)
  local ItemRowInfo = LogicShop.GetItemInfoByInstanceId(ItemInfo.InstanceId)
  local IconSizeTable = {X = 128, Y = 128}
  SetImageBrushBySoftObject(self.Img_Icon, ItemRowInfo.SpriteIcon, IconSizeTable)
  self.Txt_Name:SetText(ItemRowInfo.Name)
  self.Txt_Desc:SetText(ItemRowInfo.Desc)
  self.Price:SetText(ItemInfo.CashCost)
  local TargetInstanceInfo = LogicShop.ItemList[ItemInfo.InstanceId]
  if not TargetInstanceInfo then
    print("[LJS]:\230\178\161\230\156\137\229\174\158\228\190\139")
    return nil
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("[LJS]:\230\178\161\230\156\137DTSubsystem")
    return nil
  end
  IconSizeTable = {X = 60, Y = 60}
  local RowInfo, ReturnValue
  if TargetInstanceInfo.ItemType == UE.ERGShopItemType.AttributeModify then
    UpdateVisibility(self.Tip, Logic_Scroll:CheckScrollIsFull())
    print("WBP_ShopItemDetails_C", ItemInfo.ModifyId)
    UpdateVisibility(self.CanvasPanelScrollDuplicated, Logic_Scroll:CheckScrollIsDuplicated(ItemRowInfo.ModifyId))
    if ItemRowInfo.SetArray:Num() >= 1 then
      self.AttributeModifySet1:SetVisibility(UE.ESlateVisibility.Visible)
      ReturnValue, RowInfo = DTSubsystem:GetAttributeModifySetDataById(ItemRowInfo.SetArray:Get(1), nil)
      SetImageBrushBySoftObject(self.AttributeModifySet1, RowInfo.SetIconWithBg, IconSizeTable)
      if 2 == ItemRowInfo.SetArray:Num() then
        self.AttributeModifySet2:SetVisibility(UE.ESlateVisibility.Visible)
        ReturnValue, RowInfo = DTSubsystem:GetAttributeModifySetDataById(ItemRowInfo.SetArray:Get(2), nil)
        SetImageBrushBySoftObject(self.AttributeModifySet2, RowInfo.SetIconWithBg, IconSizeTable)
      end
    else
      self.AttributeModifySet1:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    local Inscription = ItemRowInfo.Inscription
    local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if not logicCommandDataSubsystem then
      print("WBP_ShopItemDetails_C: logicCommandDataSubsystem is null.")
      return
    end
    self.Txt_Desc:SetText(GetLuaInscriptionDesc(Inscription))
    UpdateVisibility(self.OperateTipPanel, not Logic_Scroll:CheckScrollIsFull() and not ItemInfo.bSoldOut)
  else
    UpdateVisibility(self.OperateTipPanel, not ItemInfo.bSoldOut)
  end
end

return WBP_ShopItemDetails_C
