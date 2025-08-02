local WBP_TarosQTime_C = UnLua.Class()

function WBP_TarosQTime_C:Construct()
  self.CurrentTime = self.FullTime
end

function WBP_TarosQTime_C:GetProgressPercent()
  local CurWorldSeconds = UE.UGameplayStatics.GetWorldDeltaSeconds(self)
  self.CurrentTime = math.clamp(self.CurrentTime - CurWorldSeconds, 0.0, 100.0)
  local TargetPercent = 0 ~= self.FullTime and self.CurrentTime / self.FullTime or 0.0
  if TargetPercent <= 0 then
    self:Remove()
  end
  return TargetPercent
end

function WBP_TarosQTime_C:GetRemainTimeText()
  return UE.UKismetTextLibrary.Conv_FloatToText(self.CurrentTime, UE.ERoundingMode.HalfToEven, false, true, 1, 324, 1, 1)
end

return WBP_TarosQTime_C
