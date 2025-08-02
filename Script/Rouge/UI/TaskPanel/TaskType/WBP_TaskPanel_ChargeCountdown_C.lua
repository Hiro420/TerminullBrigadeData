local WBP_TaskPanel_ChargeCountdown_C = UnLua.Class()

function WBP_TaskPanel_ChargeCountdown_C:InitEventPanel(TaskEventConfig, EventId)
  self.TaskEventConfig = TaskEventConfig
  self.EventId = EventId
  self.LastSec = 0
  if LogicBattleMode.BattleMode and LogicBattleMode.BattleMode.StageArray and LogicBattleMode.BattleMode.StageArray:IsValidIndex(5) then
    self.ChallengeStage = LogicBattleMode.BattleMode.StageArray:Get(5)
    print("WBP_TaskPanel_ChargeCountdown_C", ChallengeStage)
  end
end

function WBP_TaskPanel_ChargeCountdown_C:UpdateEventPanel(TaskInfo)
  for Index, EventData in ipairs(TaskInfo.Current:ToTable()) do
    if EventData.EventId == self.EventId then
      if self.Status ~= EventData.Status then
        self:SetWidgetStyle(EventData.Status)
        self.Status = EventData.Status
      end
      return
    end
  end
end

function WBP_TaskPanel_ChargeCountdown_C:UpdateCountDown(InDeltaTime)
  if not self.ChallengeStage then
    return
  end
  if self.ChallengeStage:GetTotalProgress() <= self.ChallengeStage:GetElapsedProgress() then
  end
  local secInt = math.floor(self.ChallengeStage:GetTotalProgress() - self.ChallengeStage:GetElapsedProgress())
  if secInt <= 5 and secInt ~= self.LastSec then
    self:PlayAnimation(self.Ani_CountDown)
  end
  self.LastSec = secInt
  local str = UE.FTextFormat(self.TxtFmt, secInt)
  self.Txt_Countdown:SetText(str)
end

function WBP_TaskPanel_ChargeCountdown_C:LuaTick(InDeltaTime)
  self:UpdateCountDown(InDeltaTime)
end

function WBP_TaskPanel_ChargeCountdown_C:SetWidgetStyle(Status)
  UpdateVisibility(self.Img_TaskCompleted, Status == UE.ERGActionEvent_TaskConditionStatus.Meet)
  if Status == UE.ERGActionEvent_TaskConditionStatus.Meet then
    self:PlayAnimation(self.Ani_accomplish)
    SetImageBrushBySoftObjectPath(self.Img_TaskState, self.TaskEventConfig.EventFinishIcon)
  elseif Status == UE.ERGActionEvent_TaskConditionStatus.NotMeet then
    SetImageBrushBySoftObjectPath(self.Img_TaskState, self.TaskEventConfig.EventIcon)
  else
    SetImageBrushBySoftObjectPath(self.Img_TaskState, self.TaskEventConfig.EventErrorIcon)
  end
end

return WBP_TaskPanel_ChargeCountdown_C
