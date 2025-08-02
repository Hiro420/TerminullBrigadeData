local WBP_ModeSelectionUnlockChipSlotItem = UnLua.Class()

function WBP_ModeSelectionUnlockChipSlotItem:Show(SingleChipSlotId)
  local BResult, ChipSlotRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBChipSlots, SingleChipSlotId)
  UpdateVisibility(self, BResult)
  if BResult then
    SetImageBrushByPath(self.Img_ChipSlotIcon, ChipSlotRowInfo.Icon)
    self.Txt_ChipSlotName:SetText(ChipSlotRowInfo.name)
  end
end

function WBP_ModeSelectionUnlockChipSlotItem:Hide(...)
  UpdateVisibility(self, false)
end

return WBP_ModeSelectionUnlockChipSlotItem
