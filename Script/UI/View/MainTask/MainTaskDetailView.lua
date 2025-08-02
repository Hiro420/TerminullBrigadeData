local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local MainTaskDetailView = Class(ViewBase)

function MainTaskDetailView:OnBindUIInput()
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    function()
      if not self:IsAnimationPlaying(self.Anim_OUT) then
        self:PlayAnimation(self.Anim_OUT)
        return
      end
    end
  })
  self.WBP_InteractTipWidgetReceiveReward:BindInteractAndClickEvent(self, self.ReceiveAward)
end

function MainTaskDetailView:OnUnBindUIInput()
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  self.WBP_InteractTipWidgetReceiveReward:UnBindInteractAndClickEvent(self, self.ReceiveAward)
end

function MainTaskDetailView:BindClickHandler()
  self.TaskList.BP_OnItemSelectionChanged:Add(self, MainTaskDetailView.OnItemSelectionChanged)
end

function MainTaskDetailView:UnBindClickHandler()
end

function MainTaskDetailView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function MainTaskDetailView:OnDestroy()
  self:UnBindClickHandler()
end

function MainTaskDetailView:OnShow(LastMainTaskId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.LastMainTaskId = LastMainTaskId
  self:InitTab()
  self.WBP_InteractTipWidget.OnMainButtonClicked:Clear()
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, function()
    if not self:IsAnimationPlaying(self.Anim_OUT) then
      self:PlayAnimation(self.Anim_OUT)
      return
    end
  end)
  self:SetEnhancedInputActionBlocking(true)
  self.Btn_ReceiveReward.OnClicked:Add(self, self.ReceiveAward)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnMainTaskDetailViewShow)
  EventSystem.AddListener(self, EventDef.MainTask.OnMainTaskRefres, MainTaskDetailView.InitTab)
end

function MainTaskDetailView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.Btn_ReceiveReward.OnClicked:Remove(self, self.ReceiveAward)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShow)
  EventSystem.RemoveListener(EventDef.MainTask.OnMainTaskRefres, MainTaskDetailView.InitTab, self)
  self:SetEnhancedInputActionBlocking(false)
end

function MainTaskDetailView:OnAnimationFinished(Animation)
  if Animation == self.Anim_OUT then
    UIMgr:Hide(ViewID.UI_MainTaskDetail, true)
  end
end

function MainTaskDetailView:InitTab()
  self.TabCache = {}
  for index, value in ipairs(self.VerticalBox_World:GetAllChildren():ToTable()) do
    value:InitWorldView(function()
      self:SelectedTab(value.MainTaskId)
    end)
    value:OnSelected(false)
    self.TabCache[value.MainTaskId] = value
  end
  self:SelectedTab(self.LastMainTaskId)
end

function MainTaskDetailView:SelectedTab(MainTaskId)
  if self.TabCache[self.LastMainTaskId] then
    self.TabCache[self.LastMainTaskId]:OnSelected(false)
  end
  if self.TabCache[MainTaskId] then
    self.TabCache[MainTaskId]:OnSelected(true)
  end
  self.LastMainTaskId = MainTaskId
  self:RefreshTaskList(MainTaskId)
end

function MainTaskDetailView:RefreshTaskList(MainTaskId)
  local ActiveTasks = Logic_MainTask.GetGroupShowTask(MainTaskId)
  UpdateVisibility(self.TaskList, nil ~= ActiveTasks and 0 ~= table.count(ActiveTasks))
  UpdateVisibility(self.TextTask, nil ~= ActiveTasks and 0 ~= table.count(ActiveTasks))
  UpdateVisibility(self.AwardList, nil ~= ActiveTasks and 0 ~= table.count(ActiveTasks))
  if nil == ActiveTasks or 0 == table.count(ActiveTasks) then
    return
  end
  table.sort(ActiveTasks, function(a, b)
    local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
    local ASortId = TaskData[a.taskID].tasksort
    local BSortId = TaskData[b.taskID].tasksort
    local ReturnVal = ASortId > BSortId
    if a.state ~= b.state then
      print(a.state)
      if 2 == a.state or 2 == b.state then
        return 2 == a.state
      elseif 1 == a.state or 1 == b.state then
        return 1 == a.state
      elseif 3 == a.state or 3 == b.state then
        return 3 == a.state
      elseif 0 == a.state or 0 == b.state then
        return 0 == a.state
      end
      return ASortId > BSortId
    end
    if a.state == b.state then
      return ASortId < BSortId
    end
    return ReturnVal
  end)
  self.TaskList:ClearListItems()
  for index, value in ipairs(ActiveTasks) do
    local Item = self.TaskList:GetOrCreateDataObj()
    Item.Finish = 2 == value.state or 3 == value.state
    Item.Receive = 3 == value.state
    Item.TaskId = value.taskID
    Item.GroupId = MainTaskId
    self.TaskList:AddItem(Item)
  end
  self.TaskList:SetSelectedIndex(0)
end

function MainTaskDetailView:OnItemSelectionChanged(Item, bSelected)
  if bSelected and Item then
    self.SelItem = Item
    self:RefreshTaskDescAndAward(Item)
    self:RefreshTaskProgress(Item)
  end
end

function MainTaskDetailView:RefreshTaskDescAndAward(Item)
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  self.TextTaskTitle:SetText(TaskData[Item.TaskId].name)
  self.TextTask:SetText(TaskData[Item.TaskId].content)
  local Index = 1
  UpdateVisibility(self.TextBlockReceive, Logic_MainTask.IsTaskReceive(Item.TaskId))
  for key, value in pairs(TaskData[Item.TaskId].rewardlist) do
    local ItemWidget = GetOrCreateItem(self.AwardList, Index, self.WBP_Item:GetClass())
    UpdateVisibility(ItemWidget, true)
    ItemWidget:InitItem(value.key, value.value)
    UpdateVisibility(ItemWidget.Text_Name, false)
    Index = Index + 1
  end
  HideOtherItem(self.AwardList, Index)
  if 1 ~= Index and not Item.Receive and Item.Finish then
    UpdateVisibility(self.Btn_ReceiveReward, true, true)
  else
    UpdateVisibility(self.Btn_ReceiveReward, false)
  end
end

function MainTaskDetailView:HoveredFunc()
  UpdateVisibility(self.WBP_CommonItemDetail, true)
  local MousePosition = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
  local Size = UE.USlateBlueprintLibrary.GetLocalSize(self.WBP_CommonItemDetail:GetCachedGeometry())
  MousePosition.Y = MousePosition.Y - Size.Y
  if self.WBP_CommonItemDetail.Slot then
    self.WBP_CommonItemDetail.Slot:SetAutoSize(true)
    self.WBP_CommonItemDetail.Slot:SetPosition(MousePosition)
  end
end

function MainTaskDetailView:UnHoveredFunc()
  UpdateVisibility(self.WBP_CommonItemDetail, false)
end

function MainTaskDetailView:ReceiveAward()
  if not self.Btn_ReceiveReward:IsVisible() then
    return
  end
  Logic_MainTask.ReceiveAward(self.SelItem.GroupId, self.SelItem.TaskId)
end

function MainTaskDetailView:RefreshTaskProgress(Item)
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  UpdateVisibility(self.Overlay_Finish, Logic_MainTask.GetStateByTaskId(Item.TaskId) >= 2)
  UpdateVisibility(self.Overlay_UnFinish, Logic_MainTask.GetStateByTaskId(Item.TaskId) < 2)
  UpdateVisibility(self.Image_Finish, Logic_MainTask.GetStateByTaskId(Item.TaskId) >= 2)
  UpdateVisibility(self.Image_UnFinish, Logic_MainTask.GetStateByTaskId(Item.TaskId) < 2)
  if TaskData[Item.TaskId].conditionnote then
    self.RichTextBlock_Condition:SetText(TaskData[Item.TaskId].conditionnote)
  end
  local Total = 0
  local FinishNum = 0
  for index, value in ipairs(Logic_MainTask.TaskInfo[Item.TaskId].counters) do
    FinishNum = value.countValue
    Total = value.TargetValue
  end
  if tonumber(FinishNum) > tonumber(Total) then
    FinishNum = Total
  end
  self.TextProgress:SetText(FinishNum .. "/" .. Total)
  UpdateVisibility(self.TextProgress, 0 ~= Total)
end

return MainTaskDetailView
