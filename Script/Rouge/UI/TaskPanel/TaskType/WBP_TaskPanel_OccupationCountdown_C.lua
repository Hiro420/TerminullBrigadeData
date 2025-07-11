local WBP_TaskPanel_OccupationCountdown_C = UnLua.Class()
function WBP_TaskPanel_OccupationCountdown_C:InitEventPanel(TaskEventConfig, EventId)
  self.TaskEventConfig = TaskEventConfig
  self.EventId = EventId
  self.LastSec = 0
end
function WBP_TaskPanel_OccupationCountdown_C:UpdateEventPanel(TaskInfo)
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
function WBP_TaskPanel_OccupationCountdown_C:UpdateCountDown(InDeltaTime)
  local secInt = 0
  self.BattleMode = LogicBattleMode.BattleMode
  if self.BattleMode and self.BattleMode:GetCurrentStage() then
    local Duration = self.BattleMode:GetDuration() - self.BattleMode:GetElapsedTime()
    secInt = math.floor(Duration)
  end
  if secInt <= 5 and secInt ~= self.LastSec then
    self:PlayAnimation(self.Ani_CountDown)
  end
  self.LastSec = secInt
  local str = UE.FTextFormat(self.TxtFmt, secInt)
  self.Txt_TaskName:SetText(str)
  print("UpdateCountDown", str)
end
function WBP_TaskPanel_OccupationCountdown_C:LuaTick(InDeltaTime)
  self:UpdateCountDown(InDeltaTime)
end
function WBP_TaskPanel_OccupationCountdown_C:SetWidgetStyle(Status)
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
return WBP_TaskPanel_OccupationCountdown_C
