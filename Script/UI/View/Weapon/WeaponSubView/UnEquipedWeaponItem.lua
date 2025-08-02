local RedDotData = require("Modules.RedDot.RedDotData")
local UnEquipedWeaponItem = UnLua.Class()

function UnEquipedWeaponItem:Construct()
  self.Btn_Main.OnHovered:Add(self, UnEquipedWeaponItem.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, UnEquipedWeaponItem.BindOnMainButtonUnHovered)
  self.Btn_Main.OnClicked:Add(self, UnEquipedWeaponItem.BindOnMainButtonClicked)
end

function UnEquipedWeaponItem:Destruct()
end

function UnEquipedWeaponItem:BindOnMainButtonHovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Name:SetColorAndOpacity(self.HoveredTextColor)
  if self.ParentView and self.ParentView.Hover then
    self.ParentView:Hover(true, self.WeaponInfo)
  end
end

function UnEquipedWeaponItem:BindOnMainButtonUnHovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Txt_Name:SetColorAndOpacity(self.UnHoveredTextColor)
  if self.ParentView and self.ParentView.Hover then
    self.ParentView:Hover(false, self.WeaponInfo)
  end
end

function UnEquipedWeaponItem:BindOnMainButtonClicked()
  if self.ParentView and self.ParentView.WeaponSelectClick then
    self.ParentView:WeaponSelectClick(self.WeaponInfo)
    if self.WeaponInfo.WeaponData and self.WBP_RedDotView then
      local redDotId = string.format("%s_%d", self.WBP_RedDotView.RedDotClass, tostring(self:GetWeaponBodyId()))
      RedDotData:SetRedDotNum(redDotId, 0)
    end
  end
  EventSystem.Invoke(EventDef.BeginnerGuide.OnClickWeaponBagItem)
end

function UnEquipedWeaponItem:InitUnEquipedWeaponItem(WeaponInfo, IsEquipped, ParentView, bIsSelect)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.WeaponInfo = WeaponInfo
  self.IsEquipped = IsEquipped
  self.ParentView = ParentView
  if not self.WeaponInfo then
    self.MainPanel:SetVisibility(UE.ESlateVisibility.Hidden)
    return
  end
  if self.WBP_RedDotView then
    self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(self:GetWeaponBodyId()))
    if self.WeaponInfo.WeaponData and IsEquipped then
      local redDotId = string.format("%s_%d", self.WBP_RedDotView.RedDotClass, tostring(self:GetWeaponBodyId()))
      RedDotData:SetRedDotNum(redDotId, 0)
    end
  end
  UpdateVisibility(self.CanvasPanel_Unlocked, not self.WeaponInfo.WeaponData)
  if self.RGStateControllerLock then
    if self.WeaponInfo.WeaponData then
      self.RGStateControllerLock:ChangeStatus(ELock.UnLock)
    else
      self.RGStateControllerLock:ChangeStatus(ELock.Lock)
    end
  end
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.MainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local bResult, ItemData = GetRowData(DT.DT_Item, tostring(self:GetWeaponBodyId()))
  if not bResult then
    return
  end
  self.WBP_Item:InitItem(self:GetWeaponBodyId())
  local GunIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ItemData.LobbyIcon)
  if GunIconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(GunIconObj, math.floor(self.WeaponIconSize.X), math.floor(self.WeaponIconSize.Y))
    if Brush then
      self.Img_Weapon:SetBrush(Brush)
      self.WBP_Item:UpdateBrush(ItemData.LobbyIcon)
    end
  end
  local Result, WorldRowInfo = GetRowData(DT.DT_WorldType, ItemData.WorldTypeId)
  if Result then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WorldRowInfo.GunSpriteIcon)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_WorldType:SetBrush(Brush)
    end
  end
  self.Txt_Name:SetText(ItemData.Name)
  UpdateVisibility(self.Img_Selected, bIsSelect)
  UpdateVisibility(self.CanvasPanelEquipped, self.IsEquipped)
  self:SetElementInfo()
  if WeaponInfo.WeaponData then
    local expireAt = WeaponInfo.WeaponData.expireAt
    self.WBP_CommonCountdown:SetItemId(WeaponInfo.WeaponData.resourceId)
    if nil ~= expireAt and "" ~= expireAt and "0" ~= expireAt then
      self.RGStateControllerLock:ChangeStatus("ForALimitedTime", true)
      UpdateVisibility(self.WBP_CommonCountdown, true)
    else
      UpdateVisibility(self.WBP_CommonCountdown, false)
    end
    self.WBP_CommonCountdown:SetTargetTimestamp(expireAt)
  else
    UpdateVisibility(self.WBP_CommonCountdown, false)
    self.WBP_CommonCountdown:SetTargetTimestamp(nil)
  end
end

function UnEquipedWeaponItem:GetWeaponBodyId()
  if self.WeaponInfo then
    return tonumber(self.WeaponInfo.resourceId)
  end
  return -1
end

function UnEquipedWeaponItem:SetElementInfo()
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

function UnEquipedWeaponItem:GetInfoToolTipWidget()
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

function UnEquipedWeaponItem:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.WeaponInfo = nil
  self.ParentView = nil
end

return UnEquipedWeaponItem
