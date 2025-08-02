local EquipedWeaponItem = UnLua.Class()

function EquipedWeaponItem:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
end

function EquipedWeaponItem:BindOnMainButtonHovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Name:SetColorAndOpacity(self.HoveredTextColor)
  EventSystem.Invoke(EventDef.Lobby.LobbyWeaponItemHoverStatusChanged, true, self.WeaponInfo, self.IsEquipped)
end

function EquipedWeaponItem:BindOnMainButtonUnHovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Txt_Name:SetColorAndOpacity(self.UnHoveredTextColor)
  EventSystem.Invoke(EventDef.Lobby.LobbyWeaponItemHoverStatusChanged, false)
end

function EquipedWeaponItem:BindOnMainButtonClicked()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView.viewModel:SwitchWeaponInfo(false, nil, true)
  end
end

function EquipedWeaponItem:InitWeaponItem(WeaponInfo, IsEquipped, ParentView)
  self.ParentView = ParentView
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.WeaponInfo = WeaponInfo
  self.IsEquipped = IsEquipped
  if table.IsEmpty(WeaponInfo) then
    self.MainPanel:SetVisibility(UE.ESlateVisibility.Hidden)
    return
  end
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.MainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local bResult, ItemData = GetRowData(DT.DT_Item, self:GetWeaponBodyId())
  if not bResult then
    return
  end
  local GunIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ItemData.LobbyIcon)
  if GunIconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(GunIconObj, math.floor(self.WeaponIconSize.X), math.floor(self.WeaponIconSize.Y))
    if Brush then
      self.Img_Weapon:SetBrush(Brush)
    end
  end
  self.Txt_Name:SetText(ItemData.Name)
  self:SetElementInfo()
end

function EquipedWeaponItem:GetWeaponBodyId()
  return tonumber(self.WeaponInfo.resourceId)
end

function EquipedWeaponItem:SetElementInfo()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ElementEffectList = {}
  local Result, AccessoryRowInfo = DTSubsystem:GetAccessoryTableRow(self:GetWeaponBodyId(), nil)
  if Result then
    ElementEffectList = AccessoryRowInfo.ElementEffectList
  end
  local TargetElementEffectId
  for i, SingleElementEffectId in pairs(ElementEffectList) do
    TargetElementEffectId = SingleElementEffectId
    break
  end
  local ElementType = 0
  local ElementValue = 0
  if TargetElementEffectId then
    local Result, EffectRowInfo = self:GetElementEffectRowInfo(tostring(TargetElementEffectId))
    if Result then
      ElementType = EffectRowInfo.ElementType
      ElementValue = EffectRowInfo.ElementEffectChance
    end
  end
  if 0 == ElementType then
  else
    local Result, ElementData = DTSubsystem:GetElementInfoTableRow(ElementType)
    if Result then
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ElementData.SpriteIcon)
      if IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
        self.Img_ElementIcon:SetBrush(Brush)
      end
    end
  end
end

function EquipedWeaponItem:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Img_Hovered, true)
end

function EquipedWeaponItem:OnMouseLeave(MouseEvent)
  UpdateVisibility(self.Img_Hovered, false)
end

function EquipedWeaponItem:Select()
  UpdateVisibility(self.Img_Selected, true)
end

function EquipedWeaponItem:UnSelect()
  UpdateVisibility(self.Img_Selected, false)
end

function EquipedWeaponItem:GetInfoToolTipWidget()
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Weapon/WBP_LobbyWeaponDisplayInfo.WBP_LobbyWeaponDisplayInfo_C")
  if WidgetClass and (not self.WeaponToolTipWidget or not self.WeaponToolTipWidget:IsValid()) then
    self.WeaponToolTipWidget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
  end
  if self.WeaponToolTipWidget then
    local AccessoryList = {}
    local TipText
    local IsShowOperateIcon = false
    if self.IsEquipped then
      TipText = self.EquippedText
    else
      IsShowOperateIcon = true
      TipText = self.NotEquippedText
    end
    local AllAccessoryList = DataMgr.GetAccessoryList()
    for i, SingleAccessoryInfo in ipairs(AllAccessoryList) do
      if self.WeaponInfo.uuid == SingleAccessoryInfo.equip then
        table.insert(AccessoryList, SingleAccessoryInfo.resourceId)
      end
    end
    self.WeaponToolTipWidget:InitInfo(self.WeaponInfo.resourceId, AccessoryList)
    if self.IsEquipped then
      self.WeaponToolTipWidget:ShowCurrentEquipTipPanel()
    elseif TipText then
      self.WeaponToolTipWidget:ShowTipPanel(TipText, IsShowOperateIcon)
    end
  end
  return self.WeaponToolTipWidget
end

function EquipedWeaponItem:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.WeaponInfo = nil
  self.ParentView = nil
end

return EquipedWeaponItem
