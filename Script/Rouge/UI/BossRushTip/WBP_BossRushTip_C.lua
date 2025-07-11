local WBP_BossRushTip_C = UnLua.Class()
function WBP_BossRushTip_C:InitBossRushTip(stage)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  if stage == UE.ERGBossRushMechanicsType.None then
    self:HideUI()
  end
  local ShowTip = ""
  ShowTip = self.ERGBossRushMechanicsString[stage + 1]
  self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_BossRushTip_C.HideUI
  }, self.MaxShowLength, false)
  self:PlayAnimation(self.Ani_Ready_in)
  self.RGTextBlock:SetText(ShowTip)
end
function WBP_BossRushTip_C:HideUI()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:HideUIByName("WBP_BossRushTip_C")
  end
end
function WBP_BossRushTip_C:OnUnDisplay()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
end
return WBP_BossRushTip_C
