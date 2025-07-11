local AchievementDetailsItem = UnLua.Class()
function AchievementDetailsItem:Construct()
  self.ButtonWithSoundLeft.OnClicked:Add(self, self.OnLeftClick)
  self.ButtonWithSoundRight.OnClicked:Add(self, self.OnRightClick)
end
function AchievementDetailsItem:Destruct()
end
function AchievementDetailsItem:InitAchievementDetailsItem(AchievementItemDataParam, taskId, ParentView)
  if not AchievementItemDataParam then
    print("AchievementDetailsItem:InitAchievementDetailsItem AchievementItemDataParam Is Nil", taskId)
    return
  end
  self.ParentView = ParentView
  self.CurSelectTaskId = taskId
  self.DisplayAchievementItemData = AchievementItemDataParam
  local bShowStep = #AchievementItemDataParam.tbTaskList > 1
  UpdateVisibility(self.HorizontalBoxStep, bShowStep)
  UpdateVisibility(self.ButtonWithSoundLeft, bShowStep, true)
  UpdateVisibility(self.ButtonWithSoundRight, bShowStep, true)
  UpdateVisibility(self.CanvasPanelStep, bShowStep, true)
  local idx = 1
  local achievementItemLockState = EAchievementItemLockState.Lock
  for i, v in ipairs(AchievementItemDataParam.tbTaskList) do
    local stepItem = GetOrCreateItem(self.HorizontalBoxStep, i, self.WBP_AchievementStepItem:GetClass())
    UpdateVisibility(stepItem, true)
    local state = Logic_MainTask.GetStateByTaskId(v.id)
    if state ~= ETaskState.Lock and state ~= ETaskState.None and state ~= ETaskState.UnFinished then
      achievementItemLockState = EAchievementItemLockState.UnLock
    end
    print("AchievementDetailsItem:InitAchievementDetailsItem state", state, v.id, taskId)
    if state == ETaskState.Lock or state == ETaskState.None or state == ETaskState.UnFinished then
      stepItem.RGStateControllerLock:ChangeStatus(ELock.Lock)
    else
      stepItem.RGStateControllerLock:ChangeStatus(ELock.UnLock)
    end
    if v.id == taskId then
      idx = i
      SetImageBrushByPath(self.URGImageIcon, v.icon)
      stepItem.RGStateControllerHighlight:ChangeStatus(2)
    else
      stepItem.RGStateControllerHighlight:ChangeStatus(1)
    end
  end
  self.CurSelectIdx = idx
  self.RGTextStep:SetText(self.CurSelectIdx)
  HideOtherItem(self.HorizontalBoxStep, #AchievementItemDataParam.tbTaskList + 1)
  self.RGStateControllerLock:ChangeStatus(tostring(achievementItemLockState))
end
function AchievementDetailsItem:OnMouseEnter()
  self.RGStateControllerHover:ChangeStatus(tostring(2))
end
function AchievementDetailsItem:OnMouseLeave()
  self.RGStateControllerHover:ChangeStatus(tostring(1))
end
function AchievementDetailsItem:OnLeftClick()
  if not self.DisplayAchievementItemData then
    return
  end
  if self.CurSelectIdx <= 1 then
    return
  end
  self.CurSelectIdx = self.CurSelectIdx - 1
  if self.ParentView then
    self.ParentView:SwitchShowModel(self.ParentView.viewModel.AchievementShowModel, self.DisplayAchievementItemData.tbTaskList[self.CurSelectIdx], self.DisplayAchievementItemData.tbTaskGroup.id, true)
  end
end
function AchievementDetailsItem:OnRightClick()
  if not self.DisplayAchievementItemData then
    return
  end
  if self.CurSelectIdx >= #self.DisplayAchievementItemData.tbTaskList then
    return
  end
  self.CurSelectIdx = self.CurSelectIdx + 1
  if self.ParentView then
    self.ParentView:SwitchShowModel(self.ParentView.viewModel.AchievementShowModel, self.DisplayAchievementItemData.tbTaskList[self.CurSelectIdx], self.DisplayAchievementItemData.tbTaskGroup.id, true)
  end
end
return AchievementDetailsItem
