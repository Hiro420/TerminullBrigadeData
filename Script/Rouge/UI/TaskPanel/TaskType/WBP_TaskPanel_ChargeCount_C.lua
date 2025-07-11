local WBP_TaskPanel_ChargeCount_C = UnLua.Class()
function WBP_TaskPanel_ChargeCount_C:Construct()
  ListenObjectMessage(nil, GMP.MSG_World_BattleStage_Charge_LevelChange, self, self.OnLevelChange)
end
function WBP_TaskPanel_ChargeCount_C:OnLevelChange(Level)
  if Level > 3 then
    return
  end
  self.Txt_Count:SetText(Level)
end
function WBP_TaskPanel_ChargeCount_C:InitEventPanel(TaskEventConfig, EventId, TaskId)
  self.EventId = EventId
  self.TaskId = TaskId
  self.TaskEventConfig = TaskEventConfig
  SetImageBrushBySoftObjectPath(self.Img_TaskState, TaskEventConfig.EventIcon)
  self.Txt_TaskName:SetText(TaskEventConfig.EventName)
  if LogicBattleMode.BattleMode and LogicBattleMode.BattleMode:GetCharge() then
    self:OnLevelChange(LogicBattleMode.BattleMode:GetCharge().CurLevel)
  end
end
function WBP_TaskPanel_ChargeCount_C:UpdateEventPanel(TaskInfo)
  for Index, EventData in ipairs(TaskInfo.Current:ToTable()) do
    if EventData.EventId == self.EventId and self.Status ~= EventData.Status then
      self:SetWidgetStyle(EventData.Status)
      self.Status = EventData.Status
    end
  end
end
function WBP_TaskPanel_ChargeCount_C:SetWidgetStyle(Status)
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
return WBP_TaskPanel_ChargeCount_C
