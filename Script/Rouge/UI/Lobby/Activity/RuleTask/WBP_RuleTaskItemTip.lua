local WBP_RuleTaskItemTip = UnLua.Class()
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")
function WBP_RuleTaskItemTip:Show(RuleInfoId)
  local Result, RuleInfoRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleInfo, RuleInfoId)
  if not Result then
    return
  end
  self.Txt_Name:SetText(RuleInfoRowInfo.Name)
  self.Txt_Desc:SetText(RuleInfoRowInfo.Desc)
  local MainTaskFinishNum, MainTaskAllNum = RuleTaskData:GetTaskGroupProgress(RuleInfoRowInfo.MainTaskGroupId)
  self.Txt_CurMainTaskFinishNum:SetText(MainTaskFinishNum)
  self.Txt_MaxMainTaskNum:SetText(MainTaskAllNum)
  local MinorTaskFinishNum, MinorTaskAllNum = RuleTaskData:GetTaskGroupProgress(RuleInfoRowInfo.MinorTaskGroupId)
  self.Txt_CurMinorTaskFinishNum:SetText(MinorTaskFinishNum)
  self.Txt_MaxMinorTaskNum:SetText(MinorTaskAllNum)
  SetImageBrushByPath(self.Img_RuleIcon, RuleInfoRowInfo.IconPath)
  self.Img_RuleIcon:SetColorAndOpacity(HexToFLinearColor(RuleInfoRowInfo.TipIconColor))
  local Result, TaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, RuleInfoRowInfo.MainTaskGroupId)
  local IsLock = not Result
  if Result then
    local CurTimestamp = GetLocalTimestampByServerTimeZone()
    local StartTimestamp = ConvertTimeStrToServerTimeByServerTimeZone(TaskGroupRowInfo.starttime)
    local EndTimestamp = ConvertTimeStrToServerTimeByServerTimeZone(TaskGroupRowInfo.endtime)
    IsLock = CurTimestamp < StartTimestamp or CurTimestamp > EndTimestamp
  end
  if IsLock then
    local Result, Date = UE.UKismetMathLibrary.DateTimeFromString(TaskGroupRowInfo.starttime, nil)
    if Result then
      local Text = UE.FTextFormat(self.UnLockTimeText, UE.UKismetMathLibrary.GetMonth(Date), UE.UKismetMathLibrary.GetDay(Date))
      self.Txt_UnlockTime:SetText(Text)
    end
  end
  local IsLockByPreTaskGroup = false
  local LockText = ""
  if not IsLock then
    for i, SingleTaskId in ipairs(TaskGroupRowInfo.tasklist) do
      local Result, TaskRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskData, SingleTaskId)
      if Result then
        local TaskState = RuleTaskData:GetTaskState(SingleTaskId)
        if TaskState == ETaskState.Lock or TaskState == ETaskState.None then
          IsLock = true
          LockText = TaskRowInfo.conditionnote
          self.Txt_UnlockTime:SetText(LockText)
          break
        end
      end
    end
    IsLockByPreTaskGroup = IsLock
  end
  UpdateVisibility(self.UnlockTipPanel, IsLock)
  local Result, TaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, RuleInfoRowInfo.MainTaskGroupId)
  if not Result then
    return
  end
  local TargetReward = TaskGroupRowInfo.rewardlist[1]
  UpdateVisibility(self.Overlay_Reward, nil ~= TargetReward)
  if TargetReward then
    self.WBP_Item:InitItem(TargetReward.key)
    local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, TargetReward.key)
    if Result then
      self.Txt_ItemName:SetText(UE.FTextFormat("{0}*{1}", ResourceRowInfo.Name, TargetReward.value))
    end
  end
end
return WBP_RuleTaskItemTip
