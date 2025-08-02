local RoleMainChipSlotItem = UnLua.Class()

function RoleMainChipSlotItem:InitRoleMainChipSlotItem(chipInfo)
  UpdateVisibility(self, true)
  if chipInfo and "0" ~= chipInfo then
    self.RGStateControllerEquiped:ChangeStatus(EEquiped.Equiped)
    local viewModel = UIModelMgr:Get("ChipViewModel")
    local chipBagDataByUUIDRef = viewModel:GetChipBagDataByUUIDRef(chipInfo.Chip.id)
    local rare = viewModel:GetChipRare(chipBagDataByUUIDRef)
    local result, row = GetRowData(DT.DT_ItemRarity, tostring(rare))
    if result then
      self.URGImageChipRare:SetColorAndOpacity(row.DisplayNameColor.SpecifiedColor)
    end
  else
    self.RGStateControllerEquiped:ChangeStatus(EEquiped.UnEquiped)
  end
end

function RoleMainChipSlotItem:Hide()
  UpdateVisibility(self, false)
end

return RoleMainChipSlotItem
