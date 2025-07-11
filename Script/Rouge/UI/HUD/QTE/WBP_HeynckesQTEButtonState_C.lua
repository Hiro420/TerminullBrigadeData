local WBP_HeynckesQTEButtonState_C = UnLua.Class()
function WBP_HeynckesQTEButtonState_C:Init(StartPercent, EndPercent)
  local DynamicMaterial = self.Img_Target:GetDynamicMaterial()
  if DynamicMaterial then
    DynamicMaterial:SetScalarParameterValue("percent", EndPercent - StartPercent)
  end
  self.Img_Target:SetRenderTransformAngle(StartPercent * 360)
end
function WBP_HeynckesQTEButtonState_C:EnterQTE()
  self.RGStateController:ChangeStatus("Enter")
end
function WBP_HeynckesQTEButtonState_C:ChangeState(IsSuccessful)
  self.RGStateController:ChangeStatus(IsSuccessful and "Success" or "Fail")
end
function WBP_HeynckesQTEButtonState_C:QuitQTE()
  self.RGStateController:ChangeStatus("Normal")
end
return WBP_HeynckesQTEButtonState_C
