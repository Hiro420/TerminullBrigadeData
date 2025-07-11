local BattleHistoryRoleItem = Class()
local ESelectAll = {All = "All", Normal = "Normal"}
function BattleHistoryRoleItem:Construct()
  self.Overridden.Construct(self)
end
function BattleHistoryRoleItem:InitBattleHistoryRoleItem(HeroId, bSelect, bIsAll)
  UpdateVisibility(self, true)
  if bIsAll then
    self.RGStateControllerAll:ChangeStatus(ESelectAll.All)
  else
    self.RGStateControllerAll:ChangeStatus(ESelectAll.Normal)
  end
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if not tbHeroMonster or not tbHeroMonster[HeroId] then
    return
  end
  local tbHeroData = tbHeroMonster[HeroId]
  SetImageBrushByPath(self.URGImageHeroIcon, tbHeroData.ActorIcon)
  if bSelect then
    self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
  else
    self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
  end
  UpdateVisibility(self.LimitedTime, false)
  if DataMgr.IsOwnHero(tbHeroData.ID) then
    self.RGStateControllerLock:ChangeStatus(ELock.UnLock)
  else
    self.RGStateControllerLock:ChangeStatus(ELock.Lock)
  end
  local ExpireAt = DataMgr.IsLimitedHeroe(tbHeroData.ID)
  if ExpireAt then
    SetExpireAtColor(self.Icon_LimitedTime, ExpireAt)
    UpdateVisibility(self.LimitedTime, true)
  end
end
function BattleHistoryRoleItem:Hide()
  UpdateVisibility(self, false)
end
function BattleHistoryRoleItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end
function BattleHistoryRoleItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end
return BattleHistoryRoleItem
