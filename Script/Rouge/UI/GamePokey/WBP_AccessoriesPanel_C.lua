local WBP_AccessoriesPanel_C = UnLua.Class()
function WBP_AccessoriesPanel_C:Construct()
  self.wbp_AccessoriesByTypeClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_AccessoriesByType.WBP_AccessoriesByType_C")
  self.Button_Selection.OnClicked:Add(self, WBP_AccessoriesPanel_C.OnClicked_Selection)
end
function WBP_AccessoriesPanel_C:LuaTick(InDeltaTime)
  self:SetBottomVisibility()
end
function WBP_AccessoriesPanel_C:GetPrimaryEquippedAccessory(Target, Type)
  if Target and self.GamePokey then
    local currentWeapon = self.GamePokey:GetCurrentWeapon(Target)
    if currentWeapon then
      return self:GetAccessoryByWeapon(currentWeapon, Type)
    end
  end
  return false, nil
end
function WBP_AccessoriesPanel_C:GetChooseEquippedAccessory(Type)
  if self.GamePokey and self.GamePokey.ChooseGun then
    return self:GetAccessoryByWeapon(self.GamePokey.ChooseGun, Type)
  end
  return false, nil
end
function WBP_AccessoriesPanel_C:GetSecondEquippedAccessory(Target, Type)
  if Target and self.GamePokey and self.GamePokey.ChooseGun then
    local equipmentComponent = Target:GetComponentByClass(UE.URGEquipmentComponent:StaticClass())
    if equipmentComponent then
      local slotId = self.GamePokey.ChooseGun:GetSlotId()
      if 1 == slotId then
        return self:GetAccessoryByWeapon(equipmentComponent:FindEquipment(2), Type)
      end
      if 2 == slotId then
        return self:GetAccessoryByWeapon(equipmentComponent:FindEquipment(1), Type)
      end
    end
  end
  return false, nil
end
function WBP_AccessoriesPanel_C:GetAccessoryByWeapon(Target, Type)
  if Target then
    local accessoryComponent = Target:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
    if accessoryComponent then
      return accessoryComponent:HasAccessoryOfType(Type), accessoryComponent:GetAccessoryByType(Type)
    end
  end
  return false, nil
end
function WBP_AccessoriesPanel_C:GetChooseWeaponAccessoryComp()
  if self.GamePokey and self.GamePokey.ChooseGun then
    return self.GamePokey.ChooseGun.AccessoryComponent
  end
end
function WBP_AccessoriesPanel_C:CanEquipSecondWeapon(Type)
  local accessoryComponent = self:GetChooseWeaponAccessoryComp()
  if accessoryComponent then
    local has, articleId = self:GetSecondEquippedAccessory(self:GetOwningPlayerPawn(), Type)
    local can, cannotReason = accessoryComponent:CanEquipAccessory(articleId)
    return has, can, articleId
  end
  return false, false, nil
end
function WBP_AccessoriesPanel_C:CanEquipCompAIPrimaryWeapon(Type)
  if self.GamePokey then
    local companionAI = self.GamePokey:GetCompanionAI()
    if companionAI then
      local accessoryComponent = self:GetChooseWeaponAccessoryComp()
      if accessoryComponent then
        local has, articleId = self:GetPrimaryEquippedAccessory(companionAI, Type)
        local can, cannotReason = accessoryComponent:CanEquipAccessory(articleId)
        return has, can, articleId
      end
    end
  end
end
function WBP_AccessoriesPanel_C:LoadEquippedAccessory(Type)
  local accessories = UE.TArray(UE.FRGArticleId)
  accessories:Clear()
  if self:GetOwningPlayerPawn() then
    local has, canEquip, articleId
    has, articleId = self:GetChooseEquippedAccessory(Type)
    if has then
      accessories:Add(articleId)
    end
    has, canEquip, articleId = self:CanEquipSecondWeapon(Type)
    if has and canEquip then
      accessories:Add(articleId)
    end
    has, canEquip, articleId = self:CanEquipCompAIPrimaryWeapon(Type)
    if has and canEquip then
      accessories:Add(articleId)
    end
    return accessories
  end
end
function WBP_AccessoriesPanel_C:LoadEquippedButCantAccessory(Type)
  local accessories = UE.TArray(UE.FRGArticleId)
  accessories:Clear()
  if self:GetOwningPlayerPawn() then
    local has, canEquip, articleId
    has, canEquip, articleId = self:CanEquipSecondWeapon(Type)
    if has and not canEquip then
      accessories:Add(articleId)
    end
    has, canEquip, articleId = self:CanEquipCompAIPrimaryWeapon(Type)
    if has and not canEquip then
      accessories:Add(articleId)
    end
    return accessories
  end
end
function WBP_AccessoriesPanel_C:LoadBagAccessory(Type)
  local canEquipArticleId = UE.TArray(UE.FRGArticleId)
  local cantEquipArticleId = UE.TArray(UE.FRGArticleId)
  local sortArticleId = UE.TArray(UE.FRGArticleId)
  local finalCantEquipArticleId = UE.TArray(UE.FRGArticleId)
  canEquipArticleId:Clear()
  cantEquipArticleId:Clear()
  sortArticleId:Clear()
  finalCantEquipArticleId:Clear()
  if self:GetOwningPlayer() then
    local bagComponent = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
    if bagComponent then
      local outStacks
      outStacks = bagComponent:GetItemsByType(UE.EArticleDataType.Accessory, outStacks)
      local articleId
      for key, value in iterator(outStacks) do
        articleId = UE.URGArticleStatics.GetArticleIdByItemStack(value)
        local outData = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, articleId)
        if Type == outData.AccessoryType and self:GetOwningPlayerPawn() then
          local accessoryComponent = self:GetChooseWeaponAccessoryComp()
          if accessoryComponent then
            local can, cannotReason = accessoryComponent:CanEquipAccessory(articleId)
            if can then
              canEquipArticleId:Add(articleId)
            else
              cantEquipArticleId:Add(articleId)
            end
          end
        end
      end
      UE.URGBlueprintLibrary.SortAccessoryByStoreRule(self, canEquipArticleId)
      UE.URGBlueprintLibrary.SortAccessoryByStoreRule(self, cantEquipArticleId)
      finalCantEquipArticleId:Append(canEquipArticleId)
      finalCantEquipArticleId:Append(self:LoadEquippedButCantAccessory(Type))
      finalCantEquipArticleId:Append(cantEquipArticleId)
      return finalCantEquipArticleId
    end
  end
end
function WBP_AccessoriesPanel_C:CreateAccessoriesByType(InByte, InGamePokey, ShowBack)
  self:ClearSelection()
  self.HasAccessoryType:RemoveItem(InByte)
  self.GamePokey = InGamePokey
  local tempArticleIds = UE.TArray(UE.FRGArticleId)
  tempArticleIds:Clear()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local result, accessoryTypeTableRow = DTSubsystem:GetAccessoryTypeTableRow(InByte)
    if result then
      tempArticleIds:Append(self:LoadEquippedAccessory(accessoryTypeTableRow.AccessoryType))
      tempArticleIds:Append(self:LoadBagAccessory(accessoryTypeTableRow.AccessoryType))
      if tempArticleIds:Length() > 0 then
        self.HasAccessoryType:Add(accessoryTypeTableRow.AccessoryType)
        local widget = UE.UWidgetBlueprintLibrary.Create(self, self.wbp_AccessoriesByTypeClass, self:GetOwningPlayer())
        if widget then
          local paddings = UE.FMargin()
          paddings.Top = 5
          widget:SetPadding(paddings)
          widget:InitInfo(self.GamePokey, accessoryTypeTableRow.AccessoryType, accessoryTypeTableRow.DisplayName, tempArticleIds, ShowBack)
          self.ScrollBox_Accessories:AddChild(widget)
        end
      end
    end
  end
end
function WBP_AccessoriesPanel_C:CreateAccessories(InGamePokey)
  if InGamePokey then
    self.ScrollBox_Accessories:ClearChildren()
    for key, value in iterator(self.AccessoryType) do
      self:CreateAccessoriesByType(value, InGamePokey, false)
    end
  end
end
function WBP_AccessoriesPanel_C:RefreshState()
  local widget
  for key, value in iterator(self.ScrollBox_Accessories:GetAllChildren()) do
    widget = value:Cast(self.wbp_AccessoriesByTypeClass)
    if widget then
      widget:RefreshState()
    end
  end
end
function WBP_AccessoriesPanel_C:CheckItemExist()
  local widget
  for key, value in iterator(self.ScrollBox_Accessories:GetAllChildren()) do
    widget = value:Cast(self.wbp_AccessoriesByTypeClass)
    if widget then
      local outType, Exit = widget:CheckItemExist()
      if Exit then
        self.HasAccessoryType:Remove(outType)
      end
    end
  end
end
function WBP_AccessoriesPanel_C:SetBottomVisibility()
  local show = self.ScrollBox_Accessories:GetDesiredSize().Y > 750
  if show then
    self.CanvasPanel_Bottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CanvasPanel_Bottom:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function WBP_AccessoriesPanel_C:ClearSelection()
  if self.Selection then
    self.Selection:RemoveFromParent()
    self.Selection = nil
    self:UpdateSelectionIcon(false)
    PlaySound2DEffect(30008, "")
  end
end
function WBP_AccessoriesPanel_C:OnSelectionOption(Option)
  if "\229\133\168\233\131\168" == Option then
    self:CreateAccessories(self.GamePokey)
    self:ClearSelection()
  else
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem then
      local dataTable = DTSubsystem:GetDataTable("AccessoryType")
      if dataTable then
        local rowNames = UE.TArray(UE.FName)
        rowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(dataTable)
        for key, value in iterator(rowNames) do
          local result, accessoryTypeTableRow = DTSubsystem:GetAccessoryTypeTableRow(tonumber(value))
          if result and Option == accessoryTypeTableRow.DisplayName then
            self.ScrollBox_Accessories:ClearChildren()
            self:CreateAccessoriesByType(accessoryTypeTableRow.AccessoryType, self.GamePokey, true)
            self:ClearSelection()
            break
          end
        end
      end
    end
  end
end
function WBP_AccessoriesPanel_C:UpdateSelectionIcon(Open)
  local sprite
  if Open then
    sprite = self.OpenSprite
  else
    sprite = self.CloseSprite
  end
  self.Image_SelectionState:SetBrush(UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(sprite, 0, 0))
end
function WBP_AccessoriesPanel_C:HasAccessory(Type)
  for key, value in iterator(self.HasAccessoryType) do
    if value == Type then
      return true
    end
  end
  return false
end
function WBP_AccessoriesPanel_C:OnClicked_Selection()
  if self.Selection then
    self:ClearSelection()
  else
    local wbp_SelectionListClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_SelectionList.WBP_SelectionList_C")
    self.Selection = UE.UWidgetBlueprintLibrary.Create(self, wbp_SelectionListClass, self:GetOwningPlayer())
    if self.Selection then
      self.NamedSlot_Selection:AddChild(self.Selection)
      self.Selection:InitSelectionList(self)
      self:UpdateSelectionIcon(true)
      PlaySound2DEffect(30007, "")
    end
  end
end
return WBP_AccessoriesPanel_C
