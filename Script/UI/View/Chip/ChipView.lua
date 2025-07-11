local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local EscName = "PauseGame"
local ChipUpgrade = "ChipUpgrade"
local ChipLock = "ChipLock"
local ChipDiscard = "ChipDiscard"
local ChipView = Class(ViewBase)
function ChipView:BindClickHandler()
  self.BP_ButtonWithSoundLeft.OnClicked:Add(self, self.OnLeftSlotClick)
  self.BP_ButtonWithSoundRight.OnClicked:Add(self, self.OnRightSlotClick)
  self.Btn_LeftLock.OnClicked:Add(self, self.OnLeftSlotClick)
  self.Btn_RightLock.OnClicked:Add(self, self.OnRightSlotClick)
  self.BP_ButtonWithSoundFilter.OnClicked:Add(self, self.OnFilterClick)
  self.RGToggleGroupSlot.OnCheckStateChanged:Add(self, self.OnSlotSelect)
  self.RGToggleGroupSlot.OnCheckCanSelectEvent:Bind(self, self.OnCheckCanSelect)
  self.BP_ButtonWithSoundEmptyLink.OnClicked:Add(self, self.OnEmptyLinkClick)
  self.BP_ButtonWithSoundLockLink.OnClicked:Add(self, self.OnLockLinkClick)
  self.BP_ButtonWithSoundHelp.OnHovered:Add(self, self.OnHelpHover)
  self.BP_ButtonWithSoundHelp.OnUnHovered:Add(self, self.OnHelpUnHover)
  self.BP_ButtonWithSoundHelpLock.OnHovered:Add(self, self.OnHelpHover)
  self.BP_ButtonWithSoundHelpLock.OnUnHovered:Add(self, self.OnHelpUnHover)
end
function ChipView:UnBindClickHandler()
  self.BP_ButtonWithSoundLeft.OnClicked:Remove(self, self.OnLeftSlotClick)
  self.BP_ButtonWithSoundRight.OnClicked:Remove(self, self.OnRightSlotClick)
  self.Btn_LeftLock.OnClicked:Remove(self, self.OnLeftSlotClick)
  self.Btn_RightLock.OnClicked:Remove(self, self.OnRightSlotClick)
  self.BP_ButtonWithSoundFilter.OnClicked:Remove(self, self.OnFilterClick)
  self.RGToggleGroupSlot.OnCheckStateChanged:Remove(self, self.OnSlotSelect)
  self.RGToggleGroupSlot.OnCheckCanSelectEvent:Unbind()
  self.BP_ButtonWithSoundEmptyLink.OnClicked:Remove(self, self.OnEmptyLinkClick)
  self.BP_ButtonWithSoundLockLink.OnClicked:Remove(self, self.OnLockLinkClick)
  self.BP_ButtonWithSoundHelp.OnHovered:Remove(self, self.OnHelpHover)
  self.BP_ButtonWithSoundHelp.OnUnHovered:Remove(self, self.OnHelpUnHover)
  self.BP_ButtonWithSoundHelpLock.OnHovered:Remove(self, self.OnHelpHover)
  self.BP_ButtonWithSoundHelpLock.OnUnHovered:Remove(self, self.OnHelpUnHover)
end
function ChipView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("ChipViewModel")
  self:BindClickHandler()
end
function ChipView:OnDestroy()
  self:UnBindClickHandler()
end
function ChipView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  LogicRole.ShowOrHideRoleMainHero(false)
  ChangeLobbyCamera(GameInstance, "Role")
  local curHeroId = -1
  local params = {
    ...
  }
  local selectSlot = 1
  if not table.IsEmpty(params) then
    curHeroId = params[1]
    self.ParentView = params[2]
    selectSlot = params[3] or 1
  end
  self:UpdateViewByHeroId(curHeroId, selectSlot)
  if not IsListeningForInputAction(self, ChipUpgrade) then
    ListenForInputAction(ChipUpgrade, UE.EInputEvent.IE_Pressed, true, {
      self,
      ChipView.ListenForChipUpgradeInputAction
    })
  end
  if not IsListeningForInputAction(self, ChipLock) then
    ListenForInputAction(ChipLock, UE.EInputEvent.IE_Pressed, true, {
      self,
      ChipView.ListenForChipLockInputAction
    })
  end
  if not IsListeningForInputAction(self, ChipDiscard) then
    ListenForInputAction(ChipDiscard, UE.EInputEvent.IE_Pressed, true, {
      self,
      ChipView.ListenForChipDiscardInputAction
    })
  end
  self:UpdateFilterStatus()
  local effActor = self:GetChipEffActor()
  effActor:SetActorHiddenInGame(false)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnChipViewShow)
end
function ChipView:OnRollback()
  LogicRole.ShowOrHideRoleMainHero(false)
  if self.ChipViewState == EChipViewState.Normal then
    self:JumpChpEffSeq(true)
  elseif self.ChipViewState == EChipViewState.Strength then
    self:JumpChpEffSeq(false)
  end
  ChangeLobbyCamera(GameInstance, "Role")
  local effActor = self:GetChipEffActor()
  effActor:SetActorHiddenInGame(false)
end
function ChipView:UpdateViewByHeroId(HeroId, SelectSlot)
  local curHeroId = HeroId
  local selectSlot = SelectSlot or 1
  self.viewModel:UpdateCurHeroId(curHeroId)
  self.viewModel:OnUpdateChipEquipSlot(curHeroId)
  self.RGToggleGroupSlot:SelectId(selectSlot)
  self.viewModel:UpdateChipAttrTips()
  self.ChipViewState = EChipViewState.Normal
  self.RGStateControllerUpgrade:ChangeStatus(self.ChipViewState)
  self:PlayChpEffSeq(true)
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if tbHeroMonster and tbHeroMonster[curHeroId] then
    self.RGTextHeroName:SetText(tbHeroMonster[curHeroId].Name)
  end
  self:UpdateChipBagList()
end
function ChipView:OnHide()
  LogicRole.ShowOrHideRoleMainHero(false)
  if UE.RGUtil.IsUObjectValid(self.SequencePlayer) then
    self.SequencePlayer:Stop()
  end
  self:PlayAnimation(self.Ani_out)
  self.viewModel:ResetDataWhenHideView()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayOperatorStrengthTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayOperatorStrengthTimer)
  end
  UpdateVisibility(self.Img_Mask, false)
  local effActor = self:GetChipEffActor()
  effActor:SetActorHiddenInGame(true)
  StopListeningForInputAction(self, ChipUpgrade, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, ChipLock, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, ChipDiscard, UE.EInputEvent.IE_Pressed)
  UpdateVisibility(self.WBP_ChipSlotTips, false)
  print("ChipView:OnHide()")
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end
function ChipView:HideViewByViewSet(ForceHide)
  self.viewModel:ResetStrengthFilter(true)
  if self.ChipViewState == EChipViewState.Normal or ForceHide then
    self.viewModel:ResetNormalFilter(true)
    UIMgr:Hide(ViewID.UI_Chip, true)
    return false
  elseif self.ChipViewState == EChipViewState.Strength then
    self.ChipViewState = EChipViewState.Normal
    self.RGStateControllerUpgrade:ChangeStatus(self.ChipViewState)
    if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelStrengthView.ChildWidget) then
      self.RGAutoLoadPanelStrengthView.ChildWidget:Hide()
    end
    self:PlayChpEffSeq(true)
    return true
  end
  return false
end
function ChipView:ListenForChipUpgradeInputAction()
  if not self.CurHoverChipBagsItemData then
    return
  end
  if not self.CurHoverChipBagsItemData.bRequestedDetail then
    return
  end
  if self.ChipViewState == EChipViewState.Strength then
    return
  end
  local rare = self.viewModel:GetChipRare(self.CurHoverChipBagsItemData)
  if self.CurHoverChipBagsItemData.Chip.level >= self.viewModel:GetMaxLv(rare) then
    return
  end
  local oldViewState = self.ChipViewState
  self.ChipViewState = EChipViewState.Strength
  self.RGStateControllerUpgrade:ChangeStatus(self.ChipViewState)
  if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelStrengthView.ChildWidget) then
    self.RGAutoLoadPanelStrengthView.ChildWidget:InitChipStrengthView(self, self.CurHoverChipBagsItemData, self.ParentView)
  end
  if oldViewState == EChipViewState.Normal then
    self:PlayChpEffSeq()
  end
end
function ChipView:ListenForChipLockInputAction()
  if not self.CurHoverChipBagsItemData then
    return
  end
  self.viewModel:RequestLockChip(self.CurHoverChipBagsItemData)
end
function ChipView:ListenForChipDiscardInputAction()
  if not self.CurHoverChipBagsItemData then
    return
  end
  self.viewModel:RequestDiscardChip(self.CurHoverChipBagsItemData)
end
function ChipView:UpdateSlotInfo(SelectModeIdx)
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if not tbChipSlot then
    return
  end
  if not tbChipSlot[SelectModeIdx] then
    return
  end
  for i, v in ipairs(tbChipSlot) do
    local item = GetOrCreateItem(self.HorizontalBoxStep, i, self.WBP_ChipStepItem:GetClass())
    if SelectModeIdx == i then
      item.RGStateControllerSelect:ChangeStatus(ESelect.Select)
    else
      item.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
    end
    local itemLock = GetOrCreateItem(self.HorizontalBoxStepLock, i, self.WBP_ChipStepItemLock:GetClass())
    if SelectModeIdx == i then
      itemLock.RGStateControllerSelect:ChangeStatus(ESelect.Select)
    else
      itemLock.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
    end
  end
  self.RGTextChipTypeName:SetText(tbChipSlot[SelectModeIdx].name)
  self.RGTextChipTypeNameLock:SetText(tbChipSlot[SelectModeIdx].name)
  local bSlotUnlock = self.viewModel:CheckSlotIsUnLock(SelectModeIdx)
  if bSlotUnlock then
    if self.viewModel:CheckSlotIsEmpty() then
      self.RGStateControllerChipListState:ChangeStatus(EChipListState.Empty)
      if self.RGTextDrop and self.SlotEmptyFmt then
        local idx = self.viewModel.CurSelectModeIdx
        local tbSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
        if tbSlot and tbSlot[idx] then
          local floor = tbSlot[idx].DropFloor or 1
          local dropTxt = UE.FTextFormat(self.SlotEmptyFmt, floor)
          self.RGTextDrop:SetText(dropTxt)
        end
      end
    else
      self.RGStateControllerChipListState:ChangeStatus(EChipListState.Normal)
    end
  elseif self.viewModel:CheckSlotIsEmpty() then
    local lockTxt = UE.FTextFormat(self.SlotLockFmt, tbChipSlot[SelectModeIdx].name)
    self.RGTextSlotLock:SetText(lockTxt)
    self.RGStateControllerChipListState:ChangeStatus(EChipListState.EmptyAndLock)
  else
    self.RGStateControllerChipListState:ChangeStatus(EChipListState.Lock)
  end
end
function ChipView:UpdateEquipChipList(EquipChipList, EquipSlot)
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if not tbChipSlot then
    return
  end
  for i, v in ipairs(tbChipSlot) do
    local chipBagItemData
    for iEquip, vEquip in ipairs(EquipChipList) do
      if vEquip.Slot == i then
        chipBagItemData = vEquip
        break
      end
    end
    local str = string.format("WBP_ChipSlotItem%d", i)
    local bUnLock = self.viewModel:CheckSlotIsUnLock(i)
    if self[str] then
      self[str]:InitChipSlotItem(chipBagItemData, bUnLock, self, i, EquipSlot)
    end
    if 1 == i then
      BeginnerGuideData:UpdateWidget("FirstChipSlotItem", self[str])
    end
  end
end
function ChipView:UpdateChipBagList(SelectSlot)
  local callback = function(chipList)
    self.RGTileViewChipList:RecyleAllData()
    local ChatDataObjList = UE.TArray(UE.UObject)
    ChatDataObjList:Reserve(#chipList)
    for i, v in ipairs(chipList) do
      local dataObj = self.RGTileViewChipList:GetOrCreateDataObj()
      dataObj:Reset()
      dataObj.ChipItemData = v
      dataObj.ParentView = self
      dataObj.ChipFilterTipsFrom = EChipViewState.Normal
      dataObj.bFirst = 1 == i
      ChatDataObjList:Add(dataObj)
    end
    self.RGTileViewChipList:SetRGListItems(ChatDataObjList, true, true)
    self:UpdateStrengthBagList()
    self:UpdateFullStatus()
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        local AllDisplayedEntryWidgets = self.RGTileViewChipList:GetDisplayedEntryWidgets()
        for i, SingleItem in iterator(AllDisplayedEntryWidgets) do
          if 1 == i then
            BeginnerGuideData:UpdateWidget("FirstChipItem", SingleItem)
          end
        end
      end
    }, 0.5, false)
  end
  self.viewModel:FilterNormalChipBagList(false, callback)
end
function ChipView:UpdateChipListKeepSort(Idx)
  local chipItemList = self.RGTileViewChipList:GetListItems():ToTable()
  local ChatDataObjList = UE.TArray(UE.UObject)
  ChatDataObjList:Reserve(#chipItemList)
  for i, v in ipairs(chipItemList) do
    local dataObj = self.RGTileViewChipList:GetOrCreateDataObj()
    dataObj:Reset()
    dataObj.ChipItemData = v.ChipItemData
    dataObj.ParentView = self
    dataObj.ChipFilterTipsFrom = EChipViewState.Normal
    dataObj.bFirst = 1 == i
    ChatDataObjList:Add(dataObj)
  end
  self.RGTileViewChipList:SetRGListItems(ChatDataObjList, true, true)
  self:UpdateStrengthBagListKeepSort()
  self:UpdateFullStatus()
end
function ChipView:UpdateFullStatus()
  local num = self.viewModel:GetChipsTotalNum()
  local maxNum = self.viewModel:GetMaxChipNum()
  local str = string.format("%d/%d", num, maxNum)
  self.RGTextChipNum:SetText(str)
  if num >= maxNum then
    self.StateCtrl_Full:ChangeStatus("Full")
  else
    self.StateCtrl_Full:ChangeStatus("NotFull")
  end
end
function ChipView:UpdateStrengthBagList()
  if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelStrengthView.ChildWidget) and CheckIsVisility(self.RGAutoLoadPanelStrengthView.ChildWidget) and CheckIsVisility(self.RGAutoLoadPanelStrengthView) then
    self.RGAutoLoadPanelStrengthView.ChildWidget:UpdateChipItemList()
  end
end
function ChipView:UpdateFilterStatus()
  local bIsDefaultFilter = self.viewModel:CheckNormalIsDefaultFilter()
  if bIsDefaultFilter then
    self.StateCtrl_Filter:ChangeStatus(EChipFilter.Normal)
  else
    self.StateCtrl_Filter:ChangeStatus(EChipFilter.Filter)
  end
end
function ChipView:UpdateStrengthFilterStatus()
  if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelStrengthView.ChildWidget) and CheckIsVisility(self.RGAutoLoadPanelStrengthView.ChildWidget) and CheckIsVisility(self.RGAutoLoadPanelStrengthView) then
    self.RGAutoLoadPanelStrengthView.ChildWidget:UpdateStrengthFilterStatus()
  end
end
function ChipView:UpdateStrengthBagListKeepSort()
  if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelStrengthView.ChildWidget) and CheckIsVisility(self.RGAutoLoadPanelStrengthView.ChildWidget) and CheckIsVisility(self.RGAutoLoadPanelStrengthView) then
    self.RGAutoLoadPanelStrengthView.ChildWidget:UpdateChipItemListKeepSort()
  end
end
function ChipView:UpdateStrength(Id, OldSubAttr)
  if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelStrengthView.ChildWidget) and CheckIsVisility(self.RGAutoLoadPanelStrengthView.ChildWidget) then
    self.RGAutoLoadPanelStrengthView.ChildWidget:UpdateStrength(Id, OldSubAttr)
  end
end
function ChipView:OnUpgradeChip(OldLv, NewLv)
  if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelStrengthView.ChildWidget) and CheckIsVisility(self.RGAutoLoadPanelStrengthView.ChildWidget) then
    self.RGAutoLoadPanelStrengthView.ChildWidget:OnUpgradeChip(OldLv, NewLv)
  end
end
function ChipView:ShowChipAttrListTip(bShow, ChipBagsItemData, Slot)
  if bShow then
    if Slot and Slot > 0 then
      self.StateCtrl_SelectSlot:ChangeStatus(tostring(Slot))
    else
      self.StateCtrl_SelectSlot:ChangeStatus("Normal")
    end
    local showAttrListTipFunc = function()
      if not self then
        return
      end
      local slot = ChipBagsItemData.TbChipData.Slot
      local str = string.format("WBP_ChipSlotItem%d", slot)
      local equipChipData
      if self[str] then
        equipChipData = self[str].EquipChipData
      end
      local bEquiped = false
      if equipChipData and equipChipData.Chip.id == ChipBagsItemData.Chip.id then
        bEquiped = true
      end
      self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget:InitChipAttrListTip(ChipBagsItemData, bEquiped, EChipAttrListTipSComparetate.Compare, EChipViewState.Normal)
      if not bEquiped and equipChipData then
        UpdateVisibility(self.RGAutoLoadPanelBeCompareChipAttrListTips, true)
        self.RGAutoLoadPanelBeCompareChipAttrListTips.ChildWidget:InitChipAttrListTip(equipChipData, false, EChipAttrListTipSComparetate.BeCompared, EChipViewState.Normal)
      end
      if bEquiped then
        self.viewModel:UpdateChipAttrTips(nil, equipChipData)
      else
        self.viewModel:UpdateChipAttrTips(ChipBagsItemData, equipChipData)
      end
      self:UpdateCurHoverChipBagsItemData(ChipBagsItemData)
    end
    UpdateVisibility(self.RGAutoLoadPanelCompareChipAttrListTips, true)
    self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget:InitEmpty()
    if not ChipBagsItemData.bRequestedDetail then
      self.viewModel:RequestGetChipDetail({
        ChipBagsItemData.Chip.id
      }, showAttrListTipFunc)
    else
      showAttrListTipFunc()
    end
  else
    if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget) then
      self.RGAutoLoadPanelCompareChipAttrListTips.ChildWidget:Hide()
    end
    if UE.RGUtil.IsUObjectValid(self.RGAutoLoadPanelBeCompareChipAttrListTips.ChildWidget) then
      self.RGAutoLoadPanelBeCompareChipAttrListTips.ChildWidget:Hide()
    end
    self.viewModel:UpdateChipAttrTips()
    self:UpdateCurHoverChipBagsItemData(nil)
  end
end
function ChipView:UpdateCurHoverChipBagsItemData(ChipBagsItemData)
  self.CurHoverChipBagsItemData = ChipBagsItemData
end
function ChipView:UpdateAttrTips(ChipOrderedMap)
  self.WBP_ChipAttrTips:InitChipAttrTips(ChipOrderedMap)
end
function ChipView:EquipChipItem(ChipBagsItemData, bRightMouseBtnClick)
  if not ChipBagsItemData then
    return
  end
  local str = string.format("WBP_ChipSlotItem%d", ChipBagsItemData.TbChipData.Slot)
  local equipChipData
  if self[str] then
    equipChipData = self[str].EquipChipData
  end
  self.viewModel:RequestEquipChip(ChipBagsItemData, equipChipData, bRightMouseBtnClick)
end
function ChipView:OnLeftSlotClick(SelectModeIdx)
  local selectModeIdx = SelectModeIdx or self.viewModel.CurSelectModeIdx
  selectModeIdx = selectModeIdx - 1
  if selectModeIdx < 1 then
    local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
    selectModeIdx = #tbChipSlot
  end
  self.RGToggleGroupSlot:SelectId(selectModeIdx)
end
function ChipView:OnRightSlotClick(SelectModeIdx)
  local selectModeIdx = SelectModeIdx or self.viewModel.CurSelectModeIdx
  selectModeIdx = selectModeIdx + 1
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if selectModeIdx > #tbChipSlot then
    selectModeIdx = 1
  end
  self.RGToggleGroupSlot:SelectId(selectModeIdx)
end
function ChipView:OnFilterClick(ChipViewState)
  local chipViewState = ChipViewState or EChipViewState.Normal
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    UpdateVisibility(self.ParentView.RGAutoLoadPanelFilterTips, true)
    if self.ParentView.RGAutoLoadPanelFilterTips.ChildWidget then
      self.ParentView.RGAutoLoadPanelFilterTips.ChildWidget:InitChipFilterTips(chipViewState)
    end
  end
end
function ChipView:HideFilterTips()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:HideFilterTips()
  end
end
function ChipView:OnCheckCanSelect(SelectId)
  return true
end
function ChipView:OnSlotSelect(SelectId)
  self.viewModel:SelectSlot(SelectId)
end
function ChipView:OnEmptyLinkClick()
  local idx = self.viewModel.CurSelectModeIdx
  UIMgr:Hide(ViewID.UI_DevelopMain, true)
  local tbSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if tbSlot and tbSlot[idx] then
    ComLink(1008, nil, self.viewModel:GetModIdBySlot(1), tbSlot[idx].DropFloor)
  end
end
function ChipView:OnLockLinkClick()
  local idx = self.viewModel.CurSelectModeIdx
  UIMgr:Hide(ViewID.UI_DevelopMain, true)
  ComLink(1008, nil, self.viewModel:GetModIdBySlot(idx))
end
function ChipView:OnHelpHover()
  UpdateVisibility(self.WBP_ChipSlotTips, true)
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if not tbChipSlot then
    return
  end
  if not tbChipSlot[self.viewModel.CurSelectModeIdx] then
    return
  end
  local slotData = tbChipSlot[self.viewModel.CurSelectModeIdx]
  self.WBP_ChipSlotTips.Text_Name:SetText(slotData.name)
  if slotData.desc then
    self.WBP_ChipSlotTips.Text_doc:SetText(slotData.desc)
  end
end
function ChipView:OnHelpUnHover()
  UpdateVisibility(self.WBP_ChipSlotTips, false)
end
function ChipView:GetChipEffActor()
  if UE.RGUtil.IsUObjectValid(self.ChipEffActor) then
    return self.ChipEffActor
  end
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "ChipEff", nil)
  for i, v in iterator(AllActors) do
    self.ChipEffActor = v
  end
  return self.ChipEffActor
end
function ChipView:PlayChpEffSeq(bIsReverse)
  local setting = UE.FMovieSceneSequencePlaybackSettings()
  setting.bPauseAtEnd = true
  if not UE.RGUtil.IsUObjectValid(self.SequencePlayer) then
    self.SequencePlayer, self.SequenceActor = UE.ULevelSequencePlayer.CreateLevelSequencePlayer(self, self.SQ_ChipEff, setting, nil)
    if self.SequencePlayer == nil or self.SequenceActor == nil then
      print("[ChipView::ListenForChipUpgradeInputAction] Player or SequenceActor is Empty!")
      return
    end
  end
  self:HideFilterTips()
  if bIsReverse then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayOperatorStrengthTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayOperatorStrengthTimer)
    end
    self.DelayOperatorStrengthTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        UpdateVisibility(self.Img_Mask, false)
      end
    }, self.DelayOperatorStrength, false)
    UpdateVisibility(self.Img_Mask, true, true)
    self.SequencePlayer:PlayReverse()
  else
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayOperatorStrengthTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayOperatorStrengthTimer)
    end
    self.DelayOperatorStrengthTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        UpdateVisibility(self.Img_Mask, false)
      end
    }, self.DelayOperatorStrength, false)
    UpdateVisibility(self.Img_Mask, true, true)
    self.SequencePlayer:Play()
  end
end
function ChipView:JumpChpEffSeq(bIsReverse)
  if not UE.RGUtil.IsUObjectValid(self.SequencePlayer) then
    return
  end
  if bIsReverse then
    UE.URGBlueprintLibrary.JumpToEnd(self.SequencePlayer)
  else
    UE.URGBlueprintLibrary.JumpToStart(self.SequencePlayer)
  end
end
function ChipView:UpdateLeftAndRightRedDot(LeftRedDotCount, RightRedDotCount)
  UpdateVisibility(self.Canvas_LeftRedDot, LeftRedDotCount > 0)
  UpdateVisibility(self.Canvas_RightRedDot, RightRedDotCount > 0)
  UpdateVisibility(self.Canvas_LeftRedDotLock, LeftRedDotCount > 0)
  UpdateVisibility(self.Canvas_RightRedDotLock, RightRedDotCount > 0)
end
return ChipView
