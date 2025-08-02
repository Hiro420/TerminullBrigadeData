local BattlePassTaskView = UnLua.Class()
local DHFormat = NSLOCTEXT("BattlePassTaskView", "DHFormat", "{0}\229\164\169{1}\229\176\143\230\151\182")
local HMFormat = NSLOCTEXT("BattlePassTaskView", "HMFormat", "{0}\229\176\143\230\151\182{1}\229\136\134\233\146\159")
local MSFormat = NSLOCTEXT("BattlePassTaskView", "MSFormat", "{0}\229\136\134\233\146\159{1}\231\167\146")

function BattlePassTaskView:OnActivated()
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0, 0)
  self:InitGroupList()
end

function BattlePassTaskView:BindFunction()
  self.ToggleGroup.OnCheckStateChanged:Add(self, self.OnGroupChanged)
  self.Btn_ReceiveAward_New.OnMainButtonClicked:Add(self, self.OnReceiveAward)
end

function BattlePassTaskView:UnBindFunction()
  self.ToggleGroup.OnCheckStateChanged:Remove(self, self.OnGroupChanged)
  self.Btn_ReceiveAward_New.OnMainButtonClicked:Remove(self, self.OnReceiveAward)
end

function BattlePassTaskView:OnShow(BattlePassID)
  self:BindFunction()
  self.BattlePassID = BattlePassID
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ExitGameTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ExitGameTimer)
  end
  self.ExitGameTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      local TimeDifference = GetNextWeeklyRefreshTimeStamp(5, 1)
      if TimeDifference > 86400 then
        self.Txt_TimeLeft:SetText(UE.FTextFormat(DHFormat(), math.floor(TimeDifference / 86400), math.floor(TimeDifference % 86400 / 3600)))
      elseif TimeDifference > 3600 then
        self.Txt_TimeLeft:SetText(UE.FTextFormat(HMFormat(), math.floor(TimeDifference / 3600), math.floor(TimeDifference % 3600 / 60)))
      else
        self.Txt_TimeLeft:SetText(UE.FTextFormat(HMFormat(), math.floor(TimeDifference / 60), math.floor(TimeDifference % 60)))
      end
    end
  }, 1, true)
  local TBBattlePassTask = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassTask)
  if not TBBattlePassTask then
    return
  end
  for index, value in ipairs(TBBattlePassTask) do
    if value.BattlePassID == self.BattlePassID and value.TaskType == TableEnums.ENUMTaskType.WEEKLYTASK then
      self.WeeklyTaskGroupId = value.TaskGroupID
    end
    local TBTaskGroupData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
    if TBTaskGroupData[self.WeeklyTaskGroupId] and TBTaskGroupData[self.WeeklyTaskGroupId].resourceslimit then
      local ResourcesLimit = TBTaskGroupData[self.WeeklyTaskGroupId].resourceslimit
      if table.count(ResourcesLimit) > 0 then
        for index, value in ipairs(ResourcesLimit) do
          self.MaxWeeklyExp = value.value
          self.Txt_TargetExp:SetText(value.value)
        end
        break
      end
    end
  end
  if self.WeeklyTaskGroupId then
    self:OnMainTaskChange(self.WeeklyTaskGroupId, 1, true, true)
  end
  EventSystem.AddListener(self, EventDef.MainTask.OnMainTaskChange, self.OnMainTaskChange)
  local BattlePassMainViewModel = UIModelMgr:Get("BattlePassMainViewModel")
  if BattlePassMainViewModel then
    BattlePassMainViewModel:PullBattlePassTaskInfo()
  end
end

function BattlePassTaskView:OnMainTaskChange(GroupId, TaskId, bReceiveAward, bActiveCall)
  if not bReceiveAward then
    return
  end
  if GroupId ~= self.WeeklyTaskGroupId then
    return
  end
  local GroupInfo = Logic_MainTask.GroupInfo[GroupId]
  if not GroupInfo then
    return
  end
  if GroupInfo.resourceLimit then
    for key, value in pairs(GroupInfo.resourceLimit) do
      self.CurWeeklyExp = value
      self.Txt_CurExp:SetText(value)
      local material = self.Image_0:GetDynamicMaterial()
      material:SetScalarParameterValue("CirclePrecent", value / self.MaxWeeklyExp)
      print("BattlePassTaskView", value, self.MaxWeeklyExp, TaskId, bReceiveAward, bActiveCall)
      if value >= self.MaxWeeklyExp and not bActiveCall and 0 ~= TaskId and 3 == Logic_MainTask.TaskInfo[TaskId].state then
        ShowWaveWindow(306001)
        return
      end
    end
  end
end

function BattlePassTaskView:OnHide()
  self:StopAllAnimations()
  self:UnBindFunction()
  EventSystem.RemoveListener(EventDef.MainTask.OnMainTaskChange, self.OnMainTaskChange, self)
end

function BattlePassTaskView:InitGroupList()
  local TBBattlePassTask = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassTask)
  if not TBBattlePassTask then
    return
  end
  self.ToggleGroup:ClearGroup()
  local Index = 1
  for index, value in ipairs(TBBattlePassTask) do
    if value.BattlePassID == self.BattlePassID then
      local Item = GetOrCreateItem(self.GroupList, Index, self.WBP_BattlePassGroupItem:GetClass())
      if Item then
        Item:InitGroupItem(value.Name, value.TaskGroupID)
        self.ToggleGroup:AddToGroup(Index - 1, Item)
        Index = Index + 1
      end
    end
  end
  self.ToggleGroup:SelectId(0, true)
  self:OnGroupChanged(0)
  HideOtherItem(self.GroupList, Index, true)
end

function BattlePassTaskView:OnGroupChanged(Index)
  local Item = self.ToggleGroup:GetToggleById(Index)
  if not Item or not Item.TaskGroupID then
    return
  end
  self.SelTaskGroupID = Item.TaskGroupID
  if self.TimerTable ~= nil then
    for index, value in ipairs(self.TimerTable) do
      if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(value) then
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, value)
      end
    end
    self.TimerTable = {}
  end
  self.TaskListView:ClearListItems()
  local AllTask = Logic_MainTask.GroupInfo[Item.TaskGroupID].tasks
  table.sort(AllTask, function(a, b)
    if a.state ~= b.state then
      if 2 == a.state or 2 == b.state then
        return 2 == a.state
      elseif 1 == a.state or 1 == b.state then
        return 1 == a.state
      elseif 0 == a.state or 0 == b.state then
        return 0 == a.state
      elseif 3 == a.state or 3 == b.state then
        return 3 == a.state
      end
    end
    return a.taskID < b.taskID
  end)
  for index, value in ipairs(AllTask) do
    local Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        local Obj = NewObject(self.DataCls, self, nil)
        Obj.TaskId = value.taskID
        Obj.GroupId = Item.TaskGroupID
        self.TaskListView:AddItem(Obj)
      end
    }, 0.04 * index, false)
    if self.TimerTable == nil then
      self.TimerTable = {}
    end
    table.insert(self.TimerTable, Timer)
  end
end

function BattlePassTaskView:OnReceiveAward()
  Logic_MainTask.ReceiveAward(self.SelTaskGroupID)
end

return BattlePassTaskView
