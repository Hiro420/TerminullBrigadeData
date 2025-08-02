local WBP_ElecChargeBar_C = UnLua.Class()

function WBP_ElecChargeBar_C:InitInfo(MinValue, MaxValue)
  self.MinValue = MinValue
  self.MaxValue = MaxValue
  self.MainProgressBar:SetPercent(0.0)
end

function WBP_ElecChargeBar_C:UpdateProgressBar(TargetValue)
  local BarValue = math.clamp(TargetValue, self.MinValue, self.MaxValue)
  self.MainProgressBar:SetPercent((BarValue - self.MinValue) / (self.MaxValue - self.MinValue))
end

return WBP_ElecChargeBar_C
