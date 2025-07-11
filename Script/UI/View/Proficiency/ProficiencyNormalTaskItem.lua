local ProficiencyNormalTaskItem = UnLua.Class()
function ProficiencyNormalTaskItem:Construct()
  self.BP_ButtonWithSoundGetAward.OnClicked:Add(self, self.OnSelectClick)
end
function ProficiencyNormalTaskItem:Destruct()
  self.BP_ButtonWithSoundGetAward.OnClicked:Remove(self, self.OnSelectClick)
end
function ProficiencyNormalTaskItem:InitProfyNormalTaskItem(TaskId, ParentView)
  self.ParentView = ParentView
  self.TaskId = TaskId
  local tbProfyTaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if tbProfyTaskData and tbProfyTaskData[TaskId] then
    self.WBP_RedDotView:ChangeRedDotIdByTag(TaskId)
    self.RGTextDesc:SetText(tbProfyTaskData[TaskId].name)
    self.RGTextDescGotAward:SetText(tbProfyTaskData[TaskId].name)
    self.RGTextDesc_Finished:SetText(tbProfyTaskData[TaskId].name)
    local progressStr = string.format("%s/%d", Logic_MainTask.GetFirstCountValueByTaskId(TaskId), Logic_MainTask.GetFirstTargetValueByTaskId(TaskId))
    self.RGTextProgress:SetText(progressStr)
    self.RGTextProgress_Finished:SetText(progressStr)
    local Mat = self.URGImageCircle:GetDynamicMaterial()
    if Mat then
      local percent = Logic_MainTask.GetFirstCountValueByTaskId(TaskId) / Logic_MainTask.GetFirstTargetValueByTaskId(TaskId)
      Mat:SetScalarParameterValue("CirclePrecent", percent)
    end
    local state = Logic_MainTask.GetStateByTaskId(TaskId)
    if state == ETaskState.UnFinished then
      UpdateVisibility(self.RGTextProgress, true)
      UpdateVisibility(self.CanvasPanelProgress, true)
      UpdateVisibility(self.CanvasPanelFinished, false)
      UpdateVisibility(self.CanvasPanelGotAward, false)
      UpdateVisibility(self.RGTextDesc, true)
    elseif state == ETaskState.Finished then
      UpdateVisibility(self.CanvasPanelFinished, true)
      UpdateVisibility(self.RGTextProgress, true)
      UpdateVisibility(self.CanvasPanelProgress, true)
      UpdateVisibility(self.CanvasPanelGotAward, false)
      UpdateVisibility(self.RGTextDesc, true)
    elseif state == ETaskState.GotAward then
      UpdateVisibility(self.CanvasPanelFinished, false)
      UpdateVisibility(self.RGTextProgress, false)
      UpdateVisibility(self.CanvasPanelProgress, false)
      UpdateVisibility(self.CanvasPanelGotAward, true)
      UpdateVisibility(self.RGTextDesc, false)
    end
    for i, v in ipairs(tbProfyTaskData[TaskId].rewardlist) do
      local item = GetOrCreateItem(self.HorizontalBoxAward, i, self.WBP_TaskRewardItem:GetClass())
      local tbGenerial = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      if tbGenerial and tbGenerial[v.key] then
        SetImageBrushByPath(item.URGImageAwardIcon, tbGenerial[v.key].Icon)
      end
      item.RGTextAwardNum:SetText(v.value)
    end
    for i, v in ipairs(tbProfyTaskData[TaskId].rewardlist) do
      local item = GetOrCreateItem(self.HorizontalBoxAward_Finished, i, self.WBP_TaskRewardItem_Finished:GetClass())
      local tbGenerial = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      if tbGenerial and tbGenerial[v.key] then
        SetImageBrushByPath(item.URGImageAwardIcon, tbGenerial[v.key].Icon)
      end
      item.RGTextAwardNum:SetText(v.value)
    end
  end
end
function ProficiencyNormalTaskItem:OnSelectClick()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    local state = Logic_MainTask.GetStateByTaskId(self.TaskId)
    if state == ETaskState.Finished then
      self.ParentView:GetTaskAward(self.TaskId)
    end
  end
end
return ProficiencyNormalTaskItem
