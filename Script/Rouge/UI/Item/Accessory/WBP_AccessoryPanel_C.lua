local WBP_AccessoryPanel_C = UnLua.Class()
function WBP_AccessoryPanel_C:Construct()
  self.WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Item/Accessory/WBP_AccessoryCard.WBP_AccessoryCard_C")
  self.DiscardButton.OnClicked:Add(self, WBP_AccessoryPanel_C.OnClicked_DiscardButton)
  self.EquipButton.OnClicked:Add(self, WBP_AccessoryPanel_C.OnClicked_EquipButton)
  self.UnEquipButton.OnClicked:Add(self, WBP_AccessoryPanel_C.OnClicked_UnEquipButton)
  self.WBP_EquippedMuzzle.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
  self.WBP_EquippedBarrel.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
  self.WBP_EquippedButt.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
  self.WBP_EquippedSight.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
  self.WBP_EquippedPart.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
  self.WBP_EquippedGrip.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
  self.WBP_EquippedMagazine.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
  self.WBP_EquippedPendant.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
  self.WBP_EquippedCoating.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
end
function WBP_AccessoryPanel_C:OnOpenPanel()
  if self:GetWeaponCapture() == false then
    return
  end
  local bagComponent = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if bagComponent then
    bagComponent.OnBagChanged:Add(self, WBP_AccessoryPanel_C.OnBagChanged)
  end
  local equipmentComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent:StaticClass())
  if equipmentComponent then
    equipmentComponent.OnCurrentWeaponChanged:Add(self, WBP_AccessoryPanel_C.OnWeaponChanged)
  end
  print(self.bDropDown)
  if self.bDropDown then
    self:UnDropDownAccessoryBox()
  else
    self:DropDownAccessoryBox()
  end
  self.CurrentDropDownButton = nil
end
function WBP_AccessoryPanel_C:OnClosePanel()
  self:UnDropDownAccessoryBox()
end
function WBP_AccessoryPanel_C:OnLoadPanel()
  self:LoadAllAccessories()
  self:LoadAllEquippedAccessories()
  self:LoadWeapon()
end
function WBP_AccessoryPanel_C:OnCardSelect(WBP_BaseCard)
  if WBP_BaseCard:GetClass() == self.WidgetClass then
    self.WBP_AccessoryInfoBox:LoadAccessoryInfo(WBP_BaseCard.AccessoryId)
  else
    local AccWidgetClass = UE.UClass.Load("/Game/Rouge/UI/Item/Accessory/WBP_EquippedAccessoryCard.WBP_EquippedAccessoryCard_C")
    if WBP_BaseCard:GetClass() == AccWidgetClass and WBP_BaseCard:HasValidAccessory() then
      self.WBP_AccessoryInfoBox:LoadAccessoryInfo(WBP_BaseCard.AccessoryId)
    end
  end
  self.CurrentSelected = WBP_BaseCard
  local childrens = self.ItemGridPanel:GetAllChildren()
  local length = childrens:Length()
  local Element
  for i = 1, length do
    Element = childrens:Get(i)
    if self.CurrentSelected ~= Element and Element then
      Element:UnselectCard()
    end
  end
  childrens = self.EquippedGridPanel:GetAllChildren()
  length = childrens:Length()
  for i = 1, length do
    Element = childrens:Get(i)
    if self.CurrentSelected ~= Element and Element then
      Element:UnselectCard()
    end
  end
end
function WBP_AccessoryPanel_C:OnCardUnselect(WBP_BaseCard)
end
function WBP_AccessoryPanel_C:OnClicked_DiscardButton()
  if self.CurrentSelected and self.CurrentSelected.bSelected then
    local bagComponent = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
    if bagComponent:DiscardItem(self.CurrentSelected.AccessoryId, 1) then
    end
  end
end
function WBP_AccessoryPanel_C:OnBagChanged()
  if self.CurrentDropDownButton then
    self:LoadAccessoriesByType(self.CurrentDropDownButton.AccessoryType)
  else
    self:LoadAllAccessories()
  end
  self:DropDownAccessoryBox()
end
function WBP_AccessoryPanel_C:OnWeaponChanged(OldWeapon, NewWeapon)
  self:LoadWeapon()
  self:LoadAllEquippedAccessories()
end
function WBP_AccessoryPanel_C:OnAccessoryChanged()
  self:LoadWeapon()
  if self.CurrentDropDownButton then
    self:LoadAccessoriesByType(self.CurrentDropDownButton.AccessoryType)
  else
    self:LoadAllAccessories()
  end
  self:LoadAllEquippedAccessories()
end
function WBP_AccessoryPanel_C:OnClicked_EquipButton()
  if self.CurrentSelected then
    if self:WillShowMessage(self.CurrentSelected.AccessoryId) then
      self.ItemPanel:ShowMessage("\229\133\182\229\174\131\233\133\141\228\187\182\228\188\154\232\162\171\229\141\184\232\189\189\227\128\130")
      self.ItemPanel.WBP_MessageBox.OnConfirm:Add(self, WBP_AccessoryPanel_C.BoxConfirmEquip)
    else
      self:ConfirmEquip()
    end
  end
end
function WBP_AccessoryPanel_C:OnClicked_UnEquipButton()
  if self.CurrentSelected then
    if self:WillShowMessage(self.CurrentSelected.AccessoryId) then
      self.ItemPanel:ShowMessage("\229\133\182\229\174\131\233\133\141\228\187\182\228\188\154\232\162\171\229\141\184\232\189\189\227\128\130")
      self.ItemPanel.WBP_MessageBox.OnConfirm:Add(self, WBP_AccessoryPanel_C.BoxConfirmUnEquip)
    else
      self:ConfirmUnEquip()
    end
  end
end
function WBP_AccessoryPanel_C:BoxConfirmEquip(Box)
  self:ConfirmEquip()
end
function WBP_AccessoryPanel_C:BoxConfirmUnEquip(Box)
  self:ConfirmUnEquip()
end
function WBP_AccessoryPanel_C:ConfirmEquip()
  if self.CurrentSelected then
    local AccessoryId = self.CurrentSelected.AccessoryId
    local currentWeapon = UE.URGCharacterStatics.GetCurrentWeapon(self:GetOwningPlayerPawn())
    if currentWeapon then
      local accessoryComponent = currentWeapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
      if accessoryComponent and accessoryComponent:CanEquipAccessory(AccessoryId) then
        accessoryComponent:TryEquipAccessory(AccessoryId)
        self.WBP_WeaponViewer:EquipAccessory(AccessoryId)
        self:LoadAllEquippedAccessories()
        self.WeaponCapture:ChangeTransformbyWeapon(true, false)
      end
    end
  end
end
function WBP_AccessoryPanel_C:ConfirmUnEquip()
  if self.CurrentSelected then
    self.CurrentSelected:UnselectCard()
    local AccessoryId = self.CurrentSelected.AccessoryId
    local currentWeapon = UE.URGCharacterStatics.GetCurrentWeapon(self:GetOwningPlayerPawn())
    if currentWeapon then
      local accessoryComponent = currentWeapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
      if accessoryComponent then
        accessoryComponent:UnEquipAccessory(AccessoryId)
        self.WBP_WeaponViewer:UnEquipAccessory(AccessoryId)
        self:LoadAllEquippedAccessories()
        if self.WeaponCapture then
          self.WeaponCapture:ChangeTransformbyWeapon(true, false)
        end
      end
    end
  end
end
function WBP_AccessoryPanel_C:OnDropDownButtonClicked(Button)
  self.CurrentDropDownButton = Button
  self:LoadAccessoriesByType(Button.AccessoryType)
end
function WBP_AccessoryPanel_C:LoadWeapon()
  local equipmentComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent:StaticClass())
  if equipmentComponent then
    local currentWeapon = equipmentComponent:GetCurrentWeapon()
    local rGGun = currentWeapon:Cast(UE.ARGGun)
    if rGGun then
      self.WBP_WeaponInfoBox:LoadWeaponInfo(rGGun)
      self.WBP_WeaponViewer:LoadWeaponView(rGGun)
      local accessoryComponent = currentWeapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
      if accessoryComponent then
        accessoryComponent.OnAccessoryChanged:Add(self, WBP_AccessoryPanel_C.OnAccessoryChanged)
      end
    end
  end
end
function WBP_AccessoryPanel_C:LoadAccessoriesByType(Type)
  self.ItemGridPanel:ClearChildren()
  local bagComponent = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if bagComponent then
    local outStacks = bagComponent:GetItemsbyType(UE.EArticleDataType.Accessory)
    local length = outStacks:Length()
    local tempElemnt, tempId, outData
    local index = 0
    local wbp_AccessoryCard
    for i = 1, length do
      tempElemnt = outStacks:Get(i)
      tempId = tempElemnt.ArticleId
      outData = UE.URGAccessoryStatics.GetAccessoryRow(self, tempId)
      if outData.AccessoryType == Type then
        wbp_AccessoryCard = UE.UWidgetBlueprintLibrary.Create(self, self.WidgetClass, self:GetOwningPlayer())
        if wbp_AccessoryCard then
          wbp_AccessoryCard:UpdateCard(tempId)
          self.ItemGridPanel:AddChildToUniformGrid(wbp_AccessoryCard, UE.UKismetMathLibrary.FTrunc(index / 2), UE.UKismetMathLibrary.FTrunc(index % 2))
          wbp_AccessoryCard.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
          wbp_AccessoryCard.OnCardUnselect:Add(self, WBP_AccessoryPanel_C.OnCardUnselect)
          index = index + 1
        end
      end
    end
  end
end
function WBP_AccessoryPanel_C:LoadAllAccessories()
  self.ItemGridPanel:ClearChildren()
  local bagComponent = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if bagComponent then
    local outStacks = bagComponent:GetItemsbyType(UE.EArticleDataType.Accessory)
    local length = outStacks:Length()
    local wbp_AccessoryCard
    local index = 0
    for i = 1, length do
      wbp_AccessoryCard = UE.UWidgetBlueprintLibrary.Create(self, UE.self.WidgetClass, self:GetOwningPlayer())
      if wbp_AccessoryCard then
        wbp_AccessoryCard:UpdateCard(outStacks:GetRef(i).ArticleId)
        self.ItemGridPanel:AddChildToUniformGrid(wbp_AccessoryCard, UE.UKismetMathLibrary.FTrunc(index / 2), UE.UKismetMathLibrary.FTrunc(index % 2))
        wbp_AccessoryCard.OnCardSelect:Add(self, WBP_AccessoryPanel_C.OnCardSelect)
        wbp_AccessoryCard.OnCardUnselect:Add(self, WBP_AccessoryPanel_C.OnCardUnselect)
        index = index + 1
      end
    end
  end
end
function WBP_AccessoryPanel_C:LoadAllEquippedAccessories()
  local currentWeapon = UE.URGCharacterStatics.GetCurrentWeapon(self:GetOwningPlayerPawn())
  if currentWeapon then
    local accessoryComponent = currentWeapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
    if accessoryComponent then
      self.WBP_EquippedBarrel:UpdateCard(accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Barrel))
      self.WBP_EquippedButt:UpdateCard(accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Butt))
      self.WBP_EquippedGrip:UpdateCard(accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Grip))
      self.WBP_EquippedMagazine:UpdateCard(accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Magazine))
      self.WBP_EquippedMuzzle:UpdateCard(accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Muzzle))
      self.WBP_EquippedPart:UpdateCard(accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Part))
      self.WBP_EquippedPendant:UpdateCard(accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Pendant))
      self.WBP_EquippedSight:UpdateCard(accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Sight))
      self.WBP_EquippedCoating:UpdateCard(accessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Coating))
    end
  end
end
function WBP_AccessoryPanel_C:DropDownAccessoryBox()
  self.bDropDown = true
  self.ItemPanel.AccessoryDropDownBox:ClearChildren()
  local bagComponent = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if bagComponent then
    local outStacks = bagComponent:GetItemsbyType(UE.EArticleDataType.Accessory)
    local length = outStacks:Length()
    local tempElemnt, tempId, outData
    local AccessoryTypes = UE.TArray(UE.ERGAccessoryType)
    for i = 1, length do
      tempElemnt = outStacks:Get(i)
      tempId = UE.URGArticleStatics.ConvertNameToArticleId(UE.EArticleDataType.Accessory, tempElemnt.ItemId)
      outData = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, tempId)
      AccessoryTypes:AddUnique(outData.AccessoryType)
    end
    local Typelength = AccessoryTypes:Length()
    local TypeElement
    local switchFun = {
      [UE.ERGAccessoryType.EAT_Barrel] = function()
        self:CreateAccessoryButtonBox("\230\158\170\231\174\161", UE.ERGAccessoryType.EAT_Barrel)
      end,
      [UE.ERGAccessoryType.EAT_Butt] = function()
        self:CreateAccessoryButtonBox("\230\158\170\230\137\152", UE.ERGAccessoryType.EAT_Butt)
      end,
      [UE.ERGAccessoryType.EAT_Grip] = function()
        self:CreateAccessoryButtonBox("\230\143\161\230\138\138", UE.ERGAccessoryType.EAT_Grip)
      end,
      [UE.ERGAccessoryType.EAT_Magazine] = function()
        self:CreateAccessoryButtonBox("\229\188\185\229\140\163", UE.ERGAccessoryType.EAT_Magazine)
      end,
      [UE.ERGAccessoryType.EAT_Muzzle] = function()
        self:CreateAccessoryButtonBox("\230\158\170\229\143\163", UE.ERGAccessoryType.EAT_Muzzle)
      end,
      [UE.ERGAccessoryType.EAT_Part] = function()
        self:CreateAccessoryButtonBox("\230\158\170\232\186\171", UE.ERGAccessoryType.EAT_Part)
      end,
      [UE.ERGAccessoryType.EAT_Pendant] = function()
        self:CreateAccessoryButtonBox("\228\184\139\230\140\130", UE.ERGAccessoryType.EAT_Pendant)
      end,
      [UE.ERGAccessoryType.EAT_Sight] = function()
        self:CreateAccessoryButtonBox("\231\158\132\229\133\183", UE.ERGAccessoryType.EAT_Sight)
      end,
      [UE.ERGAccessoryType.EAT_Coating] = function()
        self:CreateAccessoryButtonBox("\230\182\130\232\163\133", UE.ERGAccessoryType.EAT_Coating)
      end
    }
    for i = 1, Typelength do
      TypeElement = AccessoryTypes:Get(i)
      local fSwitchFun = switchFun[TypeElement]
      local result = fSwitchFun()
    end
  end
end
function WBP_AccessoryPanel_C:CreateAccessoryButtonBox(ButonContext, AccessoryType)
  local AccWidgetClass = UE.UClass.Load("/Game/Rouge/UI/Item/Accessory/WBP_AccessoryButtonBox.WBP_AccessoryButtonBox_C")
  local wbp_AccessoryButtonBox = UE4.UWidgetBlueprintLibrary.Create(self, AccWidgetClass, self:GetOwningPlayer())
  wbp_AccessoryButtonBox:InitializeButton(160, 80, ButonContext, AccessoryType)
  self.ItemPanel.AccessoryDropDownBox:AddChildtoVerticalBox(wbp_AccessoryButtonBox)
  wbp_AccessoryButtonBox.OnClicked:Add(self, WBP_AccessoryPanel_C.OnDropDownButtonClicked)
end
function WBP_AccessoryPanel_C:UnDropDownAccessoryBox()
  self.bDropDown = false
  self.ItemPanel.AccessoryDropDownBox:ClearChildren()
end
function WBP_AccessoryPanel_C:WillShowMessage(Accessory_Id)
  local currentWeapon = UE.URGCharacterStatics.GetCurrentWeapon(self:GetOwningPlayerPawn())
  if currentWeapon then
    local accessoryComponent = currentWeapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
    local hasAccessory = accessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel)
    if hasAccessory then
      local outData = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, Accessory_Id)
      return outData.AccessoryType == UE.ERGAccessoryType.EAT_Barrel
    else
      return false
    end
  end
end
function WBP_AccessoryPanel_C:SelectFirstinBag()
  local data = self.ItemGridPanel:GetChildAt(0)
  if data then
    local wbp_BaseCard = data:Cast(UE.UWBP_BaseCard_C)
    if wbp_BaseCard then
      wbp_BaseCard:SelectCard()
    end
  else
    self.CurrentSelected = nil
  end
end
return WBP_AccessoryPanel_C
