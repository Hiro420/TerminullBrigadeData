local SkinData = require("Modules.Appearance.Skin.SkinData")
local BP_AppearanceActor_C = UnLua.Class()
local CameraTimer = -1
local CameraMotionIdx = -1
local EDisplayMeshStatus = {
  Role = 1,
  Weapon = 2,
  Prop = 3
}
local DisableRoleMouseDraggingCounter = 0
local IsMultiLayerCameraMode = function(self)
  local result, row = GetRowData(DT.DT_DisplaySkin, tostring(self.SkinId))
  return result and row.bMultiCameraMode and UE.RGUtil.IsUObjectValid(self.MultiLayerCameraActor) or false
end
local GetcameraData = function(self, SkinId, MotionIdx)
  local cameraDataList
  if IsMultiLayerCameraMode(self) then
    cameraDataList = self.MultiLayerCameraActor.CameraDataList.CameraDataList
  else
    local result, row = GetRowData(DT.DT_AppearanceCameraData, tostring(SkinId))
    if result then
      cameraDataList = row.CameraDataList
    end
  end
  if not cameraDataList then
    local result, row = GetRowData(DT.DT_AppearanceCameraData, "Default")
    if result then
      cameraDataList = row.CameraDataList
    end
  end
  local cameraData
  if cameraDataList then
    if cameraDataList:IsValidIndex(MotionIdx) then
      cameraData = cameraDataList:Get(MotionIdx)
    elseif cameraDataList:IsValidIndex(1) then
      cameraData = cameraDataList:Get(1)
    end
  end
  return cameraData
end
local EnableDirectionalLights = function(self, enable)
  local DirectionalLightActors = UE.UGameplayStatics.GetAllActorsOfClass(self, UE.ADirectionalLight:StaticClass(), nil)
  for i = 1, DirectionalLightActors:Length() do
    local DirectionalLight = DirectionalLightActors:Get(i)
    if UE.RGUtil.IsUObjectValid(DirectionalLight) then
      DirectionalLight:SetEnabled(enable)
      if enable then
        print("[MultiLayerCamera] Enable DirectionalLight: ", DirectionalLight:GetName())
      else
        print("[MultiLayerCamera] Disable DirectionalLight: ", DirectionalLight:GetName())
      end
    end
  end
end
local EnterMultiLayerCameraScene = function(self)
  EnableDirectionalLights(self, false)
end
local LeaveMultiLayerCameraScene = function(self)
  EnableDirectionalLights(self, true)
end
local GetRoleTrans = function(self)
  if IsMultiLayerCameraMode(self) then
    return self.MultiLayerCameraActor.ChildActorTransform
  else
    return self.RoleDefaultTransform
  end
end
local SetMvpRoleActorTransform = function(self)
  local roleTrans = GetRoleTrans(self)
  if IsMultiLayerCameraMode(self) then
    self.ChildActor:K2_SetWorldTransform(roleTrans, false, nil, false)
  else
    self.ChildActor:K2_SetRelativeTransform(roleTrans, false, nil, false)
  end
end
local SetMvpRoleActorCameraTransform = function(self, trans)
  if IsMultiLayerCameraMode(self) then
    self.ChildActorCamera:K2_SetWorldTransform(trans, false, nil, false)
  else
    self.ChildActorCamera:K2_SetRelativeTransform(trans, false, nil, false)
  end
end
local SetCommonActorTransform = function(self, RowName, Transform)
  local rowName = "BattlePass"
  if RowName then
    rowName = RowName
  end
  local resultRole, rowRole = GetRowData(DT.DT_RoleMainTransform, rowName)
  if resultRole then
    if Transform then
      if Transform.Translation ~= UE.FVector(0, 0, 0) then
        rowRole.RoleMainTransform.Translation = Transform.Translation
      end
      if Transform.Scale3D ~= UE.FVector(1, 1, 1) then
        rowRole.RoleMainTransform.Scale3D = Transform.Scale3D
      end
    end
    self.ChildActor:K2_SetWorldTransform(rowRole.RoleMainTransform, false, nil, false)
  end
end
local SetCommonWeaponActorTransform = function(self, RowName, Transform)
  local rowName = "BattlePassWeapon"
  if RowName then
    rowName = RowName
  end
  local resultRole, rowRole = GetRowData(DT.DT_RoleMainTransform, rowName)
  if resultRole then
    if Transform then
      if Transform.Translation ~= UE.FVector(0, 0, 0) then
        rowRole.RoleMainTransform.Translation = Transform.Translation
      end
      if Transform.Scale3D ~= UE.FVector(1, 1, 1) then
        rowRole.RoleMainTransform.Scale3D = Transform.Scale3D
      end
    end
    self.ChildActorWeapon:K2_SetWorldTransform(rowRole.RoleMainTransform, false, nil, false)
  end
end
function BP_AppearanceActor_C:SetCommonCameraTransform(RowName)
  local rowName = "BattlePassWeapon"
  if RowName then
    rowName = RowName
  end
  local result, row = GetRowData(DT.DT_CameraLobby, rowName)
  if result then
    self.ChildActorCamera:K2_SetWorldTransform(row.CameraTransform, false, nil, false)
  end
end
local GetcameraDataList = function(self, SkinId)
  local cameraDataList
  if IsMultiLayerCameraMode(self) then
    cameraDataList = self.MultiLayerCameraActor.CameraDataList.CameraDataList
  end
  if cameraDataList then
    return cameraDataList.CameraDataList
  end
  local resultSkin, rowSkin = GetRowData(DT.DT_AppearanceCameraData, tostring(SkinId))
  if resultSkin then
    cameraDataList = rowSkin.CameraDataList
  end
  if not cameraDataList then
    local resultDefault, rowDefault = GetRowData(DT.DT_AppearanceCameraData, "Default")
    if resultDefault then
      cameraDataList = rowDefault.CameraDataList
    end
  end
  if cameraDataList then
    return cameraDataList
  end
  return nil
end
local SetCameraData = function(self, skinId, MotionIdx)
  local cameraData = GetcameraData(self, skinId, MotionIdx)
  if cameraData then
    SetMvpRoleActorCameraTransform(self, cameraData.CameraTransform)
  end
  CameraTimer = -1
end
local GetDefaultCameraIdx = function(SkinId)
  local Result, Row = GetRowData(DT.DT_AppearanceCameraData, tostring(SkinId))
  if not Result then
    Result, Row = GetRowData(DT.DT_AppearanceCameraData, "Default")
  end
  if Result then
    return Row.DefaultCameraDataIdx + 1
  end
  return 0
end
function BP_AppearanceActor_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  self:UpdateActived(self.bIsActived, true)
end
function BP_AppearanceActor_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
end
function BP_AppearanceActor_C:ReceiveTick(DeltaSeconds)
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
        SetMvpRoleActorCameraTransform(self, cameraData.CameraTransform)
      end
    else
      local xAxisScale = 1 / self.CameraMotionInterval
      local rate = UE.URGBlueprintLibrary.GetRichCurveFloatValue(self.CameraMotionCurve.EditorCurveData, CameraTimer * xAxisScale, 0)
      local cameraData = GetcameraData(self, skinId, CameraMotionIdx)
      if cameraData then
        local trans = LerpTransform(self.PreCameraTrans, cameraData.CameraTransform, rate)
        SetMvpRoleActorCameraTransform(self, trans)
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
function BP_AppearanceActor_C:BPLeftMouseButtonDown(bIsMouseDown)
  self.bIsMouseDown = bIsMouseDown
end
function BP_AppearanceActor_C:InitAppearanceActor(HeroId, SkinId, WeaponSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect, bForceInit, SkinChangedCallback)
  self:InitAppearanceActorInfo(HeroId, SkinId, WeaponSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect, bForceInit, SkinChangedCallback)
  if not UE.RGUtil.IsUObjectValid(self.MultiLayerCameraActor) then
    local MultiLayerCameraRenderClass = UE.UClass.Load("/Game/Rouge/Map/Lobby/MultiLayerCameraRender/BP_MultiLayerCameraRender.BP_MultiLayerCameraRender")
    local MultiLayerCameraActors = UE.UGameplayStatics.GetAllActorsOfClass(self, MultiLayerCameraRenderClass, nil)
    if MultiLayerCameraActors:IsValidIndex(1) then
      self.MultiLayerCameraActor = MultiLayerCameraActors:Get(1)
    end
  end
  SetMvpRoleActorTransform(self)
  CameraMotionIdx = GetDefaultCameraIdx(SkinId)
  SetCameraData(self, SkinId, CameraMotionIdx)
end
function BP_AppearanceActor_C:InitCommonActor(HeroId, SkinId, WeaponSkinId, CameraID, Transform)
  self:InitAppearanceActorInfo(HeroId, SkinId, WeaponSkinId)
  SetCommonActorTransform(self, CameraID, Transform)
  local cameraID = "BattlePassRole"
  if CameraID then
    cameraID = CameraID
  end
  self:SetCommonCameraTransform(cameraID)
end
function BP_AppearanceActor_C:InitAppearanceActorInfo(HeroId, SkinId, WeaponSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect, bForceInit, SkinChangedCallback)
  self.DoesSkinChanged = false
  self.MultiLayerCameraActor = nil
  if self.SkinId ~= SkinId then
  end
  self.SkinId = SkinId
  self.DisplayMeshStatus = EDisplayMeshStatus.Role
  self.ChildActor.ChildActor.IsShowLightInActor = false
  self.ChildActor:SetWorldScale3D(UE.FVector(1, 1, 1))
  self.ChildActor.ChildActor:ChangeBodyMesh(HeroId, SkinId, SkinChangedCallback, nil, bShowGlitchMatEffect, nil, bShowDrawCardShowMatEffect, bForceInit)
  if WeaponSkinId then
    self.ChildActor.ChildActor:ChangeWeaponMeshBySkinId(WeaponSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect)
    self.WeaponSkinId = WeaponSkinId
  end
  self.ChildActorWeapon:SetHiddenInGame(true)
  self.ChildActor:SetHiddenInGame(false)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(true)
  end
end
function BP_AppearanceActor_C:InitRoleScaleByHeroId(HeroId)
  local CharacterRow = LogicRole.GetCharacterTableRow(HeroId)
  if CharacterRow then
    self.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
  end
end
function BP_AppearanceActor_C:AppearanceToggleSkipEnter(bSkipEnterParam)
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:LobbyRoleActorToggleSkipEnter(bSkipEnterParam)
    LogicAudio.bSkipEnter = bSkipEnterParam
  end
end
function BP_AppearanceActor_C:AppearanceResetAnimation()
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:LobbyRoleActorResetAnimation()
  end
end
function BP_AppearanceActor_C:SetAllActorShow(IsShow)
  self.ChildActorWeapon:SetHiddenInGame(not IsShow)
  self.ChildActor:SetHiddenInGame(not IsShow)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(not IsShow)
  end
end
function BP_AppearanceActor_C:RefreshRoleAniStatus(skinId)
  self.ChildActor.ChildActor:ResetChildActorAnimation()
  LogicAudio.OnLobbyPlayHeroSound(skinId, self)
end
function BP_AppearanceActor_C:InitWeaponMesh(WeaponSkinId, WeaponResId, bShowGlitchMatEffect)
  self:InitWeaponMeshInfo(WeaponSkinId, WeaponResId, bShowGlitchMatEffect)
  self:UpdateWeaponMeshDisplayData(WeaponResId)
  LogicRole.ShowSkinLightMap(WeaponSkinId)
  CameraMotionIdx = GetDefaultCameraIdx(WeaponSkinId)
  SetCameraData(self, WeaponSkinId, CameraMotionIdx)
end
function BP_AppearanceActor_C:InitBattlePassWeaponMesh(WeaponSkinId, WeaponResId, CameraID, Transform)
  self:InitWeaponMeshInfo(WeaponSkinId, WeaponResId)
  SetCommonWeaponActorTransform(self, nil, Transform)
  local cameraID = "BattlePassWeapon"
  if CameraID then
    cameraID = CameraID
  end
  self:SetCommonCameraTransform(CameraID)
end
function BP_AppearanceActor_C:InitWeaponMeshInfo(WeaponSkinId, WeaponResId, bShowGlitchMatEffect)
  self.MultiLayerCameraActor = nil
  self.WeaponSkinId = WeaponSkinId
  self.DisplayMeshStatus = EDisplayMeshStatus.Weapon
  self.ChildActorWeapon.ChildActor:InitPreChanged(self.ChildActorWeapon.ChildActor.CurrentSkinId, bShowGlitchMatEffect)
  self.ChildActorWeapon.ChildActor:LocalSetSkinId(WeaponSkinId)
  self.ChildActorWeapon:SetHiddenInGame(false)
  self.ChildActor:SetHiddenInGame(true)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(true)
  end
end
function BP_AppearanceActor_C:SetActorAnim(Path, SkinId)
  if Path then
    local AnimClass = UE.LoadClass(Path)
    self.ChildActor.ChlidActor.Mesh:SetAnimClass(AnimClass)
  else
    local result, row = GetRowData(DT.DT_DisplaySkin, tostring(SkinId))
    if result then
      local majorMeshAniCls
      majorMeshAniCls = GetAssetBySoftObjectPtr(row.MajorSkin.AnimInstance, true)
      if UE.RGUtil.IsUObjectValid(self.Mesh) and UE.RGUtil.IsUObjectValid(majorMeshAniCls) then
        self.ChildActor.ChlidActor.Mesh:SetAnimClass(majorMeshAniCls)
      end
    end
  end
end
function BP_AppearanceActor_C:UpdateWeaponMeshDisplayData(WeaponResId)
  if not UE.RGUtil.IsUObjectValid(self.ChildActorWeapon.ChildActor) then
    print("BP_AppearanceActor_C:UpdateWeaponMeshDisplayData ChildActor IsNull")
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.ChildActorWeapon.ChildActor.Mesh) then
    print("BP_AppearanceActor_C:UpdateWeaponMeshDisplayData ChildActor.Mesh IsNull")
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
function BP_AppearanceActor_C:MoveNextCameraTrans()
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
    self.PreCameraTrans = preCameraData.CameraTransform
  end
  CameraMotionIdx = CameraMotionIdx - 1
  CameraTimer = 0
end
function BP_AppearanceActor_C:MovePreCameraTrans()
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
    self.PreCameraTrans = preCameraData.CameraTransform
  end
  CameraMotionIdx = CameraMotionIdx + 1
  CameraTimer = 0
end
function BP_AppearanceActor_C:OnMultiLayerCameraBeginPlay(MultiLayerCamera)
  self.MultiLayerCameraActor = MultiLayerCamera
  if self.DoesSkinChanged and self.DisplayMeshStatus == EDisplayMeshStatus.Role then
    EnterMultiLayerCameraScene(self)
    SetMvpRoleActorTransform(self)
    SetCameraData(self, self.SkinId, CameraMotionIdx)
  end
end
function BP_AppearanceActor_C:OnMultiLayerCameraSkinChanged()
  self.DoesSkinChanged = true
  if not UE.RGUtil.IsUObjectValid(self.MultiLayerCameraActor) then
    local MultiLayerCameraRenderClass = UE.UClass.Load("/Game/Rouge/Map/Lobby/MultiLayerCameraRender/BP_MultiLayerCameraRender.BP_MultiLayerCameraRender")
    local MultiLayerCameraActors = UE.UGameplayStatics.GetAllActorsOfClass(self, MultiLayerCameraRenderClass, nil)
    if MultiLayerCameraActors:IsValidIndex(1) then
      self.MultiLayerCameraActor = MultiLayerCameraActors:Get(1)
    end
  end
  if UE.RGUtil.IsUObjectValid(self.MultiLayerCameraActor) and self.DisplayMeshStatus == EDisplayMeshStatus.Role then
    EnterMultiLayerCameraScene(self)
    SetMvpRoleActorTransform(self)
    SetCameraData(self, self.SkinId, CameraMotionIdx)
  else
  end
end
function BP_AppearanceActor_C:UpdateActived(bIsActived, bNotChangeRoleMainHeroVisble, bAutoQuit)
  if bIsActived then
    EventSystem.AddListenerNew(EventDef.Heirloom.MultiLayerCameraBeginPlay, self, self.OnMultiLayerCameraBeginPlay)
    EventSystem.AddListenerNew(EventDef.Heirloom.MultiLayerCameraSkinChanged, self, self.OnMultiLayerCameraSkinChanged)
    if IsMultiLayerCameraMode(self) then
      EnterMultiLayerCameraScene(self)
    end
  else
    EventSystem.RemoveListenerNew(EventDef.Heirloom.MultiLayerCameraBeginPlay, self, self.OnMultiLayerCameraBeginPlay)
    EventSystem.RemoveListenerNew(EventDef.Heirloom.MultiLayerCameraSkinChanged, self, self.OnMultiLayerCameraSkinChanged)
    LeaveMultiLayerCameraScene(self)
  end
  if nil == bAutoQuit then
    bAutoQuit = true
  end
  self.bIsActived = bIsActived
  self:SetHiddenInGame(not bIsActived)
  if not bNotChangeRoleMainHeroVisble then
    LogicRole.ShowOrHideRoleMainHero(not bIsActived)
  end
  if bIsActived then
    self:ChangeToActivedCamera()
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
    CameraTimer = -1
    LogicRole.HideCurSkinLightMap()
  end
end
function BP_AppearanceActor_C:GetTypeId(Widget)
  local Character = Widget:GetOwningPlayerPawn()
  if not Character then
    return -1
  end
  return Character:GetTypeID()
end
function BP_AppearanceActor_C:HideMesh()
  self.ChildActorWeapon:SetHiddenInGame(true)
  self.ChildActor:SetHiddenInGame(true)
  if self.ChildActorProp then
    self.ChildActorProp:SetHiddenInGame(true)
  end
end
function BP_AppearanceActor_C:InitPropByActorPath(ActorPath)
  if not self.ChildActorProp then
    print("BP_AppearanceActor_C:InitPropByActorPath ChildActorProp IsNull")
    return
  end
  self.MultiLayerCameraActor = nil
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
function BP_AppearanceActor_C:RequestToDisableDraggingRole()
  DisableRoleMouseDraggingCounter = DisableRoleMouseDraggingCounter + 1
end
function BP_AppearanceActor_C:RequestToEnableDraggingRole()
  DisableRoleMouseDraggingCounter = DisableRoleMouseDraggingCounter - 1
  if DisableRoleMouseDraggingCounter < 0 then
    DisableRoleMouseDraggingCounter = 0
  end
end
function BP_AppearanceActor_C:ChangeToActivedCamera()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC then
    self:EnableInput(PC)
    PC:SetViewTargetwithBlend(self.ChildActorCamera.ChildActor, 0)
  end
end
function BP_AppearanceActor_C:ChangeTransformByIndex(Index)
  if self.TransformList and self.TransformList:IsValidIndex(Index) then
    local transform = self.TransformList:Get(Index)
    if transform then
      self:K2_SetActorTransform(transform, false, nil, false)
    end
  end
end
function BP_AppearanceActor_C:HideDrawCardShowMatEffect()
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:HideDrawCardShowMatEffect()
  end
end
return BP_AppearanceActor_C
