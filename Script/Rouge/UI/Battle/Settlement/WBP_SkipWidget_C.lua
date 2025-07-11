local WBP_SkipWidget_C = UnLua.Class()
local Frequency = 0.05
local MatParamValue = "percent"
function WBP_SkipWidget_C:Construct()
end
function WBP_SkipWidget_C:Init(CountDownTime, FinishCallback, FinishCallbackObj)
  if self.TeamTimer and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TeamTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TeamTimer)
  end
  if self.TeamTimerCircle and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TeamTimerCircle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TeamTimerCircle)
  end
  self.TeamTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_SkipWidget_C.UpdateCountDown
  }, 1, true)
  self.TeamTimerCircle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_SkipWidget_C.UpdateCountDownCircle
  }, Frequency, true)
  self.CountDownTime = CountDownTime
  self.FinishCallback = FinishCallback
  self.FinishCallbackObj = FinishCallbackObj
  self.Timer = 0
  self.Increment = Frequency / self.CountDownTime
  local CountDownTimeStr = string.format("%02dS", self.CountDownTime)
  self.RGTextCountdown:SetText(CountDownTimeStr)
  local Mat = self.URGImageCircle:GetDynamicMaterial()
  if Mat then
    Mat:SetScalarParameterValue(MatParamValue, 0)
  end
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.OnJumpClick)
end
function WBP_SkipWidget_C:OnJumpClick()
  if self.FinishCallback and self.FinishCallbackObj then
    self.FinishCallback(self.FinishCallbackObj)
  end
end
function WBP_SkipWidget_C:UpdateCountDown()
  self.CountDownTime = self.CountDownTime - 1
  local CountDownTimeStr = string.format("%02dS", self.CountDownTime)
  self.RGTextCountdown:SetText(CountDownTimeStr)
  if self.CountDownTime <= 0 then
    self.FinishCallback(self.FinishCallbackObj)
  end
end
function WBP_SkipWidget_C:UpdateCountDownCircle()
  self.Timer = self.Timer + Frequency
  local Mat = self.URGImageCircle:GetDynamicMaterial()
  if Mat then
    local PercentValue = Mat:K2_GetScalarParameterValue(MatParamValue) + self.Increment
    Mat:SetScalarParameterValue(MatParamValue, PercentValue)
  end
end
function WBP_SkipWidget_C:Reset()
  if self.TeamTimer and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TeamTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TeamTimer)
  end
  if self.TeamTimerCircle and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TeamTimerCircle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TeamTimerCircle)
  end
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.OnJumpClick)
  self.TeamTimer = nil
  self.TeamTimerCircle = nil
  self.CountDownTime = 0
  self.FinishCallback = nil
  self.FinishCallbackObj = nil
end
function WBP_SkipWidget_C:Destruct()
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.OnJumpClick)
end
return WBP_SkipWidget_C
