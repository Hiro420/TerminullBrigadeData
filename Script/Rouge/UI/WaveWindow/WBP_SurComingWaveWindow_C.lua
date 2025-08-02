local WBP_SurComingWaveWindow_C = UnLua.Class()

function WBP_SurComingWaveWindow_C:InitSurComingWaveWindow(TextShow, Duration)
  self.Duration = Duration + 1
  self.RGTextBlock:SetText(TextShow)
  self:Countdown()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_SurComingWaveWindow_C.Countdown
  }, 1, true)
  self:PlayAnimation(self.Ani_in)
end

function WBP_SurComingWaveWindow_C:Countdown()
  self.Duration = self.Duration - 1
  if self.Duration <= 0 then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
    if UIManager then
      UIManager:HideUIByName("WBP_SurComingWaveWindow_C")
    end
  end
  self.Text_Countdown:SetText(self.Duration)
end

function WBP_SurComingWaveWindow_C:OnUnDisplay()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
end

return WBP_SurComingWaveWindow_C
