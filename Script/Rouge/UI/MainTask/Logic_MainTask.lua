local rapidjson = require("rapidjson")
local AchievementData, AchievementItemData = require("Modules.Achievement.AchievementData")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local SpecificModifyConfig = require("GameConfig.SpecificModify.SpecificModifyConfig")
local ETaskState = {
  None = -1,
  Lock = 0,
  UnFinished = 1,
  Finished = 2,
  GotAward = 3
}
_G.ETaskState = _G.ETaskState or ETaskState
local ETaskGroupState = {
  None = -1,
  UnFinished = 0,
  Finished = 1,
  GotAward = 2
}
_G.ETaskGroupState = _G.ETaskGroupState or ETaskGroupState
local EOptionalGiftType = {
  None = 0,
  Task = 1,
  Rule = 2,
  Mall = 3,
  Mail = 4,
  BPass = 5
}
_G.EOptionalGiftType = _G.EOptionalGiftType or EOptionalGiftType
Logic_MainTask = Logic_MainTask or {
  MainTaskId = 1,
  GroupInfo = {},
  TaskInfo = {},
  CacheInviteDialogue = {}
}
function Logic_MainTask.GetAllGroupIds()
  local taskGroupList = {}
  local taskGroupMap = {}
  local MainStoryLine = LuaTableMgr.GetLuaTableByName(TableNames.TBMainStoryLine)
  for i, v in ipairs(MainStoryLine[1].taskgrouplist) do
    if not taskGroupMap[v] then
      taskGroupMap[v] = true
      table.insert(taskGroupList, v)
    else
      print("Logic_MainTask.GetAllGroupIds. MainStoryLine: ", v)
    end
  end
  local platformName = UE.URGBlueprintLibrary.GetPlatformName()
  if "Windows" == platformName then
    local achievementTb = LuaTableMgr.GetLuaTableByName(TableNames.TBAchievement)
    for i, v in pairs(achievementTb) do
      for k, vGroup in pairs(v.taskgrouplist) do
        if not taskGroupMap[vGroup] then
          taskGroupMap[vGroup] = true
          table.insert(taskGroupList, vGroup)
        else
          print("Logic_MainTask.GetAllGroupIds. achievementTb: ", vGroup)
        end
      end
    end
    table.insert(taskGroupList, AchievementData.AchivementPointTaskGroup)
  elseif "XSX" == platformName then
    local achievementTb = LuaTableMgr.GetLuaTableByName(TableNames.TBXBoxAchievement)
    for i, v in pairs(achievementTb) do
      local taskGroupId = v.TaskGroupid
      if not taskGroupMap[taskGroupId] then
        taskGroupMap[taskGroupId] = true
        table.insert(taskGroupList, taskGroupId)
      else
        print("Logic_MainTask.GetAllGroupIds. achievementTb: ", taskGroupId)
      end
    end
  elseif "PS5" == platformName then
    local achievementTb = LuaTableMgr.GetLuaTableByName(TableNames.TBPS5Achievement)
    for i, v in pairs(achievementTb) do
      local taskGroupId = v.TaskGroupid
      if not taskGroupMap[taskGroupId] then
        taskGroupMap[taskGroupId] = true
        table.insert(taskGroupList, taskGroupId)
      else
        print("Logic_MainTask.GetAllGroupIds. achievementTb: ", taskGroupId)
      end
    end
  end
  local PlotFragmentClueTB = LuaTableMgr.GetLuaTableByName(TableNames.TBClue)
  for Index, ClueInfo in pairs(PlotFragmentClueTB) do
    table.insert(taskGroupList, ClueInfo.taskGroupID)
  end
  local ActivityTB = LuaTableMgr.GetLuaTableByName(TableNames.TBActivityGeneral)
  for Index, ActivityInfo in pairs(ActivityTB) do
    local TaskGroupIdList = ActivityInfo.taskGroupList
    for Index, TaskGroupId in pairs(TaskGroupIdList) do
      table.insert(taskGroupList, TaskGroupId)
    end
  end
  for i, v in ipairs(SpecificModifyConfig.TaskGroupIdList) do
    table.insert(taskGroupList, v)
  end
  return taskGroupList
end
function Logic_MainTask.GetAllMainTaskGroupIds()
  local MainStoryLine = LuaTableMgr.GetLuaTableByName(TableNames.TBMainStoryLine)
  return MainStoryLine[1].taskgrouplist
end
function Logic_MainTask.LoadMainTaskModule()
  print("LoadMainTaskModule")
  Logic_MainTask.GroupInfo = {}
  Logic_MainTask.TaskInfo = {}
  Logic_MainTask.CacheInviteDialogue = {}
  Logic_MainTask.FinishDialogueId = nil
  EventSystem.RemoveListener(EventDef.WSMessage.TaskUpdate, Logic_MainTask.OnTaskUpdate, nil)
  EventSystem.AddListener(nil, EventDef.WSMessage.TaskUpdate, Logic_MainTask.OnTaskUpdate)
  Logic_MainTask.PullTask()
  Logic_MainTask.LoadInviteDialogue()
end
function Logic_MainTask.LoadInviteDialogue()
  if Logic_MainTask.CacheInviteDialogue == nil then
    Logic_MainTask.CacheInviteDialogue = {}
  end
  for key, value in pairs(Logic_MainTask.CacheInviteDialogue) do
    EventSystem.Invoke(EventDef.Lobby.OnInviteDialogue, true, value)
  end
end
function Logic_MainTask.OnTaskUpdate(Json)
  local JsonTable = rapidjson.decode(Json)
  local GroupIdList = {}
  for i, v in ipairs(JsonTable.taskinfo) do
    if not table.Contain(GroupIdList, v.groupid) then
      table.insert(GroupIdList, v.groupid)
    end
  end
  Logic_MainTask.PullTask(GroupIdList, true)
end
function Logic_MainTask.PullTask(GroupIdList, bIsFromTaskUpdage)
  local JsonParams = {}
  if GroupIdList then
    JsonParams = {groupIDs = GroupIdList}
  else
    JsonParams = {
      groupIDs = Logic_MainTask.GetAllGroupIds()
    }
  end
  if 0 == #JsonParams.groupIDs then
    print("Error: PullTask groupIDs is empty")
    return
  end
  HttpCommunication.Request("task/pull/taskgroup", JsonParams, {
    GameInstance,
    function(Target, JsonResponse)
      local Response = rapidjson.decode(JsonResponse.Content)
      Logic_MainTask.DoTaskInfoChange(Response.taskGroups, bIsFromTaskUpdage)
      print("PullTaskSucc", JsonResponse.Content)
    end
  }, {
    GameInstance,
    function()
      print("PullTaskFaill")
    end
  })
end
function Logic_MainTask.DoTaskInfoChange(TaskGroups, bIsFromTaskUpdage)
  local TaskGroupIdList = {}
  for key0, GroupValue in pairs(TaskGroups) do
    Logic_MainTask.GroupInfo[GroupValue.groupID] = GroupValue
    for key1, TaskValue in pairs(GroupValue.tasks) do
      Logic_MainTask.CheckTaskState(TaskValue, GroupValue.groupID, bIsFromTaskUpdage)
    end
    table.insert(TaskGroupIdList, GroupValue.groupID)
  end
  EventSystem.Invoke(EventDef.MainTask.OnMainTaskRefres, TaskGroupIdList)
end
function Logic_MainTask.CheckTaskState(TaskValue, GroupID, bIsFromTaskUpdage)
  if nil == TaskValue then
    return
  end
  if nil == Logic_MainTask.TaskInfo[TaskValue.taskID] then
    Logic_MainTask.TaskInfo[TaskValue.taskID] = {}
  end
  local OldTaskValue = Logic_MainTask.TaskInfo[TaskValue.taskID]
  local ChangeTask = 0
  local ChangeGroup = 0
  if OldTaskValue.state ~= TaskValue.state then
    print("Logic_MainTask \228\187\187\229\138\161\231\138\182\230\128\129\229\143\145\231\148\159\229\143\152\230\155\180", TaskValue.taskID)
    if 2 == TaskValue.state then
      NotifyObjectMessage(nil, GMP.MSG_World_Mainline_OnTaskFinished, GroupID, TaskValue.taskID)
      EventSystem.Invoke(EventDef.MainTask.OnMainTaskFinish, GroupID, TaskValue.taskID, bIsFromTaskUpdage)
      if bIsFromTaskUpdage then
        Logic_MainTask.CheckShowTaskTips(GroupID, TaskValue.taskID)
      end
      Logic_MainTask.OnMainTaskFinish(GroupID, TaskValue.taskID)
      Logic_MainTask.UpdateConsoleAchievementsProgress(GroupID, TaskValue.taskID, TaskValue)
    end
    if 1 == TaskValue.state then
      EventSystem.Invoke(EventDef.MainTask.OnMainTaskUnLock, GroupID, TaskValue.taskID)
      Logic_MainTask.OnMainTaskUnLock(GroupID, TaskValue.taskID)
    end
    if 3 == TaskValue.state then
      EventSystem.Invoke(EventDef.MainTask.OnMainTaskFinish, GroupID, TaskValue.taskID)
    end
    ChangeTask = TaskValue.taskID
    ChangeGroup = GroupID
  elseif 1 == TaskValue.state then
    local CurrentCount = 0
    local OldCurrentCount = 0
    for key, counterV in pairs(TaskValue.counters) do
      CurrentCount = tonumber(counterV.countValue)
      break
    end
    for key, counterV in pairs(OldTaskValue.counters) do
      OldCurrentCount = tonumber(counterV.countValue)
      break
    end
    if CurrentCount ~= OldCurrentCount then
      Logic_MainTask.UpdateConsoleAchievementsProgress(GroupID, TaskValue.taskID, TaskValue)
    end
  end
  if OldTaskValue.counters then
    for key, OldValue in pairs(OldTaskValue.counters) do
      local Counter = TaskValue.counters
      local NewValue = Counter[key]
      if NewValue then
        if NewValue.counterID == OldValue.counterID then
          if tonumber(OldValue.countValue) < OldValue.TargetValue and tonumber(NewValue.countValue) >= NewValue.TargetValue then
            NotifyObjectMessage(nil, GMP.MSG_World_Mainline_OnTaskEventFinished, GroupID, TaskValue.taskID, NewValue.counterID)
          end
        else
          print("CheckTaskState fail", NewValue.counterID, OldValue.counterID)
        end
      end
    end
  end
  Logic_MainTask.TaskInfo[TaskValue.taskID] = TaskValue
  EventSystem.Invoke(EventDef.MainTask.OnMainTaskChange, GroupID, ChangeTask, true, false)
end
function Logic_MainTask.UpdateConsoleAchievementsProgress(TaskGroupId, TaskId, TaskValue)
  if AchievementData:CheckIsAchievementTask(TaskGroupId) then
    local FirstCount = 0
    local TargetCount = 0
    for key, counterV in pairs(TaskValue.counters) do
      FirstCount = tonumber(counterV.countValue)
      break
    end
    for key, counterV in pairs(TaskValue.counters) do
      TargetCount = tonumber(counterV.TargetValue)
      break
    end
    local Percent = 0
    local platformName = UE.URGBlueprintLibrary.GetPlatformName()
    if "PS5" == platformName then
      Percent = FirstCount
    else
      Percent = FirstCount / TargetCount * 100
    end
    UE.UOnlineGameUtilsLibrary.MakeAchievement(GameInstance, TaskId, Percent)
  end
end
function Logic_MainTask.CheckShowTaskTips(TaskGroupId, TaskId)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  if AchievementData:CheckIsAchievementTask(TaskGroupId) then
    local Param = {}
    local WaveWindowParam = UE.FWaveWindowParam()
    WaveWindowParam.IntParam0 = TaskGroupId
    WaveWindowParam.IntParam1 = TaskId
    WaveWindowManager:ShowWaveWindowWithWaveParam(1149, Param, nil, {}, {}, WaveWindowParam)
  end
  if IllustratedGuideData:CheckIsPlotFragmentTask(TaskGroupId) then
    local Param = {}
    local WaveWindowParam = UE.FWaveWindowParam()
    WaveWindowParam.IntParam0 = TaskGroupId
    WaveWindowParam.IntParam1 = TaskId
    WaveWindowManager:ShowWaveWindowWithWaveParam(1178, Param, nil, {}, {}, WaveWindowParam)
  end
end
function Logic_MainTask.GetTaskInfoByTaskId(TaskId)
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if nil ~= TaskData and nil ~= TaskData[TaskId] then
    return TaskData[TaskId]
  end
  return nil
end
function Logic_MainTask.GetStateByTaskId(TaskId)
  if Logic_MainTask.TaskInfo[TaskId] then
    return Logic_MainTask.TaskInfo[TaskId].state
  end
  return -1
end
function Logic_MainTask.GetFirstCountValueByTaskId(TaskId)
  if Logic_MainTask.TaskInfo[TaskId] then
    for key, counterV in pairs(Logic_MainTask.TaskInfo[TaskId].counters) do
      return counterV.countValue
    end
  end
  return "0"
end
function Logic_MainTask.GetFirstTargetValueByTaskId(TaskId)
  if Logic_MainTask.TaskInfo[TaskId] then
    for key, counterV in pairs(Logic_MainTask.TaskInfo[TaskId].counters) do
      return counterV.TargetValue
    end
  end
  return 0
end
function Logic_MainTask.IsGroupUnLock(TaskGroupId)
  if Logic_MainTask.GroupInfo[TaskGroupId] == nil then
    print(" Logic_MainTask.GroupInfo[TaskGroupId] == nil", TaskGroupId)
    return true
  end
  for index, TaskValue in ipairs(Logic_MainTask.GroupInfo[TaskGroupId].tasks) do
    if Logic_MainTask.TaskInfo[TaskValue.taskID] and 0 ~= Logic_MainTask.TaskInfo[TaskValue.taskID].state then
      return true
    end
  end
  return false
end
function Logic_MainTask.IsProfyTaskGroupUnlock(HeroId, GearLv, TaskGroupId)
  if Logic_MainTask.IsGroupReceive(TaskGroupId) then
    return false
  end
  if 1 == GearLv then
    return true
  end
  local groupState = Logic_MainTask.GroupInfo[TaskGroupId].state
  if groupState == ETaskGroupState.None then
    return false
  end
  return true
end
function Logic_MainTask.IsProfyTaskGroupOrGotAward(HeroId, GearLv, TaskGroupId)
  if 1 == GearLv then
    return true
  end
  local groupState = Logic_MainTask.GroupInfo[TaskGroupId].state
  if groupState == ETaskGroupState.None then
    return false
  end
  return true
end
function Logic_MainTask.GetMaxUnlockGearLv(HeroId)
  return 0
end
function Logic_MainTask.IsGroupFinish(TaskGroupId)
  if Logic_MainTask.GroupInfo[TaskGroupId] == nil then
    print(" Logic_MainTask.GroupInfo[TaskGroupId] == nil", TaskGroupId)
    return false
  end
  for TaskKey, TaskValue in pairs(Logic_MainTask.GroupInfo[TaskGroupId].tasks) do
    if TaskValue.state < 3 then
      return false
    end
  end
  return Logic_MainTask.GroupInfo[TaskGroupId].state == ETaskGroupState.Finished
end
function Logic_MainTask.IsGroupReceive(TaskGroupId)
  if Logic_MainTask.GroupInfo[TaskGroupId] == nil then
    print(" Logic_MainTask.GroupInfo[TaskGroupId] == nil", TaskGroupId)
    return false
  end
  return Logic_MainTask.GroupInfo[TaskGroupId].state == ETaskGroupState.GotAward
end
function Logic_MainTask.IsTaskReceive(TaskId)
  if Logic_MainTask.TaskInfo[TaskId] == nil then
    print(" Logic_MainTask.TaskInfo[TaskGroupId] == nil", TaskId)
    return false
  end
  return 3 == Logic_MainTask.TaskInfo[TaskId].state
end
function Logic_MainTask.GetActiveGroups()
  local ActiveGroups = {}
  if Logic_MainTask.GetAllMainTaskGroupIds() == nil then
    return ActiveGroups
  end
  for index, GroupId in ipairs(Logic_MainTask.GetAllMainTaskGroupIds()) do
    if Logic_MainTask.IsGroupUnLock(GroupId) and not Logic_MainTask.IsGroupFinish(GroupId) and nil ~= Logic_MainTask.GetGroupActiveTask(GroupId) then
      table.insert(ActiveGroups, GroupId)
    end
  end
  return ActiveGroups
end
function Logic_MainTask.GetGroupActiveTask(GroupId)
  if Logic_MainTask.IsGroupUnLock(GroupId) and not Logic_MainTask.IsGroupFinish(GroupId) then
    if Logic_MainTask.GroupInfo[GroupId] == nil then
      return
    end
    for index, TaskValue in ipairs(Logic_MainTask.GroupInfo[GroupId].tasks) do
      if Logic_MainTask.TaskInfo[TaskValue.taskID] and 2 == Logic_MainTask.TaskInfo[TaskValue.taskID].state and Logic_MainTask.HaveReceiveAward(TaskValue.taskID) then
        return Logic_MainTask.TaskInfo[TaskValue.taskID]
      end
    end
    for index, TaskValue in ipairs(Logic_MainTask.GroupInfo[GroupId].tasks) do
      if Logic_MainTask.TaskInfo[TaskValue.taskID] and 1 == Logic_MainTask.TaskInfo[TaskValue.taskID].state then
        return Logic_MainTask.TaskInfo[TaskValue.taskID]
      end
    end
  end
  return nil
end
function Logic_MainTask.HaveReceiveAward(TsakId)
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if nil ~= TaskData and nil ~= TaskData[TsakId] then
    return 0 ~= table.count(TaskData[TsakId].rewardlist)
  end
end
function Logic_MainTask.GetGroupShowTask(GroupId)
  local ReturnIds = {}
  if not Logic_MainTask.GroupInfo[GroupId] then
    return nil
  end
  for index, TaskValue in ipairs(Logic_MainTask.GroupInfo[GroupId].tasks) do
    if Logic_MainTask.TaskInfo[TaskValue.taskID] and 0 ~= Logic_MainTask.TaskInfo[TaskValue.taskID].state then
      table.insert(ReturnIds, Logic_MainTask.TaskInfo[TaskValue.taskID])
    end
  end
  return ReturnIds
end
function Logic_MainTask.ReceiveAward(GroupId, TaskId, bNotShowPropTip, callback, callbackObj, IgnoreStateCheck, bShowLoading)
  if not TaskId then
    local taskIDs = {}
    local JsonParams = {
      groupTaskInfos = {}
    }
    for index, TaskValue in ipairs(Logic_MainTask.GroupInfo[GroupId].tasks) do
      if TaskValue.state == ETaskState.Finished then
        table.insert(taskIDs, TaskValue.taskID)
      end
    end
    if 0 == table.count(taskIDs) then
      print("\230\178\161\230\156\137\228\187\187\229\138\161\229\143\175\228\187\165\233\162\134\229\143\150")
      return
    end
    table.insert(JsonParams.groupTaskInfos, {groupID = GroupId, taskIDs = taskIDs})
    HttpCommunication.Request("task/receivereward/batch", JsonParams, {
      GameInstance,
      function(Target, JsonResponse)
        print(" Logic_MainTask.ReceiveAward \232\175\183\230\177\130\233\162\134\229\165\150 \228\187\187\229\138\161\231\187\132", GroupId)
        EventSystem.Invoke(EventDef.MainTask.OnReceiveAward, nil, GroupId, nil)
        Logic_MainTask.PullTask({GroupId})
      end
    }, {
      GameInstance,
      function()
        print("ReceiveAwardFaill")
      end
    })
    return
  end
  if Logic_MainTask.TaskInfo == nil or Logic_MainTask.TaskInfo[TaskId] == nil then
    return
  end
  if not IgnoreStateCheck and 2 ~= Logic_MainTask.TaskInfo[TaskId].state then
    return
  end
  local JsonParams = {groupID = GroupId, taskID = TaskId}
  local LocalTaskId = TaskId
  if Logic_MainTask.IsOptionalAward(TaskId) then
    local OptionalGift = {}
    local TaskDate = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
    if TaskDate[TaskId] then
      for index, Award in ipairs(TaskDate[TaskId].rewardlist) do
        if nil == OptionalGift[Award.key] then
          OptionalGift[Award.key] = 1
        else
          OptionalGift[Award.key] = OptionalGift[Award.key] + 1
        end
      end
    end
    ShowOptionalGiftWindow(OptionalGift, GroupId, _G.EOptionalGiftType.Task, callback, TaskId, TaskId)
    return
  end
  HttpCommunication.Request("task/receivereward/task", JsonParams, {
    GameInstance,
    function(Target, JsonResponse)
      print(" Logic_MainTask.ReceiveAward \232\175\183\230\177\130\233\162\134\229\165\150", LocalTaskId)
      local Response = rapidjson.decode(JsonResponse.Content)
      if Logic_MainTask.TaskInfo and Logic_MainTask.TaskInfo[LocalTaskId] then
        Logic_MainTask.TaskInfo[LocalTaskId].state = ETaskState.GotAward
        EventSystem.Invoke(EventDef.MainTask.OnMainTaskFinish, GroupId, LocalTaskId)
        EventSystem.Invoke(EventDef.MainTask.OnMainTaskChange, GroupId, LocalTaskId, true, false)
      end
      if callbackObj and callback then
        callback(callbackObj, GroupId, LocalTaskId, nil)
      end
      EventSystem.Invoke(EventDef.MainTask.OnReceiveAward, nil, GroupId, LocalTaskId)
      Logic_MainTask.OnReceiveAward(LocalTaskId)
      Logic_MainTask.PullTask({GroupId})
    end
  }, {
    GameInstance,
    function()
      print("ReceiveAwardFaill")
    end
  }, false, bShowLoading)
end
function Logic_MainTask.IsOptionalAward(TaskId)
  local TaskDate = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if TaskDate[TaskId] then
    for index, Award in ipairs(TaskDate[TaskId].rewardlist) do
      local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      if TBGeneral[Award.key] then
        return TBGeneral[Award.key].Type == TableEnums.ENUMResourceType.OptionalGift
      end
    end
  end
  return false
end
function Logic_MainTask.ReceiveTaskGroupAward(GroupId, bNotShowPropTip)
  local JsonParams = {groupID = GroupId}
  HttpCommunication.Request("task/receivereward/taskgroup", JsonParams, {
    GameInstance,
    function(Target, JsonResponse)
      Logic_MainTask.PullTask({GroupId})
    end
  }, {
    GameInstance,
    function()
      print("ReceiveTaskGroupAwardFaill")
    end
  })
end
function Logic_MainTask.BindInviteDialogue(bShow, Id, InviteDialogueWidget)
  if bShow then
    if not table.Contain(Logic_MainTask.CacheInviteDialogue, Id) and Logic_MainTask.CheckDialogueId(Id) then
      table.insert(Logic_MainTask.CacheInviteDialogue, Id)
    end
  else
    table.RemoveItem(Logic_MainTask.CacheInviteDialogue, Id)
    if Logic_MainTask.CaCheDialogueTask and Logic_MainTask.CaCheDialogueTask[Id] then
      Logic_MainTask.FinishDialogueTask(Logic_MainTask.CaCheDialogueTask[Id], Id)
    end
  end
  if nil == InviteDialogueWidget then
    return
  end
  if 1 == #Logic_MainTask.CacheInviteDialogue then
    InviteDialogueWidget:InitRequestConversation(Id)
  end
  InviteDialogueWidget:RefreshList()
  UpdateVisibility(InviteDialogueWidget, 0 ~= #Logic_MainTask.CacheInviteDialogue)
end
function Logic_MainTask.OnReceiveAward(TaskId)
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if TaskData[TaskId] and TaskData[TaskId].finishunlockdialog and 0 ~= TaskData[TaskId].finishunlockdialog then
    UIMgr:Show(ViewID.UI_MainTaskDialogueView, nil, TaskData[TaskId].finishunlockdialog)
  end
  if Logic_MainTask.WaitFinishTask and Logic_MainTask.WaitFinishTask[TaskId] then
    if Logic_MainTask.CaCheDialogueTask == nil then
      Logic_MainTask.CaCheDialogueTask = {}
    end
    Logic_MainTask.BindInviteDialogue(true, Logic_MainTask.WaitFinishTask[TaskId].Id)
    EventSystem.Invoke(EventDef.Lobby.OnInviteDialogue, true, Logic_MainTask.WaitFinishTask[TaskId].Id)
    print(" Logic_MainTask.OnReceiveAward")
    Logic_MainTask.CaCheDialogueTask[Logic_MainTask.WaitFinishTask[TaskId].Id] = Logic_MainTask.WaitFinishTask[TaskId].TaskId
  end
end
function Logic_MainTask.OnMainTaskFinish(GroupId, TaskId)
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if not TaskData[TaskId] or TaskData[TaskId].finishunlockdialog then
  end
  if Logic_MainTask.NowShowTipTaskId ~= nil and -1 ~= Logic_MainTask.NowShowTipTaskId and TaskId == Logic_MainTask.NowShowTipTaskId then
    print("Logic_MainTask.OnMainTaskFinish(GroupId,TaskId)", GroupId, TaskId, Logic_MainTask.NowShowTipTaskId)
  end
  UE.UOnlineGameUtilsLibrary.EndActivity(GameInstance, TaskId, UE.ERGOnlineActivityOutcome.Completed)
end
function Logic_MainTask.OnMainTaskUnLock(GroupId, TaskId)
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if TaskData[TaskId] and TaskData[TaskId].unlockdialog and 0 ~= TaskData[TaskId].unlockdialog then
    Logic_MainTask.BindInviteDialogue(true, TaskData[TaskId].unlockdialog)
    print(" Logic_MainTask.OnMainTaskUnLock")
    EventSystem.Invoke(EventDef.Lobby.OnInviteDialogue, true, TaskData[TaskId].unlockdialog)
    UE.UOnlineGameUtilsLibrary.StartActivity(GameInstance, TaskId)
  end
  Logic_MainTask.CheckDialogueTask(GroupId, TaskId)
end
function Logic_MainTask.CheckDialogueTask(GroupId, TaskId)
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if TaskData[TaskId] and TaskData[TaskId].targetEventsList then
    for key, Event in pairs(TaskData[TaskId].targetEventsList) do
      if Event.id == 1009 and Event.params[2] then
        if Logic_MainTask.WaitFinishTask == nil then
          Logic_MainTask.WaitFinishTask = {}
        end
        local TempTable = {
          Id = Event.params[2].param,
          TaskId = TaskId
        }
        Logic_MainTask.WaitFinishTask[TaskData[TaskId].pretask] = TempTable
        if nil == Logic_MainTask.GetGroupActiveTask(GroupId) or Logic_MainTask.GetGroupActiveTask(GroupId).taskID == TaskId then
          Logic_MainTask.OnReceiveAward(TaskData[TaskId].pretask)
        end
      end
    end
  end
end
function Logic_MainTask.FinishDialogueTask(TaskId, EventId)
  HttpCommunication.Request("task/event/clienttarget", {id = EventId, module = "1"}, {
    GameInstance,
    function()
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function Logic_MainTask.CacheDialogueId(Id)
  if Logic_MainTask.FinishDialogueId == nil then
    Logic_MainTask.FinishDialogueId = {}
  end
  local FilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/MainTaskDialogue/" .. DataMgr.GetUserId() .. "Cache.txt"
  table.insert(Logic_MainTask.FinishDialogueId, tostring(Id))
  local OutStr = "0"
  for key, value in pairs(Logic_MainTask.FinishDialogueId) do
    if tonumber(value) then
      OutStr = OutStr .. "|" .. value
    end
  end
  UE.URGBlueprintLibrary.SaveStringToFile(FilePath, OutStr)
end
function Logic_MainTask.CheckDialogueId(Id)
  if Logic_MainTask.FinishDialogueId == nil or Logic_MainTask.FinishDialogueId == {} then
    Logic_MainTask.FinishDialogueId = {}
    local FilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/MainTaskDialogue/" .. DataMgr.GetUserId() .. "Cache.txt"
    local OutString = ""
    local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(FilePath, nil)
    Logic_MainTask.FinishDialogueId = Split(FileStr, "|")
  end
  if table.Contain(Logic_MainTask.FinishDialogueId, tostring(Id)) then
    return false
  end
  return true
end
