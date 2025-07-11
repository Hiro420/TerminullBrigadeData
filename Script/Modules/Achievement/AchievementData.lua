local EAchievementItemLockState = {Lock = 1, UnLock = 2}
_G.EAchievementItemLockState = _G.EAchievementItemLockState or EAchievementItemLockState
local EAchievementItemSelectState = {Select = 1, UnSelect = 2}
_G.EAchievementItemSelectState = _G.EAchievementItemSelectState or EAchievementItemSelectState
local EAchievementShowModel = {Normal = 1, Details = 2}
_G.EAchievementShowModel = _G.EAchievementShowModel or EAchievementShowModel
local AchievementItemData = LuaClass()
function AchievementItemData:Ctor(...)
  self:Reset()
  local params = {
    ...
  }
  if params and params[1] then
    self.tbTaskGroup = params[1]
  end
end
function AchievementItemData:Reset()
  self.tbTaskGroup = {}
  self.tbTaskList = {}
  self.Badges = {}
end
local AchievementData = {
  TypeToTbAchievement = {},
  CurAchievementPointNum = 0,
  DisplayBadges = {},
  tbAchievementPointSort = {},
  AchievementDisplayToggle = {
    "\229\177\149\229\143\176",
    "\229\190\189\231\171\160",
    "\229\164\180\233\131\168"
  },
  MaxDisplayBadgesNum = 6,
  AchivementPointTaskGroup = 1101,
  AchievementTaskGroupIdSet = {}
}
function AchievementData:DealWithTable()
  AchievementData.TypeToTbAchievement = {}
  local platformName = UE.URGBlueprintLibrary.GetPlatformName()
  local tbTaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  local tbTaskGroupData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  if "Windows" == platformName then
    local tbAchievement = LuaTableMgr.GetLuaTableByName(TableNames.TBAchievement)
    for i, v in ipairs(tbAchievement) do
      if not AchievementData.TypeToTbAchievement[v.id] then
        AchievementData.TypeToTbAchievement[v.id] = {}
      end
      AchievementData.TypeToTbAchievement[v.id].AchievementTb = v
      AchievementData.TypeToTbAchievement[v.id].AchievementItemDataList = {}
      for idxGroup, vGroup in ipairs(v.taskgrouplist) do
        AchievementData.AchievementTaskGroupIdSet[vGroup] = true
        if tbTaskGroupData and tbTaskGroupData[vGroup] then
          local achievementItemData = AchievementItemData.New(tbTaskGroupData[vGroup])
          table.insert(AchievementData.TypeToTbAchievement[v.id].AchievementItemDataList, achievementItemData)
          for idxTask, vTask in ipairs(tbTaskGroupData[vGroup].tasklist) do
            if tbTaskData and tbTaskData[vTask] then
              table.insert(achievementItemData.tbTaskList, tbTaskData[vTask])
              self:InitTaskGroupToBadges(achievementItemData, tbTaskData[vTask].rewardlist)
            end
          end
        end
      end
    end
  elseif "XSX" == platformName then
    local tbAchievementXSX = LuaTableMgr.GetLuaTableByName(TableNames.TBXBoxAchievement)
    for kAchievement, vAchievement in pairs(tbAchievementXSX) do
      local taskGroupId = vAchievement.TaskGroupid
      AchievementData.AchievementTaskGroupIdSet[taskGroupId] = true
      if tbTaskGroupData and tbTaskGroupData[taskGroupId] then
        local achievementItemData = AchievementItemData.New(tbTaskGroupData[taskGroupId])
        local taskId = tbTaskGroupData[taskGroupId].tasklist[1]
        if tbTaskData and tbTaskData[taskId] then
          table.insert(achievementItemData.tbTaskList, tbTaskData[taskId])
          self:InitTaskGroupToBadges(achievementItemData, tbTaskData[taskId].rewardlist)
        end
      end
    end
  elseif "PS5" == platformName then
    local tbAchievementPS5 = LuaTableMgr.GetLuaTableByName(TableNames.TBPS5Achievement)
    for kAchievement, vAchievement in pairs(tbAchievementPS5) do
      local taskGroupId = vAchievement.TaskGroupid
      AchievementData.AchievementTaskGroupIdSet[taskGroupId] = true
      if tbTaskGroupData and tbTaskGroupData[taskGroupId] then
        local achievementItemData = AchievementItemData.New(tbTaskGroupData[taskGroupId])
        local taskId = tbTaskGroupData[taskGroupId].tasklist[1]
        if tbTaskData and tbTaskData[taskId] then
          table.insert(achievementItemData.tbTaskList, tbTaskData[taskId])
          self:InitTaskGroupToBadges(achievementItemData, tbTaskData[taskId].rewardlist)
        end
      end
    end
  end
  local tbAchievementPoint = LuaTableMgr.GetLuaTableByName(TableNames.TBAchievementPoint)
  self.tbAchievementPointSort = {}
  for i, v in pairs(tbAchievementPoint) do
    table.insert(self.tbAchievementPointSort, v)
  end
  table.sort(self.tbAchievementPointSort, function(A, B)
    return A.id < B.id
  end)
end
function AchievementData:InitTaskGroupToBadges(achievementItemData, rewardlist)
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  for i, v in ipairs(rewardlist) do
    local item = tbGeneral[v.key]
    if item and 12 == item.Type then
      table.insert(achievementItemData.Badges, v.key)
      break
    end
  end
end
function AchievementData:GetAchievementTypeList()
  local typeList = {}
  local tbAchievement = LuaTableMgr.GetLuaTableByName(TableNames.TBAchievement)
  if not tbAchievement then
    print("AchievementData:GetAchievementTypeList tbAchievement Is Nil")
    return typeList
  end
  for i, v in ipairs(tbAchievement) do
    table.insert(typeList, v)
  end
  return typeList
end
function AchievementData:GetAchievementByType(AchievementType)
  if table.IsEmpty(AchievementData.TypeToTbAchievement) then
    self:DealWithTable()
  end
  return AchievementData.TypeToTbAchievement[AchievementType]
end
function AchievementData:GetAchievementItemDataListByType(AchievementType)
  if table.IsEmpty(AchievementData.TypeToTbAchievement) then
    self:DealWithTable()
  end
  return AchievementData.TypeToTbAchievement[AchievementType].AchievementItemDataList
end
function AchievementData:GetAllAchievementItemDataList()
  if table.IsEmpty(AchievementData.TypeToTbAchievement) then
    self:DealWithTable()
  end
  local tbAchievementItemDataList = {}
  for k, v in pairs(AchievementData.TypeToTbAchievement) do
    for i, vAchievementItemData in ipairs(v.AchievementItemDataList) do
      table.insert(tbAchievementItemDataList, vAchievementItemData)
    end
  end
  return tbAchievementItemDataList
end
function AchievementData:GetAchievementTaskGroupListByType(AchievementType)
  if table.IsEmpty(AchievementData.TypeToTbAchievement) then
    self:DealWithTable()
  end
  if AchievementData.TypeToTbAchievement[AchievementType] then
    return AchievementData.TypeToTbAchievement[AchievementType].taskgrouplist
  end
  return {}
end
function AchievementData:GetCurDoingPointTask()
  for i, v in ipairs(self.tbAchievementPointSort) do
    local taskId = v.taskid
    local state = Logic_MainTask.GetStateByTaskId(taskId)
    if state == ETaskState.UnFinished or state == ETaskState.None then
      return taskId, i
    end
  end
  return self.tbAchievementPointSort[#self.tbAchievementPointSort].taskid, #self.tbAchievementPointSort
end
function AchievementData:GetCurDoingPointAwards()
  local taskId, idx = self:GetCurDoingPointTask()
  local tbTaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if taskId and tbTaskData and tbTaskData[taskId] then
    return tbTaskData[taskId].rewardlist, idx
  end
  return nil, nil
end
function AchievementData:GetAwardsByIdx(Idx)
  local tbTaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if self.tbAchievementPointSort and self.tbAchievementPointSort[Idx] then
    local taskId = self.tbAchievementPointSort[Idx].taskid
    if taskId and tbTaskData and tbTaskData[taskId] then
      return tbTaskData[taskId].rewardlist
    end
  end
  return nil
end
function AchievementData:GetPointTaskIdByIdx(Idx)
  if self.tbAchievementPointSort and self.tbAchievementPointSort[Idx] then
    return self.tbAchievementPointSort[Idx].taskid
  end
  return -1
end
function AchievementData:GetCurAchievementPointNum()
  return self.CurAchievementPointNum
end
function AchievementData:GetDisplayBadges()
  local displayBadges = {}
  for i, v in ipairs(self.DisplayBadges) do
    if v > 0 then
      table.insert(displayBadges, v)
    end
  end
  return displayBadges
end
function AchievementData:CheckIsAchievementTask(TaskGroupId)
  if table.IsEmpty(AchievementData.AchievementTaskGroupIdSet) then
    self:DealWithTable()
  end
  return AchievementData.AchievementTaskGroupIdSet[TaskGroupId]
end
return AchievementData, AchievementItemData
