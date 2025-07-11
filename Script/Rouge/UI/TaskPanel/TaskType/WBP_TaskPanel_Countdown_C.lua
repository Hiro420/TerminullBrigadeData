local WBP_TaskPanel_Countdown_C = UnLua.Class()
function WBP_TaskPanel_Countdown_C:InitEventPanel(TaskEventConfig, EventId)
  self.TaskEventConfig = TaskEventConfig
  self.EventId = EventId
  self.LastSec = 0
end
function WBP_TaskPanel_Countdown_C:UpdateEventPanel(TaskInfo)
  self.TimeOffUTCStamp = nil
  if TaskInfo.bIsCustomTask then
    self.TimeOffUTCStamp = TaskInfo.TimeOffUTCStamp
    self:UpdateCountDown(0)
  else
    for Index, EventData in ipairs(TaskInfo.Current:ToTable()) do
      if EventData.EventId == self.EventId then
        self.TimeOffUTCStamp = EventData.ExpireTimeSeconds
        print("WBP_TaskPanel_Countdown_C", EventData.ExpireTimeSeconds)
        self:UpdateCountDown(0)
        if self.Status ~= EventData.Status then
          self:SetWidgetStyle(EventData.Status)
          self.Status = EventData.Status
        end
        return
      end
    end
  end
end
function WBP_TaskPanel_Countdown_C:UpdateCountDown(InDeltaTime)
  if self.TimeOffUTCStamp then
    local curtime = GetCurrentTimestamp(true)
    local sec = self.TimeOffUTCStamp - curtime
    if sec <= 0 then
      local str = UE.FTextFormat(self.TxtFmt, 0)
      self.Txt_Countdown:SetText(str)
      self.TimeOffUTCStamp = nil
    else
      local secInt = math.floor(sec)
      if secInt <= 5 and secInt ~= self.LastSec then
        self:PlayAnimation(self.Ani_CountDown)
      end
      self.LastSec = secInt
      local str = UE.FTextFormat(self.TxtFmt, secInt)
      self.Txt_Countdown:SetText(str)
    end
  end
end
function WBP_TaskPanel_Countdown_C:LuaTick(InDeltaTime)
  self:UpdateCountDown(InDeltaTime)
end
function WBP_TaskPanel_Countdown_C:SetWidgetStyle(Status)
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
return WBP_TaskPanel_Countdown_C
