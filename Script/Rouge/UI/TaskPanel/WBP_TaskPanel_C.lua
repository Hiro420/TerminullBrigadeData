local WBP_TaskPanel_C = UnLua.Class()

function WBP_TaskPanel_C:Construct()
  self.HaveTask = false
  ListenObjectMessage(nil, GMP.MSG_TaskSystem_UpdateTask_FromHall, self, self.UpdateTaskInfoByHall)
  ListenObjectMessage(nil, GMP.MSG_TaskSystem_UpdateTask_FromGameplay, self, self.UpdateTaskInfoByGameplay)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.FoldList, nil)
  EventSystem.AddListenerNew(EventDef.Task.UpdateCustomTask, self, self.OnUpdateCustomTask)
  self.CurTaskPanel = {}
  self.bFold = false
  self.TaskList:ClearChildren()
  local PC = self:GetOwningPlayer()
  if PC and PC.MiscHelper then
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        if PC and PC.MiscHelper then
          PC.MiscHelper:ServerRequestFullActionEventTask_Hall()
        end
      end
    }, 3.1, false)
  end
end

function WBP_TaskPanel_C:Destruct()
  LogicTaskPanel.ClearUp()
  EventSystem.RemoveListenerNew(EventDef.Task.UpdateCustomTask, self, self.OnUpdateCustomTask)
end

function WBP_TaskPanel_C:FoldList()
  if not self.HaveTask then
    return
  end
  if self.bFold then
    self:PlayAnimation(self.Ani_unfold)
  else
    self:PlayAnimation(self.Ani_PackUp)
  end
  self.bFold = not self.bFold
end

function WBP_TaskPanel_C:UpdateTaskInfoByHall(SyncData)
  self:UpdateTaskInfo(SyncData.Tasks, true)
end

function WBP_TaskPanel_C:UpdateTaskInfoByGameplay(SyncData)
  self:UpdateTaskInfo(SyncData.Tasks, false)
end

function WBP_TaskPanel_C:UpdateTaskInfo(TaskInfo, bHall)
  LogicTaskPanel.UpdateDifferenceData(TaskInfo:ToTable(), bHall)
  if not UE.RGUtil.IsUObjectValid(self) then
    return
  end
  self:UpdateTaskPanel()
  self.WBP_TaskPanel_Fold.Text_TitleCount:SetText(self:GetTaskNum())
end

function WBP_TaskPanel_C:OnUpdateCustomTask()
  self:UpdateTaskPanel()
  self.WBP_TaskPanel_Fold.Text_TitleCount:SetText(self:GetTaskNum())
end

function WBP_TaskPanel_C:UpdateTaskPanel()
  for index, TaskValue in ipairs(LogicTaskPanel.TaskInfo) do
    local ItemPanel = self.CurTaskPanel[TaskValue.EventId]
    local bAdd = false
    if ItemPanel then
      ItemPanel:UpdateInfo(TaskValue)
    else
      ItemPanel = UE.UWidgetBlueprintLibrary.Create(self, self.ItemClass)
      ItemPanel:UpdateInfo(TaskValue)
      local OverlayWidget = NewObject(self.OverlayWidget:GetClass(), self, nil)
      self.TaskList:AddChild(OverlayWidget)
      self.CurTaskPanel[TaskValue.EventId] = ItemPanel
      bAdd = true
      self.WBP_TaskPanel_Fold:PlayAnimation(self.WBP_TaskPanel_Fold.Ani_add)
    end
  end
  local Idx = 1
  for TaskId, TaskValue in pairs(LogicTaskPanel.TaskInfo) do
    if self.CurTaskPanel[TaskId] and not self.CurTaskPanel[TaskId].GoneForever then
      local OverlayWidget = GetOrCreateItem(self.TaskList, Idx, nil)
      OverlayWidget:AddChild(self.CurTaskPanel[TaskId])
      UpdateVisibility(OverlayWidget, true)
      Idx = Idx + 1
    end
  end
  HideOtherItem(self.TaskList, Idx, true)
  self.HaveTask = self:GetTaskNum() > 1
  UpdateVisibility(self.WBP_InteractTipWidget, self.HaveTask)
end

function WBP_TaskPanel_C:GetTaskNum()
  local Index = 0
  for TaskId, TaskValue in pairs(LogicTaskPanel.TaskInfo) do
    if TaskValue.Status == UE.ERGActionEventTaskStatus.Running then
      Index = Index + 1
    end
  end
  return Index
end

return WBP_TaskPanel_C
