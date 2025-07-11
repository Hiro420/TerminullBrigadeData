local WBP_AccessoryDisplayInfo_C = UnLua.Class()
function WBP_AccessoryDisplayInfo_C:Construct()
  self:InitRarityInfo()
end
function WBP_AccessoryDisplayInfo_C:InitRarityInfo()
  self.RarityInfo = {
    [UE.ERGItemRarity.EIR_Normal] = {
      BottomColor = UE.FLinearColor(0.205079, 0.23074, 0.250158, 1.0),
      TitleColor = UE.FLinearColor(0.254152, 0.254152, 0.254152, 0.6)
    },
    [UE.ERGItemRarity.EIR_Excellent] = {
      BottomColor = UE.FLinearColor(0.097587, 0.296138, 0.141263, 1.0),
      TitleColor = UE.FLinearColor(0.107023, 0.266356, 0.162029, 0.6)
    },
    [UE.ERGItemRarity.EIR_Rare] = {
      BottomColor = UE.FLinearColor(0.082283, 0.309469, 0.473532, 1.0),
      TitleColor = UE.FLinearColor(0.084376, 0.300544, 0.630757, 0.6)
    },
    [UE.ERGItemRarity.EIR_Epic] = {
      BottomColor = UE.FLinearColor(0.381326, 0.122139, 0.508881, 1.0),
      TitleColor = UE.FLinearColor(0.40724, 0.093059, 0.558341, 0.6)
    },
    [UE.ERGItemRarity.EIR_Legend] = {
      BottomColor = UE.FLinearColor(0.597202, 0.40724, 0.102242, 1.0),
      TitleColor = UE.FLinearColor(0.955974, 0.545725, 0.093059, 0.6)
    }
  }
end
function WBP_AccessoryDisplayInfo_C:InitEquipped(IsEquip)
  if IsEquip then
    self.Txt_Status:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Txt_Status:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_AccessoryDisplayInfo_C:InitItemRarity(ItemRarity)
  if not self.RarityInfo then
    self:InitRarityInfo()
  end
  local SingleRarityInfo = self.RarityInfo[ItemRarity]
  SingleRarityInfo = SingleRarityInfo or self.RarityInfo[UE.ERGItemRarity.EIR_Normal]
  local SlateColor = UE.FSlateColor()
  SlateColor.SpecifiedColor = SingleRarityInfo.BottomColor
  SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  self.Txt_Quality:SetColorAndOpacity(SlateColor)
  self.Img_Title:SetColorAndOpacity(SingleRarityInfo.TitleColor)
end
function WBP_AccessoryDisplayInfo_C:InitInfo(ArticleId, IsCompare, Equipped, CompareId, EquipInfoType)
  self.ArticleId = ArticleId
  self:InitEquipped(Equipped)
  self:InitEquipInfo(EquipInfoType)
  self:InitAccessoryInfo()
  self:InitInscriptionInfo()
  self:InitDes()
  self:InitAttributeInfo(IsCompare, CompareId)
end
function WBP_AccessoryDisplayInfo_C:InitAccessoryInfo()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(self.ArticleId)
    local itemData = DTSubsystem:K2_GetItemTableRow(configId)
    self.TextBlock_Name:SetText(itemData.Name)
    self:LoadAccessoryImage(itemData.SpriteIcon)
    local result, worldTypeData = DTSubsystem:GetWorldTypeTableRow(itemData.WorldTypeId)
    self.Txt_WorldType:SetText(worldTypeData.WorldDisplayName)
    local outData = UE.URGAccessoryStatics.GetAccessoryData(self, self.ArticleId, nil)
    local itemRarityResult, itemRarityData = DTSubsystem:GetItemRarityTableRow(outData.InnerData.ItemRarity)
    self.Txt_Quality:SetText(itemRarityData.DisplayName)
    self:LoadRarityImage(itemRarityData.SpriteIcon)
    self:InitItemRarity(outData.InnerData.ItemRarity)
  end
end
function WBP_AccessoryDisplayInfo_C:InitInscriptionInfo()
  self.VerticalBox_Inscription:ClearChildren()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(self.ArticleId)
    local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(configId))
    if result then
      local innerData = self:GetAccessoryInfo(self.ArticleId)
      local findValue = accessoryData.InscriptionMap:Find(innerData.ItemRarity)
      if findValue then
        local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
        if RGLogicCommandDataSubsystem then
          local wbp_SingleInscriptionClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_SingleInscription.WBP_SingleInscription_C")
          local wbp_SingleInscription
          for key, value in iterator(findValue.Inscriptions) do
            if value.bIsShowInUI then
              wbp_SingleInscription = UE.UWidgetBlueprintLibrary.Create(self, wbp_SingleInscriptionClass, self:GetOwningPlayer())
              if wbp_SingleInscription then
                local outString = GetLuaInscriptionDesc(value.InscriptionId, 0)
                wbp_SingleInscription:InitInscription(outString, 420)
                self.VerticalBox_Inscription:AddChild(wbp_SingleInscription)
              end
            end
          end
        end
      end
    end
  end
end
function WBP_AccessoryDisplayInfo_C:InitDes()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(self.ArticleId)
    local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(configId))
    if result then
      local tableResult, IDToTxtData = DTSubsystem:GetIDToTxtTableRow(accessoryData.DisplayDescId)
      if tableResult then
        self.TextBlock_Des:SetText(IDToTxtData.Text)
      end
    end
  end
end
function WBP_AccessoryDisplayInfo_C:InitAttributeInfo(IsCompare, CompareId)
  local count = 0
  self.VerticalBox_Attribute:ClearChildren()
  local outArray = UE.URGAccessoryStatics.GetAccessoryMainAttributeList(self, self.ArticleId)
  for key, value in iterator(outArray) do
    local can, attributeString, displayName, showValue, attributeValue = self:CanShowAttributeInUI(value)
    if can then
      local wbp_normalAttributeClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_NormalAttribute.WBP_NormalAttribute_C")
      local wbp_normalAttribute = UE.UWidgetBlueprintLibrary.Create(self, wbp_normalAttributeClass, self:GetOwningPlayer())
      if wbp_normalAttribute then
        wbp_normalAttribute:InitAccessoryAttributeInfo(attributeString, displayName, showValue, attributeValue, IsCompare, CompareId)
        self.VerticalBox_Attribute:AddChild(wbp_normalAttribute)
        count = count + 1
      end
    end
  end
  if 0 == count then
    self.Image_lineDown:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Image_lineDown:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_AccessoryDisplayInfo_C:InitEquipInfo(EquipInfoType)
  local inputNum = 0
  if -1 == EquipInfoType then
    self.EquipInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if 0 == EquipInfoType then
    self.EquipInfo:SetVisibility(UE.ESlateVisibility.Visible)
    self.InUseTxt:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.UseEquip:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if 1 == EquipInfoType then
    inputNum = 1
    self.EquipInfo:SetVisibility(UE.ESlateVisibility.Visible)
    self.InUseTxt:SetVisibility(UE.ESlateVisibility.Visible)
    self.UseEquip:SetVisibility(UE.ESlateVisibility.Visible)
    self.UseEquip:SetText(UE.UKismetTextLibrary.Conv_IntToText(inputNum))
    self.NoEquip:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if 2 == EquipInfoType then
    inputNum = 2
    self.EquipInfo:SetVisibility(UE.ESlateVisibility.Visible)
    self.InUseTxt:SetVisibility(UE.ESlateVisibility.Visible)
    self.UseEquip:SetVisibility(UE.ESlateVisibility.Visible)
    self.UseEquip:SetText(UE.UKismetTextLibrary.Conv_IntToText(inputNum))
    self.NoEquip:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_AccessoryDisplayInfo_C:GetAccessoryInfo(ArticleId)
  local accessoryManager = UE.URGAccessoryStatics.GetAccessoryManager(self)
  if accessoryManager then
    local outAccessory = accessoryManager:GetAccessory(ArticleId)
    return outAccessory.InnerData
  end
  return nil
end
function WBP_AccessoryDisplayInfo_C:CanShowAttributeInUI(AttributeConfig)
  local attributeName = UE.URGBlueprintLibrary.GetAttributeName(AttributeConfig)
  local appendValue = "EquipAttributeSet." .. attributeName
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local result, rowData = DTSubsystem:GetEquipAttributeTableRow(appendValue)
    if result and rowData.DisplayInUI then
      return rowData.DisplayInUI, attributeName, rowData.DisplayNameInUI, UE.URGBlueprintLibrary.GetAttributeDisplayText(AttributeConfig.Value, rowData.AttributeDisplayType, rowData.UnitText, rowData.DisplayValueRatioInUI), AttributeConfig.Value
    end
  end
  return false, nil, nil, nil, nil
end
return WBP_AccessoryDisplayInfo_C
