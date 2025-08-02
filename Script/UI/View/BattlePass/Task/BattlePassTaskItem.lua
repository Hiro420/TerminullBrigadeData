local BattlePassTaskItem = UnLua.Class()

function BattlePassTaskItem:Construct()
  self.WBP_CommonButton_Receive.OnMainButtonClicked:Add(self, self.Receive)
  EventSystem.AddListener(self, EventDef.MainTask.OnMainTaskChange, self.OnMainTaskChange)
end

function BattlePassTaskItem:OnMainTaskChange(GroupId, TaskId)
  if GroupId == self.GroupId and TaskId == self.TaskId then
    self:InitTaskItem(TaskId)
    print("BattlePassTaskItem", TaskId)
  end
end

function BattlePassTaskItem:OnListItemObjectSet(Item)
  if not Item then
    return
  end
  self:PlayAnimation(self.Ani_in)
  self.Item = Item
  self.TaskId = Item.TaskId
  self.GroupId = Item.GroupId
  self:InitTaskItem(self.TaskId)
  print(self.GroupId, self.TaskId)
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.GroupId .. "_" .. self.TaskId)
end

function BattlePassTaskItem:InitTaskItem(TaskId)
  local TBTask = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if TBTask[TaskId] then
    self.Txt_Name:SetText(TBTask[TaskId].content)
    UpdateVisibility(self.Overlay_Loop, TBTask[TaskId].finishcount > 0, true)
  end
  local TaskInfo = Logic_MainTask.TaskInfo[TaskId]
  if not TaskInfo then
    return
  end
  for index, value in ipairs(TBTask[TaskId].rewardlist) do
    self.Txt_Num:SetText(value.value)
    self.WBP_Item:InitItem(value.key, value.value)
  end
  self.WBP_Item:UpdateReceivedPanelVis(3 == TaskInfo.state)
  UpdateVisibility(self.WBP_CommonButton_Receive, 2 == TaskInfo.state)
  UpdateVisibility(self.Overlay_Finish, 3 == TaskInfo.state)
  UpdateVisibility(self.WBP_CommonButton_UnFinish, 1 == TaskInfo.state)
  if 3 == TaskInfo.state then
    self.RGStateController_Finish:ChangeStatus("Finish")
  else
    self.RGStateController_Finish:ChangeStatus("NotFinish")
  end
  for index, value in ipairs(TaskInfo.counters) do
    local CanRewardCount = 0
    local CountValue = 0
    local TargetValue = 0
    if 0 ~= tonumber(value.countValue) then
      CanRewardCount = math.floor(tonumber(value.countValue) / value.TargetValue)
    end
    if TaskInfo.state >= 2 then
      CountValue = value.TargetValue
    else
      CountValue = tonumber(value.countValue) - CanRewardCount * value.TargetValue
    end
    TargetValue = value.TargetValue
    self.Txt_CurValue:SetText(CountValue)
    self.Txt_TargetValue:SetText(TargetValue)
    self.Progress:SetPercent(CountValue / TargetValue)
  end
end

function BattlePassTaskItem:GetLoopToolTipWidget()
  if not self.ToolTipWidget then
    self.ToolTipWidget = UE.UWidgetBlueprintLibrary.Create(self, self.WBP_BattlePassTask_LoopTips:GetClass())
  end
  local TaskInfo = Logic_MainTask.TaskInfo[self.TaskId]
  if not TaskInfo then
    return
  end
  self.ToolTipWidget.Txt_Cur:SetText(TaskInfo.rewardCount)
  local TBTask = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if TBTask[self.TaskId] then
    self.ToolTipWidget.Txt_Target:SetText(TBTask[self.TaskId].finishcount)
  end
  return self.ToolTipWidget
end

function BattlePassTaskItem:Receive()
  Logic_MainTask.ReceiveAward(self.GroupId, self.TaskId)
end

return BattlePassTaskItem
