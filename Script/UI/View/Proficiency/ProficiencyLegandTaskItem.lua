local ProficiencyLegandTaskItem = UnLua.Class()
function ProficiencyLegandTaskItem:Construct()
  self.ButtonSelect.OnClicked:Add(self, self.OnSelectClick)
end
function ProficiencyLegandTaskItem:Destruct()
  self.ButtonSelect.OnClicked:Remove(self, self.OnSelectClick)
end
function ProficiencyLegandTaskItem:InitProfyLegandTaskItem(TaskId, GearLv, ParentView)
  print("ProficiencyLegandTaskItem:InitProfyLegandTaskItem", TaskId, GearLv)
  self.TaskId = TaskId
  self.ParentView = ParentView
  local tbProfyTaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if tbProfyTaskData and tbProfyTaskData[TaskId] then
    self.WBP_RedDotViewFinished:ChangeRedDotIdByTag(TaskId)
    self.WBP_RedDotViewLegandTask:ChangeRedDotIdByTag(TaskId)
    local progressStr = string.format("%s/%d", Logic_MainTask.GetFirstCountValueByTaskId(TaskId), Logic_MainTask.GetFirstTargetValueByTaskId(TaskId))
    self.RGTextProgress:SetText(progressStr)
    local Mat = self.URGImageCircle:GetDynamicMaterial()
    if Mat then
      local percent = Logic_MainTask.GetFirstCountValueByTaskId(TaskId) / Logic_MainTask.GetFirstTargetValueByTaskId(TaskId)
      Mat:SetScalarParameterValue("CirclePrecent", percent)
    end
    local state = Logic_MainTask.GetStateByTaskId(TaskId)
    print("ProficiencyLegandTaskItem:InitProfyLegandTaskItem1 state", state)
    if state == ETaskState.UnFinished then
      UpdateVisibility(self.CanvasPanelProgress, true)
      UpdateVisibility(self.CanvasPanelFinished, false)
      UpdateVisibility(self.CanvasPanelGotAward, false)
      UpdateVisibility(self.HorizontalBoxName, false)
      UpdateVisibility(self.RGTextDesc, true)
      UpdateVisibility(self.RGTextDesc_Finished, false)
      UpdateVisibility(self.HorizontalBoxAward, true)
      self.RGTextDesc:SetText(tbProfyTaskData[TaskId].name)
      UpdateVisibility(self.URGImage_hero, true)
    elseif state == ETaskState.Finished then
      UpdateVisibility(self.CanvasPanelFinished, true)
      UpdateVisibility(self.CanvasPanelProgress, false)
      UpdateVisibility(self.CanvasPanelGotAward, false)
      UpdateVisibility(self.HorizontalBoxName, true)
      UpdateVisibility(self.RGTextDesc, false)
      UpdateVisibility(self.RGTextDesc_Finished, true)
      UpdateVisibility(self.HorizontalBoxAward, true)
      UpdateVisibility(self.URGImage_hero, true)
      local str = string.format("\231\172\172%s\231\171\160", NumToTxt(GearLv))
      self.RGTextDesc_Finished:SetText(str)
      local profyData = self.ParentView.viewModel:GetProfyData(GearLv)
      if profyData then
        self.RGTextName:SetText(profyData.ProfyTaskTb.Name)
        self.RGTextNameGotAward:SetText(profyData.ProfyTaskTb.Name)
      end
    elseif state == ETaskState.GotAward then
      UpdateVisibility(self.CanvasPanelFinished, false)
      UpdateVisibility(self.CanvasPanelProgress, false)
      UpdateVisibility(self.CanvasPanelGotAward, true)
      UpdateVisibility(self.HorizontalBoxName, false)
      UpdateVisibility(self.RGTextDesc, false)
      UpdateVisibility(self.RGTextDesc_Finished, true)
      UpdateVisibility(self.HorizontalBoxAward, false)
      local str = string.format("\231\172\172%s\231\171\160", NumToTxt(GearLv))
      self.RGTextDesc_Got:SetText(str)
      local profyData = self.ParentView.viewModel:GetProfyData(GearLv)
      if profyData then
        self.RGTextName:SetText(profyData.ProfyTaskTb.Name)
        self.RGTextNameGotAward:SetText(profyData.ProfyTaskTb.Name)
      end
      local str = string.format("\231\172\172%s\231\171\160", NumToTxt(GearLv))
      self.RGTextDesc_Finished:SetText(str)
      local tbProfy = LuaTableMgr.GetLuaTableByName(TableNames.TBProfy)
      if tbProfy and tbProfy[GearLv] then
        SetImageBrushByPath(self.URGImage_hero, tbProfy[GearLv].IconPath)
        UpdateVisibility(self.URGImage_hero, true)
      else
        UpdateVisibility(self.URGImage_hero, true)
      end
      SetImageBrushByPath(self.URGImage_hero, tbProfyTaskData[TaskId].icon)
    end
    for i, v in ipairs(tbProfyTaskData[TaskId].rewardlist) do
      local itemGotAward = GetOrCreateItem(self.HorizontalBoxAwardGotAward, i, self.WBP_CommonItemGotAward:GetClass())
      local resId = v.key
      itemGotAward:InitCommonItem(v.key, v.value, false, function()
        if UE.RGUtil.IsUObjectValid(self.ParentView) then
          self.ParentView:ShowAwardTips(resId, true, GearLv, itemGotAward, true)
        end
      end, function()
        if UE.RGUtil.IsUObjectValid(self.ParentView) then
          self.ParentView:ShowAwardTips(resId, false, GearLv)
        end
      end, function()
        self:OnSelectAwardClick()
      end)
      UpdateVisibility(itemGotAward, true, true)
      local item = GetOrCreateItem(self.HorizontalBoxAward, i, self.WBP_CommonItem:GetClass())
      item:InitCommonItem(v.key, v.value, false, function()
        if UE.RGUtil.IsUObjectValid(self.ParentView) then
          self.ParentView:ShowAwardTips(resId, true, GearLv, item, true)
        end
      end, function()
        if UE.RGUtil.IsUObjectValid(self.ParentView) then
          self.ParentView:ShowAwardTips(resId, false, GearLv)
        end
      end, function()
        self:OnSelectAwardClick()
      end)
      UpdateVisibility(item, true, true)
    end
    HideOtherItem(self.HorizontalBoxAward, #tbProfyTaskData[TaskId].rewardlist + 1)
    HideOtherItem(self.HorizontalBoxAwardGotAward, #tbProfyTaskData[TaskId].rewardlist + 1)
  end
end
function ProficiencyLegandTaskItem:OnSelectClick()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:SelectLegandTask(self.TaskId, true)
  end
end
function ProficiencyLegandTaskItem:OnSelectAwardClick()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:SelectLegandTask(self.TaskId)
  end
end
return ProficiencyLegandTaskItem
