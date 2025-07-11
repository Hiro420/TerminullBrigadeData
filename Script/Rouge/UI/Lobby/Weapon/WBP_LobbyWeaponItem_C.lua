local WBP_LobbyWeaponItem_C = UnLua.Class()
function WBP_LobbyWeaponItem_C:Construct()
  self.Btn_Main.OnHovered:Add(self, WBP_LobbyWeaponItem_C.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, WBP_LobbyWeaponItem_C.BindOnMainButtonUnHovered)
  self.Btn_Main.OnClicked:Add(self, WBP_LobbyWeaponItem_C.BindOnMainButtonClicked)
end
function WBP_LobbyWeaponItem_C:BindOnMainButtonHovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Name:SetColorAndOpacity(self.HoveredTextColor)
  EventSystem.Invoke(EventDef.Lobby.LobbyWeaponItemHoverStatusChanged, true, self.WeaponInfo, self.IsEquipped)
end
function WBP_LobbyWeaponItem_C:BindOnMainButtonUnHovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Txt_Name:SetColorAndOpacity(self.UnHoveredTextColor)
  EventSystem.Invoke(EventDef.Lobby.LobbyWeaponItemHoverStatusChanged, false)
end
function WBP_LobbyWeaponItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Lobby.WeaponItemSelected, self.WeaponInfo)
end
function WBP_LobbyWeaponItem_C:Show(WeaponInfo, IsEquipped)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.WeaponInfo = WeaponInfo
  self.IsEquipped = IsEquipped
  if not self.WeaponInfo then
    self.MainPanel:SetVisibility(UE.ESlateVisibility.Hidden)
    return
  end
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.MainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ItemData = DTSubsystem:K2_GetItemTableRow(tostring(self:GetWeaponBodyId()))
  local GunIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ItemData.CompleteGunIcon)
  if GunIconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(GunIconObj, math.floor(self.WeaponIconSize.X), math.floor(self.WeaponIconSize.Y))
    if Brush then
      self.Img_Weapon:SetBrush(Brush)
    end
  end
  local Result, WorldRowInfo = DTSubsystem:GetWorldTypeTableRow(ItemData.WorldTypeId)
  if Result then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WorldRowInfo.GunSpriteIcon)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_WorldType:SetBrush(Brush)
    end
  end
  self.Txt_Name:SetText(ItemData.Name)
  self:SetElementInfo()
end
function WBP_LobbyWeaponItem_C:GetWeaponBodyId()
  return tonumber(self.WeaponInfo.resourceId)
end
function WBP_LobbyWeaponItem_C:SetElementInfo()
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
function WBP_LobbyWeaponItem_C:GetInfoToolTipWidget()
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
function WBP_LobbyWeaponItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.WeaponInfo = nil
end
return WBP_LobbyWeaponItem_C
