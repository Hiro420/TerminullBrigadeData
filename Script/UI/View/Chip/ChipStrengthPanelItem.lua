local ChipStrengthPanelItem = UnLua.Class()
function ChipStrengthPanelItem:Construct()
end
function ChipStrengthPanelItem:Destruct()
end
function ChipStrengthPanelItem:InitChipStrengthPanelItem(ChipBagItemData, ParentView)
  self.ParentView = ParentView
  self.ChipItemData = ChipBagItemData
  UpdateVisibility(self, true)
  self.RGStateControllerDiscard:ChangeStatus(tostring(ChipBagItemData.Chip.state))
  if ChipBagItemData.Chip.equipHeroID > 0 then
    self.RGStateControllerEquip:ChangeStatus(EEquiped.Equiped)
    local resultHero, heroData = GetRowData(DT.DT_Hero, tostring(ChipBagItemData.Chip.equipHeroID))
    if resultHero then
      SetImageBrushBySoftObject(self.URGImageEquiped, heroData.RoleIcon)
    end
  else
    self.RGStateControllerEquip:ChangeStatus(EEquiped.UnEquiped)
  end
  self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if tbGeneral and tbGeneral[tonumber(ChipBagItemData.Chip.resourceID)] then
    local tbGeneralData = tbGeneral[tonumber(ChipBagItemData.Chip.resourceID)]
    SetImageBrushByPath(self.URGImageIcon, tbGeneralData.Icon)
    local result, row = GetRowData(DT.DT_ItemRarity, tostring(tbGeneralData.Rare))
    if result then
      self.URGImageRare:SetColorAndOpacity(row.DisplayNameColor.SpecifiedColor)
    end
  end
  local strengthLv = string.format("%d", ChipBagItemData.Chip.level)
  self.RGTextStrength:SetText(strengthLv)
end
function ChipStrengthPanelItem:OnMouseEnter()
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  self.ParentView:ShowChipAttrListTip(true, self.ChipItemData)
end
function ChipStrengthPanelItem:OnMouseLeave()
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  self.ParentView:ShowChipAttrListTip(false)
end
return ChipStrengthPanelItem
