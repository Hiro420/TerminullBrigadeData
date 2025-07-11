local SkinData = require("Modules.Appearance.Skin.SkinData")
local BP_AppearanceActorBase_C = UnLua.Class()
local CameraTimer = -1
local CameraMotionIdx = -1
local PreCameraTrans
local EDisplayMeshStatus = {
  Role = 1,
  Weapon = 2,
  Prop = 3
}
function BP_AppearanceActorBase_C:GetcameraData(SkinId, MotionIdx)
  local cameraData
  local cameraDataList = self.CameraDataMap.CameraDataListMap:Find(tonumber(SkinId))
  cameraDataList = cameraDataList or self.CameraDataMap.CameraDataListMap:Find("Default")
  if cameraDataList and cameraDataList.CameraDataList then
    if cameraDataList.CameraDataList:IsValidIndex(MotionIdx) then
      cameraData = cameraDataList.CameraDataList:Get(MotionIdx)
    elseif cameraDataList.CameraDataList:IsValidIndex(1) then
      cameraData = cameraDataList.CameraDataList:Get(1)
    end
  end
  return cameraData
end
function BP_AppearanceActorBase_C:GetcameraDataList(SkinId)
  local cameraDataList = self.CameraDataMap.CameraDataListMap:Find(tonumber(SkinId))
  cameraDataList = cameraDataList or self.CameraDataMap.CameraDataListMap:Find("Default")
  if cameraDataList and cameraDataList.CameraDataList then
    return cameraDataList.CameraDataList
  end
  return nil
end
local SetCameraData = function(self, skinId, MotionIdx)
  local cameraData = self:GetcameraData(skinId, MotionIdx)
  if cameraData then
    self.ChildActorCamera:K2_SetRelativeTransform(cameraData.CameraTransform, false, nil, false)
    self.ChildActorCamera.ChildActor.CameraComponent:SetFieldOfView(cameraData.CameraFOV)
  end
  CameraTimer = -1
end
function BP_AppearanceActorBase_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  self:UpdateActived(self.bIsActived, true)
end
function BP_AppearanceActorBase_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
end
function BP_AppearanceActorBase_C:ReceiveTick(DeltaSeconds)
  self.Overridden.ReceiveTick(self, DeltaSeconds)
  if not NearlyEquals(CameraTimer, -1) then
    local skinId = self.SkinId
    if self.DisplayMeshStatus == EDisplayMeshStatus.Weapon then
      skinId = self.WeaponSkinId
    end
    if CameraTimer > self.CameraMotionInterval then
      CameraTimer = -1
      local cameraData = self:GetcameraData(skinId, CameraMotionIdx)
      if cameraData then
        self.ChildActorCamera:K2_SetRelativeTransform(cameraData.CameraTransform, false, nil, false)
        self.ChildActorCamera.ChildActor.CameraComponent:SetFieldOfView(cameraData.CameraFOV)
      end
    else
      local xAxisScale = 1 / self.CameraMotionInterval
      local rate = UE.URGBlueprintLibrary.GetRichCurveFloatValue(self.CameraMotionCurve.EditorCurveData, CameraTimer * xAxisScale, 0)
      local cameraData = self:GetcameraData(skinId, CameraMotionIdx)
      if cameraData then
        local trans = LerpTransform(PreCameraTrans, cameraData.CameraTransform, rate)
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
    if self.bIsMouseDown then
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
function BP_AppearanceActorBase_C:BPLeftMouseButtonDown(bIsMouseDown)
  self.bIsMouseDown = bIsMouseDown
end
function BP_AppearanceActorBase_C:InitAppearanceActor(HeroId, SkinId, WeaponSkinId)
  self.SkinId = SkinId
  self.DisplayMeshStatus = EDisplayMeshStatus.Role
  self.ChildActor.ChildActor.IsShowLightInActor = false
  self.ChildActor.ChildActor:ChangeBodyMesh(HeroId, SkinId)
  if WeaponSkinId then
    self.ChildActor.ChildActor:ChangeWeaponMeshBySkinId(WeaponSkinId)
    self.WeaponSkinId = WeaponSkinId
  end
  self.ChildActorWeapon:SetHiddenInGame(true)
  self.ChildActor:SetHiddenInGame(false)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(true)
  end
  local trans = self.RoleDefaultTransform
  self.ChildActor:K2_SetRelativeTransform(trans, false, nil, false)
  CameraMotionIdx = 1
  SetCameraData(self, SkinId, CameraMotionIdx)
end
function BP_AppearanceActorBase_C:InitWeaponMesh(WeaponSkinId, WeaponResId)
  self.WeaponSkinId = WeaponSkinId
  self.DisplayMeshStatus = EDisplayMeshStatus.Weapon
  self.ChildActorWeapon.ChildActor:LocalSetSkinId(WeaponSkinId)
  self.ChildActorWeapon:SetHiddenInGame(false)
  self.ChildActor:SetHiddenInGame(true)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(true)
  end
  self:UpdateWeaponMeshDisplayData(WeaponResId)
  CameraMotionIdx = 1
  SetCameraData(self, WeaponSkinId, CameraMotionIdx)
end
function BP_AppearanceActorBase_C:UpdateWeaponMeshDisplayData(WeaponResId)
  if not UE.RGUtil.IsUObjectValid(self.ChildActorWeapon.ChildActor) then
    print("BP_AppearanceActorBase_C:UpdateWeaponMeshDisplayData ChildActor IsNull")
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.ChildActorWeapon.ChildActor.Mesh) then
    print("BP_AppearanceActorBase_C:UpdateWeaponMeshDisplayData ChildActor.Mesh IsNull")
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
function BP_AppearanceActorBase_C:MoveNextCameraTrans()
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
  local preCameraData = self:GetcameraData(skinId, CameraMotionIdx)
  if preCameraData then
    PreCameraTrans = preCameraData.CameraTransform
  end
  CameraMotionIdx = CameraMotionIdx - 1
  CameraTimer = 0
end
function BP_AppearanceActorBase_C:MovePreCameraTrans()
  if not NearlyEquals(CameraTimer, -1) then
    return
  end
  local skinId = self.SkinId
  if self.DisplayMeshStatus == EDisplayMeshStatus.Weapon then
    skinId = self.WeaponSkinId
  end
  local cameraDataList = self:GetcameraDataList(skinId)
  if not cameraDataList then
    return
  end
  if CameraMotionIdx >= cameraDataList:Length() then
    return
  end
  local preCameraData = self:GetcameraData(skinId, CameraMotionIdx)
  if preCameraData then
    PreCameraTrans = preCameraData.CameraTransform
  end
  CameraMotionIdx = CameraMotionIdx + 1
  CameraTimer = 0
end
function BP_AppearanceActorBase_C:UpdateActived(bIsActived, bNeedNotHideRoleMain, bAutoQuit)
  if nil == bAutoQuit then
    bAutoQuit = true
  end
  self.bIsActived = bIsActived
  self.bNeedNotHideRoleMain = bNeedNotHideRoleMain
  LogicRole.ShowOrHideRoleMainHero(not bIsActived)
  self:SetActorHiddenInGame(not bIsActived)
  if bIsActived then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      self:EnableInput(PC)
      PC:SetViewTargetwithBlend(self.ChildActorCamera.ChildActor)
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
        PC:SetViewTargetwithBlend(TargetCamera)
      end
    end
    CameraTimer = -1
    LogicRole.HideCurSkinLightMap()
  end
end
function BP_AppearanceActorBase_C:GetTypeId(Widget)
  local Character = Widget:GetOwningPlayerPawn()
  if not Character then
    return -1
  end
  return Character:GetTypeID()
end
function BP_AppearanceActorBase_C:HideMesh()
  self.ChildActorWeapon:SetHiddenInGame(false)
  self.ChildActor:SetHiddenInGame(false)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(false)
  end
end
function BP_AppearanceActorBase_C:InitPropByActorPath(ActorPath)
  if not self.ChildActorProp then
    print("BP_AppearanceActorBase_C:InitPropByActorPath ChildActorProp IsNull")
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
return BP_AppearanceActorBase_C
