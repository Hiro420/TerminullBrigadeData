local AchievementAwardList = UnLua.Class()
local MaxShowNum = 11
function AchievementAwardList:BindUIInput()
  self.WBP_InteractTipWidgetReward:BindInteractAndClickEvent(self, self.OnGetAllAwardClick)
end
function AchievementAwardList:UnBindUIInput()
  self.WBP_InteractTipWidgetReward:UnBindInteractAndClickEvent(self, self.OnGetAllAwardClick)
end
function AchievementAwardList:Construct()
  self.ButtonWithSoundLeft.OnClicked:Add(self, self.OnLeftClick)
  self.ButtonWithSoundRight.OnClicked:Add(self, self.OnRightClick)
  self.ButtonWithSoundGetAllAward.OnClicked:Add(self, self.OnGetAllAwardClick)
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Add(self, self.OnExitClick)
end
function AchievementAwardList:Destruct()
end
function AchievementAwardList:InitAchievementAwardList(TbAchievementPointSort, taskId, ParentView)
  if not TbAchievementPointSort then
    return
  end
  self.ParentView = ParentView
  self.CurSelectTaskId = taskId
  self.TbAchievementPointSort = TbAchievementPointSort
  local count = #TbAchievementPointSort
  self.PageNum = math.floor((count - 1) / MaxShowNum) + 1
  self.PageToAwardList = {}
  local idx = 1
  local pageIdx = 1
  for i, v in ipairs(TbAchievementPointSort) do
    if not self.PageToAwardList[pageIdx] then
      self.PageToAwardList[pageIdx] = {
        AwardList = {}
      }
    end
    if idx <= MaxShowNum then
      table.insert(self.PageToAwardList[pageIdx].AwardList, v)
      idx = idx + 1
    else
      idx = 2
      pageIdx = pageIdx + 1
      if not self.PageToAwardList[pageIdx] then
        self.PageToAwardList[pageIdx] = {
          AwardList = {v}
        }
      end
    end
  end
  self.SelectTaskIdx = 1
  for i, v in ipairs(TbAchievementPointSort) do
    if v.taskid == taskId then
      self.SelectTaskIdx = i
      break
    end
  end
  self.CurSelectPageIdx = math.floor((self.SelectTaskIdx - 1) / MaxShowNum) + 1
  self.DoingTaskIdxInPage = self.SelectTaskIdx % MaxShowNum
  if 0 == self.SelectTaskIdx then
    self.SelectTaskIdx = MaxShowNum
  end
  self.DoingTaskPageIdx = self.CurSelectPageIdx
  self:InitAwardListByPageIdx()
  if self:CheckHaveAwardActive() then
    self.RGStateControllerGetAllEnable:ChangeStatus(EEnable.Enable)
  else
    self.RGStateControllerGetAllEnable:ChangeStatus(EEnable.Disable)
  end
end
function AchievementAwardList:InitPointNum(PointNum)
  self.RGTextPointNum:SetText(PointNum)
end
function AchievementAwardList:InitAwardListByPageIdx()
  local tbTask = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  local selectItem
  local selectIdx = 0
  for i, v in ipairs(self.PageToAwardList[self.CurSelectPageIdx].AwardList) do
    local bSelect = v.taskid == self.CurSelectTaskId
    local item = GetOrCreateItem(self.HorizontalBoxAward, i, self.WBP_AchievementPointAwardItem:GetClass())
    item:InitAchievementPointAwardItem(tbTask[v.taskid], bSelect, self.ParentView, self)
    if bSelect then
      selectItem = item
      selectIdx = i
    end
  end
  HideOtherItem(self.HorizontalBoxAward, #self.PageToAwardList[self.CurSelectPageIdx].AwardList + 1)
  self.ButtonWithSoundLeft:SetIsEnabled(self.CurSelectPageIdx > 1)
  self.ButtonWithSoundRight:SetIsEnabled(self.CurSelectPageIdx < self.PageNum)
  if selectItem then
    local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.URGImageArrow)
    local tipsSize = self.URGImageArrow:GetDesiredSize()
    if slotCanvas then
      local GeometryItem = selectItem:GetCachedGeometry()
      local GeometryCanvasPanelRoot = self.CanvasPanelRoot:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelRoot, GeometryItem)
      local itemSize = selectItem:GetDesiredSize()
      local offset = UE.FVector2D(0)
      offset = UE.FVector2D(tipsSize.X / 2 - itemSize.X / 2, -tipsSize.X - itemSize.Y)
      slotCanvas:SetPosition(Pos - offset)
    end
    self.URGImageProgress:SetClippingValue(selectIdx / MaxShowNum - 1 / (2 * MaxShowNum))
  elseif self.DoingTaskPageIdx > self.CurSelectPageIdx then
    self.URGImageProgress:SetClippingValue(1 - 1 / (2 * MaxShowNum))
  elseif self.DoingTaskPageIdx < self.CurSelectPageIdx then
    self.URGImageProgress:SetClippingValue(0)
  end
end
function AchievementAwardList:OnLeftClick()
  if self.CurSelectPageIdx <= 1 then
    return
  end
  self.CurSelectPageIdx = self.CurSelectPageIdx - 1
  self:InitAwardListByPageIdx()
end
function AchievementAwardList:OnRightClick()
  if self.CurSelectPageIdx >= self.PageNum then
    return
  end
  self.CurSelectPageIdx = self.CurSelectPageIdx + 1
  self:InitAwardListByPageIdx()
end
function AchievementAwardList:OnGetAllAwardClick()
  if not self.ParentView then
    return
  end
  if not self.TbAchievementPointSort then
    return
  end
  local taskIds = {}
  for i, v in ipairs(self.TbAchievementPointSort) do
    local state = Logic_MainTask.GetStateByTaskId(v.taskid)
    if state == ETaskState.Finished then
      table.insert(taskIds, v.taskid)
    end
  end
  self.ParentView:ReceivePointAwards(taskIds)
end
function AchievementAwardList:CheckHaveAwardActive()
  local taskIds = {}
  for i, v in ipairs(self.TbAchievementPointSort) do
    local state = Logic_MainTask.GetStateByTaskId(v.taskid)
    if state == ETaskState.Finished then
      return true
    end
  end
  return false
end
function AchievementAwardList:OnExitClick()
  UpdateVisibility(self, false)
end
function AchievementAwardList:ShowAwardTips(resId, bIsShow, AwardItem)
  if bIsShow then
    local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    if tbGeneral and tbGeneral[resId] then
      local slotCanvas, tipsSize
      if 5 == tbGeneral[resId].Type then
        UpdateVisibility(self.WBP_LobbyWeaponDisplayInfo, true)
        self.WBP_LobbyWeaponDisplayInfo:InitInfo(resId, nil, false, nil)
        self.WBP_LobbyWeaponDisplayInfo:SetRenderOpacity(1)
        slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_LobbyWeaponDisplayInfo)
        tipsSize = self.WBP_LobbyWeaponDisplayInfo:GetDesiredSize()
      else
        UpdateVisibility(self.WBP_CommonItemDetail, true)
        self.WBP_CommonItemDetail:InitCommonItemDetail(resId)
        slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_CommonItemDetail)
        tipsSize = self.WBP_CommonItemDetail:GetDesiredSize()
      end
      local GeometryItem = AwardItem:GetCachedGeometry()
      local GeometryCanvasPanelRoot = self.CanvasPanelRoot:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelRoot, GeometryItem)
      if slotCanvas then
        local itemSize = AwardItem:GetDesiredSize()
        local offset = UE.FVector2D(0)
        offset = UE.FVector2D(tipsSize.X / 2 - itemSize.X / 2, 0)
        slotCanvas:SetPosition(Pos - offset)
      end
    end
  else
    self.WBP_LobbyWeaponDisplayInfo:SetVisibility(UE.ESlateVisibility.Hidden)
    self.WBP_CommonItemDetail:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
return AchievementAwardList
