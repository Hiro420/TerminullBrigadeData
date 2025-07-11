local WBP_RuleTaskCreditExchangeItem = UnLua.Class()
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")
function WBP_RuleTaskCreditExchangeItem:Construct()
  self.WBP_Item.OnClicked:Add(self, self.BindOnMainButtonClicked)
end
function WBP_RuleTaskCreditExchangeItem:Show(TaskId, TaskGroupId)
  UpdateVisibility(self, true)
  self.TaskId = TaskId
  self.TaskGroupId = TaskGroupId
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.TaskId)
  self.IsShow = true
  local Result, TaskRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskData, TaskId)
  if not Result then
    return
  end
  local PointNum = TaskRowInfo.targetEventsList[1].value
  self.Txt_PointNum:SetText(PointNum)
  local TargetReward = TaskRowInfo.rewardlist[1]
  UpdateVisibility(self.WBP_Item, nil ~= TargetReward)
  if TargetReward then
    self.WBP_Item:InitItem(TargetReward.key)
  end
  self:RefreshStatus()
end
function WBP_RuleTaskCreditExchangeItem:RefreshStatus(...)
  if not self.IsShow then
    return
  end
  local State = RuleTaskData:GetTaskState(self.TaskId)
  UpdateVisibility(self.Overlay_CanReceive, State == ETaskState.Finished)
  UpdateVisibility(self.CanvasPanel_Receive, State == ETaskState.Finished)
  UpdateVisibility(self.Overlay_Received, State == ETaskState.GotAward)
  UpdateVisibility(self.AchieveBottomPanel, State == ETaskState.GotAward or State == ETaskState.Finished)
  UpdateVisibility(self.UnAchieveBottomPanel, State ~= ETaskState.GotAward and State ~= ETaskState.Finished)
end
function WBP_RuleTaskCreditExchangeItem:BindOnMainButtonClicked()
  local State = RuleTaskData:GetTaskState(self.TaskId)
  if State ~= ETaskState.Finished then
    return
  end
  Logic_MainTask.ReceiveAward(self.TaskGroupId, self.TaskId)
end
function WBP_RuleTaskCreditExchangeItem:Hide(...)
  UpdateVisibility(self, false)
  self.TaskId = -1
  self.TaskGroupId = -1
  self.IsHide = false
end
return WBP_RuleTaskCreditExchangeItem
