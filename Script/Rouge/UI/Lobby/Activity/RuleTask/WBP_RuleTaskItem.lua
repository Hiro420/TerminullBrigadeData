local WBP_RuleTaskItem = UnLua.Class()
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")
function WBP_RuleTaskItem:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end
function WBP_RuleTaskItem:Show(RuleInfoId)
  self.RuleInfoId = RuleInfoId
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.RuleInfoId)
  self.IsShow = true
  UpdateVisibility(self, true)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleInfo, self.RuleInfoId)
  if not Result then
    return
  end
  self.MainTaskGroupId = RowInfo.MainTaskGroupId
  self.MinorTaskGroupId = RowInfo.MinorTaskGroupId
  SetImageBrushByPath(self.Img_Icon, RowInfo.IconPath)
  SetImageBrushByPath(self.Img_LockIcon, RowInfo.IconPath)
  SetImageBrushByPath(self.Img_FinishedIcon, RowInfo.FinishedIconPath)
  self:RefreshStatus()
end
function WBP_RuleTaskItem:RefreshStatus(...)
  if not self.IsShow then
    return
  end
  local CurStatus = self:GetMainTaskGroupStatus()
  UpdateVisibility(self.Overlay_Finished, CurStatus == ETaskGroupState.Finished or CurStatus == ETaskGroupState.GotAward)
  UpdateVisibility(self.Overlay_Unlock, CurStatus == ETaskGroupState.UnFinished)
  local MinorStatus = RuleTaskData:GetTaskGroupState(self.MinorTaskGroupId)
  local IsAllFinished = (CurStatus == ETaskGroupState.Finished or CurStatus == ETaskGroupState.GotAward) and (MinorStatus == ETaskGroupState.Finished or MinorStatus == ETaskGroupState.GotAward)
  UpdateVisibility(self.Overlay_AllFinished, IsAllFinished)
  UpdateVisibility(self.CanvasPanel_Finished, not IsAllFinished)
  local Result, TaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, self.MainTaskGroupId)
  local IsLock = not Result
  if Result then
    local CurTimestamp = GetLocalTimestampByServerTimeZone()
    local StartTimestamp = ConvertTimeStrToServerTimeByServerTimeZone(TaskGroupRowInfo.starttime)
    local EndTimestamp = ConvertTimeStrToServerTimeByServerTimeZone(TaskGroupRowInfo.endtime)
    IsLock = CurTimestamp < StartTimestamp or CurTimestamp > EndTimestamp
  end
  self.IsLockByTime = IsLock
  if IsLock then
    local Result, Date = UE.UKismetMathLibrary.DateTimeFromString(TaskGroupRowInfo.starttime, nil)
    if Result then
      local Text = UE.FTextFormat(self.UnLockTimeText, UE.UKismetMathLibrary.GetMonth(Date), UE.UKismetMathLibrary.GetDay(Date))
      self.Txt_UnlockTime:SetText(Text)
    end
  end
  self.IsLockByPreTaskGroup = false
  if not IsLock then
    for i, SingleTaskId in ipairs(TaskGroupRowInfo.tasklist) do
      local Result, TaskRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskData, SingleTaskId)
      if Result then
        local TaskState = RuleTaskData:GetTaskState(SingleTaskId)
        if TaskState == ETaskState.Lock or TaskState == ETaskState.None then
          IsLock = true
          self.Txt_UnlockTime:SetText(TaskRowInfo.conditionnote)
          break
        end
      end
    end
    self.IsLockByPreTaskGroup = IsLock
  end
  UpdateVisibility(self.Overlay_Lock, IsLock)
  UpdateVisibility(self.HorizontalBox_Progress, not IsLock and not IsAllFinished)
  UpdateVisibility(self.CanvasPanel_UnFinished, not IsLock)
  if not IsLock and not IsAllFinished then
    local MainTaskFinishNum, MainTaskAllNum = RuleTaskData:GetTaskGroupProgress(self.MainTaskGroupId)
    local MinorTaskFinishNum, MinorTaskAllNum = RuleTaskData:GetTaskGroupProgress(self.MinorTaskGroupId)
    self.Txt_FinishNum:SetText(MainTaskFinishNum + MinorTaskFinishNum)
    self.Txt_AllNum:SetText(MainTaskAllNum + MinorTaskAllNum)
  end
end
function WBP_RuleTaskItem:GetMainTaskGroupStatus()
  return RuleTaskData:GetTaskGroupState(self.MainTaskGroupId)
end
function WBP_RuleTaskItem:BindOnMainButtonClicked(...)
  if self.IsLockByTime then
    ShowWaveWindow(self.LockWaveId)
    return
  end
  if self.IsLockByPreTaskGroup then
    ShowWaveWindow(self.LockByPreTaskGroupWaveId)
    return
  end
  EventSystem.Invoke(EventDef.RuleTask.OnShowRuleTaskDetailPanel, self.RuleInfoId)
end
function WBP_RuleTaskItem:BindOnMainButtonHovered(...)
  local WidgetClassPath = "/Game/Rouge/UI/Lobby/Activity/RuleTask/WBP_RuleTaskItemTip.WBP_RuleTaskItemTip_C"
  local TipsOffset = UE.FVector2D(90, 0)
  if self.RuleInfoId == 1000103 or self.RuleInfoId == 1000104 then
    TipsOffset = UE.FVector2D(20, 0)
  end
  self.WBP_RuleTaskItemTip = ShowCommonTips(nil, self, nil, WidgetClassPath, nil, nil, TipsOffset)
  self.WBP_RuleTaskItemTip:Show(self.RuleInfoId)
end
function WBP_RuleTaskItem:BindOnMainButtonUnhovered(...)
  UpdateVisibility(self.WBP_RuleTaskItemTip, false)
end
function WBP_RuleTaskItem:GetToolTipWidget(...)
end
function WBP_RuleTaskItem:Hide(...)
  UpdateVisibility(self, false)
  self.IsShow = false
  self.RuleInfoId = -1
  self.MainTaskGroupId = -1
  if self.WBP_RuleTaskItemTip and self.WBP_RuleTaskItemTip:IsValid() then
    UpdateVisibility(self.WBP_RuleTaskItemTip, false)
  end
end
return WBP_RuleTaskItem
