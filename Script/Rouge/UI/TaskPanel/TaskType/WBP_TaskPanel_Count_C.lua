local funcutil = require("Framework.Utils.FuncUtil")
local WBP_TaskPanel_Countl_C = UnLua.Class()
function WBP_TaskPanel_Countl_C:InitEventPanel(TaskEventConfig, EventId, TaskId)
  self.EventId = EventId
  self.TaskId = TaskId
  self.TaskEventConfig = TaskEventConfig
  SetImageBrushBySoftObjectPath(self.Img_TaskState, TaskEventConfig.EventIcon)
  SetImageBrushBySoftObjectPath(self.Img_TaskIcon, TaskEventConfig.AnnexIcon)
  self.Txt_TaskName:SetText(TaskEventConfig.EventName)
  UpdateVisibility(self, true)
end
function WBP_TaskPanel_Countl_C:UpdateEventPanel(TaskInfo)
  if TaskInfo.bIsCustomTask then
  else
    local bHaveConfig = false
    for Index, EventData in ipairs(TaskInfo.Current:ToTable()) do
      if EventData.EventId == self.EventId then
        print(EventData.Value)
        local CurValue = EventData.Value
        local TargetValue = self:GetEventTargetValue()
        self.Txt_Count:SetText(CurValue .. "/" .. TargetValue)
        if self.Status ~= EventData.Status then
          self:SetWidgetStyle(EventData.Status)
          self.Status = EventData.Status
        end
        bHaveConfig = true
      end
    end
    if not bHaveConfig then
      self:RemoveFromParent()
    end
  end
end
function WBP_TaskPanel_Countl_C:GetEventTargetValue()
  local Result, Row = GetRowData(DT.DT_ActionEventGameplayTask, self.TaskId)
  if not Result then
    return -1
  end
  for key, value in pairs(Row.Conditions:ToTable()) do
    if value.EventId == self.EventId then
      return value.Target
    end
  end
  return -1
end
function WBP_TaskPanel_Countl_C:SetWidgetStyle(Status)
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
return WBP_TaskPanel_Countl_C
