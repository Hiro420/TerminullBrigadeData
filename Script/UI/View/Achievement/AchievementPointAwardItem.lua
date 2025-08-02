local AchievementPointAwardItem = UnLua.Class()

function AchievementPointAwardItem:Construct()
  self.BP_ButtonWithSoundGetAward.OnClicked:Add(self, self.OnGetAwardClick)
end

function AchievementPointAwardItem:Destruct()
end

function AchievementPointAwardItem:InitAchievementPointAwardItem(tbTask, bSelect, ParentView, AwardListView)
  if not tbTask then
    return
  end
  UpdateVisibility(self, true)
  local generalId = tbTask.rewardlist[1].key
  self.GeneralId = generalId
  self.WBP_Item:InitItem(tbTask.rewardlist[1].key, tbTask.rewardlist[1].value)
  local taskId = tbTask.id
  local firstCount = tonumber(Logic_MainTask.GetFirstCountValueByTaskId(taskId))
  local targetCount = Logic_MainTask.GetFirstTargetValueByTaskId(taskId)
  self.RGTextPointNum:SetText(targetCount)
  local state = Logic_MainTask.GetStateByTaskId(taskId)
  self.RGStateController:ChangeStatus(tostring(state))
  if bSelect then
    self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
  else
    self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
  end
  self.ParentView = ParentView
  self.AwardListView = AwardListView
  self.TaskId = taskId
end

function AchievementPointAwardItem:OnMouseEnter()
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
  if self.AwardListView then
    self.AwardListView:ShowAwardTips(self.GeneralId, true, self)
  end
end

function AchievementPointAwardItem:OnMouseLeave()
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  if self.AwardListView then
    self.AwardListView:ShowAwardTips(self.GeneralId, false, self)
  end
end

function AchievementPointAwardItem:OnGetAwardClick()
  if not self.ParentView then
    return
  end
  self.ParentView:ReceivePointAwards({
    self.TaskId
  })
end

function AchievementPointAwardItem:Hide()
  UpdateVisibility(self, false)
end

return AchievementPointAwardItem
