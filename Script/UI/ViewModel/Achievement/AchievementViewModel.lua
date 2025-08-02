local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local AchievementData, AchievementItemData = require("Modules.Achievement.AchievementData")
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local AchievementHandler = require("Protocol.Achievement.AchievementHandler")
local AchievementViewModel = CreateDefaultViewModel()
local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
local BadgesSort = function(A, B)
  local generalA = tbGeneral[A]
  local generalB = tbGeneral[B]
  if generalA.Rare ~= generalB.Rare then
    return generalA.Rare > generalB.Rare
  end
  return B < A
end
AchievementViewModel.propertyBindings = {}
AchievementViewModel.subViewModels = {}

function AchievementViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.OnMainTaskRefres)
  EventSystem.AddListenerNew(EventDef.MainTask.OnReceiveAward, self, self.OnReceiveAward)
  EventSystem.AddListenerNew(EventDef.Achievement.GetAchievementInfo, self, self.OnGetAchievementInfo)
  EventSystem.AddListenerNew(EventDef.Achievement.SetDisplayBadges, self, self.OnSetDisplayBadges)
end

function AchievementViewModel:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.OnMainTaskRefres)
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnReceiveAward, self, self.OnReceiveAward)
  EventSystem.RemoveListenerNew(EventDef.Achievement.GetAchievementInfo, self, self.OnGetAchievementInfo)
  EventSystem.RemoveListenerNew(EventDef.Achievement.SetDisplayBadges, self, self.OnSetDisplayBadges)
  self.Super.OnShutdown(self)
end

function AchievementViewModel:RequestGetAchievementInfo(RoleID, callback, bIsShowLoading)
  AchievementHandler.RequestGetAchievementInfo(RoleID, callback, bIsShowLoading)
end

function AchievementViewModel:RequestSetDisplayBadges(displayBadgesList)
  if AchievementData.MaxDisplayBadgesNum < #displayBadgesList then
    return
  end
  local checkIsChanged = false
  if #displayBadgesList == #AchievementData.DisplayBadges then
    for i, v in ipairs(displayBadgesList) do
      if AchievementData.DisplayBadges[i] ~= v then
        checkIsChanged = true
      end
    end
  else
    checkIsChanged = true
  end
  if not checkIsChanged then
    print("AchievementViewModel:RequestSetDisplayBadges DisplayBadgesList Not Changed")
    for i, v in ipairs(displayBadgesList) do
      print("AchievementViewModel:RequestSetDisplayBadges Need Set BadgesId", v)
    end
    for i, v in ipairs(AchievementData.DisplayBadges) do
      print("AchievementViewModel:RequestSetDisplayBadges Equiped BadgesId", v)
    end
    return
  end
  AchievementHandler.RequestSetDisplayBadges(displayBadgesList)
end

function AchievementViewModel:SwitchShowModel(AchievementShowModel, tbTask, taskGroupId, NotUpdateAchievementList)
  self.AchievementShowModel = EAchievementShowModel.Details
  self.CurSelectTaskGroupId = taskGroupId or nil
  if tbTask then
    self.CurSelectTaskId = tbTask.id
  else
    self.CurSelectTaskId = nil
  end
  if self:GetFirstView() then
    self:GetFirstView():OnSwitchShowModel(self.AchievementShowModel, tbTask, taskGroupId)
    if not NotUpdateAchievementList then
      self:UpdateAchievementList()
    end
    self:GetFirstView():UpdateAchievementAwardList()
  end
end

function AchievementViewModel:SelectToggle(ToggleType)
  local bIsChange = false
  if self.CurSelectToggleType ~= ToggleType then
    bIsChange = true
  end
  self.CurSelectToggleType = ToggleType
  if bIsChange then
    self:SwitchShowModel(self.AchievementShowModel)
  else
    local tbTaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
    local tbTask
    if self.CurSelectTaskId then
      tbTask = tbTaskData[self.CurSelectTaskId]
    end
    self:SwitchShowModel(self.AchievementShowModel, tbTask, self.CurSelectTaskGroupId)
  end
end

function AchievementViewModel:OnMainTaskRefres()
  self:SelectToggle(self.CurSelectToggleType)
  if self:GetFirstView() then
    local firstValue = AchievementData:GetCurAchievementPointNum()
    self:GetFirstView():OnUpdateAchievementPoint(firstValue)
  end
end

function AchievementViewModel:OnTaskGroupAwardReceived(GroupId, List)
  if self:GetFirstView() then
    self:GetFirstView():OnTaskGroupAwardReceived(GroupId, List)
  end
end

function AchievementViewModel:OnReceiveAward(List, GroupId, TaskId)
  local tbTaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  local tbTaskGroup = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  if not tbTaskData or not tbTaskGroup then
    return
  end
  local tbTaskGroupData = tbTaskGroup[GroupId]
  local taskId = -1
  for idxTask, vTask in ipairs(tbTaskGroupData.tasklist) do
    local state = Logic_MainTask.GetStateByTaskId(vTask)
    if state == ETaskState.Finished or state == ETaskState.UnFinished or state == ETaskState.Lock then
      taskId = vTask
      break
    end
  end
  if -1 == taskId then
    taskId = tbTaskGroupData.tasklist[#tbTaskGroupData.tasklist]
  end
  local tbTask = tbTaskData[taskId]
  if GroupId ~= AchievementData.AchivementPointTaskGroup then
    self:SwitchShowModel(EAchievementShowModel.Details, tbTask, GroupId)
  end
  if self:GetFirstView() then
    self:RequestGetAchievementInfo(DataMgr.GetUserId(), nil, true)
  end
end

function AchievementViewModel:UpdateAchievementList()
  if self:GetFirstView() then
    local achievementItemDataList = AchievementData:GetAchievementItemDataListByType(self.CurSelectToggleType)
    if self.AchievementShowModel == EAchievementShowModel.Details then
      self:GetFirstView():UpdateAchievementList(achievementItemDataList, self.CurSelectTaskId, self.CurSelectTaskGroupId)
    end
  end
end

function AchievementViewModel:UpdateAchievementPointAward()
  if self:GetFirstView() then
    local rewardList, idx = AchievementData:GetCurDoingPointAwards()
    self.CurShowPointAwardIdx = idx
    if rewardList and rewardList[1] then
      local taskId = AchievementData:GetPointTaskIdByIdx(idx)
      local targetValue = Logic_MainTask.GetFirstTargetValueByTaskId(taskId)
      local needPointNum = targetValue - AchievementData:GetCurAchievementPointNum()
      self:GetFirstView():UpdateAchievementPointAward(rewardList[1], needPointNum)
    end
  end
end

function AchievementViewModel:SwitchLeftPointAward()
  if self.CurShowPointAwardIdx == nil then
    return
  end
  if self.CurShowPointAwardIdx <= 1 then
    return
  end
  self.CurShowPointAwardIdx = self.CurShowPointAwardIdx - 1
  self:UpdateAchievementPointAwardByIdx(self.CurShowPointAwardIdx)
end

function AchievementViewModel:SwitchRightPointAward()
  if self.CurShowPointAwardIdx == nil then
    return
  end
  if self.CurShowPointAwardIdx >= #AchievementData.tbAchievementPointSort then
    return
  end
  self.CurShowPointAwardIdx = self.CurShowPointAwardIdx + 1
  self:UpdateAchievementPointAwardByIdx(self.CurShowPointAwardIdx)
end

function AchievementViewModel:UpdateAchievementPointAwardByIdx(Idx)
  if self:GetFirstView() then
    local rewardList = AchievementData:GetAwardsByIdx(Idx)
    if rewardList and rewardList[1] then
      local taskId = AchievementData:GetPointTaskIdByIdx(Idx)
      local targetValue = Logic_MainTask.GetFirstTargetValueByTaskId(taskId)
      local needPointNum = targetValue - AchievementData:GetCurAchievementPointNum()
      self:GetFirstView():UpdateAchievementPointAward(rewardList[1], needPointNum)
    end
  end
end

function AchievementViewModel:OnGetAchievementInfo()
  self:UpdateAchievementList()
  self:UpdateAchievementPointAward()
  if self:GetFirstView() then
    self:GetFirstView():OnUpdateAchievementPoint(AchievementData:GetCurAchievementPointNum())
    self:GetFirstView():OnUpdateDisplayBadges()
  end
end

function AchievementViewModel:OnSetDisplayBadges()
  if self:GetFirstView() then
    self:GetFirstView():OnUpdateDisplayBadges()
  end
end

function AchievementViewModel:ResetData()
end

function AchievementViewModel:GetAchievementToggleList()
  return AchievementData:GetAchievementTypeList()
end

function AchievementViewModel:GetCurSelectAchievementItemData()
  local achievementItemDataList = AchievementData:GetAchievementItemDataListByType(self.CurSelectToggleType)
  for i, v in ipairs(achievementItemDataList) do
    if self.CurSelectTaskGroupId == v.tbTaskGroup.id then
      return v
    end
  end
  return nil
end

function AchievementViewModel:GetTBAchievementPointSort()
  return AchievementData.tbAchievementPointSort
end

function AchievementViewModel:GetDisplayBadges()
  return AchievementData:GetDisplayBadges()
end

function AchievementViewModel:GetAchievementDisplayToggleList()
  return AchievementData.AchievementDisplayToggle
end

function AchievementViewModel:GetAchievementItemDataListByType(CurSelectToggleType)
  return AchievementData:GetAchievementItemDataListByType(CurSelectToggleType)
end

function AchievementViewModel:GetCurDoingPointTaskNeedPoint()
  local rewardList, idx = AchievementData:GetCurDoingPointAwards()
  if rewardList then
    local taskId = AchievementData:GetPointTaskIdByIdx(idx)
    local targetValue = Logic_MainTask.GetFirstTargetValueByTaskId(taskId)
    local needPointNum = targetValue - AchievementData:GetCurAchievementPointNum()
    return needPointNum
  end
  return -1
end

function AchievementViewModel:GetTypeToTbAchievement()
  return AchievementData.TypeToTbAchievement
end

function AchievementViewModel:GetAchivementPointTaskGroup()
  return AchievementData.AchivementPointTaskGroup
end

function AchievementViewModel:GetMaxDisplayBadgesNum()
  return AchievementData.MaxDisplayBadgesNum
end

function AchievementViewModel:GetAchievementBadges()
  local badgesTb = {}
  local allAchievementItemDataList = AchievementData:GetAllAchievementItemDataList()
  if allAchievementItemDataList then
    for i, v in ipairs(allAchievementItemDataList) do
      local idx = -1
      for idxTask, vTask in ipairs(v.tbTaskGroup.tasklist) do
        local state = Logic_MainTask.GetStateByTaskId(vTask)
        if state == ETaskState.GotAward then
          idx = idxTask
        end
      end
      if idx > 0 then
        local badge = v.Badges[idx]
        table.insert(badgesTb, badge)
      end
    end
    table.sort(badgesTb, function(A, B)
      local equipedA = table.Contain(AchievementData.DisplayBadges, A)
      local equipedB = table.Contain(AchievementData.DisplayBadges, B)
      if equipedA ~= equipedB then
        return equipedA
      end
      local generalA = tbGeneral[A]
      local generalB = tbGeneral[B]
      if generalA.Rare ~= generalB.Rare then
        return generalA.Rare > generalB.Rare
      end
      return B < A
    end)
  end
  return badgesTb
end

return AchievementViewModel
