local AchievePlayerInfoBadgesTips = Class()

function AchievePlayerInfoBadgesTips:BindUIInput()
  self.WBP_InteractTipWidgetSave:BindInteractAndClickEvent(self, self.OnSaveClick)
  self.WBP_InteractTipWidgetAll:BindInteractAndClickEvent(self, self.LinkToAchievement)
end

function AchievePlayerInfoBadgesTips:UnBindUIInput()
  self.WBP_InteractTipWidgetSave:UnBindInteractAndClickEvent(self, self.OnSaveClick)
  self.WBP_InteractTipWidgetAll:UnBindInteractAndClickEvent(self, self.LinkToAchievement)
end

function AchievePlayerInfoBadgesTips:Construct()
  self.Overridden.Construct(self)
end

function AchievePlayerInfoBadgesTips:InitAchievePlayerInfoBadgesTips(bResetDisplayEquipedCache)
  UpdateVisibility(self, true)
  self:BindUIInput()
  self.AchievementViewModel = UIModelMgr:Get("AchievementViewModel")
  local displayBadges = self.AchievementViewModel:GetDisplayBadges()
  if self.DisplayEquipedCache == nil or bResetDisplayEquipedCache then
    self.DisplayEquipedCache = DeepCopy(displayBadges)
  end
  self.viewModel = UIModelMgr:Get("PlayerInfoViewModel")
  self.BP_ButtonWithSoundSave.Onclicked:Add(self, self.OnSaveClick)
  self.BP_ButtonWithSoundCheckAllAchievement.Onclicked:Add(self, self.LinkToAchievement)
  local badgeSortList = self.AchievementViewModel:GetAchievementBadges()
  local num = #badgeSortList
  local sum = self:GetTotalBadgesNum()
  local numStr = string.format("%d/%d", num, sum)
  self.RGTextBadgesNum:SetText(numStr)
  for i, v in ipairs(badgeSortList) do
    local item = GetOrCreateItem(self.WrapBoxBadgesList, i, self.WBP_AchievePlayerInfoBadgesItem:GetClass())
    local bSelect = table.Contain(self.DisplayEquipedCache, v)
    item:InitAchievePlayerInfoBadgesItem(v, bSelect, self)
  end
  HideOtherItem(self.WrapBoxBadgesList, #badgeSortList + 1)
end

function AchievePlayerInfoBadgesTips:ShowBadgesTips(bIsShow, BadgesId, HoverItem)
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

function AchievePlayerInfoBadgesTips:GetTotalBadgesNum()
  local achievementViewModel = UIModelMgr:Get("AchievementViewModel")
  local typeToTbAchievement = achievementViewModel:GetTypeToTbAchievement()
  local maxNum = 0
  for i, v in pairs(typeToTbAchievement) do
    maxNum = maxNum + #v.AchievementItemDataList
  end
  return maxNum
end

function AchievePlayerInfoBadgesTips:OperatorDisplayBadges(BadgesId)
  if table.Contain(self.DisplayEquipedCache, BadgesId) then
    table.RemoveItem(self.DisplayEquipedCache, BadgesId)
    return true
  elseif #self.DisplayEquipedCache < self.AchievementViewModel:GetMaxDisplayBadgesNum() then
    table.insert(self.DisplayEquipedCache, BadgesId)
    return true
  end
  return false
end

function AchievePlayerInfoBadgesTips:OnSaveClick()
  self.AchievementViewModel:RequestSetDisplayBadges(self.DisplayEquipedCache)
end

function AchievePlayerInfoBadgesTips:LinkToAchievement()
  local playerInfoMainViewModel = UIModelMgr:Get("PlayerInfoMainViewModel")
  playerInfoMainViewModel:SelectToggleId(EPlayerInfoMainToggleStatus.Achievement)
end

function AchievePlayerInfoBadgesTips:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end

function AchievePlayerInfoBadgesTips:Hide()
  local displayBadges = self.AchievementViewModel:GetDisplayBadges()
  self.DisplayEquipedCache = DeepCopy(displayBadges)
  self.BP_ButtonWithSoundSave.Onclicked:Remove(self, self.OnSaveClick)
  self.BP_ButtonWithSoundCheckAllAchievement.Onclicked:Remove(self, self.LinkToAchievement)
  self:UnBindUIInput()
  SetHitTestInvisible(self)
  self:PlayAnimation(self.Ani_out)
end

return AchievePlayerInfoBadgesTips
