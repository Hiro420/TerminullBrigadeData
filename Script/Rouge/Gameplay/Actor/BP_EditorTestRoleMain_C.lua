local BP_EditorTestRoleMain_C = UnLua.Class()
function BP_EditorTestRoleMain_C:ReceiveBeginPlay()
  if UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  if not UE.URGBlueprintLibrary.CheckWithEditor() then
    return
  end
  if UE.UGameplayStatics.GetCurrentLevelName(self) == "Lobby" then
    return
  end
  local Controller = UE.UGameplayStatics.GetPlayerController(self, 0):Cast(UE.ARGPlayerController)
  if Controller then
    return
  end
  local CameraActorList = UE.UGameplayStatics.GetAllActorsWithTag(self, "RoleMainCamera", nil)
  local TargetCamera
  for key, SingleCamera in pairs(CameraActorList) do
    TargetCamera = SingleCamera
    break
  end
  if TargetCamera then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    PC:SetViewTargetWithBlend(TargetCamera)
    if self.IsUseConfigCameraPos then
      local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
      if DTSubsystem then
        local RoleCameraInfo = DTSubsystem:GetCameraLobbyInfoByName("Role")
        TargetCamera:K2_SetActorTransform(RoleCameraInfo.CameraTransform)
        TargetCamera.CameraComponent:SetFieldOfView(RoleCameraInfo.CameraFOV)
      end
    end
  end
  local RoleMainClassObj = UE.UClass.Load("/Game/Rouge/UI/Lobby/WBP_RoleMain.WBP_RoleMain_C")
  local RoleMainWidget = UE.UWidgetBlueprintLibrary.Create(self, RoleMainClassObj)
  RoleMainWidget:EditorMapShow()
  RoleMainWidget:AddToViewport(0)
  LogicRole.EditorChangeHeroLight(self.LightName)
  local RoleActorList = UE.UGameplayStatics.GetAllActorsWithTag(self, "RoleMainHero", nil)
  for i, SingleRoleActor in pairs(RoleActorList) do
    self.TargetRoleActor = SingleRoleActor
    break
  end
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      self.TargetRoleActor:EnableInputActor(true)
      if self.TargetRoleActor then
        local CharacterRow = LogicRole.GetCharacterTableRow(self.HeroId)
        if CharacterRow then
          self.TargetRoleActor.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
        end
        self.TargetRoleActor:ChangeBodyMesh(self.HeroId)
        self.TargetRoleActor:ChangeChildActorDefaultRotation(self.HeroId)
        self.TargetRoleActor:ChangeWeaponMeshById(self.WeaponId)
      end
    end
  }, 0.2, false)
end
return BP_EditorTestRoleMain_C
