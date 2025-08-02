local BP_LobbyInputHandle_C = UnLua.Class()

function BP_LobbyInputHandle_C:PlayerForwardMovementInput(Value)
  if not LogicLobby.GetCanMove3DLobby() then
    return
  end
  if UE.UKismetMathLibrary.NearlyEqual_FloatFloat(Value, 0.0) then
    return
  end
  local Pawn = self:GetOwner()
  if not Pawn then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local Rotation = UE.FRotator()
  Rotation.Pitch = 0.0
  Rotation.Yaw = PC:GetControlRotation().Yaw
  Rotation.Roll = 0.0
  Pawn:AddMovementInput(UE.UKismetMathLibrary.GetForwardVector(Rotation), Value)
end

function BP_LobbyInputHandle_C:PlayerRightMovementInput(Value)
  if not LogicLobby.GetCanMove3DLobby() then
    return
  end
  if UE.UKismetMathLibrary.NearlyEqual_FloatFloat(Value, 0.0) then
    return
  end
  local Pawn = self:GetOwner()
  if not Pawn then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local Rotation = UE.FRotator()
  Rotation.Pitch = 0.0
  Rotation.Yaw = PC:GetControlRotation().Yaw
  Rotation.Roll = 0.0
  Pawn:AddMovementInput(UE.UKismetMathLibrary.GetRightVector(Rotation), Value)
end

function BP_LobbyInputHandle_C:PlayerCameraUpInput(Value)
  if not LogicLobby.GetCanMove3DLobby() then
    return
  end
  if UE.UKismetMathLibrary.NearlyEqual_FloatFloat(Value, 0.0) then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  PC:AddPitchInput(Value)
end

function BP_LobbyInputHandle_C:PlayerCameraRightInput(Value)
  if not LogicLobby.GetCanMove3DLobby() then
    return
  end
  if UE.UKismetMathLibrary.NearlyEqual_FloatFloat(Value, 0.0) then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  PC:AddYawInput(Value)
end

function BP_LobbyInputHandle_C:CanControlLobbyInput()
  return LogicLobby.GetCanMove3DLobby()
end

return BP_LobbyInputHandle_C
