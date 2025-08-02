local WBP_DataTurbulenceDeliverCdBombInfo_C = UnLua.Class()

function WBP_DataTurbulenceDeliverCdBombInfo_C:SetOwningBomb(OwningBomb)
  self.OwningBomb = OwningBomb
  self:InitWidget()
end

function WBP_DataTurbulenceDeliverCdBombInfo_C:InitWidget()
  if self.OwningBomb then
    self.CountdownTime = self.OwningBomb:GetDeliverCdTime()
    print(self.CountdownTime)
    print("---------------------------------------------")
  end
  self.txt_Countdown:SetVisibility(UE.ESlateVisibility.Visible)
  self.txt_Countdown:SetText(math.ceil(self.CountdownTime))
  self.huoxing:SetVisibility(UE.ESlateVisibility.Hidden)
  self.image_glow:SetVisibility(UE.ESlateVisibility.Hidden)
  self.line_di_1:SetVisibility(UE.ESlateVisibility.Hidden)
  local fColor = UE4.FLinearColor(0, 0, 0, 1.0)
  local fColor2 = UE4.FLinearColor(0.212231, 0.212231, 0.212231, 1)
  self.image_touyin:SetColorAndOpacity(fColor)
  self.image_di:SetColorAndOpacity(fColor2)
  local Mat = self.image_touyin:GetDynamicMaterial()
  if Mat then
    Mat:SetScalarParameterValue("scale_speed", 0.0)
  end
  local Mat2 = self.image_di:GetDynamicMaterial()
  if Mat2 then
    Mat2:SetScalarParameterValue("scale_speed", 0.0)
  end
end

local MappedRangeValueClamped = function(Value, InMin, InMax, OutMin, OutMax)
  if InMin == InMax then
    error("Input range is invalid (InMin should not be equal to InMax)")
  end
  local normalized = (Value - InMin) / (InMax - InMin)
  local mappedValue = OutMin + (OutMax - OutMin) * normalized
  return math.clamp(mappedValue, OutMin, OutMax)
end

function WBP_DataTurbulenceDeliverCdBombInfo_C:UpdateWidgetPosition()
  local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
  if CameraManager and self.OwningBomb then
    local CameraLocation = CameraManager:GetCameraLocation()
    local OwnerLocation = self.OwningBomb:K2_GetActorLocation()
    local Distance = UE.UKismetMathLibrary.Vector_Distance(CameraLocation, OwnerLocation)
    local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
    local ScaleFactor = MappedRangeValueClamped(TargetDistance, self.MaxDistance, self.MinDistance, self.MinScale, self.MaxScale)
    self:SetRenderScale(UE.FVector2D(ScaleFactor, ScaleFactor))
  end
end

function WBP_DataTurbulenceDeliverCdBombInfo_C:LuaTick(InDeltaTime)
  self:UpdateWidgetPosition()
  if self.OwningBomb then
    self.CountdownTime = self.CountdownTime - InDeltaTime
    if self.CountdownTime < 0 then
      return
    end
    self.txt_Countdown:SetVisibility(UE.ESlateVisibility.Visible)
    self.txt_Countdown:SetText(math.ceil(self.CountdownTime))
  end
end

return WBP_DataTurbulenceDeliverCdBombInfo_C
