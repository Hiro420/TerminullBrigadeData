local WBP_TaskPanel_Seek_Count_C = UnLua.Class()

function WBP_TaskPanel_Seek_Count_C:InitEventPanel(TaskEventConfig, EventId, TaskId)
  self.EventId = EventId
  self.TaskId = TaskId
  self.TaskEventConfig = TaskEventConfig
  SetImageBrushBySoftObjectPath(self.Img_TaskState, TaskEventConfig.EventIcon)
  SetImageBrushBySoftObjectPath(self.Img_TaskIcon, TaskEventConfig.AnnexIcon)
  self.Txt_TaskName:SetText(TaskEventConfig.EventName)
  UpdateVisibility(self, true)
  self:InitSeekProgress()
  ListenObjectMessage(nil, GMP.MSG_UI_HUD_BattleMode_OnSeekCaveDestoryCountChange, self, self.BindOnUpdateTaskProgress)
end

function WBP_TaskPanel_Seek_Count_C:InitSeekProgress()
  local BattleActorClass = UE.ARGSweepBattleActor:StaticClass()
  local BattleActorList = UE.UGameplayStatics.GetAllActorsOfClass(self, BattleActorClass, nil)
  for i, v in iterator(BattleActorList) do
    if UE.RGUtil.IsUObjectValid(v) then
      local CurrentDestoryCount = v:GetCurrentDestoryCount()
      local TotalDestoryCount = v:GetTotalDestoryCount()
      self:BindOnUpdateTaskProgress(nil, CurrentDestoryCount, TotalDestoryCount)
      break
    end
  end
end

function WBP_TaskPanel_Seek_Count_C:UpdateEventPanel(TaskInfo)
  if TaskInfo.bIsCustomTask then
  else
    local bHaveConfig = false
    for Index, EventData in ipairs(TaskInfo.Current:ToTable()) do
      if EventData.EventId == self.EventId then
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

function WBP_TaskPanel_Seek_Count_C:BindOnUpdateTaskProgress(Instigator, CurrentValue, TargetValue)
  local CurValue = CurrentValue
  local TargetValue = TargetValue
  self.Txt_Count:SetText(CurValue .. "/" .. TargetValue)
end

function WBP_TaskPanel_Seek_Count_C:SetWidgetStyle(Status)
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

return WBP_TaskPanel_Seek_Count_C
