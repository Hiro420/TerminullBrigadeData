local WBP_RuleTaskDetailTaskItem = UnLua.Class()
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")
function WBP_RuleTaskDetailTaskItem:Construct()
  self.Btn_Receive.OnMainButtonClicked:Add(self, self.BindOnReceiveButtonClicked)
end
function WBP_RuleTaskDetailTaskItem:Show(TaskId, TaskGroupId, IsMainTaskGroup, MainTaskBottomColor)
  UpdateVisibility(self, true)
  UpdateVisibility(self.Overlay_MainTaskFlag, IsMainTaskGroup)
  if IsMainTaskGroup and MainTaskBottomColor then
    local LineColor = HexToFLinearColor(MainTaskBottomColor)
    self.Image_MainTask:SetColorAndOpacity(LineColor)
  end
  self.TaskId = TaskId
  self.TaskGroupId = TaskGroupId
  local Result, TaskRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskData, self.TaskId)
  if not Result then
    print("WBP_RuleTaskDetailTaskItem:RefreshTaskStatus not found task row info!", self.TaskId)
    return
  end
  self.DescText = TaskRowInfo.content
  self.CounterId = TaskRowInfo.targetEventsList[1].id
  self.MaxNum = TaskRowInfo.targetEventsList[1].value
  local TargetReward = TaskRowInfo.rewardlist[1]
  self.WBP_Item:InitItem(TargetReward.key)
  self.Txt_RewardNum:SetText(string.format("x%d", TargetReward.value))
  self:RefreshTaskStatus()
  self:ChangeLineVis(false)
end
function WBP_RuleTaskDetailTaskItem:RefreshTaskStatus()
  if not self:CanRefreshTaskStatus() then
    return
  end
  local CurNum = math.clamp(RuleTaskData:GetTaskCountValue(self.TaskId, self.CounterId), 0, self.MaxNum)
  local TargetDesc = UE.FTextFormat("{0} (<RuleTaskDetailNum>{1}</>/{2})", self.DescText, CurNum, self.MaxNum)
  self.Txt_TaskDesc:SetText(TargetDesc)
  self.Progress_Task:SetPercent(CurNum / self.MaxNum)
  local TaskState = RuleTaskData:GetTaskState(self.TaskId)
  UpdateVisibility(self.Overlay_Received, TaskState == ETaskState.GotAward)
  local StyleName = ""
  local ContentText = ""
  if TaskState == ETaskState.Finished then
    StyleName = self.FinishedBtnStyle
    ContentText = self.ReceiveText
  elseif TaskState == ETaskState.GotAward then
    StyleName = self.GetRewardBtnStyle
    ContentText = self.ReceivedText
  else
    StyleName = self.LockBtnStyle
    ContentText = self.UnReceiveText
  end
  self.Btn_Receive:SetStyleByBottomStyleRowName(StyleName)
  self.Btn_Receive:SetContentText(ContentText)
end
function WBP_RuleTaskDetailTaskItem:CanRefreshTaskStatus()
  return -1 ~= self.TaskGroupId and -1 ~= self.TaskId
end
function WBP_RuleTaskDetailTaskItem:BindOnReceiveButtonClicked(...)
  local TaskState = RuleTaskData:GetTaskState(self.TaskId)
  if TaskState ~= ETaskState.Finished then
    return
  end
  Logic_MainTask.ReceiveAward(self.TaskGroupId, self.TaskId)
end
function WBP_RuleTaskDetailTaskItem:ChangeLineVis(IsShow)
  UpdateVisibility(self.URGImage_Line, IsShow)
end
function WBP_RuleTaskDetailTaskItem:Hide()
  UpdateVisibility(self, false)
  self.TaskId = -1
  self.TaskGroupId = -1
end
return WBP_RuleTaskDetailTaskItem
