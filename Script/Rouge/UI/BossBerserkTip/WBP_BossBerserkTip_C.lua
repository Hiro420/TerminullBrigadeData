local WBP_BossBerserkTip_C = UnLua.Class()
function WBP_BossBerserkTip_C:InitBossBerserkTip(Boss, BerserkState, StartTimestamp)
  self.BossIns = Boss
  self.BerserkState = BerserkState
  self.StartTimestamp = StartTimestamp
  self.Duration = self.StartTimestamp - os.time()
  if Boss and Boss:IsBossAI() then
    self.StateController:ChangeStatus("Boss", true)
  else
    self.StateController:ChangeStatus("NotBoss", true)
  end
  UpdateVisibility(self.Overlay_Ready, 1 == self.BerserkState)
  UpdateVisibility(self.Overlay_Berserk, 2 == self.BerserkState)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  if self.BerserkState == UE.EBossBerserkStateType.Ready then
    self:Countdown()
    self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      WBP_BossBerserkTip_C.Countdown
    }, 1, true)
    self:PlayAnimation(self.Ani_Ready_in)
  else
    if self.BossIns then
      EventSystem.Invoke(EventDef.BossTips.BossBerserk, Boss)
    end
    self:PlayAnimation(self.Ani_Berserk_in)
  end
  if self.BossIns then
    UnListenObjectMessage(GMP.MSG_Pawn_OnDeath)
    ListenObjectMessage(self.BossIns, GMP.MSG_Pawn_OnDeath, self, self.BindBossDeath)
  end
end
function WBP_BossBerserkTip_C:Countdown()
  self.Duration = self.Duration - 1
  if self.Duration < 0 then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
    if UIManager then
      UIManager:HideUIByName("WBP_BossBerserkTip_C")
    end
  end
  self.Text_Countdown:SetText(string.format(self.CountdownString, self.Duration, "%"))
end
function WBP_BossBerserkTip_C:BindBossDeath()
  self.BossIns = nil
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:HideUIByName("WBP_BossBerserkTip_C")
  end
end
function WBP_BossBerserkTip_C:OnUnDisplay(bIsPlaySound)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
  end
end
return WBP_BossBerserkTip_C
