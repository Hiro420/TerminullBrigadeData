local WBP_GRWeaponPanel_C = UnLua.Class()

function WBP_GRWeaponPanel_C:Construct()
  EventSystem.AddListener(self, EventDef.GameRecordPanel.TypeButtonChanged, WBP_GRWeaponPanel_C.OnTypeButtonChanged)
  EventSystem.AddListener(self, EventDef.Lobby.LobbyPanelChanged, WBP_GRWeaponPanel_C.OnLobbyActivePanelChanged)
  EventSystem.AddListener(self, EventDef.GunDisplayPanel.OnGunSlotClicked, WBP_GRWeaponPanel_C.OnGunSlotClicked)
  self:SaveCameraWeapon()
  self.bUpdateAccessorySlot = false
end

function WBP_GRWeaponPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.GameRecordPanel.TypeButtonChanged, WBP_GRWeaponPanel_C.OnTypeButtonChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.LobbyPanelChanged, WBP_GRWeaponPanel_C.OnLobbyActivePanelChanged, self)
  EventSystem.RemoveListener(EventDef.GunDisplayPanel.OnGunSlotClicked, WBP_GRWeaponPanel_C.OnGunSlotClicked, self)
end

function WBP_GRWeaponPanel_C:LuaTick(InDeltaTime)
  if self.bUpdateAccessorySlot and self.TargetCamera and self.TargetCamera:IsValid() then
    self.WBP_GunMainPanel:UpdateAccessorySlotsPosition(tostring(100802), self.TargetCamera.SKM_Basics:K2_GetComponentToWorld())
  end
end

function WBP_GRWeaponPanel_C:OnTypeButtonChanged(LastActiveWidget, CurActiveWidget, CurrentRoleInfoData)
  if CurActiveWidget == self then
    self.CurrentRoleInfoData = CurrentRoleInfoData
    self:UpdateViewTarget(true)
    self:UpdateGunItemBox()
  else
    self.bUpdateAccessorySlot = false
    self:UpdateViewTarget(false)
  end
end

function WBP_GRWeaponPanel_C:OnLobbyActivePanelChanged(LastActiveWidget, CurActiveWidget)
  self:UpdateViewTarget(false)
end

function WBP_GRWeaponPanel_C:OnGunSlotClicked(GunId)
  self:UpdateGRWeaponPanel(GunId)
end

function WBP_GRWeaponPanel_C:UpdateGRWeaponPanel(GunId)
  local accessoryIdArray = UE.TArray(0)
  local accessoryIdList = {}
  local attributeList = {}
  local gunLevel
  for key, value in pairs(self.CurrentRoleInfoData.WeaponList) do
    if GunId == value.WeaponId then
      accessoryIdList = value.AccessoryList
      attributeList = value.AttributeList
      gunLevel = value.Level
      local AccessoryIdTable = GetAccessoryIdTable(value.AccessoryList)
      for key, value in pairs(AccessoryIdTable) do
        accessoryIdArray:Add(value)
      end
    end
  end
  if self.TargetCamera and self.TargetCamera:IsValid() then
    self.TargetCamera:SetRGCameraGun(GunId, accessoryIdArray)
    local find, cameraWeaponConfig = self:GetCameraWeaponConfig(tostring(GunId))
    if find then
      local has, barreId = CheckHasBarrel(GetAccessoryIdTable(accessoryIdList))
      self.TargetCamera:UpdateRGCameraGunTransformByConfig(has, cameraWeaponConfig)
    else
      self.TargetCamera:UpdateInitRGCameraGunTransform()
    end
    self.WBP_GunMainPanel:UpdateAccessorySlots(accessoryIdList)
    local inscriptionIdTable = {}
    local tempInscriptionIdTable = {}
    for key, value in pairs(accessoryIdList) do
      tempInscriptionIdTable = GetInscriptionIdTable(key, value)
      for key, value in pairs(tempInscriptionIdTable) do
        table.insert(inscriptionIdTable, value)
      end
    end
    self.WBP_GunMainPanel:UpdateGunDisplayPanel(GunId, gunLevel, accessoryIdList, attributeList, inscriptionIdTable)
  else
    print("TargetCamera is nil.")
  end
  self.bUpdateAccessorySlot = true
end

function WBP_GRWeaponPanel_C:UpdateViewTarget(Weapon)
  if self.bUpdateViewTarget == Weapon then
    return
  end
  self.bUpdateViewTarget = Weapon
  local playerController = self:GetOwningPlayer()
  if playerController and playerController:IsValid() and Weapon then
    playerController:SetViewTargetWithBlend(self.TargetCamera.CameraActor.ChildActor)
  else
  end
end

function WBP_GRWeaponPanel_C:UpdateGunItemBox()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local gunInfoTable = {}
  for key, value in pairs(self.CurrentRoleInfoData.WeaponList) do
    local ItemData
    ItemData = DTSubsystem:K2_GetItemTableRow(value.WeaponId, nil)
    if not ItemData then
      return
    end
    local tempInfoTable = {}
    tempInfoTable.GunId = value.WeaponId
    local AccessoryIdTable = GetAccessoryIdTable(value.AccessoryList)
    local has, barreId = CheckHasBarrel(AccessoryIdTable)
    if has then
      tempInfoTable.BarrelId = barreId
    else
      tempInfoTable.BarrelId = -1
    end
    tempInfoTable.AccessoryNumber = GetAccessoryNumber(AccessoryIdTable, true)
    table.insert(gunInfoTable, tempInfoTable)
  end
  if table.count(gunInfoTable) > 0 then
    self.WBP_GunItemBox:UpdateGunItemBox(gunInfoTable)
    self.Overlay_Empty:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Overlay_Empty:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_GRWeaponPanel_C:SaveCameraWeapon()
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "GameRecordWeapon", nil)
  for i, SingleActor in iterator(AllActors) do
    self.TargetCamera = SingleActor
    break
  end
end

return WBP_GRWeaponPanel_C
