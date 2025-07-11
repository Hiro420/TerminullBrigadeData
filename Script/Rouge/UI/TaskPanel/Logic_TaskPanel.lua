local rapidjson = require("rapidjson")
local OrderedMap = require("Framework.DataStruct.OrderedMap")
LogicTaskPanel = LogicTaskPanel or {
  TaskInfo = OrderedMap.New(),
  TaskStatus = {}
}
function LogicTaskPanel.UpdateDifferenceData(TaskInfo, bHall)
  for index, Value in ipairs(TaskInfo) do
    local TaskValue = Value
    if bHall then
      LogicTaskPanel.ShowMainTaskInfo(TaskValue)
    elseif LogicTaskPanel.TaskInfo[TaskValue.EventId] then
      LogicTaskPanel.TaskInfo[TaskValue.EventId] = TaskValue
    else
      LogicTaskPanel.TaskInfo:Add(TaskValue.EventId, TaskValue, 1)
    end
    if bHall then
      local Counters = {}
      for i, v in ipairs(TaskValue.Current:ToTable()) do
        local TempValue = {}
        TempValue.TargetValue = 0
        local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
        if TaskData[TaskValue.EventId] and TaskData[TaskValue.EventId].targetEventsList then
          for key, Event in pairs(TaskData[TaskValue.EventId].targetEventsList) do
            if Event.id == v.EventId then
              TempValue.TargetValue = Event.value
            end
          end
        end
        TempValue.counterID = v.EventId
        TempValue.countValue = v.Value
        table.insert(Counters, TempValue)
      end
      local TaskJsonTable = {
        state = TaskValue.Status,
        taskID = TaskValue.EventId,
        counters = Counters
      }
      local TaskJsonStr = RapidJsonEncode(TaskJsonTable)
      local TaskJsonObj = rapidjson.decode(TaskJsonStr)
      Logic_MainTask.CheckTaskState(TaskJsonObj, TaskValue.GroupId, true)
    end
  end
end
function LogicTaskPanel.ShowMainTaskInfo(TaskValue)
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local LevelId = 0
  local Difficulty = 0
  local ModeId = 0
  if LevelSubSystem then
    LevelId = LevelSubSystem:GetLevelID()
    Difficulty = LevelSubSystem:GetDifficulty()
    ModeId = LevelSubSystem:GetMatchGameMode()
  end
  local TaskDate = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if TaskDate[TaskValue.EventId] and Difficulty >= TaskDate[TaskValue.EventId].diffculty then
    local TaskModeTab = Split(TaskDate[TaskValue.EventId].taskModeId, ",")
    local bIsMatchMode = false
    for key, value in pairs(TaskModeTab) do
      if tonumber(value) == ModeId then
        bIsMatchMode = true
        break
      end
    end
    local LevelIdStrTab = Split(TaskDate[TaskValue.EventId].guidelevel, ",")
    for key, value in pairs(LevelIdStrTab) do
      if tonumber(value) == LevelId and bIsMatchMode then
        LogicTaskPanel.TaskInfo[TaskValue.EventId] = TaskValue
      end
    end
  end
end
function LogicTaskPanel.ClearUp()
  LogicTaskPanel.TaskInfo = OrderedMap.New()
  LogicTaskPanel.TaskStatus = {}
end
function LogicTaskPanel.UpdateCustomTaskData(CustomTaskInfoList, TriggerUpdatePanel)
  for index, value in ipairs(CustomTaskInfoList) do
    local TaskValue = value
    if LogicTaskPanel.TaskInfo[TaskValue.EventId] then
      LogicTaskPanel.TaskInfo[TaskValue.EventId] = TaskValue
    else
      LogicTaskPanel.TaskInfo:Add(TaskValue.EventId, TaskValue, 1)
    end
  end
  if TriggerUpdatePanel then
    EventSystem.Invoke(EventDef.Task.UpdateCustomTask)
  end
end
function LogicTaskPanel.RemoveCustomTaskData(CustomTaskDataList)
  for index, CustomTaskData in ipairs(CustomTaskDataList) do
    if LogicTaskPanel.TaskInfo[CustomTaskData.EventId] then
      LogicTaskPanel.TaskInfo[CustomTaskData.EventId] = nil
    end
  end
  EventSystem.Invoke(EventDef.Task.UpdateCustomTask)
end
function LogicTaskPanel.ClearRiftTask()
  local taskInfoKeyList = {}
  for k, v in pairs(LogicTaskPanel.TaskInfo) do
    if string.find(tostring(k), "Rift") ~= nil then
      table.insert(taskInfoKeyList, k)
    end
  end
  for i, v in ipairs(taskInfoKeyList) do
    LogicTaskPanel.TaskInfo[v] = nil
  end
  EventSystem.Invoke(EventDef.Task.UpdateCustomTask)
end
function LogicTaskPanel.CreatCustomTaskData(EventId, GamePlayTaskRowName, TimeOffUTCStamp, ...)
  return {
    EventId = EventId,
    GamePlayTaskRowName = GamePlayTaskRowName,
    bIsCustomTask = true,
    TimeOffUTCStamp = TimeOffUTCStamp,
    Params = {
      ...
    }
  }
end
