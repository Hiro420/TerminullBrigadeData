local ChipIconItem = UnLua.Class()

function ChipIconItem:Construct()
end

function ChipIconItem:Destruct()
end

function ChipIconItem:InitChipIconItem(EquipChipData)
  local resId = tonumber(EquipChipData.Chip.resourceID)
  local tbResChip = LuaTableMgr.GetLuaTableByName(TableNames.TBResChip)
  if tbResChip and tbResChip[resId] then
    SetImageBrushByPath(self.URGImageChipIcon, tbResChip[resId].SlotIcon)
    local result, row = GetRowData(DT.DT_AttributeModifyOp, EquipChipData.TbChipData.AttrID)
    if result then
      SetImageBrushBySoftObject(self.Img_CoreAttrIcon, row.Icon)
      SetImageBrushBySoftObject(self.Img_CoreAttrIcon_Shadow, row.ShadowIcon)
    end
    local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Img_CoreAttrIcon)
    slotCanvas:SetPosition(UE.FVector2D(EquipChipData.TbChipData.MainAttrIconPos.x, EquipChipData.TbChipData.MainAttrIconPos.y))
    self.Img_CoreAttrIcon:SetColorAndOpacity(HexToFLinearColor(EquipChipData.TbChipData.MainAttrIconColor))
    local slotShadowCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Img_CoreAttrIcon_Shadow)
    slotShadowCanvas:SetPosition(UE.FVector2D(EquipChipData.TbChipData.MainAttrIconPos.x, EquipChipData.TbChipData.MainAttrIconPos.y) + self.ShadowOffset)
    self.Img_CoreAttrIcon_Shadow:SetColorAndOpacity(HexToFLinearColor(EquipChipData.TbChipData.MainAttrIconShadowColor))
    self.StateCtrl_Eff:ChangeStatus(EquipChipData.TbChipData.EffStateName)
  end
end

function ChipIconItem:Hide()
  self.EquipChipData = nil
  self.ParentView = nil
  UpdateVisibility(self, false)
end

return ChipIconItem
