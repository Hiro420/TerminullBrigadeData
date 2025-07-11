local AchievePlayerInfoBadgesItem = Class()
function AchievePlayerInfoBadgesItem:InitAchievePlayerInfoBadgesItem(BadgesId, bSelect, ParentView)
  if not BadgesId or 0 == BadgesId then
    self.RGStateControllerEmpty:ChangeStatus(EEmpty.Empty)
    return
  end
  self.RGStateControllerEmpty:ChangeStatus(EEmpty.NotEmpty)
  self.BP_ButtonWithSoundSelect.OnClicked:Add(self, self.OnSelect)
  self.BadgesId = BadgesId
  self.ParentView = ParentView
  self.bSelect = bSelect
  UpdateVisibility(self, true)
  if bSelect then
    self.RGStateControllerSelectBadge:ChangeStatus(ESelect.Select)
  else
    self.RGStateControllerSelectBadge:ChangeStatus(ESelect.UnSelect)
  end
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if tbGeneral and tbGeneral[BadgesId] then
    SetImageBrushByPath(self.URGImageBadgeIcon, tbGeneral[BadgesId].Icon)
  end
  self.RGStateControllerLock:ChangeStatus(ELock.UnLock)
end
function AchievePlayerInfoBadgesItem:OnSelect()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    local operatorSucc = self.ParentView:OperatorDisplayBadges(self.BadgesId)
    if operatorSucc then
      self.bSelect = not self.bSelect
      if self.bSelect then
        self.RGStateControllerSelectBadge:ChangeStatus(ESelect.Select)
      else
        self.RGStateControllerSelectBadge:ChangeStatus(ESelect.UnSelect)
      end
    end
  end
end
function AchievePlayerInfoBadgesItem:Hide()
  self.BP_ButtonWithSoundSelect.OnClicked:Remove(self, self.OnSelect)
  UpdateVisibility(self, false)
end
function AchievePlayerInfoBadgesItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowBadgesTips(true, self.BadgesId, self)
  end
end
function AchievePlayerInfoBadgesItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowBadgesTips(false, self.BadgesId)
  end
end
return AchievePlayerInfoBadgesItem
