local WBP_MainTaskItem_C = UnLua.Class()
function WBP_MainTaskItem_C:GotoMainTaskDetail()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.TASK) then
    return
  end
  UIMgr:Show(ViewID.UI_MainTaskDetail, true, self.GroupId)
end
function WBP_MainTaskItem_C:Construct()
  self.Btn.OnClicked:Clear()
  self.Btn.OnClicked:Add(self, self.GotoMainTaskDetail)
  self.ReceiveAward.OnClicked:Clear()
  self.ReceiveAward.OnClicked:Add(self, self.GotoMainTaskDetail)
end
function WBP_MainTaskItem_C:InitMainTaskItem(ActiveGroupId)
  local TaskGroupData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  local ActiveTask = Logic_MainTask.GetGroupActiveTask(ActiveGroupId)
  UpdateVisibility(self, nil ~= ActiveTask)
  if nil == ActiveTask then
    return
  end
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  self.GroupId = ActiveGroupId
  self.TsakId = ActiveTask.taskID
  if TaskData[tonumber(ActiveTask.taskID)] then
    self.TextTaskDesc:SetText(TaskData[tonumber(ActiveTask.taskID)].tasktitle)
    local TextTaskNameText = NSLOCTEXT("WBP_MainTaskItem_C", "\194\183", "{0}\194\183{1}")
    local FTextTaskName = UE.FTextFormat(TextTaskNameText(), TaskGroupData[ActiveGroupId].name, TaskData[tonumber(ActiveTask.taskID)].name)
    self.TextTaskName:SetText(FTextTaskName)
  end
  SetImageBrushByPath(self.URGImage_BG, TaskGroupData[ActiveGroupId].image)
  local Total = 0
  local FinishNum = 0
  for index, value in ipairs(ActiveTask.counters) do
    FinishNum = value.countValue
    Total = value.TargetValue
  end
  self.TextTaskProgress:SetText(FinishNum .. "/" .. Total)
  self.TaskProgressBar:SetPercent(FinishNum / Total)
  UpdateVisibility(self.Overlay_UnActivated, 0 == ActiveTask.state)
  UpdateVisibility(self.Overlay_Finish, 2 == ActiveTask.state and Logic_MainTask.HaveReceiveAward(tonumber(ActiveTask.taskID)))
end
return WBP_MainTaskItem_C
