local WBP_MechanismInfo_C = UnLua.Class()
function WBP_MechanismInfo_C:Construct()
  self.CameraToCharacterDistance = 0
  self:ListenForAttributeChanged(true)
end
function WBP_MechanismInfo_C:SetOwningCharacter(OwningCharacter)
  self.OwningCharacter = OwningCharacter
  self.HealthBar:InitASCInfo(OwningCharacter)
  self:ListenForAttributeChanged(true)
end
function WBP_MechanismInfo_C:UpdateBarInfo(NewValue, OldValue)
  self.HealthBar:UpdateBarInfo(NewValue, OldValue)
end
function WBP_MechanismInfo_C:LuaTick(InDeltaTime)
  local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
  if CameraManager and self.OwningCharacter then
    local CameraLocation = CameraManager:GetCameraLocation()
    local OwnerLocation = self.OwningCharacter:K2_GetActorLocation()
    local Distance = UE.UKismetMathLibrary.Vector_Distance(CameraLocation, OwnerLocation) - self.CameraToCharacterDistance
    self:UpdateBarLength(Distance)
  end
end
function WBP_MechanismInfo_C:UpdateBarLength(Distance)
  local HealthSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.HealthBar)
  local Margin = UE.FMargin()
  Margin.Left = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2
  Margin.Right = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2
  Margin.Bottom = self:CalculateHealthHeightByDistance(Distance)
  HealthSlot:SetOffsets(Margin)
end
function WBP_MechanismInfo_C:CalculateBarLengthByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  return (self.MinLength - self.MaxLength) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + self.MaxLength
end
function WBP_MechanismInfo_C:CalculateHealthHeightByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  return (self.MinBarHeight - self.MaxBarHeight) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + self.MaxBarHeight
end
function WBP_MechanismInfo_C:Destruct(...)
  self:ListenForAttributeChanged(false)
end
return WBP_MechanismInfo_C
