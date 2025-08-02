local BP_RGCameraGun_C = UnLua.Class()

function BP_RGCameraGun_C:ReceiveBeginPlay()
  self.CameraInitialTransform = self.CameraActor:GetRelativeTransform()
  self.GunCenterInitialTransform = self.CenterScene:GetRelativeTransform()
  self.GunInitialTransform = self.SKM_Basics:GetRelativeTransform()
  self.CameraComponent = self.CameraActor.ChildActor.CameraComponent
end

function BP_RGCameraGun_C:UpdateInitRGCameraGunTransform()
  local cameraWeaponConfig = UE.FCameraWeapon()
  cameraWeaponConfig.WeaponRelativeTransform = self.GunCenterInitialTransform
  cameraWeaponConfig.CameraRelativeTransform = self.CameraInitialTransform
  cameraWeaponConfig.WeaponAnchorOffset = self.GunInitialTransform
  cameraWeaponConfig.CameraFOV = 90
  self:UpdateRGCameraGunTransformByConfig(cameraWeaponConfig)
end

function BP_RGCameraGun_C:UpdateRGCameraGunTransformByConfig(HasBarrel, CameraWeaponConfig)
  if HasBarrel then
    self:UpdateRGCameraGunTransform(CameraWeaponConfig.CameraWeaponWithBarrel)
  else
    self:UpdateRGCameraGunTransform(CameraWeaponConfig.CameraWeaponNoBarrel)
  end
end

function BP_RGCameraGun_C:UpdateRGCameraGunTransform(CameraWeapon)
  self.CenterScene:K2_SetRelativeTransform(CameraWeapon.WeaponRelativeTransform, false, nil, false)
  self.CameraActor:K2_SetRelativeTransform(CameraWeapon.CameraRelativeTransform, false, nil, false)
  self.SKM_Basics:K2_SetRelativeTransform(CameraWeapon.WeaponAnchorOffset, false, nil, false)
  self.CameraComponent:SetFieldOfView(CameraWeapon.CameraFOV)
end

return BP_RGCameraGun_C
