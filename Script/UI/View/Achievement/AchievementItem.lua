local AchievementItem = UnLua.Class()
function AchievementItem:Construct()
  self.ButtonSelect.OnClicked:Add(self, self.OnSelectClick)
end
function AchievementItem:Destruct()
  self.ButtonSelect.OnClicked:Remove(self, self.OnSelectClick)
end
function AchievementItem:OnListItemObjectSet(ListItemObj)
  self.DataObj = ListItemObj
  local DataObjTemp = ListItemObj
  if not UE.RGUtil.IsUObjectValid(DataObjTemp) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(DataObjTemp.ParentView) then
    return
  end
  local curTaskIdx = DataObjTemp.CurTaskIdx
  local taskGroupId = DataObjTemp.TaskGroupId
  local taskGroupTb = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  local taskTb = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if not taskGroupTb or not taskTb then
    return
  end
  print("AchievementItem:OnListItemObjectSet taskGroupId", taskGroupId)
  local taskGroupTbData = taskGroupTb[taskGroupId]
  UpdateVisibility(self.ProgressBarStep, true)
  if #taskGroupTbData.tasklist > 0 then
    local num = 0
    for i, v in ipairs(taskGroupTbData.tasklist) do
      local state = Logic_MainTask.GetStateByTaskId(v)
      if state == ETaskState.Finished or state == ETaskState.GotAward then
        num = num + 1
      end
    end
    self.ProgressBarStep:SetPercent(num / #taskGroupTbData.tasklist)
  end
  UpdateVisibility(self.CanvasPanelStep, #taskGroupTbData.tasklist > 1)
  self.RGTextStep:SetText(curTaskIdx)
  self.RGStateControllerLock:ChangeStatus(tostring(DataObjTemp.LockStatus))
  local curTaskId = taskGroupTbData.tasklist[curTaskIdx]
  local taskTbData = taskTb[curTaskId]
  self.taskTbData = taskTbData
  self.RGTextName:SetText(taskTbData.name)
  SetImageBrushByPath(self.URGImageIcon, taskTbData.icon)
  local firstCount = tonumber(Logic_MainTask.GetFirstCountValueByTaskId(curTaskId))
  local firstTargetCount = Logic_MainTask.GetFirstTargetValueByTaskId(curTaskId)
  local progress = firstCount / firstTargetCount
  self.URGImageProgress:SetClippingValue(progress)
  print("AchievementItem:OnListItemObjectSet", firstCount, firstTargetCount, progress)
  self.RGStateControllerSelect:ChangeStatus(tostring(DataObjTemp.SelectStatus))
  self.WBP_RedDotView:ChangeRedDotIdByTag(taskGroupId)
end
function AchievementItem:BP_OnEntryReleased()
  self.DataObj = nil
  self.taskTbData = nil
end
function AchievementItem:OnMouseEnter()
  self.RGStateControllerHover:ChangeStatus(tostring(2))
end
function AchievementItem:OnMouseLeave()
  self.RGStateControllerHover:ChangeStatus(tostring(1))
end
function AchievementItem:OnSelectClick()
  if not UE.RGUtil.IsUObjectValid(self.DataObj) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  if not self.taskTbData then
    return
  end
  self.RGStateControllerHover:ChangeStatus(tostring(1))
  local state = Logic_MainTask.GetStateByTaskId(self.taskTbData.id)
  if state == ETaskState.Finished then
    self.DataObj.ParentView:ReceiveTaskAward(self.DataObj.TaskGroupId, self.taskTbData.id)
  else
    self.DataObj.ParentView:SelectItem(EAchievementShowModel.Details, self.taskTbData, self.DataObj.TaskGroupId)
    self.DataObj.SelectStatus = EAchievementItemSelectState.Select
    self.RGStateControllerSelect:ChangeStatus(tostring(EAchievementItemSelectState.Select))
  end
end
return AchievementItem
