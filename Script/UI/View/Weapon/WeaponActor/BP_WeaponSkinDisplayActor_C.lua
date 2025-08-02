local BP_WeaponSkinDisplayActor_C = UnLua.Class()
local CameraTimer = -1
local CameraMotionIdx = -1
local EDisplayMeshStatus = {
  Role = 1,
  Weapon = 2,
  Prop = 3
}
local DisableRoleMouseDraggingCounter = 0
local GetcameraData = function(self, SkinId, MotionIdx)
  local cameraData, cameraDataList
  local result, row = GetRowData(DT.DT_WeaponCameraData, tostring(SkinId))
  if result then
    cameraDataList = row.CameraDataList
  end
  if not cameraDataList then
    local resultDefault, rowDefault = GetRowData(DT.DT_WeaponCameraData, "Default")
    if resultDefault then
      cameraDataList = rowDefault.CameraDataList
    end
  end
  if cameraDataList then
    if cameraDataList:IsValidIndex(MotionIdx) then
      cameraData = cameraDataList:Get(MotionIdx)
    elseif cameraDataList:IsValidIndex(1) then
      cameraData = cameraDataList:Get(1)
    end
  end
  return cameraData
end
local GetcameraDataList = function(self, SkinId)
  local cameraDataList
  local resultSkin, rowSkin = GetRowData(DT.DT_WeaponCameraData, tostring(SkinId))
  if resultSkin then
    cameraDataList = rowSkin.CameraDataList
  end
  if not cameraDataList then
    local resultDefault, rowDefault = GetRowData(DT.DT_WeaponCameraData, "Default")
    if resultDefault then
      cameraDataList = rowDefault.CameraDataList
    end
  end
  if cameraDataList then
    return cameraDataList
  end
  return nil
end
local GetDefaultCameraIdx = function(SkinId)
  local Result, Row = GetRowData(DT.DT_AppearanceCameraData, tostring(SkinId))
  if not Result then
    Result, Row = GetRowData(DT.DT_AppearanceCameraData, "Default")
  end
  if Result then
    return Row.DefaultCameraDataIdx
  end
  return 1
end
local SetCameraData = function(self, skinId, MotionIdx)
  local cameraData = GetcameraData(self, skinId, MotionIdx)
  if cameraData then
    self.ChildActorCamera:K2_SetRelativeTransform(cameraData.CameraTransform + self.TransOffset, false, nil, false)
  end
  CameraTimer = -1
end

function BP_WeaponSkinDisplayActor_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  self:UpdateActived(self.bIsActived, true)
end

function BP_WeaponSkinDisplayActor_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
end

function BP_WeaponSkinDisplayActor_C:ReceiveTick(DeltaSeconds)
  self.Overridden.ReceiveTick(self, DeltaSeconds)
  if not NearlyEquals(CameraTimer, -1) then
    local skinId = self.SkinId
    if self.DisplayMeshStatus == EDisplayMeshStatus.Weapon then
      skinId = self.WeaponSkinId
    end
    if CameraTimer > self.CameraMotionInterval then
      CameraTimer = -1
      local cameraData = GetcameraData(self, skinId, CameraMotionIdx)
      if cameraData then
        self.ChildActorCamera:K2_SetRelativeTransform(cameraData.CameraTransform + self.TransOffset, false, nil, false)
      end
    else
      local xAxisScale = 1 / self.CameraMotionInterval
      local rate = UE.URGBlueprintLibrary.GetRichCurveFloatValue(self.CameraMotionCurve.EditorCurveData, CameraTimer * xAxisScale, 0)
      local cameraData = GetcameraData(self, skinId, CameraMotionIdx)
      if cameraData then
        local trans = LerpTransform(self.PreCameraTrans, cameraData.CameraTransform + self.TransOffset, rate)
        self.ChildActorCamera:K2_SetRelativeTransform(trans, false, nil, false)
      end
      CameraTimer = CameraTimer + DeltaSeconds
    end
  end
  if self.DisplayMeshStatus == EDisplayMeshStatus.Weapon then
    if self.bIsMouseDown then
      self.ChildActorWeapon:K2_AddRelativeRotation(self.MeshRotateDelta * self:GetMouseX(), false, nil, false)
    else
      self.ChildActorWeapon:K2_AddRelativeRotation(self.WeaponMeshAutoRotateDelta * (DeltaSeconds / 0.02), false, nil, false)
    end
  elseif self.DisplayMeshStatus == EDisplayMeshStatus.Role then
    if self.bIsMouseDown and 0 == DisableRoleMouseDraggingCounter then
      self.ChildActor:K2_AddRelativeRotation(self.MeshRotateDelta * self:GetMouseX(), false, nil, false)
    else
      local curRotator = UE.UKismetMathLibrary.RInterpTo(self.ChildActor.RelativeRotation, self.InitRelativeRotation, DeltaSeconds, self.MeshRotatorRecoverSpeed)
      self.ChildActor:K2_SetRelativeRotation(curRotator, false, nil, false)
    end
  elseif self.DisplayMeshStatus == EDisplayMeshStatus.Prop then
    if self.bIsMouseDown then
      self.ChildActorProp:K2_AddRelativeRotation(self.MeshRotateDelta * self:GetMouseX(), false, nil, false)
    else
      self.ChildActorProp:K2_AddRelativeRotation(self.WeaponMeshAutoRotateDelta * (DeltaSeconds / 0.02), false, nil, false)
    end
  end
end

function BP_WeaponSkinDisplayActor_C:BPLeftMouseButtonDown(bIsMouseDown)
  self.bIsMouseDown = bIsMouseDown
end

function BP_WeaponSkinDisplayActor_C:InitAppearanceActor(HeroId, SkinId, WeaponSkinId, bShowGlitchMatEffect)
  self.TransOffset = self.RoleCameraOffsetTransform
  self.SkinId = SkinId
  self.DisplayMeshStatus = EDisplayMeshStatus.Role
  self.ChildActor.ChildActor.IsShowLightInActor = false
  self.ChildActor.ChildActor:ChangeBodyMesh(HeroId, SkinId, nil, nil, bShowGlitchMatEffect)
  if WeaponSkinId then
    self.ChildActor.ChildActor:ChangeWeaponMeshBySkinId(WeaponSkinId, bShowGlitchMatEffect)
    self.WeaponSkinId = WeaponSkinId
  end
  self.ChildActorWeapon:SetHiddenInGame(true)
  self.ChildActor:SetHiddenInGame(false)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(true)
  end
  local trans = self.RoleDefaultTransform
  self.ChildActor:K2_SetRelativeTransform(trans, false, nil, false)
  CameraMotionIdx = GetDefaultCameraIdx(SkinId)
  SetCameraData(self, SkinId, CameraMotionIdx)
end

function BP_WeaponSkinDisplayActor_C:InitWeaponMesh(WeaponSkinId, WeaponResId, TransOffset, bForceUpdate, bShowGlitchMatEffect)
  if not bForceUpdate and not self.ChildActorWeapon.bHiddenInGame and self.TransOffset == TransOffset and self.WeaponSkinId == WeaponSkinId then
    return
  end
  self.TransOffset = TransOffset
  self.WeaponSkinId = WeaponSkinId
  self.DisplayMeshStatus = EDisplayMeshStatus.Weapon
  self.ChildActorWeapon.ChildActor:InitPreChanged(self.ChildActorWeapon.ChildActor.CurrentSkinId, bShowGlitchMatEffect)
  self.ChildActorWeapon.ChildActor:LocalSetSkinId(WeaponSkinId)
  self.ChildActorWeapon:SetHiddenInGame(false)
  self.ChildActor:SetHiddenInGame(true)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(true)
  end
  self:UpdateWeaponMeshDisplayData(WeaponResId, TransOffset)
  CameraMotionIdx = GetDefaultCameraIdx(WeaponSkinId)
  SetCameraData(self, WeaponSkinId, CameraMotionIdx)
end

function BP_WeaponSkinDisplayActor_C:UpdateWeaponMeshDisplayData(WeaponResId, TransOffset)
  if not UE.RGUtil.IsUObjectValid(self.ChildActorWeapon.ChildActor) then
    print("BP_WeaponSkinDisplayActor_C:UpdateWeaponMeshDisplayData ChildActor IsNull")
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.ChildActorWeapon.ChildActor.Mesh) then
    print("BP_WeaponSkinDisplayActor_C:UpdateWeaponMeshDisplayData ChildActor.Mesh IsNull")
    return
  end
  local result, rowData = GetRowData(DT.DT_WeaponDisplayConfig, tostring(WeaponResId))
  if result then
    local trans = rowData.WeaponRelativeTransform
    if self.InitialWeaponTransform then
      trans = trans + self.InitialWeaponTransform
    end
    self.ChildActorWeapon:K2_SetRelativeTransform(trans, false, nil, false)
    self.ChildActorWeapon.ChildActor.Mesh:K2_SetRelativeTransform(rowData.WeaponAnchorOffset, false, nil, false)
  else
    local resultDefault, rowDataDefault = GetRowData(DT.DT_WeaponDisplayConfig, "Default")
    if resultDefault then
      local trans = rowDataDefault.WeaponRelativeTransform
      if self.InitialWeaponTransform then
        trans = trans + self.InitialWeaponTransform
      end
      self.ChildActorWeapon:K2_SetRelativeTransform(trans, false, nil, false)
      self.ChildActorWeapon.ChildActor.Mesh:K2_SetRelativeTransform(rowDataDefault.WeaponAnchorOffset, false, nil, false)
    end
  end
end

function BP_WeaponSkinDisplayActor_C:MoveNextCameraTrans()
  if CameraMotionIdx <= 1 then
    return
  end
  if not NearlyEquals(CameraTimer, -1) then
    return
  end
  local skinId = self.SkinId
  if self.DisplayMeshStatus == EDisplayMeshStatus.Weapon then
    skinId = self.WeaponSkinId
  end
  local preCameraData = GetcameraData(self, skinId, CameraMotionIdx)
  if preCameraData then
    self.PreCameraTrans = preCameraData.CameraTransform + self.TransOffset
  end
  CameraMotionIdx = CameraMotionIdx - 1
  CameraTimer = 0
end

function BP_WeaponSkinDisplayActor_C:MovePreCameraTrans()
  if not NearlyEquals(CameraTimer, -1) then
    return
  end
  local skinId = self.SkinId
  if self.DisplayMeshStatus == EDisplayMeshStatus.Weapon then
    skinId = self.WeaponSkinId
  end
  local cameraDataList = GetcameraDataList(self, skinId)
  if not cameraDataList then
    return
  end
  if CameraMotionIdx >= cameraDataList:Length() then
    return
  end
  local preCameraData = GetcameraData(self, skinId, CameraMotionIdx)
  if preCameraData then
    self.PreCameraTrans = preCameraData.CameraTransform + self.TransOffset
  end
  CameraMotionIdx = CameraMotionIdx + 1
  CameraTimer = 0
end

function BP_WeaponSkinDisplayActor_C:UpdateActived(bIsActived, bNotChangeRoleMainHeroVisble, bAutoQuit)
  if nil == bAutoQuit then
    bAutoQuit = true
  end
  self.bIsActived = bIsActived
  if not bNotChangeRoleMainHeroVisble then
    LogicRole.ShowOrHideRoleMainHero(not bIsActived)
  end
  self:SetHiddenInGame(not bIsActived)
  if bIsActived then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      self:EnableInput(PC)
      PC:SetViewTargetwithBlend(self.ChildActorCamera.ChildActor, 0)
    end
    if self.DisplayMeshStatus == EDisplayMeshStatus.Weapon then
      if self.WeaponSkinId then
        LogicRole.ShowSkinLightMap(self.WeaponSkinId)
      end
    elseif self.DisplayMeshStatus == EDisplayMeshStatus.Role and self.SkinId then
      LogicRole.ShowSkinLightMap(self.SkinId)
    end
  else
    if bAutoQuit then
      local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "MainCamera", nil)
      local TargetCamera
      for i, SingleActor in iterator(AllActors) do
        TargetCamera = SingleActor
        break
      end
      local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
      if PC then
        self:DisableInput(PC)
        PC:SetViewTargetwithBlend(TargetCamera, 0)
      end
    end
    self.WeaponSkinId = -1
    CameraTimer = -1
    LogicRole.HideCurSkinLightMap()
  end
end

function BP_WeaponSkinDisplayActor_C:GetTypeId(Widget)
  local Character = Widget:GetOwningPlayerPawn()
  if not Character then
    return -1
  end
  return Character:GetTypeID()
end

function BP_WeaponSkinDisplayActor_C:HideMesh()
  self.ChildActorWeapon:SetHiddenInGame(true)
  self.ChildActor:SetHiddenInGame(true)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(true)
  end
end

function BP_WeaponSkinDisplayActor_C:InitPropByActorPath(ActorPath)
  if not self.ChildActorProp then
    print("BP_WeaponSkinDisplayActor_C:InitPropByActorPath ChildActorProp IsNull")
    return
  end
  self.DisplayMeshStatus = EDisplayMeshStatus.Prop
  local Class = GetAssetByPath(ActorPath, true)
  if Class and not UE.UKismetMathLibrary.EqualEqual_ClassClass(self.ChildActorProp.ChildActorClass, Class) then
    self.ChildActorProp:SetChildActorClass(Class)
  end
  self.ChildActorWeapon:SetHiddenInGame(true)
  self.ChildActor:SetHiddenInGame(true)
  self.ChildActorProp:SetHiddenInGame(false)
  SetCameraData(self, 0, 1)
end

function BP_WeaponSkinDisplayActor_C:RequestToDisableDraggingRole()
  DisableRoleMouseDraggingCounter = DisableRoleMouseDraggingCounter + 1
end

function BP_WeaponSkinDisplayActor_C:RequestToEnableDraggingRole()
  DisableRoleMouseDraggingCounter = DisableRoleMouseDraggingCounter - 1
  if DisableRoleMouseDraggingCounter < 0 then
    DisableRoleMouseDraggingCounter = 0
  end
end

return BP_WeaponSkinDisplayActor_C
