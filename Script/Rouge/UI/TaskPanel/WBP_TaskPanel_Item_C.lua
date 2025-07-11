local WBP_TaskPanel_Item_C = UnLua.Class()
function WBP_TaskPanel_Item_C:Construct()
end
function WBP_TaskPanel_Item_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_win_out or Animation == self.Ani_fail_out then
    self.GoneForever = true
    self:RemoveFromParent()
  end
end
function WBP_TaskPanel_Item_C:UpdateInfo(TaskInfo)
  self:InitWidgetConfig(TaskInfo)
  if not self.EventList or not self.EventList.GetAllChildren then
    return
  end
  if not self.EventList:IsValid() or not UE.RGUtil.IsUObjectValid(self.EventList) then
    return
  end
  local ItemListArr = self.EventList:GetAllChildren()
  if ItemListArr:Num() > 0 then
    for index, value in ipairs(ItemListArr:ToTable()) do
      value:UpdateEventPanel(TaskInfo)
    end
  end
  if self.TaskStatu ~= TaskInfo.Status then
    self.GoneForever = false
    self:UpdateWidgetConfig(TaskInfo.Status)
    self.TaskStatu = TaskInfo.Status
  end
end
function WBP_TaskPanel_Item_C:InitWidgetConfig(TaskInfo)
  if self.TaskId ~= TaskInfo.EventId then
    self.TaskId = TaskInfo.EventId
  else
    return
  end
  print("WBP_TaskPanel_Item_C:InitWidgetConfig", self, TaskInfo.EventId)
  self:PlayAnimation(self.Ani_in)
  local TaskPanelRowId = 0
  local rowName = TaskInfo.EventId
  if TaskInfo.bIsCustomTask then
    rowName = TaskInfo.GamePlayTaskRowName
  end
  local Result, Row = GetRowData(DT.DT_ActionEventGameplayTask, rowName)
  if Result then
    TaskPanelRowId = Row.TaskPanelRowId
  else
    local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
    if TaskData and TaskData[TaskInfo.EventId] and TaskData[TaskInfo.EventId].taskPanelRowId > 0 then
      TaskPanelRowId = TaskData[TaskInfo.EventId].taskPanelRowId
    else
      TaskPanelRowId = -1
    end
  end
  local Result1, PanelRow = GetRowData(DT.DT_TaskPanelTable, TaskPanelRowId)
  if not Result1 then
    return
  end
  self.WidgetConfig = PanelRow
  self.EventList:ClearChildren()
  local EventConfig = self.WidgetConfig.EventConfig:ToTable()
  local EventConfigKeysArr = self.WidgetConfig.EventConfig:Keys()
  for i = 1, self.WidgetConfig.EventConfig:Length() do
    local EventId = EventConfigKeysArr:Get(i)
    local TaskEventConfig = self.WidgetConfig.EventConfig:Find(EventId)
    local Widget = UE.UWidgetBlueprintLibrary.Create(self, UE.LoadClass(UE.UKismetSystemLibrary.BreakSoftClassPath(TaskEventConfig.WidgetClass)))
    if Widget then
      Widget:InitEventPanel(TaskEventConfig, tonumber(EventId), TaskInfo.EventId)
      if Widget.Img_TaskState then
        Widget.Img_TaskState:SetColorAndOpacity(TaskEventConfig.InColorAndOpacity)
      end
      self.EventList:AddChild(Widget)
    end
  end
  if self.WidgetConfig.bHallTask then
    self.Text_TitleName:SetColorAndOpacity(self.HallColor)
  else
    self.Text_TitleName:SetColorAndOpacity(self.GamePlayColor)
  end
  SetImageBrushBySoftObjectPath(self.Img_TitleIcon_Bg1, self.WidgetConfig.TitleBg1)
  SetImageBrushBySoftObjectPath(self.Img_TitleIcon_Bg2, self.WidgetConfig.TitleBg2)
end
function WBP_TaskPanel_Item_C:UpdateWidgetConfig(TaskStatus)
  if self.WidgetConfig then
    self.Text_TitleName:SetText(self.WidgetConfig.TitleName)
    if TaskStatus == UE.ERGActionEventTaskStatus.Running then
      SetImageBrushBySoftObjectPath(self.Img_TitleIcon, self.WidgetConfig.TitleIcon)
      self.TitlePanel:SetRenderOpacity(1)
    elseif TaskStatus == UE.ERGActionEventTaskStatus.Complete or TaskStatus == UE.ERGActionEventTaskStatus.RewardTaken then
      if self.WidgetConfig.HideOnFinish then
        self:PlayAnimation(self.Ani_win_out)
      else
        self:PlayAnimation(self.Ani_win_dark)
      end
      SetImageBrushBySoftObjectPath(self.Img_TitleIcon, self.WidgetConfig.TitleFinishIcon)
    elseif TaskStatus == UE.ERGActionEventTaskStatus.None or TaskStatus == UE.ERGActionEventTaskStatus.Fail then
      if self.WidgetConfig.HideOnFinish then
      else
      end
      print("WBP_TaskPanel_Item_C", self.WidgetConfig.Des, TaskStatus)
      self:PlayAnimation(self.Ani_fail_out)
      SetImageBrushBySoftObjectPath(self.Img_TitleIcon, self.WidgetConfig.TitleErrorIcon)
    end
  end
end
function WBP_TaskPanel_Item_C:Hide()
end
return WBP_TaskPanel_Item_C
