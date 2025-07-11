local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local AchievementConfig = require("GameConfig.Achievement.AchievementConfig")
local EscName = "PauseGame"
local AchievementView = Class(ViewBase)
local CurrentSelectedID = 1
local AchievementTypeList = {}
function AchievementView:OnBindUIInput()
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      AchievementView.ListenForEscInputAction
    })
  end
  self.WBP_InteractTipWidgetMenuPrev:BindInteractAndClickEvent(self, self.OnSelectPrevTab)
  self.WBP_InteractTipWidgetMenuNext:BindInteractAndClickEvent(self, self.OnSelectNextTab)
  self.WBP_InteractTipWidgetReward:BindInteractAndClickEvent(self, self.OnShowPointAwardListClick)
end
function AchievementView:OnUnBindUIInput()
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidgetMenuPrev:UnBindInteractAndClickEvent(self, self.OnSelectPrevTab)
  self.WBP_InteractTipWidgetMenuNext:UnBindInteractAndClickEvent(self, self.OnSelectNextTab)
  self.WBP_InteractTipWidgetReward:UnBindInteractAndClickEvent(self, self.OnShowPointAwardListClick)
end
function AchievementView:BindClickHandler()
  self.RGToggleGroupAchievementType.OnCheckStateChanged:Add(self, self.OnToggleGroupAchievementTypeChanged)
  self.ButtonWithSoundLeft.OnClicked:Add(self, self.OnBtnAwardLeftClick)
  self.ButtonWithSoundRight.OnClicked:Add(self, self.OnBtnAwardRightClick)
  self.ButtonWithSoundAwardList.OnClicked:Add(self, self.OnShowPointAwardListClick)
  self.ButtonWithSoundAwardListDetails.OnClicked:Add(self, self.OnShowPointAwardListClick)
  self.ButtonWithSoundChangeShow.OnClicked:Add(self, self.OnShowDisplayClick)
end
function AchievementView:UnBindClickHandler()
  self.RGToggleGroupAchievementType.OnCheckStateChanged:Remove(self, self.OnToggleGroupAchievementTypeChanged)
  self.ButtonWithSoundLeft.OnClicked:Remove(self, self.OnBtnAwardLeftClick)
  self.ButtonWithSoundRight.OnClicked:Remove(self, self.OnBtnAwardRightClick)
  self.ButtonWithSoundAwardList.OnClicked:Remove(self, self.OnShowPointAwardListClick)
  self.ButtonWithSoundAwardListDetails.OnClicked:Remove(self, self.OnShowPointAwardListClick)
  self.ButtonWithSoundChangeShow.OnClicked:Remove(self, self.OnShowDisplayClick)
end
function AchievementView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("AchievementViewModel")
  self:BindClickHandler()
end
function AchievementView:OnDestroy()
  self:UnBindClickHandler()
end
function AchievementView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self:SetViewEmpty()
  self.viewModel:RequestGetAchievementInfo()
  self:UpdateAchievementTypeToggleList()
  self:SwitchShowModel(EAchievementShowModel.Details)
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Add(self, self.ListenForEscInputAction)
  self:PushInputAction()
  self:PlayAnimation(self.Ani_in)
end
function AchievementView:OnHide()
  self.viewModel:ResetData()
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Remove(self, self.ListenForEscInputAction)
  print("AchievementView:OnHide()")
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end
function AchievementView:SetViewEmpty()
  self.RGTextAchievementNumDetails:SetText("")
  self.RGTextPointAwardDescDetails:SetText("")
end
function AchievementView:SwitchShowModel(AchievementShowModel, tbTask, taskGroupId, NotUpdateAchievementList)
  self.viewModel:SwitchShowModel(AchievementShowModel, tbTask, taskGroupId, NotUpdateAchievementList)
end
function AchievementView:SelectItem(AchievementShowModel, tbTask, taskGroupId)
  local displayItemAry = self.RGTileViewAchievement:GetDisplayedEntryWidgets()
  for i, v in pairs(displayItemAry) do
    if IsValidObj(v) then
      v.RGStateControllerSelect:ChangeStatus(tostring(EAchievementItemSelectState.UnSelect))
    end
  end
  local dataAry = self.RGTileViewAchievement:GetListItems()
  for i, v in pairs(dataAry) do
    if IsValidObj(v) and v.SelectStatus == EAchievementItemLockState.Select then
      v.SelectStatus = EAchievementItemSelectState.UnSelect
      break
    end
  end
  self.viewModel:SwitchShowModel(AchievementShowModel, tbTask, taskGroupId, true)
end
function AchievementView:OnSwitchShowModel(AchievementShowModel, tbTask, taskGroupId)
  self.RGStateControllerShowModel:ChangeStatus(tostring(AchievementShowModel), true)
  if AchievementShowModel == EAchievementShowModel.Details then
    if tbTask then
      local taskId = tbTask.id
      local firstCount = tonumber(Logic_MainTask.GetFirstCountValueByTaskId(taskId))
      local targetCount = tonumber(Logic_MainTask.GetFirstTargetValueByTaskId(taskId))
      self.RGTextAchievementName:SetText(tbTask.name)
      self.RGTextTaskDesc:SetText(tbTask.content)
      self.ProgressBarTask:SetPercent(firstCount / targetCount)
      local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      local idx = 1
      for i, v in ipairs(tbTask.rewardlist) do
        if not (tbGeneral and tbGeneral[v.key]) or 12 == tbGeneral[v.key].Type then
        else
          local item = GetOrCreateItem(self.ScrollBoxAward, idx, self.WBP_Item_1:GetClass())
          local itemSlotTemplate = UE.UWidgetLayoutLibrary.SlotAsScrollBoxSlot(self.WBP_Item_1)
          local itemSlot = UE.UWidgetLayoutLibrary.SlotAsScrollBoxSlot(item)
          if itemSlot then
            itemSlot:SetPadding(itemSlotTemplate.Padding)
          end
          item.DT_Handle.RowName = self.WBP_Item_1.DT_Handle.RowName
          item:InitItem(v.key, v.value)
          UpdateVisibility(item, true)
          idx = idx + 1
        end
      end
      HideOtherItem(self.ScrollBoxAward, idx)
      local firstCount = tonumber(Logic_MainTask.GetFirstCountValueByTaskId(taskId))
      local targetCount = tonumber(Logic_MainTask.GetFirstTargetValueByTaskId(taskId))
      print("AchievementView:OnSwitchShowModel taskId firstCount, targetCount", taskId, firstCount, targetCount)
      if firstCount > targetCount then
        firstCount = targetCount
      end
      local str = string.format("%d/%d", firstCount, targetCount)
      self.RGTextAchievementDetailsNum:SetText(str)
      local achievementItemData = self.viewModel:GetCurSelectAchievementItemData()
      self.WBP_AchievementDetialsItem:InitAchievementDetailsItem(achievementItemData, tbTask.id, self)
    else
      UpdateVisibility(self.CanvasPanelAchievementDetails, false)
      UpdateVisibility(self.WBP_AchievementDetialsItem, false)
    end
  end
end
function AchievementView:UpdateAchievementTypeToggleList()
  self.RGToggleGroupAchievementType:ClearGroup()
  AchievementTypeList = self.viewModel:GetAchievementToggleList()
  for i, v in ipairs(AchievementTypeList) do
    local item = GetOrCreateItem(self.HorizontalToggle, i, self.WBP_AchievementToggle:GetClass())
    item:InitAchievementToggle(v)
    self.RGToggleGroupAchievementType:AddToGroup(i, item)
  end
  self.RGToggleGroupAchievementType:SelectId(1)
end
function AchievementView:UpdateAchievementList(achievementItemDataList, SelectTaskId, SelectGroupId)
  if self.viewModel.AchievementShowModel == EAchievementShowModel.Details and (nil == SelectGroupId or nil == SelectTaskId) then
    local achievementItemData = achievementItemDataList[1]
    if achievementItemData and achievementItemData.tbTaskGroup then
      local idx = 1
      local finishIdx = -1
      for idxTask, vTask in ipairs(achievementItemData.tbTaskGroup.tasklist) do
        local state = Logic_MainTask.GetStateByTaskId(vTask)
        if -1 == finishIdx and state == ETaskState.Finished then
          finishIdx = idxTask
        end
        if state == ETaskState.Finished or state == ETaskState.GotAward then
          idx = idx + 1
        end
      end
      if -1 ~= finishIdx then
        idx = finishIdx
      end
      if idx > #achievementItemData.tbTaskGroup.tasklist then
        idx = #achievementItemData.tbTaskGroup.tasklist
      end
      self:SwitchShowModel(self.viewModel.AchievementShowModel, achievementItemData.tbTaskList[idx], achievementItemData.tbTaskGroup.id)
    else
      self:SwitchShowModel(self.viewModel.AchievementShowModel, nil, nil, true)
      self.RGTileViewAchievement:RecyleAllData()
    end
    return
  end
  self.RGTileViewAchievement:RecyleAllData()
  if table.IsEmpty(achievementItemDataList) then
    print("achievementItemDataList Is Empty")
    return
  end
  local TileViewAry = UE.TArray(UE.UObject)
  TileViewAry:Reserve(#achievementItemDataList)
  for i, v in ipairs(achievementItemDataList) do
    local DataObj = self.RGTileViewAchievement:GetOrCreateDataObj()
    DataObj.ParentView = self
    DataObj.TaskGroupId = v.tbTaskGroup.id
    print("AchievementView:UpdateAchievementList", v.tbTaskGroup.id)
    local idx = 1
    local finishIdx = -1
    for idxTask, vTask in ipairs(v.tbTaskGroup.tasklist) do
      if SelectTaskId and SelectGroupId == v.tbTaskGroup.id then
        if SelectTaskId == vTask then
          idx = idxTask
        end
      else
        local state = Logic_MainTask.GetStateByTaskId(vTask)
        if -1 == finishIdx and state == ETaskState.Finished then
          finishIdx = idxTask
        end
        if state == ETaskState.Finished or state == ETaskState.GotAward then
          idx = idx + 1
        end
      end
    end
    if -1 ~= finishIdx then
      idx = finishIdx
    end
    if idx > #v.tbTaskGroup.tasklist then
      idx = #v.tbTaskGroup.tasklist
    end
    if SelectGroupId == v.tbTaskGroup.id then
      DataObj.SelectStatus = EAchievementItemSelectState.Select
    else
      DataObj.SelectStatus = EAchievementItemSelectState.UnSelect
    end
    local achievementItemLockState = EAchievementItemLockState.Lock
    local selectTaskState = Logic_MainTask.GetStateByTaskId(v.tbTaskGroup.tasklist[1])
    if selectTaskState == ETaskState.Lock or selectTaskState == ETaskState.None or selectTaskState == ETaskState.UnFinished then
      achievementItemLockState = EAchievementItemLockState.Lock
    else
      achievementItemLockState = EAchievementItemLockState.UnLock
    end
    DataObj.LockStatus = achievementItemLockState
    DataObj.CurTaskIdx = idx
    TileViewAry:Add(DataObj)
  end
  self.RGTileViewAchievement:SetRGListItems(TileViewAry, true, true)
end
function AchievementView:ListenForEscInputAction()
  local achievementAwardList = self:GetAchievementAwardListObj()
  if CheckIsVisility(achievementAwardList) then
    self:ShowAchievementAwardList(false)
    return
  end
  local playerInfoMainViewModel = UIModelMgr:Get("PlayerInfoMainViewModel")
  playerInfoMainViewModel:HidePlayerMainView()
end
function AchievementView:OnUpdateAchievementPoint(PointNum)
  self.RGTextAchievementNum:SetText(PointNum)
  self.RGTextAchievementNumDetails:SetText(PointNum)
  local needPointNum = self.viewModel:GetCurDoingPointTaskNeedPoint()
  local str = ""
  if needPointNum <= 0 then
    str = ""
  else
    str = UE.FTextFormat(AchievementConfig.NeedAchievePointStrFmt(), needPointNum)
  end
  self.RGTextPointAwardDescDetails:SetText(str)
  local achievementAwardList = self:GetAchievementAwardListObj()
  if achievementAwardList then
    achievementAwardList:InitPointNum(PointNum)
  end
end
function AchievementView:UpdateDetails(profyData)
  local tbProfy = LuaTableMgr.GetLuaTableByName(TableNames.TBProfy)
  if tbProfy and tbProfy[profyData.ProfyTaskTb.Level] then
    self.RGTextProficiencyName:SetText(tbProfy[profyData.ProfyTaskTb.Level].Name)
  end
end
function AchievementView:UpdateAchievementPointAward(award, needPointNum)
  self.PointAwardId = award.key
  self.WBP_CommonItemPointAward:InitCommonItem(award.key, award.value, false, function()
    self:HoveredFunc()
  end, function()
    self:UnHoveredFunc()
  end)
  self.ButtonWithSoundLeft:SetIsEnabled(self.viewModel.CurShowPointAwardIdx > 1)
  self.ButtonWithSoundRight:SetIsEnabled(self.viewModel.CurShowPointAwardIdx < #self.viewModel:GetTBAchievementPointSort())
  if needPointNum <= 0 then
    self.RGTextPointAwardDesc:SetText("")
  else
    local str = UE.FTextFormat(AchievementConfig.NeedAchievePointStrFmt(), needPointNum)
    self.RGTextPointAwardDesc:SetText(str)
  end
end
function AchievementView:HoveredFunc()
  self.WBP_CommonItemDetail:InitCommonItemDetail(self.PointAwardId)
  UpdateVisibility(self.WBP_CommonItemDetail, true)
end
function AchievementView:UnHoveredFunc()
  UpdateVisibility(self.WBP_CommonItemDetail, false)
end
function AchievementView:OnToggleGroupAchievementTypeChanged(SelectId)
  CurrentSelectedID = SelectId
  self.viewModel:SelectToggle(SelectId)
end
function AchievementView:OnBtnAwardLeftClick()
  self.viewModel:SwitchLeftPointAward()
end
function AchievementView:OnBtnAwardRightClick()
  self.viewModel:SwitchRightPointAward()
end
function AchievementView:OnShowPointAwardListClick()
  self:ShowAchievementAwardList(true)
end
function AchievementView:OnSelectPrevTab()
  CurrentSelectedID = CurrentSelectedID - 1
  if CurrentSelectedID < 1 then
    CurrentSelectedID = #AchievementTypeList
  end
  self.RGToggleGroupAchievementType:SelectId(CurrentSelectedID)
end
function AchievementView:OnSelectNextTab()
  CurrentSelectedID = CurrentSelectedID + 1
  if CurrentSelectedID > #AchievementTypeList then
    CurrentSelectedID = 1
  end
  self.RGToggleGroupAchievementType:SelectId(CurrentSelectedID)
end
function AchievementView:OnShowDisplayClick()
  self.WBP_AchievementDisplayView:InitAchievementDisplayView()
end
function AchievementView:OnrHideProfyLvUpByOpacity()
  self.WBP_ProficiencyLvUp:SetRenderOpacity(0)
end
function AchievementView:OnReceivePointAwards(GroupId, TsakId, List)
end
function AchievementView:GetCurHeroId()
  return self.viewModel.CurHeroId
end
function AchievementView:ReceivePointAwards(TaskIds)
  Logic_MainTask.ReceiveAward(self.viewModel:GetAchivementPointTaskGroup(), nil, true, self.OnReceivePointAwards, self)
end
function AchievementView:ReceiveTaskAward(GroupId, TaskId)
  Logic_MainTask.ReceiveAward(GroupId, TaskId, nil, nil, nil, nil, true)
end
function AchievementView:ShowAchievementAwardList(bShow)
  local achievementAwardList = self:GetAchievementAwardListObj()
  if achievementAwardList then
    if bShow then
      self:OnUnBindUIInput()
      if not IsListeningForInputAction(self, EscName) then
        ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
          self,
          AchievementView.ListenForEscInputAction
        })
      end
      achievementAwardList:BindUIInput()
    else
      self:OnBindUIInput()
      achievementAwardList:UnBindUIInput()
    end
  end
  UpdateVisibility(achievementAwardList, bShow)
  if bShow and achievementAwardList then
    local tbAchievementPointSort = self.viewModel.GetTBAchievementPointSort()
    local taskId
    for i, v in ipairs(tbAchievementPointSort) do
      local state = Logic_MainTask.GetStateByTaskId(v.taskid)
      if state == ETaskState.UnFinished then
        taskId = v.taskid
      end
    end
    achievementAwardList:InitAchievementAwardList(tbAchievementPointSort, taskId, self)
  end
end
function AchievementView:GetAchievementAwardListObj()
  return self.WBP_AchievementAwardList
end
function AchievementView:UpdateAchievementAwardList()
  local achievementAwardList = self:GetAchievementAwardListObj()
  if CheckIsVisility(achievementAwardList) then
    self:ShowAchievementAwardList(true)
  end
end
function AchievementView:OnUpdateDisplayBadges()
  if CheckIsVisility(self.WBP_AchievementDisplayView) then
    self.WBP_AchievementDisplayView:UpdateBadgesTileView()
  end
end
function AchievementView:ShowAwardTips(bIsShow, BadgesId, HoverItem)
  if bIsShow then
    if UE.RGUtil.IsUObjectValid(self.HoveredTipWidget) then
      UpdateVisibility(self.HoveredTipWidget, true)
      self.HoveredTipWidget:InitCommonItemDetail(BadgesId)
    else
      self.HoveredTipWidget = GetItemDetailWidget(BadgesId)
      self.CanvasPanelTips:AddChild(self.HoveredTipWidget)
    end
    ShowTipsAndInitPos(self.HoveredTipWidget, self.CanvasPanelTips, HoverItem, self.TipsOffset)
  else
    UpdateVisibility(self.HoveredTipWidget, false)
  end
end
return AchievementView
