local WBP_GamePokey_C = UnLua.Class()

function WBP_GamePokey_C:Construct()
  EventSystem.AddListener(self, EventDef.GamePokey.OnWeaponMeshPressed, WBP_GamePokey_C.OnWeaponMeshPressed)
  EventSystem.AddListener(self, EventDef.GamePokey.OnWeaponMeshReleased, WBP_GamePokey_C.OnWeaponMeshReleased)
  EventSystem.AddListener(self, EventDef.MainPanel.MainPanelChanged, WBP_GamePokey_C.OnActiveWidgetChange)
  EventSystem.AddListener(self, EventDef.MainPanel.OnExit, WBP_GamePokey_C.OnMainPanelExit)
  self.wbp_WeaponSwitchClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_WeaponSwitch.WBP_WeaponSwitch_C")
  self.wbp_EquipSlotClass = UE.UClass.Load("/Game/Rouge/UI/GamePokey/WBP_EquipSlot.WBP_EquipSlot_C")
  self:GetWeaponCapture()
  self:InitWeaponSwitch()
  self:InitChooseWeapon()
  self:InitWeaponDisplayInfo()
  self:InitAccessoriesPanel()
  self:InitEquipSlot()
  self:BindOnAccessoryChanged(true)
  self:BindOnBagChanged(true)
  self:BindOnEquipChanged(true)
  self:BindClearEquipSlotChoose(true)
end

function WBP_GamePokey_C:LuaTick(InDeltaTime)
  self:UpdateEquipSlotsPosition()
end

function WBP_GamePokey_C:Destruct()
  EventSystem.RemoveListener(EventDef.GamePokey.OnWeaponMeshPressed, WBP_GamePokey_C.OnWeaponMeshPressed)
  EventSystem.RemoveListener(EventDef.GamePokey.OnWeaponMeshReleased, WBP_GamePokey_C.OnWeaponMeshReleased)
  EventSystem.RemoveListener(EventDef.MainPanel.MainPanelChanged, WBP_GamePokey_C.OnActiveWidgetChange)
  EventSystem.RemoveListener(EventDef.MainPanel.OnExit, WBP_GamePokey_C.OnMainPanelExit)
  self:BindOnBagChanged(false)
  self:BindOnEquipChanged(false)
  self:UnBindWeaponSwitch()
  self:BindOnAccessoryChanged(false)
  self:BindClearEquipSlotChoose(false)
  self.Clicked = nil
end

function WBP_GamePokey_C:InitWeaponSwitch()
  self.WeaponSwitch:Clear()
  local widgetArray = self.VerticalBox_WeaponSwitch:GetAllChildren()
  local widget
  for key, value in iterator(widgetArray) do
    widget = value:Cast(self.wbp_WeaponSwitchClass)
    if widget then
      widget.OnWeaponChoose:Add(self, WBP_GamePokey_C.OnWeaponSwitchChoose)
      self.WeaponSwitch:Add(widget)
      widget:InitInfo()
    end
  end
end

function WBP_GamePokey_C:InitWeaponDisplayInfo()
  self.WBP_GPWeaponDisplayInfo:UpdateWeaponDisplayInfo(self.ChooseGun)
  self:InitCameraWeapon()
end

function WBP_GamePokey_C:InitChooseWeapon()
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local equipComp = self:GetEquipComp(pawn)
    if equipComp then
      local currentWeapon = equipComp:GetCurrentWeapon()
      if currentWeapon then
        local slotId = equipComp:GetWeaponSlotId(currentWeapon)
        if 1 == slotId then
          self.WBP_WeaponSwitch_Primary:ClickButton()
        end
        if 2 == slotId then
          self.WBP_WeaponSwitch_Second:ClickButton()
        end
      end
    end
  end
end

function WBP_GamePokey_C:InitAccessoriesPanel()
  self.Accessories:Clear()
end

function WBP_GamePokey_C:InitCameraWeapon()
  if self.WeaponCapture and self.WeaponCapture:IsValid() then
    self.WeaponCapture:SetWeapon(self.ChooseGun)
    self.WeaponCapture:ChangeTransformByWeapon(false, false)
    self.WeaponCapture:UpdateBGImage()
  end
end

function WBP_GamePokey_C:InitEquipSlot()
  local widgetArray = self.CanvasPanel_EquipSlot:GetAllChildren()
  local widget
  for key, value in iterator(widgetArray) do
    widget = value:Cast(self.wbp_EquipSlotClass)
    if widget then
      widget:InitInfo(self)
    end
  end
end

function WBP_GamePokey_C:InitAccessoriesByType()
  self.Accessories:Clear()
  if self.Selected then
    self.WBP_AccessoriesPanel.ScrollBox_Accessories:ClearChildren()
    self.WBP_AccessoriesPanel:CreateAccessoriesByType(self.Selected.AccessoryType, nil, false)
  end
end

function WBP_GamePokey_C:UnBindWeaponSwitch()
  for key, value in iterator(self.WeaponSwitch) do
    value.OnWeaponChoose:Remove(self, WBP_GamePokey_C.OnWeaponSwitchChoose)
  end
end

function WBP_GamePokey_C:BindOnAccessoryChanged(Bind)
  local accessoryComponent = self:GetAccessoryComp()
  if accessoryComponent then
    if Bind then
      accessoryComponent.OnAccessoryChanged:Add(self, WBP_GamePokey_C.OnAccessoryChanged)
      accessoryComponent.OnAccessoryEquip:Add(self, WBP_GamePokey_C.OnAccessoryEquipped)
      accessoryComponent.OnAccessoryUnEquip:Add(self, WBP_GamePokey_C.OnAccessoryUnEquip)
    else
      accessoryComponent.OnAccessoryChanged:Remove(self, WBP_GamePokey_C.OnAccessoryChanged)
      accessoryComponent.OnAccessoryEquip:Remove(self, WBP_GamePokey_C.OnAccessoryEquipped)
      accessoryComponent.OnAccessoryUnEquip:Remove(self, WBP_GamePokey_C.OnAccessoryUnEquip)
    end
  end
end

function WBP_GamePokey_C:BindOnBagChanged(Bind)
  local bagComponent = self:GetBagComp()
  if bagComponent then
    if Bind then
      bagComponent.OnBagChanged:Add(self, WBP_GamePokey_C.OnBagChanged)
    else
      bagComponent.OnBagChanged:Remove(self, WBP_GamePokey_C.OnBagChanged)
    end
  end
end

function WBP_GamePokey_C:BindOnEquipChanged(Bind)
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local equipmentComponent = self:GetEquipComp(pawn)
    if equipmentComponent then
      if Bind then
        equipmentComponent.OnEquipmentChanged:Add(self, WBP_GamePokey_C.OnEquipChanged)
      else
        equipmentComponent.OnEquipmentChanged:Remove(self, WBP_GamePokey_C.OnEquipChanged)
      end
    end
  end
end

function WBP_GamePokey_C:BindClearEquipSlotChoose(Bind)
  if self.WeaponCapture and self.WeaponCapture:IsValid() then
    if Bind then
      self.WeaponCapture.OnClearEquipSlot:Add(self, WBP_GamePokey_C.OnClearEquipSlotChoose)
    else
      self.WeaponCapture.OnClearEquipSlot:Remove(self, WBP_GamePokey_C.OnClearEquipSlotChoose)
    end
  end
end

function WBP_GamePokey_C:OnAccessoryClicked(Clicked)
  self.CurrentChooseAccessory = Clicked
  for key, value in iterator(self.Accessories) do
    if value ~= self.CurrentChooseAccessory then
      value:SetUnClicked()
    end
  end
end

function WBP_GamePokey_C:OnAccessoryHovered(ArticleId, Equipped)
  self.WBP_AccessoryCompare:InitInfoForGamePokey(ArticleId, self.ChooseGun, Equipped)
  self.WBP_AccessoryCompare:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_GamePokey_C:OnAccessoryUnHovered()
  self.WBP_AccessoryCompare:SetVisibility(UE.ESlateVisibility.Hidden)
end

function WBP_GamePokey_C:OnWeaponSwitchChoose(Clicked)
  if Clicked ~= self.Clicked then
    self.Clicked = Clicked
    self.WBP_AccessoryCompare:SetVisibility(UE.ESlateVisibility.Hidden)
    self:BindOnAccessoryChanged(false)
    self.ChooseGun = Clicked.Gun
    self:BindOnAccessoryChanged(true)
    self:InitWeaponDisplayInfo()
    self:InitAccessoriesPanel()
    self:InitEquipSlot()
    for key, value in iterator(self.WeaponSwitch) do
      if value ~= self.Clicked then
        value:UnsetInUse()
      else
        value:SetInUse()
      end
    end
    if self.WeaponCapture and self.WeaponCapture:IsValid() then
      self.WeaponCapture:ChangeTransformByWeapon(false, false)
      PlaySound2DEffect(30004, "")
    end
  end
end

function WBP_GamePokey_C:OnAccessoryChanged()
  self:InitWeaponDisplayInfo()
  self:CheckItemExist()
  self.WBP_AccessoriesPanel:RefreshState()
end

function WBP_GamePokey_C:OnAccessoryEquipped()
  local waveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if waveManager then
    waveManager:ShowWaveWindow(1022)
  end
  print(" WBP_GamePokey_C:OnAccessoryEquipped ")
  PlaySound2DEffect(30003, "")
end

function WBP_GamePokey_C:OnAccessoryUnEquip()
  PlaySound2DEffect(30002, "")
  print(" WBP_GamePokey_C:OnAccessoryUnEquip ")
end

function WBP_GamePokey_C:OnBagChanged()
  self.WBP_AccessoriesPanel:RefreshState()
  if self.Discard then
    self:CheckItemExist()
    self.Discard = false
  end
end

function WBP_GamePokey_C:OnEquipChanged()
  local widget
  for key, value in iterator(self.VerticalBox_WeaponSwitch:GetAllChildren()) do
    widget = value:Cast(self.wbp_WeaponSwitchClass)
    if widget then
      widget:InitInfo()
    end
  end
  if self.LockWeaponSwitch then
    self:OnWeaponSwitchChoose(self.Clicked)
  else
    self:InitChooseWeapon()
  end
end

function WBP_GamePokey_C:OnEquipSlotSelected(Selected)
  self.Selected = Selected
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local result, accessoryTypeTableRow = DTSubsystem:GetAccessoryTypeTableRow(Selected.AccessoryType)
    if result and accessoryTypeTableRow then
      self.WBP_AccessoriesPanel.ScrollBox_Accessories:ClearChildren()
      self.WBP_AccessoriesPanel:CreateAccessoriesByType(Selected.AccessoryType, self, true)
    end
  end
end

function WBP_GamePokey_C:OnClearEquipSlotChoose()
  self:ClearChooseEquipSlot()
end

function WBP_GamePokey_C:OnWeaponMeshPressed()
  self.CanvasPanel_EquipSlot:SetVisibility(UE.ESlateVisibility.Hidden)
end

function WBP_GamePokey_C:OnWeaponMeshReleased()
  self.CanvasPanel_EquipSlot:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_GamePokey_C:OnMainPanelEnter(Index)
  if 0 == Index then
    self:PlayAnimation(self.ani_33_gamepokey_in)
  end
end

function WBP_GamePokey_C:OnMainPanelExit(CurrentActivateWidget)
  if self == CurrentActivateWidget then
    self:PlayAnimation(self.ani_33_gamepokey_out)
  end
end

function WBP_GamePokey_C:OnActiveWidgetChange(LastActiveWidget, CurActiveWidget, MainPanel)
  self.MainPanel = MainPanel
  if CurActiveWidget == self then
    self:SetDisplayCamera()
    PlaySound2DEffect(30001, "")
    self:PlayAnimation(self.ani_33_gamepokey_in)
  end
end

function WBP_GamePokey_C:GetAccessoryComp()
  if self.ChooseGun then
    return self.ChooseGun.AccessoryComponent
  end
  return nil
end

function WBP_GamePokey_C:GetBagComp()
  local playerController = self:GetOwningPlayer()
  if playerController then
    return playerController:GetComponentByClass(UE.URGBagComponent:StaticClass())
  end
  return nil
end

function WBP_GamePokey_C:GetEquipComp(Actor)
  if Actor then
    return Actor:GetComponentByClass(UE.URGEquipmentComponent:StaticClass())
  end
  return nil
end

function WBP_GamePokey_C:GetCompanionAI()
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local companionComp = pawn:GetComponentByClass(UE.UCompanionComponent:StaticClass())
    if companionComp then
      return companionComp:GetCompanionAI()
    end
  end
  return nil
end

function WBP_GamePokey_C:GetCurrentWeapon(Target)
  local equipmentComp = self:GetEquipComp(Target)
  if equipmentComp then
    return equipmentComp:GetCurrentWeapon()
  end
  return nil
end

function WBP_GamePokey_C:GetAccessoryCompByActor(Target)
  return Target.AccessoryComponent
end

function WBP_GamePokey_C:HasBarrel(Target)
  local AccessoryComponent = self:GetAccessoryCompByActor(Target)
  if AccessoryComponent then
    return AccessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel), AccessoryComponent:GetAccessoryByType(UE.ERGAccessoryType.EAT_Barrel)
  end
  return nil
end

function WBP_GamePokey_C:GetNotChooseGun()
  if self.ChooseGun then
    if self.WBP_WeaponSwitch_Primary.Gun == self.ChooseGun then
      return self.WBP_WeaponSwitch_Second.Gun
    elseif self.WBP_WeaponSwitch_Second.Gun == self.ChooseGun then
      return self.WBP_WeaponSwitch_Primary.Gun
    end
  end
  return nil
end

function WBP_GamePokey_C:IsAccessoryRotate()
  if self.WeaponCapture and self.WeaponCapture:IsValid() then
    return self.WeaponCapture.RotateByAccessory
  end
  return false
end

function WBP_GamePokey_C:DiscardAccessory()
  if self.CurrentChooseAccessory and not self.CurrentChooseAccessory.Equipped then
    self.Discard = true
    local rgBagComponent = self:GetBagComp()
    if rgBagComponent then
      rgBagComponent:DiscardItem(self.CurrentChooseAccessory.ArticleId, 1)
      self.WBP_AccessoriesPanel:ClearSelection()
      local waveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
      if waveManager then
        waveManager:ShowWaveWindow(1024)
      end
    end
  end
end

function WBP_GamePokey_C:DiscardWeapon()
end

function WBP_GamePokey_C:WillShowMessage(AccessoryId)
  local accessoryComponent = self:GetAccessoryComp()
  if accessoryComponent then
    if accessoryComponent:HasAccessoryOfType(UE.ERGAccessoryType.EAT_Barrel) then
      local outData = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, AccessoryId)
      return outData.AccessoryType == UE.ERGAccessoryType.EAT_Barrel
    else
      return false
    end
  end
end

function WBP_GamePokey_C:UpdateEquipSlotPosition(AsSlot, InLocation)
  if self.WeaponCapture and self.WeaponCapture:IsValid() then
    local result, screenPosition = UE.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(self:GetOwningPlayer(), UE.UKismetMathLibrary.TransformLocation(self.WeaponCapture.SKM_Basics:K2_GetComponentToWorld(), InLocation), nil, false)
    AsSlot:SetPosition(screenPosition)
  end
end

function WBP_GamePokey_C:ClearChooseEquipSlot()
  if self.Selected then
    self.Selected:ClearButtonClicked()
    self:RecoverAccessoriesPanel()
    self.Selected = nil
  end
end

function WBP_GamePokey_C:RecoverAccessoriesPanel()
  self.WBP_AccessoriesPanel:CreateAccessories(self)
end

function WBP_GamePokey_C:CheckItemExist()
  self.WBP_AccessoryCompare:SetVisibility(UE.ESlateVisibility.Hidden)
  self.WBP_AccessoriesPanel:CheckItemExist()
end

function WBP_GamePokey_C:OnClose()
  self:RecoverDisplayCamera()
end

function WBP_GamePokey_C:RecoverDisplayCamera()
  if self.WeaponCapture and self.WeaponCapture:IsValid() then
    self.WeaponCapture:SetWeaponCaptureInfo(false, false, false)
    local playerController = self:GetOwningPlayer()
    if playerController:IsValid() then
      playerController:SetViewTargetWithBlend(self:GetOwningPlayerPawn())
    end
  end
end

function WBP_GamePokey_C:GetWeaponCapture()
  local outActors
  local weaponCaptureClass = UE.UClass.Load("/Game/Rouge/UI/Item/Weapon/BP_WeaponCapture.BP_WeaponCapture_C")
  outActors = UE.UGameplayStatics.GetAllActorsOfClass(self, weaponCaptureClass, nil)
  if outActors:IsValidIndex(1) then
    self.WeaponCapture = outActors:Get(1)
  end
end

function WBP_GamePokey_C:SetDisplayCamera()
  if self.WeaponCapture and self.WeaponCapture:IsValid() then
    self.WeaponCapture:SetWeaponCaptureInfo(true, false, false)
  end
end

function WBP_GamePokey_C:InterpolationCameraWeapon(Selected, Equipped, AccessoryId)
  if Equipped and self.WeaponCapture and self.WeaponCapture:IsValid() then
    self.WeaponCapture:OnAccessoryClicked(Selected, AccessoryId)
  end
end

return WBP_GamePokey_C
