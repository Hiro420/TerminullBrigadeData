local AchievementBadgesItem = UnLua.Class()
function AchievementBadgesItem:Construct()
  self.ButtonSelect.OnClicked:Add(self, self.OnSelectClick)
end
function AchievementBadgesItem:Destruct()
  self.ButtonSelect.OnClicked:Remove(self, self.OnSelectClick)
end
function AchievementBadgesItem:OnListItemObjectSet(ListItemObj)
  self.DataObj = ListItemObj
  local DataObjTemp = ListItemObj
  if not UE.RGUtil.IsUObjectValid(DataObjTemp) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(DataObjTemp.ParentView) then
    return
  end
  local badgeId = DataObjTemp.BadgeId
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not tbGeneral or not tbGeneral[badgeId] then
    return
  end
  local badgeItem = tbGeneral[badgeId]
  SetImageBrushByPath(self.URGImageIcon, badgeItem.Icon)
  self.RGTextName:SetText(badgeItem.Name)
  self.RGStateControllerSelect:ChangeStatus(DataObjTemp.SelectStatus)
end
function AchievementBadgesItem:BP_OnEntryReleased()
  self.DataObj = nil
end
function AchievementBadgesItem:OnMouseEnter()
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  self.DataObj.ParentView:HoverBadge(self.DataObj.BadgeId)
end
function AchievementBadgesItem:OnMouseLeave()
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  self.DataObj.ParentView:UnHoverBadge(self.DataObj.BadgeId)
end
function AchievementBadgesItem:OnSelectClick()
  if not UE.RGUtil.IsUObjectValid(self.DataObj) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  if self.DataObj.SelectStatus == ESelect.Select then
    self.DataObj.ParentView:UnEquipAchievementBadges(self.DataObj.BadgeId)
  else
    self.DataObj.ParentView:EquipAchievementBadges(self.DataObj.BadgeId)
  end
end
return AchievementBadgesItem
