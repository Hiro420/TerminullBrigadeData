local WBP_HeynckesQTE_C = UnLua.Class()
function WBP_HeynckesQTE_C:InitQTEWindow(QTEAsset)
  local QTEConfigList = QTEAsset.QTEConfig:ToTable()
  self.TimeLineLength = 0
  for i, v in ipairs(QTEConfigList) do
    self.TimeLineLength = self.TimeLineLength + math.clamp(v.QTEWindowActiveDelayTime, 0, 999) + math.clamp(v.QTEWindowDuration, 0, 999)
  end
  self.CurrentCheckTime = 0
  for i, v in ipairs(QTEConfigList) do
    self.CurrentCheckTime = self.CurrentCheckTime + math.clamp(v.QTEWindowActiveDelayTime, 0, 999)
    local StartPercent = self.CurrentCheckTime / self.TimeLineLength
    local EndPercent = StartPercent + math.clamp(v.QTEWindowDuration, 0, 999) / self.TimeLineLength
    local QTEButtonState = GetOrCreateItem(self.Canvas_Target, i, self.WBP_HeynckesQTEButtonState:GetClass())
    QTEButtonState:Init(StartPercent, EndPercent)
    self.CurrentCheckTime = self.CurrentCheckTime + math.clamp(v.QTEWindowDuration, 0, 999)
  end
  HideOtherItem(self.Canvas_Target, #QTEConfigList + 1)
  self:PlayAnimation(self.Ani_in)
end
function WBP_HeynckesQTE_C:LuaTick(InDeltaTime)
  self.CurrentTime = self.CurrentTime + InDeltaTime
  self.Canvas_Pointer:SetRenderTransformAngle(self.CurrentTime / self.TimeLineLength * 360)
end
function WBP_HeynckesQTE_C:EndQTEWindow(index)
  self.Canvas_Target:GetChildAt(index):QuitQTE()
  if index + 2 == self.Canvas_Target:GetChildrenCount() then
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        self:PlayAnimation(self.Ani_out)
      end
    }, 0.67, false)
  end
  UpdateVisibility(self.Canvas_Clickable, false)
end
function WBP_HeynckesQTE_C:QTETrigger(IsSuccessful, index)
  self.Canvas_Target:GetChildAt(index):ChangeState(IsSuccessful and true or false)
  if IsSuccessful then
    self:PlayAnimation(self.Ani_succeed)
  else
    self:PlayAnimation(self.Ani_fail)
  end
end
function WBP_HeynckesQTE_C:OnQTEWindowActive(index)
  self.Canvas_Target:GetChildAt(index):EnterQTE()
  if index + 1 ~= self.Canvas_Target:GetChildrenCount() then
    UpdateVisibility(self.Canvas_Clickable, true)
  end
end
return WBP_HeynckesQTE_C
