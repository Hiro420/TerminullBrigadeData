local WBP_BattleModeTask_C = UnLua.Class()

function WBP_BattleModeTask_C:Construct()
  EventSystem.AddListener(self, EventDef.HUD.ChangeTaskTip, WBP_BattleModeTask_C.ShowTip)
end

function WBP_BattleModeTask_C:LuaTick(InDeltaTime)
  self:HappyJumpRefreshCountDown()
end

function WBP_BattleModeTask_C:OnInit()
  self:Reset()
end

function WBP_BattleModeTask_C:OnAnimationFinished(Animation)
  if Animation == self.CountDownFadeoutAni then
    UpdateVisibility(self.CanvasPanelCountDown, false)
  end
end

function WBP_BattleModeTask_C:OnDeInit()
  self:Reset()
end

function WBP_BattleModeTask_C:InitById(Id, GameStage)
  self.ModeId = Id
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local Result, BattleModeRowInfo = DTSubsystem:GetBattleModeRowInfoById(Id, nil)
    if Result and BattleModeRowInfo.BattleTaskTips:Find(GameStage) then
      self:Init(BattleModeRowInfo.BattleTaskTips:Find(GameStage))
    end
  end
end

function WBP_BattleModeTask_C:ShowTip(bShow, bFromMainTask)
  print("WBP_BattleModeTask_Cm", bShow)
  if bShow then
    self:PlayAnimation(self.CountDownShowAni, 0, 1, UE.EUMGSequencePlayMode.Forward)
    return
  else
    self:Reset()
    if bFromMainTask then
      self:PlayAnimation(self.CountDownFinishedAni)
    else
      self:PlayAnimation(self.CountDownFadeoutAni)
    end
  end
end

function WBP_BattleModeTask_C:HappyJumpRefreshCountDown()
  if self.ModeId == nil then
    return
  end
  local Result, Info = GetRowData(DT.DT_BattleMode, self.ModeId)
  if not Result or not Info.bBattleMode then
    return
  end
  if self.CurGameStage == UE.EBattleModeStage.BeginAssemblyStage then
    local Time = LogicBattleMode:GetDuration(LogicBattleMode.BattleModeStage.Assembly)
    self:RefreshCountdown(Time, true)
  elseif self.CurGameStage == UE.EBattleModeStage.BeginChallengeStage then
    local Time = LogicBattleMode:GetDuration(LogicBattleMode.BattleModeStage.Challenge)
    self:RefreshCountdown(Time, false)
  end
end

function WBP_BattleModeTask_C:OccupancyRefreshCountDown(CountDown)
  if self.ModeId ~= 1000 then
    return
  end
  self:RefreshCountdown(tonumber(CountDown), true)
end

function WBP_BattleModeTask_C:QianLongCountDown(LiftTime, BeginTimestamp, FinishFunc)
  if self.ModeId ~= 1003 then
    return
  end
  local CountDown = LiftTime
  if self.QianLongTimer then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.QianLongTimer)
  end
  self.QianLongTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      CountDown = LiftTime - GetCurrentTimestamp(false) + BeginTimestamp
      self:RefreshCountdown(CountDown, true)
      if CountDown <= 0 then
        FinishFunc()
      end
    end
  }, 0.02, true)
end

function WBP_BattleModeTask_C:RefreshCountdown(CountDown, bShowWarningAnim)
  if bShowWarningAnim then
    if nil ~= CountDown and CountDown <= 5 and not self.Warning then
      self.Warning = true
      self:PlayAnimation(self.CountDownFlushAni, 0, 0)
    else
    end
    if nil ~= CountDown and CountDown <= 0 then
      self.Warning = false
    end
  else
    self:StopAnimation(self.CountDownFlushAni)
  end
  if type(CountDown) == "number" then
    CountDown = math.floor(CountDown)
  end
  self.RgTextChallengeCountDown:SetText(CountDown)
end

function WBP_BattleModeTask_C:BeginAssembly()
  self.CurGameStage = UE.EBattleModeStage.BeginAssemblyStage
  self:InitById(self.ModeId, self.CurGameStage)
end

function WBP_BattleModeTask_C:EndAssembly()
  self.CurGameStage = UE.EBattleModeStage.EndAssemblyStage
  self:InitById(self.ModeId, self.CurGameStage)
end

function WBP_BattleModeTask_C:BeginChanllenge()
  self.CurGameStage = UE.EBattleModeStage.BeginChallengeStage
  self:InitById(self.ModeId, self.CurGameStage)
end

function WBP_BattleModeTask_C:EndChallenge()
  self.CurGameStage = UE.EBattleModeStage.EndChallengeStage
  self:InitById(self.ModeId, self.CurGameStage)
end

function WBP_BattleModeTask_C:ShowSuccess()
  self.CurGameStage = UE.EBattleModeStage.SuccessStage
  self:InitById(self.ModeId, self.CurGameStage)
end

function WBP_BattleModeTask_C:ShowFailed()
  self.CurGameStage = UE.EBattleModeStage.FailedStage
  self:InitById(self.ModeId, self.CurGameStage)
end

function WBP_BattleModeTask_C:OccupancyShutdown()
end

function WBP_BattleModeTask_C:Reset()
  self.CurGameStage = UE.EBattleModeStage.None
  self.ModeId = 0
  self.Warning = false
  if self.QianLongTimer then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.QianLongTimer)
    self.QianLongTimer = nil
  end
end

return WBP_BattleModeTask_C
