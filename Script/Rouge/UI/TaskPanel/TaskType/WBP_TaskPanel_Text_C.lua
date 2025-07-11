local WBP_TaskPanel_Text_C = UnLua.Class()
function WBP_TaskPanel_Text_C:InitEventPanel(TaskEventConfig, EventId, TaskId)
  self.EventId = EventId
  self.TaskId = TaskId
  self.TaskEventConfig = TaskEventConfig
  SetImageBrushBySoftObjectPath(self.Img_TaskState, TaskEventConfig.EventIcon)
  if self.UpdateTxtTimer then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.UpdateTxtTimer)
  end
  if 11 == TaskId then
    local Txt = TaskEventConfig.EventName
    local hud = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
    self.Txt_TaskName:SetText("")
    if hud and CheckIsVisility(hud) then
      self.Txt_TaskName:SetText(Txt)
    else
      self.UpdateTxtTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        function()
          if UE.RGUtil.IsUObjectValid(self) and Txt and self.UpdateTxtTimer and hud and CheckIsVisility(hud) then
            self.Txt_TaskName:SetText(Txt)
            if self.UpdateTxtTimer and hud and hud then
              UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.UpdateTxtTimer)
            end
          end
        end
      }, 0.5, true)
    end
  else
    self.Txt_TaskName:SetText(TaskEventConfig.EventName)
  end
end
function WBP_TaskPanel_Text_C:UpdateEventPanel(TaskInfo)
  for Index, EventData in ipairs(TaskInfo.Current:ToTable()) do
    if EventData.EventId == self.EventId and self.Status ~= EventData.Status then
      self:SetWidgetStyle(EventData.Status)
      self.Status = EventData.Status
    end
  end
end
function WBP_TaskPanel_Text_C:SetWidgetStyle(Status)
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
return WBP_TaskPanel_Text_C
