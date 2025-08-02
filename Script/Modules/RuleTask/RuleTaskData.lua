local RuleTaskData = {
  MainRewardState = {}
}
local EMainRewardState = {UnReceive = 0, Received = 1}
_G.EMainRewardState = EMainRewardState

function RuleTaskData:SetMainRewardState(ActivityId, InState)
  RuleTaskData.MainRewardState[ActivityId] = InState
end

function RuleTaskData:GetMainRewardState(ActivityId)
  return RuleTaskData.MainRewardState[ActivityId] and RuleTaskData.MainRewardState[ActivityId] or EMainRewardState.UnReceive
end

function RuleTaskData:GetTaskGroupState(TaskGroupId)
  if Logic_MainTask.GroupInfo[TaskGroupId] then
    return Logic_MainTask.GroupInfo[TaskGroupId].state
  end
  return ETaskGroupState.None
end

function RuleTaskData:GetTaskState(TaskId)
  if Logic_MainTask.TaskInfo[TaskId] then
    return Logic_MainTask.TaskInfo[TaskId].state
  end
  return ETaskState.None
end

function RuleTaskData:GetTaskCountValue(TaskId, CounterId)
  local TaskValue = Logic_MainTask.TaskInfo[TaskId]
  if not TaskValue then
    return 0
  end
  for i, SingleCounterInfo in ipairs(TaskValue.counters) do
    if nil ~= CounterId then
      if SingleCounterInfo.counterID == CounterId then
        return tonumber(SingleCounterInfo.countValue)
      end
    else
      return tonumber(SingleCounterInfo.countValue)
    end
  end
  return 0
end

function RuleTaskData:GetTaskGroupProgress(TaskGroupId)
  local Result, TaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, TaskGroupId)
  if not Result then
    print("RuleTaskData:GetTaskGroupProgress not found taskgroup table row!", self.MainTaskGroupId)
    return 0, 1
  end
  local FinishTaskNum = 0
  local AllTaskNum = 0
  for i, SingleTaskId in ipairs(TaskGroupRowInfo.tasklist) do
    local State = RuleTaskData:GetTaskState(SingleTaskId)
    if State == ETaskState.Finished or State == ETaskState.GotAward then
      FinishTaskNum = FinishTaskNum + 1
    end
    AllTaskNum = AllTaskNum + 1
  end
  return FinishTaskNum, AllTaskNum
end

return RuleTaskData
