local ChipItem = UnLua.Class()
function ChipItem:Construct()
  self.ButtonSelect.OnPressed:Add(self, self.OnBtnSelectPressed)
  self.ButtonSelect.OnReleased:Add(self, self.OnBtnSelectReleased)
  self.Btn_Cancel.OnPressed:Add(self, self.OnBtnCancelPressed)
  self.Btn_Cancel.OnReleased:Add(self, self.OnBtnCancelReleased)
end
function ChipItem:Destruct()
  self.ButtonSelect.OnPressed:Remove(self, self.OnBtnSelectPressed)
  self.ButtonSelect.OnReleased:Remove(self, self.OnBtnSelectReleased)
  self.Btn_Cancel.OnPressed:Remove(self, self.OnBtnCancelPressed)
  self.Btn_Cancel.OnReleased:Remove(self, self.OnBtnCancelReleased)
end
function ChipItem:OnListItemObjectSet(ListItemObj)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  UpdateVisibility(self, true, true)
  self.DataObj = ListItemObj
  local DataObjTemp = ListItemObj
  if not UE.RGUtil.IsUObjectValid(DataObjTemp) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(DataObjTemp.ParentView) then
    return
  end
  local viewModel = UIModelMgr:Get("ChipViewModel")
  local slot = -1
  if DataObjTemp.ChipItemData.TbChipData then
    slot = DataObjTemp.ChipItemData.TbChipData.Slot
  end
  local bSlotUnlock = viewModel:CheckSlotIsUnLock(slot)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  if DataObjTemp.ChipItemData.Chip and DataObjTemp.ChipItemData.Chip.state then
    self.RGStateControllerDiscard:ChangeStatus(tostring(DataObjTemp.ChipItemData.Chip.state))
  else
    self.RGStateControllerDiscard:ChangeStatus(EChipState.Normal)
  end
  if bSlotUnlock or self.DataObj.ChipFilterTipsFrom == EChipViewState.Strength then
    if self.RGStateControllerSlotLock then
      self.RGStateControllerSlotLock:ChangeStatus(EChipSlotLock.Normal)
    end
  elseif self.RGStateControllerSlotLock then
    self.RGStateControllerSlotLock:ChangeStatus(EChipSlotLock.SlotLock)
  end
  if DataObjTemp.ChipItemData.Chip and DataObjTemp.ChipItemData.Chip.equipHeroID > 0 then
    self.RGStateControllerEquip:ChangeStatus(EEquiped.Equiped)
    local resultHero, heroData = GetRowData(DT.DT_Hero, tostring(DataObjTemp.ChipItemData.Chip.equipHeroID))
    if resultHero then
      SetImageBrushBySoftObject(self.URGImageEquiped, heroData.RoleIcon)
    end
  else
    self.RGStateControllerEquip:ChangeStatus(EEquiped.UnEquiped)
  end
  if self:CheckbSelect() then
    self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
  else
    self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
  end
  if DataObjTemp.ChipItemData.Chip and DataObjTemp.ChipItemData.Chip.bindHeroID > 0 and DataObjTemp.ChipItemData.Chip.bindHeroID ~= viewModel:GetCurHeroId() then
    self.StateCtrl_RoleLimit:ChangeStatus(ERoleLimit.RoleLimit)
  elseif DataObjTemp.ChipItemData.Chip and DataObjTemp.ChipItemData.Chip.bindHeroID == viewModel:GetCurHeroId() then
    self.StateCtrl_RoleLimit:ChangeStatus(ERoleLimit.RoleFit)
  else
    self.StateCtrl_RoleLimit:ChangeStatus(ERoleLimit.Normal)
  end
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local resID = -1
  if DataObjTemp.ChipItemData.Chip and DataObjTemp.ChipItemData.Chip.resourceID then
    UpdateVisibility(self.Txt_UpgradeMatAmout, false)
    UpdateVisibility(self.Hor_Lv, true)
    resID = DataObjTemp.ChipItemData.Chip.resourceID
  elseif DataObjTemp.ChipItemData.ChipUpgradeMat then
    resID = DataObjTemp.ChipItemData.ChipUpgradeMat.ResID
    UpdateVisibility(self.Txt_UpgradeMatAmout, true)
    UpdateVisibility(self.Hor_Lv, false)
  end
  if tbGeneral and tbGeneral[tonumber(resID)] then
    local tbGeneralData = tbGeneral[tonumber(resID)]
    SetImageBrushByPath(self.URGImageIcon, tbGeneralData.Icon)
    local rare = viewModel:GetChipRare(DataObjTemp.ChipItemData)
    local result, itemRarity = GetRowData(DT.DT_ItemRarity, tostring(rare))
    if result then
      self.URGImageRare:SetColorAndOpacity(itemRarity.DisplayNameColor.SpecifiedColor)
    end
  end
  if DataObjTemp.ChipItemData.Chip and DataObjTemp.ChipItemData.Chip.level then
    self.RGTextStrength:SetText(DataObjTemp.ChipItemData.Chip.level)
  elseif DataObjTemp.ChipItemData.ChipUpgradeMat then
    if self:CheckbSelect() then
      local str = UE.FTextFormat(self.MatAmountTxtFmt, DataObjTemp.ChipItemData.ChipUpgradeMat.SelectAmount, DataObjTemp.ChipItemData.ChipUpgradeMat.amount)
      self.Txt_UpgradeMatAmout:SetText(str)
    else
      self.Txt_UpgradeMatAmout:SetText(DataObjTemp.ChipItemData.ChipUpgradeMat.amount)
    end
    if DataObjTemp.ParentView:CheckCanEatByChipBagData(DataObjTemp.ChipItemData) then
      self.StateCtrl_UpgradeMatLimit:ChangeStatus(EUpgradeMatLimit.Normal)
    else
      self.StateCtrl_UpgradeMatLimit:ChangeStatus(EUpgradeMatLimit.MatLimit)
    end
  end
  if self.bNeedHoverWhenListObjSet and DataObjTemp.bFirst then
    self:Hover()
  end
  self.bNeedHoverWhenListObjSet = false
  if DataObjTemp.ChipItemData.Chip and DataObjTemp.ChipItemData.Chip.id then
    self.WBP_RedDotView:ChangeRedDotIdByTag(DataObjTemp.ChipItemData.Chip.id)
  elseif DataObjTemp.ChipItemData.ChipUpgradeMat then
    UpdateVisibility(self.WBP_RedDotView, false)
  end
end
function ChipItem:BP_OnEntryReleased()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerLoopSelectHander) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimerLoopSelectHander)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerLoopCancelHander) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimerLoopCancelHander)
  end
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  self.bNeedHoverWhenListObjSet = false
  self.DataObj = nil
end
function ChipItem:OnMouseEnter()
  self.bNeedHoverWhenListObjSet = true
  self:Hover()
end
function ChipItem:Hover()
  if not UE.RGUtil.IsUObjectValid(self.DataObj) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  self.bNeedHoverWhenListObjSet = false
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
  self.WBP_RedDotView:SetNum(0)
  if not self.DataObj.ChipItemData.bRequestedDetail then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HoverTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HoverTimer)
      self.HoverTimer = nil
    end
    self.HoverTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        if self and UE.RGUtil.IsUObjectValid(self.DataObj) then
          if self.DataObj.ChipFilterTipsFrom == EChipViewState.Normal then
            self.DataObj.ParentView:ShowChipAttrListTip(true, self.DataObj.ChipItemData)
          elseif self.DataObj.ChipFilterTipsFrom == EChipViewState.Strength then
            local bSelect = self:CheckbSelect()
            self.DataObj.ParentView:ShowChipAttrListTip(true, self.DataObj.ChipItemData, bSelect)
          end
        end
      end
    }, 0.08, false)
    return
  elseif self.DataObj.ChipFilterTipsFrom == EChipViewState.Normal then
    self.DataObj.ParentView:ShowChipAttrListTip(true, self.DataObj.ChipItemData)
  elseif self.DataObj.ChipFilterTipsFrom == EChipViewState.Strength then
    local bSelect = self:CheckbSelect()
    self.DataObj.ParentView:ShowChipAttrListTip(true, self.DataObj.ChipItemData, bSelect)
  end
end
function ChipItem:OnMouseLeave()
  self.bNeedHoverWhenListObjSet = false
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HoverTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HoverTimer)
    self.HoverTimer = nil
  end
  if not UE.RGUtil.IsUObjectValid(self.DataObj) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  self.DataObj.ParentView:ShowChipAttrListTip(false)
end
function ChipItem:OnMouseButtonDown(MyGeometry, MouseEvent)
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.RightMouseButton then
    self:OnSelectClick(true)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
function ChipItem:OnBtnSelectPressed()
  self:OnSelectClick(false)
  local viewModel = UIModelMgr:Get("ChipViewModel")
  if viewModel:CheckIsChipUpgradeMat(self.DataObj.ChipItemData) and not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerLoopSelectHander) then
    self.TimerLoopSelectHander = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.TimerLoopSelect
    }, self.PressLoopRate, true)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HoverTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HoverTimer)
    self.HoverTimer = nil
  end
end
function ChipItem:OnBtnSelectReleased()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerLoopSelectHander) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerLoopSelectHander)
  end
end
function ChipItem:TimerLoopSelect()
  self:OnSelectClick(false)
end
function ChipItem:OnBtnCancelPressed()
  self:OnCancelClick()
  local viewModel = UIModelMgr:Get("ChipViewModel")
  if viewModel:CheckIsChipUpgradeMat(self.DataObj.ChipItemData) and not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerLoopCancelHander) then
    self.TimerLoopCancelHander = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.TimerLoopCancel
    }, self.PressLoopRate, true)
  end
end
function ChipItem:OnBtnCancelReleased()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerLoopCancelHander) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerLoopCancelHander)
  end
end
function ChipItem:TimerLoopCancel()
  self:OnCancelClick()
end
function ChipItem:OnSelectClick(bRightMouseBtnClick)
  if not UE.RGUtil.IsUObjectValid(self.DataObj) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  if self.DataObj.ChipFilterTipsFrom == EChipViewState.Normal then
    local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
    local viewModel = UIModelMgr:Get("ChipViewModel")
    local slot = self.DataObj.ChipItemData.TbChipData.Slot
    local bSlotUnlock = viewModel:CheckSlotIsUnLock(slot)
    if tbChipSlot and tbChipSlot[slot] and not bSlotUnlock then
      ShowWaveWindow(1188, {
        tbChipSlot[slot].name
      })
      return
    end
    self.DataObj.ParentView:EquipChipItem(self.DataObj.ChipItemData, bRightMouseBtnClick)
  elseif self.DataObj.ChipFilterTipsFrom == EChipViewState.Strength and not bRightMouseBtnClick and self.DataObj.ParentView:CheckCanSelect(self.DataObj.ChipItemData) then
    self.DataObj.ParentView:SelectEatChip(self.DataObj.ChipItemData, true, function(ChipItemDataTemp)
      if not ChipItemDataTemp then
        return
      end
      local bSelect = self.DataObj.ParentView:CheckInEatTb(ChipItemDataTemp)
      if bSelect then
        self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
      else
        self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
      end
      if ChipItemDataTemp.Chip and ChipItemDataTemp.Chip.resourceID then
        UpdateVisibility(self.Txt_UpgradeMatAmout, false)
        UpdateVisibility(self.Hor_Lv, true)
      elseif ChipItemDataTemp.ChipUpgradeMat then
        UpdateVisibility(self.Txt_UpgradeMatAmout, true)
        UpdateVisibility(self.Hor_Lv, false)
        if self:CheckbSelect() then
          local str = UE.FTextFormat(self.MatAmountTxtFmt, ChipItemDataTemp.ChipUpgradeMat.SelectAmount, ChipItemDataTemp.ChipUpgradeMat.amount)
          self.Txt_UpgradeMatAmout:SetText(str)
        else
          self.Txt_UpgradeMatAmout:SetText(ChipItemDataTemp.ChipUpgradeMat.amount)
        end
      end
    end)
  end
end
function ChipItem:OnCancelClick()
  if not UE.RGUtil.IsUObjectValid(self.DataObj) then
    return
  end
  if not UE.RGUtil.IsUObjectValid(self.DataObj.ParentView) then
    return
  end
  if self.DataObj.ChipFilterTipsFrom == EChipViewState.Strength and self:CheckbSelect() then
    self.DataObj.ParentView:SelectEatChip(self.DataObj.ChipItemData, false, function(ChipItemDataTemp)
      if not ChipItemDataTemp then
        return
      end
      local bSelect = self.DataObj.ParentView:CheckInEatTb(ChipItemDataTemp)
      if bSelect then
        self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
      else
        self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
      end
      if ChipItemDataTemp.Chip and ChipItemDataTemp.Chip.resourceID then
        UpdateVisibility(self.Txt_UpgradeMatAmout, false)
        UpdateVisibility(self.Hor_Lv, true)
      elseif ChipItemDataTemp.ChipUpgradeMat then
        UpdateVisibility(self.Txt_UpgradeMatAmout, true)
        UpdateVisibility(self.Hor_Lv, false)
        if self:CheckbSelect() then
          local str = UE.FTextFormat(self.MatAmountTxtFmt, ChipItemDataTemp.ChipUpgradeMat.SelectAmount, ChipItemDataTemp.ChipUpgradeMat.amount)
          self.Txt_UpgradeMatAmout:SetText(str)
        else
          self.Txt_UpgradeMatAmout:SetText(ChipItemDataTemp.ChipUpgradeMat.amount)
        end
      end
    end)
  end
end
function ChipItem:CheckbSelect()
  if not self.DataObj then
    return false
  end
  if not self.DataObj.ParentView then
    return false
  end
  if self.DataObj.ChipFilterTipsFrom == EChipViewState.Strength then
    return self.DataObj.ParentView:CheckInEatTb(self.DataObj.ChipItemData)
  elseif self.DataObj.ChipFilterTipsFrom == EChipViewState.Normal then
    return self.DataObj.bSelect
  end
end
return ChipItem
