local AchievementDisplayView = UnLua.Class()
local EscName = "PauseGame"
local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
local BadgesSort = function(A, B)
  local generalA = tbGeneral[A]
  local generalB = tbGeneral[B]
  if generalA.rare ~= generalB.rare then
    return generalA.rare > generalB.rare
  end
  return B < A
end
function AchievementDisplayView:Construct()
  self.RGToggleGroup.OnCheckStateChanged:Add(self, self.OnToggleFirstGroupChanged)
  self.RGToggleGroupAchievementType.OnCheckStateChanged:Add(self, self.OnToggleGroupAchievementTypeChanged)
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Add(self, self.Hide)
end
function AchievementDisplayView:Destruct()
  self.RGToggleGroup.OnCheckStateChanged:Remove(self, self.OnToggleFirstGroupChanged)
  self.RGToggleGroupAchievementType.OnCheckStateChanged:Remove(self, self.OnToggleGroupAchievementTypeChanged)
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Remove(self, self.Hide)
end
function AchievementDisplayView:InitAchievementDisplayView()
  UpdateVisibility(self, true)
  self.viewModel = UIModelMgr:Get("AchievementViewModel")
  self:UpdateAchievementFirstToggleList()
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      AchievementDisplayView.Hide
    })
  end
  self:PushInputAction()
end
function AchievementDisplayView:Hide()
  UpdateVisibility(self, false)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  self.viewModel = nil
end
function AchievementDisplayView:UpdateAchievementTypeToggleList()
  self.RGToggleGroupAchievementType:ClearGroup()
  local achievementTypeList = self.viewModel:GetAchievementToggleList()
  for i, v in ipairs(achievementTypeList) do
    local item = GetOrCreateItem(self.HorizontalToggle, i, self.WBP_AchievementToggle:GetClass())
    item:InitAchievementToggle(v)
    self.RGToggleGroupAchievementType:AddToGroup(i, item)
  end
  self.RGToggleGroupAchievementType:SelectId(1)
end
function AchievementDisplayView:UpdateAchievementFirstToggleList()
  self.RGToggleGroup:ClearGroup()
  local achievementToggleList = self.viewModel:GetAchievementDisplayToggleList()
  for i, v in ipairs(achievementToggleList) do
    local item = GetOrCreateItem(self.ScrollBoxToggle, i, self.WBP_AchievementDisplayToggle:GetClass())
    local curNum, maxNum = self:CalToggleNum(i)
    local str = v
    if curNum >= 0 and maxNum > 0 then
      str = string.format("%s %d/%d", str, curNum, maxNum)
    end
    item:InitAchievementDisplayToggle(str)
    self.RGToggleGroup:AddToGroup(i, item)
  end
  HideOtherItem(self.ScrollBoxToggle, #achievementToggleList + 1)
  self.RGToggleGroup:SelectId(2)
end
function AchievementDisplayView:CalToggleNum(toggleIdx)
  if 2 == toggleIdx then
    local typeToTbAchievement = self.viewModel:GetTypeToTbAchievement()
    local maxNum = 0
    local curNum = 0
    for i, v in pairs(typeToTbAchievement) do
      maxNum = maxNum + #v.AchievementItemDataList
      for idxAchievementItemData, vAchievementItemData in ipairs(v.AchievementItemDataList) do
        for idxTask, vTask in ipairs(vAchievementItemData.tbTaskGroup.tasklist) do
          local state = Logic_MainTask.GetStateByTaskId(vTask)
          if state == ETaskState.GotAward then
            curNum = curNum + 1
            break
          end
        end
      end
    end
    return curNum, maxNum
  end
  return -1, -1
end
function AchievementDisplayView:OnToggleFirstGroupChanged(SelectId)
  UpdateVisibility(self.CanvasPanelBadges, 2 == SelectId)
  if 2 == SelectId then
    self:UpdateAchievementTypeToggleList()
  end
end
function AchievementDisplayView:OnToggleGroupAchievementTypeChanged(SelectId)
  self.CurSelectAchievementType = SelectId
  self:UpdateBadgesTileView()
end
function AchievementDisplayView:UpdateBadgesTileView()
  local achievementItemDataList = self.viewModel:GetAchievementItemDataListByType(self.CurSelectAchievementType)
  self.RGTileViewAchievement:RecyleAllData()
  if table.IsEmpty(achievementItemDataList) then
    print("achievementItemDataList Is Empty")
    return
  end
  local badgesTb = {}
  for i, v in ipairs(achievementItemDataList) do
    local DataObj = self.RGTileViewAchievement:GetOrCreateDataObj()
    DataObj.ParentView = self
    DataObj.TaskGroupId = v.tbTaskGroup.id
    print("AchievementDisplayView:UpdateBadgesTileView", v.tbTaskGroup.id)
    local idx = -1
    for idxTask, vTask in ipairs(v.tbTaskGroup.tasklist) do
      local state = Logic_MainTask.GetStateByTaskId(vTask)
      if state == ETaskState.GotAward then
        idx = idxTask
      end
    end
    if idx > 0 then
      local badge = v.Badges[idx]
      table.insert(badgesTb, badge)
    end
  end
  table.sort(badgesTb, BadgesSort)
  local TileViewAry = UE.TArray(UE.UObject)
  TileViewAry:Reserve(#badgesTb)
  for i, v in ipairs(badgesTb) do
    local DataObj = self.RGTileViewAchievement:GetOrCreateDataObj()
    DataObj.ParentView = self
    local badge = v
    DataObj.BadgeId = badge
    DataObj.SelectStatus = ESelect.UnSelect
    DataObj.bSelect = false
    for i, v in ipairs(self.viewModel:GetDisplayBadges()) do
      if v == badge then
        DataObj.SelectStatus = ESelect.Select
        break
      end
    end
    TileViewAry:Add(DataObj)
  end
  self.RGTileViewAchievement:SetRGListItems(TileViewAry, true, true)
  local displayBadgesTemp = self.viewModel:GetDisplayBadges()
  local count = 0
  for i, v in ipairs(displayBadgesTemp) do
    if v > 0 then
      count = count + 1
    end
  end
  local str = string.format("\230\156\128\229\164\154\229\143\175\232\174\190\231\189\174\229\177\149\231\164\186%d/%d\228\184\170\230\136\144\229\176\177\229\190\189\231\171\160", count, self.viewModel:GetMaxDisplayBadgesNum())
  self.RGTextDisplayBadgesNum:SetText(str)
end
function AchievementDisplayView:EquipAchievementBadges(BadgeId)
  local displayBadges = self.viewModel:GetDisplayBadges()
  if not table.Contain(displayBadges, BadgeId) then
    table.insert(displayBadges, BadgeId)
    self.viewModel:RequestSetDisplayBadges(displayBadges)
  end
end
function AchievementDisplayView:UnEquipAchievementBadges(BadgeId)
  local displayBadges = self.viewModel:GetDisplayBadges()
  if table.Contain(displayBadges, BadgeId) then
    table.RemoveItem(displayBadges, BadgeId)
    if table.IsEmpty(displayBadges) then
      displayBadges = {0}
    end
    self.viewModel:RequestSetDisplayBadges(displayBadges)
  end
end
function AchievementDisplayView:HoverBadge(BadgeId)
  if tbGeneral and tbGeneral[BadgeId] then
    self.WBP_AchievementBadgeTip:InitAchievementBadgeTip(tbGeneral[BadgeId])
  end
end
function AchievementDisplayView:UnHoverBadge(BadgeId)
  self.WBP_AchievementBadgeTip:Hide()
end
return AchievementDisplayView
