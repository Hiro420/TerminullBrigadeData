local BP_PickUpChip_C = UnLua.Class()

function BP_PickUpChip_C:OnChipPickup(Picker, ChipIDs)
  EventSystem.Invoke(EventDef.Chip.PickUpChip, Picker, ChipIDs)
end

return BP_PickUpChip_C
