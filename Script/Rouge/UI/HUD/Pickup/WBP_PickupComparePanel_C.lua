local WBP_PickupComparePanel_C = UnLua.Class()
function WBP_PickupComparePanel_C:Construct()
  self.Overridden.Construct(self)
  self.OnHidden:Add(self, WBP_PickupComparePanel_C.BindOnHidden)
  if not IsListeningForInputAction(self, self.ActionName) then
  end
  EventSystem.AddListener(self, EventDef.GameSettings.OnKeyChanged, WBP_PickupComparePanel_C.BindOnKeyChanged)
end
function WBP_PickupComparePanel_C:BindOnKeyChanged()
  self:RefreshOperateKeyText()
end
function WBP_PickupComparePanel_C:InitInfo(PickupActor)
  self.PickupActor = PickupActor
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  self:PlayAnimation(self.ani_pickupcomparepa_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  local ItemData = DTSubsystem:K2_GetItemTableRow(self.PickupActor:GetItemId(), nil)
  if ItemData.ArticleType == UE.EArticleDataType.Weapon then
    local PickupWeapon = PickupActor:Cast(UE.ARGPickup_Weapon)
    if PickupWeapon then
      local WorldId = PickupWeapon:GetWorldId()
      print("WBP_PickupComparePanel_C:InitInfo " .. PickupActor:GetName() .. " WorldId " .. WorldId)
    end
    self.SwitchWeaponAccessory:SetActiveWidgetIndex(0)
    self.WeaponDisplayInfo:InitInfo(self.PickupActor:GetWeapon())
    self.Img_CompareQuality:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.IsWeapon = true
  elseif ItemData.ArticleType == UE.EArticleDataType.Accessory then
    self.AccessoryId = self.PickupActor.AccessoryId
    self.SwitchWeaponAccessory:SetActiveWidgetIndex(1)
    self.AccessoryDisplayInfo:InitInfo(self.AccessoryId)
    self.IsWeapon = false
    self:ChangeCanPickupPanel()
  end
  self:UpdatePanelSizeCaterToPickupType()
  self:RefreshCurCompareWeaponInfo()
  self:RefreshInscriptionList()
  self:ClearDecomposeTimer()
  local CurWeapon = self:GetCurCompareWeapon()
  if CurWeapon and CurWeapon.AccessoryComponent then
    CurWeapon.AccessoryComponent.OnAccessoryChanged:Add(self, WBP_PickupComparePanel_C.BindOnAccessoryChanged)
    EventSystem.Invoke(EventDef.Battle.OnPickupWeaponSelected, true, CurWeapon)
  end
  self:RefreshOperateKeyText()
end
function WBP_PickupComparePanel_C:RefreshOperateKeyText()
  self.PickUp:SetKeyText(LogicGameSetting.GetCurSelectedKeyNameByKeyRowName(self.PickUp.CustomKeyRowName))
  self.Decompose:SetKeyText(LogicGameSetting.GetCurSelectedKeyNameByKeyRowName(self.Decompose.CustomKeyRowName))
  self.Replace:SetKeyText(LogicGameSetting.GetCurSelectedKeyNameByKeyRowName(self.Replace.CustomKeyRowName))
end
function WBP_PickupComparePanel_C:BindOnAccessoryChanged()
  self:RefreshCurCompareWeaponInfo()
  self:RefreshInscriptionList()
end
function WBP_PickupComparePanel_C:InitAccessoryInfo(AccessoryId)
  self.AccessoryId = AccessoryId
  self.SwitchWeaponAccessory:SetActiveWidgetIndex(1)
  self.AccessoryDisplayInfo:InitInfo(self.AccessoryId)
  self:ChangeQualityVisibility()
  self:ChangeCanPickupPanel()
  self.IsWeapon = false
  self:RefreshCurCompareWeaponInfo()
  self:RefreshInscriptionList()
  self:ClearDecomposeTimer()
end
function WBP_PickupComparePanel_C:RefreshCurCompareWeaponInfo()
  local CurCompareWeapon = self:GetCurCompareWeapon()
  if not CurCompareWeapon then
    self.CompareWeaponPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    print("\230\178\161\230\156\137\230\137\190\229\136\176\231\155\184\229\144\140\228\184\150\231\149\140\231\154\132\230\173\166\229\153\168\229\142\187\232\191\155\232\161\140\229\175\185\230\175\148\239\188\140\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174")
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local Result, WorldRowInfo = DTSubsystem:GetWorldTypeTableRow(CurCompareWeapon:GetWorldId())
    if Result then
      self.Img_Equipped:SetColorAndOpacity(WorldRowInfo.WorldColor)
    end
  end
  self.CompareWeaponPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  self.CompareWeaponInfo:InitInfo(CurCompareWeapon)
  if self.IsWeapon then
    self.WeaponDisplayInfo:CompareAttributeInfo(CurCompareWeapon)
  else
    self.CompareWeaponInfo:CompareAccessoryAttributeInfo(self.AccessoryId)
  end
end
function WBP_PickupComparePanel_C:GetCurCompareWeapon()
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local TargetWeapon
  local AllWeapons = EquipmentComp:GetAllWeapons(nil)
  if self.IsWeapon then
    for i, SingleWeapon in pairs(AllWeapons) do
      if self.PickupActor:GetWorldId() == SingleWeapon:GetWorldId() then
        TargetWeapon = SingleWeapon
        break
      end
    end
  else
    local AccessoryRowInfo = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, self.AccessoryId, nil)
    for i, SingleWeapon in pairs(AllWeapons) do
      if SingleWeapon:GetWorldId() == AccessoryRowInfo.WorldId then
        TargetWeapon = SingleWeapon
        break
      end
    end
  end
  return TargetWeapon
end
function WBP_PickupComparePanel_C:RefreshInscriptionList()
  if self.IsWeapon then
    self.CompareInscriptionList:InitInfo(self:GetCurCompareWeapon(), self.IsWeapon, self.PickupActor:GetWeapon())
    self.InscriptionNounExplainList:InitInfo(self:GetCurCompareWeapon(), self.IsWeapon, self.PickupActor:GetWeapon())
  else
    self.CompareInscriptionList:InitInfo(self:GetCurCompareWeapon(), self.IsWeapon, self.AccessoryId)
    self.InscriptionNounExplainList:InitInfo(self:GetCurCompareWeapon(), self.IsWeapon, self.AccessoryId)
  end
end
function WBP_PickupComparePanel_C:ChangeCanPickupPanel()
  self.DisablePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  local CurCompareWeapon = self:GetCurCompareWeapon()
  local AccessoryRowInfo = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, self.AccessoryId, nil)
  if CurCompareWeapon and CurCompareWeapon.AccessoryComponent then
    local AccessoryComp = CurCompareWeapon.AccessoryComponent
    if AccessoryComp and AccessoryComp:HasAccessoryOfType(AccessoryRowInfo.AccessoryType) then
      UpdateVisibility(self.Replace, true)
      UpdateVisibility(self.PickUp, false)
    else
      UpdateVisibility(self.Replace, false)
      UpdateVisibility(self.PickUp, true)
    end
  end
end
function WBP_PickupComparePanel_C:ChangeQualityVisibility()
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurrentWeapon = EquipmentComp:GetCurrentWeapon()
  local AccessoryRowInfo = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, self.AccessoryId, nil)
  local AccessoryComp = CurrentWeapon.AccessoryComponent
  if not AccessoryComp then
    return
  end
  if AccessoryComp:HasAccessoryOfType(AccessoryRowInfo.AccessoryType) then
    local CurWeaponAccessoryId = AccessoryComp:GetAccessoryByType(AccessoryRowInfo.AccessoryType)
    local CurWeaponAccessoryData = UE.URGAccessoryStatics.GetAccessoryData(self, CurWeaponAccessoryId, nil)
    local CurPickupAccessoryData = UE.URGAccessoryStatics.GetAccessoryData(self, self.AccessoryId, nil)
    if CurPickupAccessoryData.InnerData.ItemRarity > CurWeaponAccessoryData.InnerData.ItemRarity then
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.HighSprite)
      if IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
        self.Img_CompareQuality:SetBrush(Brush)
      end
      self.Img_CompareQuality:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    elseif CurPickupAccessoryData.InnerData.ItemRarity == CurWeaponAccessoryData.InnerData.ItemRarity then
      self.Img_CompareQuality:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.LowSprite)
      if IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
        self.Img_CompareQuality:SetBrush(Brush)
      end
      self.Img_CompareQuality:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.HighSprite)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_CompareQuality:SetBrush(Brush)
    end
    self.Img_CompareQuality:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_PickupComparePanel_C:ListenForChangeSimpleUI()
  LogicPickup.IsShowComparePanel = not LogicPickup.IsShowComparePanel
  LogicPickup.ShowOptimalWidget()
  self:Hide(true, true)
end
function WBP_PickupComparePanel_C:BindOnHidden()
  if IsListeningForInputAction(self, self.ActionName) then
    StopListeningForInputAction(self, self.ActionName, UE.EInputEvent.IE_Pressed)
  end
  local CurWeapon = self:GetCurCompareWeapon()
  if CurWeapon and CurWeapon.AccessoryComponent then
    CurWeapon.AccessoryComponent.OnAccessoryChanged:Remove(self, WBP_PickupComparePanel_C.BindOnAccessoryChanged)
    EventSystem.Invoke(EventDef.Battle.OnPickupWeaponSelected, false)
  end
  EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, WBP_PickupComparePanel_C.BindOnKeyChanged, self)
end
function WBP_PickupComparePanel_C:Destruct()
  self.Overridden.Destruct(self)
  self.OnHidden:Remove(self, WBP_PickupComparePanel_C.BindOnHidden)
  if IsListeningForInputAction(self, self.ActionName) then
    StopListeningForInputAction(self, self.ActionName, UE.EInputEvent.IE_Pressed)
  end
  if self.PickupActor and self.PickupActor:IsValid() then
    local CurWeapon = self:GetCurCompareWeapon()
    if CurWeapon and CurWeapon.AccessoryComponent then
      CurWeapon.AccessoryComponent.OnAccessoryChanged:Remove(self, WBP_PickupComparePanel_C.BindOnAccessoryChanged)
    end
  end
  EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, WBP_PickupComparePanel_C.BindOnKeyChanged, self)
end
return WBP_PickupComparePanel_C
