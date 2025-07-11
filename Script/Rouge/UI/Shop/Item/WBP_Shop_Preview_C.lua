local WBP_Shop_Preview_C = UnLua.Class()
function WBP_Shop_Preview_C:RefreshItemPreview(ItemInfo)
  if nil == ItemInfo then
    print("WBP_Shop_Preview_C ,RefreshItemPreview() ItemInfo == nil")
    return
  end
  local Category = LogicShop.GetCategoryByInstanceId(ItemInfo.InstanceId)
  local ItemRowInfo = LogicShop.GetItemInfoByInstanceId(ItemInfo.InstanceId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return nil
  end
  if 2 == Category then
    self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(0)
    local RowInfo, ReturnValue
    if 0 == ItemRowInfo.SetArray:Num() then
      UpdateVisibility(self.ScrollSetPickupTipsItem1, false)
      return
    end
    ReturnValue, RowInfo = DTSubsystem:GetAttributeModifySetDataById(ItemRowInfo.SetArray:Get(1), nil)
    self.ScrollSetPickupTipsItem1:InitScrollSetTipsItem(ItemRowInfo.SetArray:Get(1), ItemRowInfo.ModifyId, true, EScrollTipsOpenType.EFromPickup)
    if 2 == ItemRowInfo.SetArray:Num() then
      self.ScrollSetPickupTipsItem2:InitScrollSetTipsItem(ItemRowInfo.SetArray:Get(2), ItemRowInfo.ModifyId, false, EScrollTipsOpenType.EFromPickup)
    else
      UpdateVisibility(self.ScrollSetPickupTipsItem2, false)
    end
    UpdateVisibility(self.ScrollSetPickupTipsItem1.URGImageBg, false)
    UpdateVisibility(self.ScrollSetPickupTipsItem2.URGImageBg, false)
    UpdateVisibility(self.ScrollSetPickupTipsItem1.URGImageBg_chuanshuo, false)
    UpdateVisibility(self.ScrollSetPickupTipsItem2.URGImageBg_chuanshuo, false)
  end
  if 1 == Category then
    self.Switcher:SetActiveWidgetIndex(1)
    self.Txt_Desc:SetText(ItemRowInfo.Desc)
    if ItemRowInfo.ArticleType == UE.EArticleDataType.Buff then
      self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:UpdateAttributeList(ItemRowInfo)
    else
      self:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  if 3 == Category then
    self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(2)
    self:UpdateRecoveryPropsList(ItemRowInfo)
  end
end
function WBP_Shop_Preview_C:UpdateAttributeList(ItemRowInfo)
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local ItemAsset = ItemRowInfo.ItemAsset
  if not ItemAsset then
    return
  end
  local ItemConfig = ItemAsset.ItemConfig
  if not ItemConfig then
    return
  end
  local AllHeartBuffList = ItemConfig.BuffList:ToTable()
  local CurHealth = self:GetAttributeValue(self.HealthAttribute)
  local CurMaxHealth = self:GetAttributeValue(self.MaxHealthAttribute)
  local CurShield = self:GetAttributeValue(self.ShieldAttribute)
  local CurMaxShield = self:GetAttributeValue(self.MaxShieldAttribute)
  if CurHealth > 0 and CurHealth < 1 then
    CurHealth = 1
  end
  local HealthStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", CurHealth))))
  local MaxHealthStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", CurMaxHealth))))
  self.OldHealth:SetText(HealthStr)
  self.OldHealthMax:SetText(MaxHealthStr)
  local ShieldStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", CurShield))))
  local MaxShieldStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", CurMaxShield))))
  self.OldShield:SetText(ShieldStr)
  self.OldShieldMax:SetText(MaxShieldStr)
  for index, SingleBuffId in ipairs(AllHeartBuffList) do
    local BuffInfo = BuffDataSubsystem:GetDataFormID(SingleBuffId)
    for key, SingleModifyAttribute in pairs(BuffInfo.GEData.ModifyAttributeArray) do
      local TargetValue = self:CalcAttributeAddition(SingleModifyAttribute)
      if SingleModifyAttribute.Attribute == self.HealthAttribute then
        CurHealth = CurHealth + TargetValue
      elseif SingleModifyAttribute.Attribute == self.MaxHealthAttribute then
        CurMaxHealth = CurMaxHealth + TargetValue
      elseif SingleModifyAttribute.Attribute == self.ShieldAttribute then
        CurShield = CurShield + TargetValue
      elseif SingleModifyAttribute.Attribute == self.MaxShieldAttribute then
        CurMaxShield = CurMaxShield + TargetValue
      end
    end
  end
  if CurHealth > 0 and CurHealth < 1 then
    CurHealth = 1
  end
  HealthStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", math.clamp(CurHealth, 0, CurMaxHealth)))))
  MaxHealthStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", CurMaxHealth))))
  self.NewHealth:SetText(HealthStr)
  self.NewHealthMax:SetText(MaxHealthStr)
  ShieldStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", math.clamp(CurShield, 0, CurMaxShield)))))
  MaxShieldStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", CurMaxShield))))
  self.NewShield:SetText(ShieldStr)
  self.NewShieldMax:SetText(MaxShieldStr)
end
function WBP_Shop_Preview_C:CalcAttributeAddition(ModifyAttribute)
  if ModifyAttribute.ValueModifyRule == UE.EAttributeModifyRule.StaticValue then
    return ModifyAttribute.BaseValue
  else
    local TargetValue = 0
    for key, SingleAttributeValueModifyData in pairs(ModifyAttribute.AttributeValueModifyData) do
      local ModifyByAttributeValue = self:GetAttributeValue(SingleAttributeValueModifyData.ValueModifyData.Attribute)
      if SingleAttributeValueModifyData.ValueModifyData.ModifierOp == UE.EGameplayModOp.Additive then
        TargetValue = TargetValue + ModifyByAttributeValue + SingleAttributeValueModifyData.ValueModifyData.BaseValue
      elseif SingleAttributeValueModifyData.ValueModifyData.ModifierOp == UE.EGameplayModOp.Multiplicitive then
        TargetValue = TargetValue + ModifyByAttributeValue * SingleAttributeValueModifyData.ValueModifyData.BaseValue
      end
      if SingleAttributeValueModifyData.ModifierOp == UE.EGameplayModOp.Additive then
        TargetValue = TargetValue + ModifyAttribute.BaseValue
      elseif SingleAttributeValueModifyData.ModifierOp == UE.EGameplayModOp.Multiplicitive then
        TargetValue = TargetValue * ModifyAttribute.BaseValue
      end
    end
    return TargetValue
  end
end
function WBP_Shop_Preview_C:GetAttributeValue(Attribute)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return 0
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if not ASC then
    return 0
  end
  local AttributeValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, Attribute, nil)
  return AttributeValue
end
function WBP_Shop_Preview_C:UpdateRecoveryPropsList(ItemRowInfo)
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local ItemAsset = ItemRowInfo.ItemAsset
  if not ItemAsset then
    return
  end
  local ItemConfig = ItemAsset.ItemConfig
  if not ItemConfig then
    return
  end
  local AllHeartBuffList = ItemConfig.BuffList:ToTable()
  local CurHealth = self:GetAttributeValue(self.HealthAttribute)
  local CurMaxHealth = self:GetAttributeValue(self.MaxHealthAttribute)
  if CurHealth > 0 and CurHealth < 1 then
    CurHealth = 1
  end
  local HealthStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", CurHealth))))
  self.OldHealth_2:SetText(HealthStr)
  for index, SingleBuffId in ipairs(AllHeartBuffList) do
    local BuffInfo = BuffDataSubsystem:GetDataFormID(SingleBuffId)
    for key, SingleModifyAttribute in pairs(BuffInfo.GEData.ModifyAttributeArray) do
      local TargetValue = self:CalcAttributeAddition(SingleModifyAttribute)
      if SingleModifyAttribute.Attribute == self.HealthAttribute then
        CurHealth = CurHealth + TargetValue
      end
    end
  end
  if CurHealth > 0 and CurHealth < 1 then
    CurHealth = 1
  end
  HealthStr = string.format("%d", UE.UKismetMathLibrary.Round(tonumber(string.format("%.2f", math.clamp(CurHealth, 0, CurMaxHealth)))))
  self.NewHealth_2:SetText(HealthStr)
end
return WBP_Shop_Preview_C
