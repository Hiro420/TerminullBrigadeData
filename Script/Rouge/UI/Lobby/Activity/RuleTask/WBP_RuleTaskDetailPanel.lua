local WBP_RuleTaskDetailPanel = UnLua.Class()
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")

function WBP_RuleTaskDetailPanel:Construct()
  self.Btn_Receive.OnMainButtonClicked:Add(self, self.BindOnReceiveButtonClicked)
end

function WBP_RuleTaskDetailPanel:OnShow(RuleInfoId)
  UpdateVisibility(self, true)
  self.RuleInfoId = RuleInfoId
  UIMgr:Show(ViewID.UI_RuleTaskCreditExchangePanel, false, nil, true)
  local Result, RuleInfoRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleInfo, self.RuleInfoId)
  if not Result then
    print("WBP_RuleTaskDetailPanel:Show not found RuleInfo table row!", self.RuleInfoId)
    return
  end
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.ListenForEscKeyPressed)
  SetImageBrushByPath(self.Img_RuleIcon, RuleInfoRowInfo.RuleIconPath)
  SetImageBrushByPath(self.Img_TaskBottom, RuleInfoRowInfo.TaskBGIconPath)
  SetImageBrushByPath(self.Img_GenericModifyIcon, RuleInfoRowInfo.TitleBGIconPath)
  self:InitBG(RuleInfoRowInfo.BGBPPath)
  self.Txt_Name:SetText(RuleInfoRowInfo.Name)
  self.MainTaskGroupId = RuleInfoRowInfo.MainTaskGroupId
  self.MinorTaskGroupId = RuleInfoRowInfo.MinorTaskGroupId
  self:PlayAnimation(self.Ani_in)
  self:RefreshMainTaskGroupInfo()
  self:RefreshTaskScrollList()
  EventSystem.AddListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnMainTaskGroupRefresh)
end

function WBP_RuleTaskDetailPanel:InitBG(TargetBGPath)
  local AssetObj
  if not UE.UKismetStringLibrary.IsEmpty(TargetBGPath) then
    AssetObj = GetAssetByPath(TargetBGPath, true)
  end
  local TargetItem
  local AllChildren = self.CanvasPanel_GenericModify:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    if SingleItem:StaticClass() ~= AssetObj then
      UpdateVisibility(SingleItem, false)
    else
      UpdateVisibility(SingleItem, true)
      TargetItem = SingleItem
    end
  end
  if not TargetItem and AssetObj then
    TargetItem = UE.UWidgetBlueprintLibrary.Create(self, AssetObj)
    local Slot = self.CanvasPanel_GenericModify:AddChildToCanvas(TargetItem)
    local TemplateSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_GenericModifyDialog_Group_6)
    Slot:SetAnchors(TemplateSlot:GetAnchors())
    Slot:SetOffsets(TemplateSlot:GetOffsets())
  end
  if TargetItem then
    TargetItem:PlayAnimation(TargetItem.Ani_GenericModifyChoose_in)
  end
end

function WBP_RuleTaskDetailPanel:RefreshMainTaskGroupInfo()
  local Result, TaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, self.MainTaskGroupId)
  if not Result then
    print("WBP_RuleTaskDetailPanel:RefreshMainTaskGroupInfo not found taskgroup table row!", self.MainTaskGroupId)
    return
  end
  self.MainTaskGroupTaskList = TaskGroupRowInfo.tasklist
  if TaskGroupRowInfo.rewardlist[1] then
    UpdateVisibility(self.MainTaskGroupReward, true)
    self.MainTaskGroupReward:InitItem(TaskGroupRowInfo.rewardlist[1].key)
  else
    UpdateVisibility(self.MainTaskGroupReward, false)
  end
  self:RefreshMainTaskGroupStatus()
end

function WBP_RuleTaskDetailPanel:RefreshMainTaskGroupStatus(...)
  local FinishTaskNum, AllTaskNum = RuleTaskData:GetTaskGroupProgress(self.MainTaskGroupId)
  self.Txt_CurFinishTaskNum:SetText(FinishTaskNum)
  self.Txt_MaxTaskNum:SetText(AllTaskNum)
  local MainGroupState = RuleTaskData:GetTaskGroupState(self.MainTaskGroupId)
  UpdateVisibility(self.Overlay_Received, MainGroupState == ETaskGroupState.GotAward)
  local StyleName = ""
  local ContentText = ""
  if MainGroupState == ETaskGroupState.Finished then
    StyleName = self.FinishedBtnStyle
    ContentText = self.ReceiveText
    self.RGStateController_ReceiveBtn:ChangeStatus("CanReceive")
  elseif MainGroupState == ETaskGroupState.GotAward then
    StyleName = self.GetRewardBtnStyle
    ContentText = self.ReceivedText
    self.RGStateController_ReceiveBtn:ChangeStatus("Received")
  else
    StyleName = self.LockBtnStyle
    ContentText = self.UnReceiveText
    self.RGStateController_ReceiveBtn:ChangeStatus("Lock")
  end
  self.Btn_Receive:SetStyleByBottomStyleRowName(StyleName)
  UpdateVisibility(self.NiagaraSystemWidget_94, MainGroupState == ETaskGroupState.Finished)
end

function WBP_RuleTaskDetailPanel:RefreshTaskScrollList(...)
  local MainResult, MainTaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, self.MainTaskGroupId)
  if not MainResult then
    print("WBP_RuleTaskDetailPanel:RefreshMainTaskGroupInfo not found taskgroup table row!", self.MainTaskGroupId)
    return
  end
  local Result, RuleInfoRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleInfo, self.RuleInfoId)
  if not Result then
    print("WBP_RuleTaskDetailPanel:Show not found RuleInfo table row!", self.RuleInfoId)
    return
  end
  local Index = 1
  for index, SingleTaskId in ipairs(MainTaskGroupRowInfo.tasklist) do
    local Item = GetOrCreateItem(self.ScrollBox_Task, Index, self.WBP_RuleTaskDetailTaskItem:StaticClass())
    Item:Show(SingleTaskId, self.MainTaskGroupId, true, RuleInfoRowInfo.MainTaskBGColor)
    Index = Index + 1
  end
  HideOtherItem(self.ScrollBox_Task, Index)
  local MinorResult, MinorTaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, self.MinorTaskGroupId)
  if not MinorResult then
    print("WBP_RuleTaskDetailPanel:RefreshMainTaskGroupInfo not found taskgroup table row!", self.MinorTaskGroupId)
    return
  end
  local IsNeedShowLine = true
  for index, SingleTaskId in ipairs(MinorTaskGroupRowInfo.tasklist) do
    local Item = GetOrCreateItem(self.ScrollBox_Task, Index, self.WBP_RuleTaskDetailTaskItem:StaticClass())
    Item:Show(SingleTaskId, self.MinorTaskGroupId, false)
    Index = Index + 1
    if IsNeedShowLine then
      Item:ChangeLineVis(true)
      IsNeedShowLine = false
    end
  end
  HideOtherItem(self.ScrollBox_Task, Index)
end

function WBP_RuleTaskDetailPanel:BindOnMainTaskGroupRefresh(TaskGroupIdList)
  local IsContainMainTaskGroup = table.Contain(TaskGroupIdList, self.MainTaskGroupId)
  if IsContainMainTaskGroup then
    self:RefreshMainTaskGroupStatus()
  end
  if not IsContainMainTaskGroup then
    if table.Contain(TaskGroupIdList, self.MinorTaskGroupId) then
      self:RefreshTaskItemStatus()
    end
  else
    self:RefreshTaskItemStatus()
  end
end

function WBP_RuleTaskDetailPanel:RefreshTaskItemStatus(...)
  local AllChildren = self.ScrollBox_Task:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    if SingleItem.RefreshTaskStatus then
      SingleItem:RefreshTaskStatus()
    end
  end
end

function WBP_RuleTaskDetailPanel:BindOnReceiveButtonClicked()
  local MainGroupState = RuleTaskData:GetTaskGroupState(self.MainTaskGroupId)
  if MainGroupState ~= ETaskGroupState.Finished then
    return
  end
  Logic_MainTask.ReceiveTaskGroupAward(self.MainTaskGroupId)
end

function WBP_RuleTaskDetailPanel:ListenForEscKeyPressed(...)
  UIMgr:Hide(ViewID.UI_RuleTaskDetailPanel)
end

function WBP_RuleTaskDetailPanel:OnHide()
  UpdateVisibility(self, false)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.ListenForEscKeyPressed)
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnMainTaskGroupRefresh)
  local AllChildren = self.CanvasPanel_GenericModify:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    if SingleItem.StopAllAnimations then
      SingleItem:StopAllAnimations()
    end
  end
  self:StopAllAnimations()
end

function WBP_RuleTaskDetailPanel:Destruct(...)
  self:OnHide()
end

return WBP_RuleTaskDetailPanel
