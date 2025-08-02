local OrderedMap = require("Framework.DataStruct.OrderedMap")
local ViewSetChangeHeroTip = UnLua.Class()
local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)

function ViewSetChangeHeroTip:OnShow(ParentView, HeroToIdxOrderMap, RedDotClass, bIsHideLockHero)
  self.IsNeedHideByUIMgr = true
  self:InitViewSetChangeHeroTip(ParentView, HeroToIdxOrderMap, RedDotClass, bIsHideLockHero)
end

function ViewSetChangeHeroTip:InitViewSetChangeHeroTip(ParentView, HeroToIdxOrderMap, RedDotClass, bIsHideLockHero)
  self.ParentView = ParentView
  self.BP_ButtonWithSoundClose.OnClicked:Add(self, self.Hide)
  self.BP_ButtonWithSoundMask.OnClicked:Add(self, self.Hide)
  UpdateVisibility(self.AutoLoadPanel, true)
  UpdateVisibility(self, true)
  self.RGToggleGroupHero.OnCheckStateChanged:Add(self, self.OnFirstGroupCheckStateChanged)
  self.RGToggleGroupHero:ClearGroup()
  local idx = 1
  local selectId
  local heroIds = {}
  for k in pairs(HeroToIdxOrderMap) do
    table.insert(heroIds, k)
  end
  table.sort(heroIds, function(a, b)
    local aOwned = DataMgr.IsOwnHero(a)
    local bOwned = DataMgr.IsOwnHero(b)
    local aLimited = DataMgr.IsLimitedHeroe(a) ~= nil
    local bLimited = DataMgr.IsLimitedHeroe(b) ~= nil
    if aOwned ~= bOwned then
      return aOwned
    end
    if aOwned and bOwned then
      return not aLimited and bLimited
    end
    return false
  end)
  for i, v in ipairs(heroIds) do
    local heroId = v
    if tbHeroMonster and tbHeroMonster[heroId] and (not bIsHideLockHero or DataMgr.IsOwnHero(heroId)) then
      local item = GetOrCreateItem(self.WrapBoxHeroList, idx, self.WBP_ViewSetRoleItem:GetClass())
      self.RGToggleGroupHero:AddToGroup(heroId, item)
      local curHeroId = self.ParentView:GetCurShowHeroId() or DataMgr.GetMyHeroInfo().equipHero
      local bSelect = curHeroId == heroId
      if bSelect then
        selectId = heroId
      end
      item:InitViewSetRoleItem(heroId, DataMgr.GetMyHeroInfo().equipHero == heroId, bSelect, RedDotClass)
      self.RGToggleGroupHero:AddToGroup(heroId, item)
      idx = idx + 1
    end
  end
  if selectId then
    self.RGToggleGroupHero.CurSelectId = selectId
  end
  HideOtherItem(self.WrapBoxHeroList, idx)
  self:PlayAnimation(self.Ani_in)
end

function ViewSetChangeHeroTip:OnFirstGroupCheckStateChanged(selectId)
  if UE.RGUtil.IsUObjectValid(self.ParentView) and self.ParentView.SelectHeroId then
    self.ParentView:SelectHeroId(selectId)
    self:Hide()
  end
end

function ViewSetChangeHeroTip:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
    UpdateVisibility(self.AutoLoadPanel, false)
    if self.IsNeedHideByUIMgr then
      UIMgr:Hide(ViewID.UI_ViewSetChangeHeroTip)
      self.IsNeedHideByUIMgr = false
    end
  end
end

function ViewSetChangeHeroTip:Hide(bNotFadeOut)
  if bNotFadeOut then
    UpdateVisibility(self, false)
    UpdateVisibility(self.AutoLoadPanel, false)
  else
    self:StopAnimation(self.Ani_in)
    self:PlayAnimation(self.Ani_out)
  end
  self.BP_ButtonWithSoundClose.OnClicked:Remove(self, self.Hide)
  self.BP_ButtonWithSoundMask.OnClicked:Remove(self, self.Hide)
  self.RGToggleGroupHero.OnCheckStateChanged:Remove(self, self.OnFirstGroupCheckStateChanged)
end

function ViewSetChangeHeroTip:OnHide(...)
  self:Hide(true)
end

return ViewSetChangeHeroTip
