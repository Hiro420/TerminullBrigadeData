local EChipSlotType = {
  Lock = "Lock",
  Empty = "Empty",
  Equiped = "Equiped"
}
local ChipSlotItem = UnLua.Class()
function ChipSlotItem:Construct()
end
function ChipSlotItem:Destruct()
end
function ChipSlotItem:InitChipSlotItem(EquipChipData, bUnLock, ParentView, Slot, EquipSlot)
  UpdateVisibility(self, true, true)
  self.ParentView = ParentView
  self.EquipChipData = EquipChipData
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if EquipChipData and tbChipSlot and tbChipSlot[EquipChipData.TbChipData.Slot] and tbChipSlot[EquipChipData.TbChipData.Slot].icon then
    SetImageBrushByPath(self.Img_SlotIcon, tbChipSlot[EquipChipData.TbChipData.Slot].icon)
  end
  if EquipChipData then
    local lvStr = string.format("lv.%d", EquipChipData.Chip.level)
    self.Txt_Grade:SetText(lvStr)
    UpdateVisibility(self.Txt_Grade, true)
  else
    UpdateVisibility(self.Txt_Grade, false)
  end
  if not bUnLock then
    self.RGStateControllerSlot:ChangeStatus(EChipSlotType.Lock)
    self.RGStateControllerSlotIdx:ChangeStatus(tostring(Slot))
  elseif not EquipChipData then
    self.RGStateControllerSlot:ChangeStatus(EChipSlotType.Empty)
    self.RGStateControllerSlotIdx:ChangeStatus(tostring(Slot))
  else
    self.RGStateControllerSlot:ChangeStatus(EChipSlotType.Equiped)
    local EndTime = self.Ani_Unload:GetEndTime()
    self.WBP_ChipIconItem:InitChipIconItem(EquipChipData)
    local resId = tonumber(EquipChipData.Chip.resourceID)
    local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    if tbGeneral and tbGeneral[resId] then
      self.StateCtrl_Rare:ChangeStatus(tostring(tbGeneral[resId].Rare))
      local result, row = GetRowData(DT.DT_ItemRarity, tostring(tbGeneral[resId].Rare))
      if result then
        self.URGImageQuality_1:SetColorAndOpacity(row.DisplayNameColor.SpecifiedColor)
        self.URGImageQuality_2:SetColorAndOpacity(row.DisplayNameColor.SpecifiedColor)
      end
    end
    if EquipSlot and EquipSlot == Slot then
      self:PlayAnimation(self.Ani_Equipped)
      self.WBP_ChipIconItem:PlayAnimation(self.WBP_ChipIconItem.Ani_Equipped)
    end
  end
end
function ChipSlotItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  if not self.EquipChipData then
    return
  end
  self.ParentView:ShowChipAttrListTip(true, self.EquipChipData, self.EquipChipData.TbChipData.Slot)
end
function ChipSlotItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  self.ParentView:ShowChipAttrListTip(false)
end
function ChipSlotItem:OnMouseButtonDown(MyGeometry, MouseEvent)
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.RightMouseButton then
    self.ParentView:EquipChipItem(self.EquipChipData, true)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
function ChipSlotItem:Hide()
  self.EquipChipData = nil
  self.ParentView = nil
  UpdateVisibility(self, false)
end
return ChipSlotItem
