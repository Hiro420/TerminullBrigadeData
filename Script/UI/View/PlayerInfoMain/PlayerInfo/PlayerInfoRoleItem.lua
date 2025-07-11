local PlayerInfoRoleItem = Class()
function PlayerInfoRoleItem:Construct()
  self.Overridden.Construct(self)
end
function PlayerInfoRoleItem:InitPlayerInfoRoleItem(tbHeroData, bSelect)
  UpdateVisibility(self, true)
  SetImageBrushByPath(self.URGImageRoleHeadIcon, tbHeroData.ActorIcon)
  if bSelect then
    self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
  else
    self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
  end
  if DataMgr.IsOwnHero(tbHeroData.ID) then
    self.RGStateControllerLock:ChangeStatus(ELock.UnLock)
  else
    self.RGStateControllerLock:ChangeStatus(ELock.Lock)
  end
end
function PlayerInfoRoleItem:Hide()
  UpdateVisibility(self, false)
end
function PlayerInfoRoleItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end
function PlayerInfoRoleItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end
return PlayerInfoRoleItem
