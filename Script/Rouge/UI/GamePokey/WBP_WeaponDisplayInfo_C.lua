local WBP_WeaponDisplayInfo_C = UnLua.Class()

function WBP_WeaponDisplayInfo_C:Destruct()
  self:BindAccessoryChange(false)
end

function WBP_WeaponDisplayInfo_C:InitInfo(Weapon, IsBag)
  self.IsBag = IsBag
  if Weapon then
    self.Weapon = Weapon
    self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:BindAccessoryChange(true)
    self:RefreshWeaponInfo()
  else
    self:SetVisibility(UE.ESlateVisibility.Hidden)
  end
  self.CoreComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGCoreComponent:StaticClass())
end

function WBP_WeaponDisplayInfo_C:InitBackGround(IsBag)
  if IsBag then
    self.Image_BackGround:SetVisibility(UE.ESlateVisibility.Hidden)
  else
    local brush = UE.FSlateBrush()
    brush.ImageSize = self.Image_BackGround.Brush.ImageSize
    brush.Margin = self.Image_BackGround.Brush.Margin
    brush.TintColor = self.Image_BackGround.Brush.TintColor
    brush.ResourceObject = self.Image
    brush.DrawAs = self.Image_BackGround.Brush.DrawAs
    brush.Tiling = self.Image_BackGround.Brush.Tiling
    brush.Mirroring = self.Image_BackGround.Brush.Mirroring
    self.Image_BackGround:SetBrush(brush)
  end
end

function WBP_WeaponDisplayInfo_C:InitWeaponInfo()
  self:SetInfoFromTable()
  self:InitRarity()
  self:SetDamageText()
  self:InitElement()
  self:InitCoreAttributeInfo()
  self:InitNormalAttributeInfo()
  self:InitInscriptionInfo()
end

function WBP_WeaponDisplayInfo_C:InitNormalAttributeInfo()
  self.VerticalBox_Attribute:ClearChildren()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local dataTable = DTSubsystem:GetDataTable("EquipAttribute")
    if dataTable then
      local rowNames = UE.TArray(UE.FName)
      rowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(dataTable)
      local wbp_NormalAttributeClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_NormalAttribute.WBP_NormalAttribute_C")
      local wbp_NormalAttribute
      for key, value in iterator(rowNames) do
        local result, rowData = DTSubsystem:GetEquipAttributeTableRow(value)
        if result and rowData.DisplayInUI and not rowData.bCoreAttributeInUI then
          wbp_NormalAttribute = UE.UWidgetBlueprintLibrary.Create(self, wbp_NormalAttributeClass, self:GetOwningPlayer())
          if wbp_NormalAttribute then
            wbp_NormalAttribute:SetAttributeInfo(rowData.DisplayNameInUI, UE.URGBlueprintLibrary.GetAttributeDisplayText(self:GetWeaponAttributeValue(value), rowData.AttributeDisplayType, rowData.DisplayUnitInUI, rowData.DisplayValueRatioInUI))
            self.VerticalBox_Attribute:AddChild(wbp_NormalAttribute)
            self.VerticalBox_Attribute:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
          end
        end
      end
    end
  end
end

function WBP_WeaponDisplayInfo_C:InitElement()
  if self.Weapon then
    self.TextBlock_ElementValue:SetText(math.floor(self.Weapon:GetMainElementChance() * 100))
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem then
      local result, elementInfoData = DTSubsystem:GetElementInfoTableRow(self.Weapon:GetMainElementType())
      if result then
        self:LoadElementImage(elementInfoData.SpriteIcon)
      end
    end
  end
end

function WBP_WeaponDisplayInfo_C:InitCoreAttributeInfo()
  self.VerticalBox_MainAttribute:ClearChildren()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local dataTable = DTSubsystem:GetDataTable("EquipAttribute")
    if dataTable then
      local rowNames = UE.TArray(UE.FName)
      rowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(dataTable)
      local wbp_MainAttributeBarClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_MainAttributeBar.WBP_MainAttributeBar_C")
      local wbp_MainAttributeBar
      for key, value in iterator(rowNames) do
        local result, rowData = DTSubsystem:GetEquipAttributeTableRow(value)
        if result and rowData.DisplayInUI and rowData.bCoreAttributeInUI then
          wbp_MainAttributeBar = UE.UWidgetBlueprintLibrary.Create(self, wbp_MainAttributeBarClass, self:GetOwningPlayer())
          if wbp_MainAttributeBar then
            wbp_MainAttributeBar:InitAttributeInfo(rowData.DisplayNameInUI, UE.URGBlueprintLibrary.GetAttributeDisplayText(self:GetWeaponAttributeValue(value), rowData.AttributeDisplayType, rowData.DisplayUnitInUI, rowData.DisplayValueRatioInUI), rowData.SpriteIcon)
            self.VerticalBox_MainAttribute:AddChild(wbp_MainAttributeBar)
          end
        end
      end
    end
  end
end

function WBP_WeaponDisplayInfo_C:InitInscriptionInfo()
  self.ScrollBox_Inscription:ClearChildren()
  if self.Weapon then
    local accessoryComponent = self.Weapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
    if accessoryComponent then
      local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
      if DTSubsystem then
        for key, value in iterator(accessoryComponent:GetOwnedAccessories()) do
          local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(value)
          local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(configId))
          local findValue = accessoryData.InscriptionMap:FindRef(self:GetAccessoryInfo(value).ItemRarity)
          if findValue then
            local wbp_SingleInscriptionClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_SingleInscription.WBP_SingleInscription_C")
            local wbp_SingleInscription
            local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
            if RGLogicCommandDataSubsystem then
              for key, value in iterator(findValue.Inscriptions) do
                if value.bIsShowInUI then
                  wbp_SingleInscription = UE.UWidgetBlueprintLibrary.Create(self, wbp_SingleInscriptionClass, self:GetOwningPlayer())
                  if wbp_SingleInscription then
                    local outString = GetLuaInscriptionDesc(value.InscriptionId, 0)
                    wbp_SingleInscription:InitInscription(outString, 420)
                    self.ScrollBox_Inscription:AddChild(wbp_SingleInscription)
                    self.SizeBox_Inscription:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

function WBP_WeaponDisplayInfo_C:InitAccessoryIcon()
  local accessoryComponent = self:GetAccessoryComp()
  if accessoryComponent then
    self.WBP_AccessoriesBox.Box_Accessory:ClearChildren()
    local wbp_AccessoryTipIconClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_AccessoryTipIcon.WBP_AccessoryTipIcon_C")
    local wbp_AccessoryTipIcon
    for key, value in iterator(accessoryComponent:GetOwnedAccessories()) do
      wbp_AccessoryTipIcon = UE.UWidgetBlueprintLibrary.Create(self, wbp_AccessoryTipIconClass, self:GetOwningPlayer())
      if wbp_AccessoryTipIcon then
        wbp_AccessoryTipIcon:InitAccessoryInfo(value)
        self.WBP_AccessoriesBox.Box_Accessory:AddChild(wbp_AccessoryTipIcon)
      end
    end
  end
end

function WBP_WeaponDisplayInfo_C:InitRarity()
  if self.Weapon then
    local weaponLevel = self.Weapon:GetWeaponLevel()
    if weaponLevel > 0 then
      self.TextBlock_Rarity:SetText("+" .. tostring(weaponLevel))
    end
  end
end

function WBP_WeaponDisplayInfo_C:InitTitleTextSize(IsBag)
  local textSize
  if IsBag then
    textSize = 28
  else
    textSize = 20
  end
  local widget
  for key, value in iterator(self.HorizontalBox_Name:GetAllChildren()) do
    widget = value:Cast(UE.UTextBlock)
    if widget then
      local slateFontInfo = UE.FSlateFontInfo()
      slateFontInfo.FontObject = widget.Font.FontObject
      slateFontInfo.FontMaterial = widget.Font.FontMaterial
      slateFontInfo.OutlineSettings = widget.Font.OutlineSettings
      slateFontInfo.TypefaceFontName = widget.Font.TypefaceFontName
      slateFontInfo.Size = textSize
      slateFontInfo.LetterSpacing = widget.Font.LetterSpacing
      widget:SetFont(slateFontInfo)
    end
  end
end

function WBP_WeaponDisplayInfo_C:SetInfoFromTable()
  if self.Weapon then
    local hasBarrel, articleId = self:HasBarrel()
    local tempItemId
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem then
      if hasBarrel then
        local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(articleId)
        tempItemId = tonumber(configId)
        local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tempItemId)
        if result then
          local tableResult, IDToTxtData = DTSubsystem:GetIDToTxtTableRow(accessoryData.DescId)
          if tableResult then
            self.TextBlock_GunName:SetText(IDToTxtData.Text)
          end
          tableResult, IDToTxtData = DTSubsystem:GetIDToTxtTableRow(accessoryData.DisplayDescId)
          if tableResult then
            self.TextBlock_Describe:SetText(IDToTxtData.Text)
          end
        end
      else
        tempItemId = self.Weapon:GetItemId()
        local itemData = DTSubsystem:K2_GetItemTableRow(tostring(tempItemId))
        self.TextBlock_GunName:SetText(itemData.Name)
        self.TextBlock_Describe:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
      local itemData = DTSubsystem:K2_GetItemTableRow(tostring(tempItemId))
      self:LoadGunImage(itemData.CompleteGunIcon)
      local result, worldTypeData = DTSubsystem:GetWorldTypeTableRow(itemData.WorldTypeId)
      if result then
        self.TextBlock_WorldName:SetText(worldTypeData.WorldDisplayName)
      end
    end
  end
end

function WBP_WeaponDisplayInfo_C:SetDamageText()
  if self.Weapon then
    local damageString = tostring(self.Weapon:GetWeaponLevel() * 15 + 100)
    self.TextBlock_Damage:SetText("\228\188\164\229\174\179\231\179\187\230\149\176+" .. damageString .. "%")
  end
end

function WBP_WeaponDisplayInfo_C:GetAccessoryInfo(ArticleId)
  local accessoryManager = UE.URGAccessoryStatics.GetAccessoryManager(self)
  if accessoryManager then
    return accessoryManager:GetAccessory(ArticleId).InnerData
  end
end

function WBP_WeaponDisplayInfo_C:GetAccessoryComp()
  if self.Weapon then
    return self.Weapon.AccessoryComponent
  end
end

function WBP_WeaponDisplayInfo_C:HasBarrel()
  local accessoryComponent = self:GetAccessoryComp()
  if accessoryComponent then
    return accessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel), accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Barrel)
  end
end

function WBP_WeaponDisplayInfo_C:GetWeaponAttributeValue(InAttributeName)
  local stringArray = UE.TArray(UE.FString)
  stringArray = UE.UKismetStringLibrary.ParseIntoArray(InAttributeName, ".", false)
  if stringArray:IsValidIndex(2) then
    local tempString = stringArray:Get(2)
    if self.CoreComp then
      local success, attribute = self.CoreComp:GetAttributeByName(tempString)
      if success then
        if "ReloadInterval" == tempString then
          local successReloadRatio, attributeReloadRatio = self.CoreComp:GetAttributeByName("ReloadRatio")
          if successReloadRatio then
            return self.CoreComp:GetCurrentAttributeValue(attribute) / self.CoreComp:GetCurrentAttributeValue(attributeReloadRatio)
          end
        end
        return self.CoreComp:GetCurrentAttributeValue(attribute)
      end
    end
  end
end

function WBP_WeaponDisplayInfo_C:BindAccessoryChange(Bind)
  local accessoryComponent = self:GetAccessoryComp()
  if accessoryComponent then
    if Bind then
      accessoryComponent.OnAccessoryChanged:Add(self, WBP_WeaponDisplayInfo_C.OnAccessoryChanged)
    else
      accessoryComponent.OnAccessoryChanged:Remove(self, WBP_WeaponDisplayInfo_C.OnAccessoryChanged)
    end
  end
end

function WBP_WeaponDisplayInfo_C:OnAccessoryChanged()
  self:RefreshWeaponInfo()
end

function WBP_WeaponDisplayInfo_C:RefreshWeaponInfo()
  self:InitTitleTextSize(self.IsBag)
  self:InitBackGround(self.IsBag)
  self:InitWeaponInfo()
  if self.IsBag then
    self.HorizontalBox_Accessories:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self:InitAccessoryIcon()
  end
end

return WBP_WeaponDisplayInfo_C
