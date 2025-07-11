local PlayerInfoChangeHeroTips = Class()
function PlayerInfoChangeHeroTips:InitPlayerInfoChangeHeroTips()
  self:StopAnimation(self.Ani_out)
  if not CheckIsVisility(self) then
    self:PlayAnimation(self.Ani_in)
  end
  UpdateVisibility(self, true)
  self.RGToggleGroupRoleItem.OnCheckStateChanged:Add(self, self.OnHeroSelect)
  self.RGToggleGroupRoleItem.OnCheckCanSelectEvent:Bind(self, self.OnCheckCanSelectEvent)
  self.viewModel = UIModelMgr:Get("PlayerInfoViewModel")
  self.RGToggleGroupRoleItem:ClearGroup()
  local heroInfo = DataMgr.GetMyHeroInfo()
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  local selectId = tonumber(heroInfo.equipHero)
  local idx = 1
  local allCharacterList = LogicRole.GetAllCanSelectCharacterList()
  table.sort(allCharacterList, function(A, B)
    if DataMgr.IsOwnHero(A) ~= DataMgr.IsOwnHero(B) then
      return DataMgr.IsOwnHero(A)
    end
    return A < B
  end)
  for i, v in ipairs(allCharacterList) do
    if tbHeroMonster and tbHeroMonster[v] then
      local item = GetOrCreateItem(self.WrapBoxRoleList, idx, self.WBP_PlayerInfoRoleItem:GetClass())
      local bSelect = self.viewModel:GetCurShowHeroId() == v
      if bSelect then
        selectId = v
      end
      item:InitPlayerInfoRoleItem(tbHeroMonster[v], bSelect)
      self.RGToggleGroupRoleItem:AddToGroup(v, item)
      idx = idx + 1
    end
  end
  HideOtherItem(self.WrapBoxRoleList, idx)
  self.RGToggleGroupRoleItem:SelectId(selectId)
end
function PlayerInfoChangeHeroTips:OnHeroSelect(SelectId)
  if DataMgr.IsOwnHero(SelectId) then
    if self.viewModel:GetCurShowHeroId() ~= SelectId then
      self.viewModel:ChangePlayerInfoRoleDisplay(SelectId)
    end
  else
    self.RGToggleGroupRoleItem:SelectId(self.viewModel:GetCurShowHeroId())
  end
end
function PlayerInfoChangeHeroTips:OnCheckCanSelectEvent(SelectId)
  return DataMgr.IsOwnHero(SelectId)
end
function PlayerInfoChangeHeroTips:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end
function PlayerInfoChangeHeroTips:Hide()
  self.RGToggleGroupRoleItem.OnCheckStateChanged:Remove(self, self.OnHeroSelect)
  self.RGToggleGroupRoleItem.OnCheckCanSelectEvent:Unbind()
  SetHitTestInvisible(self)
  self:PlayAnimation(self.Ani_out)
end
return PlayerInfoChangeHeroTips
