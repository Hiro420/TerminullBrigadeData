local OrderedMap = require("Framework.DataStruct.OrderedMap")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local ViewSet = UnLua.Class()
local PuzzleViewId = 4
local CurrentSelectIndex = 1
local ToggleItemList = {}

function ViewSet:Construct()
end

function ViewSet:OnBindUIInput()
  if self.bCanChangeHero then
    self.WBP_InteractTipWidgetHeroLeft:BindInteractAndClickEvent(self, self.PreChangeHero)
    self.WBP_InteractTipWidgetHeroRight:BindInteractAndClickEvent(self, self.NextChangeHero)
  end
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.HideView)
  self.WBP_InteractTipWidgetMenuPrev:BindInteractAndClickEvent(self, self.OnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:BindInteractAndClickEvent(self, self.OnSelectNextMenu)
end

function ViewSet:OnUnBindUIInput()
  if self.bCanChangeHero then
    self.WBP_InteractTipWidgetHeroLeft:UnBindInteractAndClickEvent(self, self.PreChangeHero)
    self.WBP_InteractTipWidgetHeroRight:UnBindInteractAndClickEvent(self, self.NextChangeHero)
  end
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.HideView)
  self.WBP_InteractTipWidgetMenuPrev:UnBindInteractAndClickEvent(self, self.OnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:UnBindInteractAndClickEvent(self, self.OnSelectNextMenu)
end

function ViewSet:OnShowViewSet(ParentView, DefaultToggleId, DefaultHeroId, ...)
  self.ParentView = ParentView
  self.TbToggleIdToView = self.ParentView:GetToggleIdToView()
  self.CurSelectHeroId = DefaultHeroId or DataMgr.GetMyHeroInfo().equipHero
  UpdateVisibility(self.BP_ButtonWithSoundChangeHero, self.bCanChangeHero, true)
  UpdateVisibility(self.WBP_InteractTipWidgetHeroLeft, self.bCanChangeHero)
  UpdateVisibility(self.WBP_InteractTipWidgetRight, self.bCanChangeHero)
  self.BP_ButtonWithSoundChangeHero.OnClicked:Add(self, self.OnShowChangeTip)
  self.RGToggleGroupViewSet.OnCheckStateChanged:Add(self, self.OnFirstGroupCheckStateChanged)
  if self.bCanChangeHero then
    self:InitHeroList()
  end
  self:PushInputAction()
  ToggleItemList = {}
  self.RGToggleGroupViewSet:ClearGroup()
  local Index = 1
  for i, v in pairs(self.TbToggleIdToView) do
    local toggleItem = GetOrCreateItem(self.HorizontalBoxToggle, Index, self.WBP_ViewSetToggle:GetClass())
    toggleItem:InitViewSetToggle(v.ToggleName, self, v.SystemId)
    if ViewID[v.ViewID] == ViewID.UI_ProficiencyView then
      toggleItem.WBP_RedDotView:ChangeRedDotId(string.format("Proficiency_Menu_1_%d", self.CurSelectHeroId))
    elseif ViewID[v.ViewID] == ViewID.UI_WeaponMain then
      toggleItem.WBP_RedDotView:ChangeRedDotId(string.format("Weapon_Menu_%d", self.CurSelectHeroId))
    else
      toggleItem.WBP_RedDotView:ChangeRedDotId("")
    end
    self.RGToggleGroupViewSet:AddToGroup(i, toggleItem)
    print("ViewSet:OnShowViewSet", v.ViewID)
    BeginnerGuideData:UpdateWidget("ViewSetToggle_" .. v.ViewID, toggleItem)
    Index = Index + 1
    table.insert(ToggleItemList, {
      WidgetItem = toggleItem,
      SystemId = v.SystemId
    })
  end
  HideOtherItem(self.HorizontalBoxToggle, Index)
  CurrentSelectIndex = DefaultToggleId or 1
  self.RGToggleGroupViewSet:SelectId(CurrentSelectIndex)
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if tbHeroMonster and tbHeroMonster[self.CurSelectHeroId] then
    self.RGTextHeroName:SetText(tbHeroMonster[self.CurSelectHeroId].Name)
  end
  self:PushInputAction()
end

function ViewSet:SelectToggle(SelectIdx)
  self.RGToggleGroupViewSet:SelectId(SelectIdx)
end

function ViewSet:OnShowLink(SelectId, ...)
  self.RGToggleGroupViewSet:SelectId(SelectId, true)
  self.SelectViewId = SelectId
  local selectInfo
  for i, v in pairs(self.TbToggleIdToView) do
    if i == SelectId then
      selectInfo = v
    else
      local inst = UIMgr:GetLuaFromActiveView(ViewID[v.ViewID])
      if inst and inst.HideViewByViewSet then
        inst:HideViewByViewSet(true)
      else
        UIMgr:Hide(ViewID[v.ViewID], false)
      end
    end
  end
  if selectInfo then
    local showParams = {}
    if UE.RGUtil.IsUObjectValid(self.ParentView) then
      if self.ParentView.GetShowParamsByViewId then
        showParams = self.ParentView:GetShowParamsByViewId(ViewID[selectInfo.ViewID])
      end
      if self.ParentView.PreShowSubView then
        self.ParentView:PreShowSubView(ViewID[selectInfo.ViewID])
      end
    end
    local params = {
      ...
    }
    for i, v in ipairs(params) do
      table.insert(showParams, v)
    end
    UIMgr:Show(ViewID[selectInfo.ViewID], false, table.unpack(showParams))
  end
end

function ViewSet:InitHeroList()
  local allCharacterList = LogicRole.GetAllCanSelectCharacterList()
  table.sort(allCharacterList, function(A, B)
    if DataMgr.IsOwnHero(A) ~= DataMgr.IsOwnHero(B) then
      return DataMgr.IsOwnHero(A)
    end
    return A < B
  end)
  self.HeroToIdxOrderMap = OrderedMap.New()
  for i, v in ipairs(allCharacterList) do
    self.HeroToIdxOrderMap:Add(v, i)
  end
end

function ViewSet:OnShowChangeTip()
  UpdateVisibility(self.RGAutoLoadPanelChangeHero, true)
  self.RGAutoLoadPanelChangeHero.ChildWidget:InitViewSetChangeHeroTip(self, self.HeroToIdxOrderMap, nil, true)
end

function ViewSet:OnFirstGroupCheckStateChanged(SelectId)
  self.SelectViewId = SelectId
  local selectInfo
  for i, v in pairs(self.TbToggleIdToView) do
    if i == SelectId then
      selectInfo = v
    else
      local inst = UIMgr:GetLuaFromActiveView(ViewID[v.ViewID])
      if inst and inst.HideViewByViewSet then
        inst:HideViewByViewSet(true)
      else
        UIMgr:Hide(ViewID[v.ViewID], false)
      end
    end
  end
  if selectInfo then
    local showParams = {}
    if UE.RGUtil.IsUObjectValid(self.ParentView) then
      if self.ParentView.GetShowParamsByViewId then
        showParams = self.ParentView:GetShowParamsByViewId(ViewID[selectInfo.ViewID])
      end
      if self.ParentView.PreShowSubView then
        self.ParentView:PreShowSubView(ViewID[selectInfo.ViewID])
      end
    end
    UIMgr:Show(ViewID[selectInfo.ViewID], false, table.unpack(showParams))
  end
  if PuzzleViewId == SelectId then
    self.RGTextHeroName:SetColorAndOpacity(self.HeroNameTextColor_PuzzieView)
  else
    self.RGTextHeroName:SetColorAndOpacity(self.HeroNameTextColor)
  end
end

function ViewSet:UpdateViewByHeroId(HeroId)
  if self.TbToggleIdToView[self.SelectViewId] then
    local viewData = self.TbToggleIdToView[self.SelectViewId]
    local view = UIMgr:GetLuaFromActiveView(ViewID[viewData.ViewID])
    if view and view.UpdateViewByHeroId then
      view:UpdateViewByHeroId(HeroId)
    end
  end
  local Index = 1
  for i, SingleViewData in pairs(self.TbToggleIdToView) do
    if ViewID[SingleViewData.ViewID] == ViewID.UI_ProficiencyView then
      local Item = self.HorizontalBoxToggle:GetChildAt(Index - 1)
      if Item then
        Item.WBP_RedDotView:ChangeRedDotId(string.format("Proficiency_Menu_1_%d", HeroId))
      end
    elseif ViewID[SingleViewData.ViewID] == ViewID.UI_WeaponMain then
      local Item = self.HorizontalBoxToggle:GetChildAt(Index - 1)
      if Item then
        Item.WBP_RedDotView:ChangeRedDotId(string.format("Weapon_Menu_%d", HeroId))
      end
    else
      local Item = self.HorizontalBoxToggle:GetChildAt(Index - 1)
      if Item then
        Item.WBP_RedDotView:ChangeRedDotId("")
      end
    end
    Index = Index + 1
  end
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if tbHeroMonster and tbHeroMonster[HeroId] then
    self.RGTextHeroName:SetText(tbHeroMonster[HeroId].Name)
  end
end

function ViewSet:IsStstemUnlockByIndex(index)
  if not ToggleItemList[index] then
    return true
  end
  local SystemID = ToggleItemList[index].SystemId
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and SystemUnlockModule:CheckIsSystemUnlock(SystemID) then
    return true
  elseif SystemID < 0 then
    return true
  end
  return false
end

function ViewSet:OnSelectPrevMenu()
  local StartSelectIndex = CurrentSelectIndex
  while true do
    CurrentSelectIndex = CurrentSelectIndex - 1
    if CurrentSelectIndex < 1 then
      CurrentSelectIndex = #ToggleItemList
    end
    if CurrentSelectIndex == StartSelectIndex then
      return
    end
    if self:IsStstemUnlockByIndex(CurrentSelectIndex) then
      ToggleItemList[CurrentSelectIndex].WidgetItem:OnCheckClick()
      return
    end
  end
end

function ViewSet:OnSelectNextMenu()
  local StartSelectIndex = CurrentSelectIndex
  while true do
    CurrentSelectIndex = CurrentSelectIndex + 1
    if CurrentSelectIndex > #ToggleItemList then
      CurrentSelectIndex = 1
    end
    if CurrentSelectIndex == StartSelectIndex then
      return
    end
    print("zzq CurrentSelectIndex: ", CurrentSelectIndex)
    if self:IsStstemUnlockByIndex(CurrentSelectIndex) then
      ToggleItemList[CurrentSelectIndex].WidgetItem:OnCheckClick()
      return
    end
  end
end

function ViewSet:OnHideViewSet()
  for i, v in pairs(self.TbToggleIdToView) do
    if UIMgr:IsShow(ViewID[v.ViewID]) then
      local inst = UIMgr:GetLuaFromActiveView(ViewID[v.ViewID])
      if inst and inst.HideViewByViewSet then
        inst:HideViewByViewSet(true)
      else
        UIMgr:Hide(ViewID[v.ViewID], false)
      end
    end
  end
  self.ParentView = nil
  self.BP_ButtonWithSoundChangeHero.OnClicked:Remove(self, self.OnShowChangeTip)
  self.RGToggleGroupViewSet.OnCheckStateChanged:Remove(self, self.OnFirstGroupCheckStateChanged)
end

function ViewSet:PreChangeHero(Step)
  if CheckIsVisility(self.RGAutoLoadPanelChangeHero) then
    return
  end
  local step = Step or 1
  local curSelectId = self:GetCurShowHeroId()
  local idx = self.HeroToIdxOrderMap[curSelectId]
  idx = idx - step
  if idx <= 0 then
    idx = #self.HeroToIdxOrderMap + idx
  end
  local heroId = self.HeroToIdxOrderMap:GetKeyByIdx(idx)
  if heroId then
    if DataMgr.IsOwnHero(heroId) then
      self:SelectHeroId(heroId)
      PlaySound2DByName(self.ChangeHeroSoundName, "ViewSet:PreChangeHero")
    else
      self:PreChangeHero(step + 1)
    end
  end
end

function ViewSet:NextChangeHero(Step)
  if CheckIsVisility(self.RGAutoLoadPanelChangeHero) then
    return
  end
  local step = Step or 1
  local curSelectId = self:GetCurShowHeroId()
  local idx = self.HeroToIdxOrderMap[curSelectId]
  idx = idx + step
  if idx > #self.HeroToIdxOrderMap then
    idx = idx - #self.HeroToIdxOrderMap
  end
  local heroId = self.HeroToIdxOrderMap:GetKeyByIdx(idx)
  if heroId then
    if DataMgr.IsOwnHero(heroId) then
      self:SelectHeroId(heroId)
      PlaySound2DByName(self.ChangeHeroSoundName, "ViewSet:NextChangeHero")
    else
      self:NextChangeHero(step + 1)
    end
  end
end

function ViewSet:HideView(bWithoutAni)
  if self.RGAutoLoadPanelChangeHero.ChildWidget then
    self.RGAutoLoadPanelChangeHero.ChildWidget:Hide(true)
  else
    UpdateVisibility(self.RGAutoLoadPanelChangeHero, false)
  end
  local notHide = false
  if self.TbToggleIdToView[self.RGToggleGroupViewSet.CurSelectId] then
    local viewId = self.TbToggleIdToView[self.RGToggleGroupViewSet.CurSelectId].ViewID
    local inst = UIMgr:GetLuaFromActiveView(ViewID[viewId])
    if inst and inst.HideViewByViewSet then
      notHide = inst:HideViewByViewSet()
    else
      UIMgr:Hide(ViewID[viewId], false, nil, bWithoutAni)
    end
  end
  if not notHide then
    for i, v in pairs(self.TbToggleIdToView) do
      if i ~= self.RGToggleGroupViewSet.CurSelectId then
        local inst = UIMgr:GetLuaFromActiveView(ViewID[v.ViewID])
        if inst and inst.HideViewByViewSet then
          inst:HideViewByViewSet()
        else
          UIMgr:Hide(ViewID[v.ViewID], false, nil, bWithoutAni)
        end
      end
    end
  end
  if UE.RGUtil.IsUObjectValid(self.ParentView) and not notHide then
    UIMgr:Hide(self.ParentView.ViewID, true, nil, bWithoutAni)
  end
end

function ViewSet:GetCurShowHeroId()
  return self.CurSelectHeroId
end

function ViewSet:SelectHeroId(SelectId)
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    if self.ParentView.GetCanChangeHero and not self.ParentView:GetCanChangeHero() then
      return
    end
    if self.ParentView.SelectHeroId then
      self.ParentView:SelectHeroId(SelectId)
    end
  end
  self.CurSelectHeroId = SelectId
  self:UpdateViewByHeroId(SelectId)
end

return ViewSet
