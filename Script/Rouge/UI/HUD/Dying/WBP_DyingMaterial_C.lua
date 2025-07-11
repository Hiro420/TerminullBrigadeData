local WBP_DyingMaterial_C = UnLua.Class()
function WBP_DyingMaterial_C:PreConstruct(IsDesignTime)
  self.BarName = "percent"
  if self.ShowInsideOpacity then
    self:SetScalarParameterValue("InsideOpacity", 1)
  end
  if self.ShowOutLineOpacity then
    self:SetScalarParameterValue("OutLineOpacity", 1)
  end
  self:SetScalarParameterValue(self.BarName, 0)
end
function WBP_DyingMaterial_C:Construct()
  self.Ratio = 0
  self.Rescue = false
  ListenObjectMessage(nil, GMP.MSG_World_OnRescueRatioChange, self, self.OnRescueRatioChange)
  self.SizeBox_Rescue:SetWidthOverride(self.InWidthOverride)
  self.SizeBox_Rescue:SetHeightOverride(self.InHeightOverride)
end
function WBP_DyingMaterial_C:LuaTick(InDeltaTime)
  if self.Rescue then
    self:SetScalarParameterValue(self.BarName, UE.UKismetMathLibrary.FInterpTo(self:GetScalarParameterValue(self.BarName), self.Ratio, InDeltaTime, 10))
  end
end
function WBP_DyingMaterial_C:Destruct()
  UnListenObjectMessage(GMP.MSG_World_OnRescueRatioChange)
end
function WBP_DyingMaterial_C:OnRescueRatioChange(Character, Ratio)
  if Character == self.Target then
    if Ratio > self.Ratio then
      self.OnRescueRatioChangeEvent:Broadcast(true, Ratio)
      self.Rescue = true
    else
      self.OnRescueRatioChangeEvent:Broadcast(false, Ratio)
      self.Rescue = false
    end
    self.Ratio = Ratio
    self:SetScalarParameterValue(self.BarName, self.Ratio)
  end
end
function WBP_DyingMaterial_C:SetScalarParameterValue(ParameterName, Value)
  local material = self.Image_Rescue:GetDynamicMaterial()
  if material and material:IsValid() then
    material:SetScalarParameterValue(ParameterName, Value)
  end
end
function WBP_DyingMaterial_C:GetScalarParameterValue(ParameterName)
  local material = self.Image_Rescue:GetDynamicMaterial()
  if material and material:IsValid() then
    return material:K2_GetScalarParameterValue(ParameterName)
  end
end
return WBP_DyingMaterial_C
