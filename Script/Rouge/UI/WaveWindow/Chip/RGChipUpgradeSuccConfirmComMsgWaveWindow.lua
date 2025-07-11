local RGChipUpgradeSuccConfirmComMsgWaveWindow = UnLua.Class()
function RGChipUpgradeSuccConfirmComMsgWaveWindow:InitUpgradeSuccConfirm(OldMainAttrGrowth, OldSubAttr, ChipId)
  local chipViewModel = UIModelMgr:Get("ChipViewModel")
  local chipBagItemData = chipViewModel:GetChipBagDataByUUIDRef(ChipId)
  self.StateCtrl_Slot:ChangeStatus(tostring(chipBagItemData.TbChipData.Slot))
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if tbGeneral and tbGeneral[tonumber(chipBagItemData.Chip.resourceID)] then
    local tbGeneralData = tbGeneral[tonumber(chipBagItemData.Chip.resourceID)]
    SetImageBrushByPath(self.URGImage_Icon, tbGeneralData.Icon)
  end
  local idx = 1
  for i, v in ipairs(chipBagItemData.Chip.mainAttrGrowth) do
    local vOld
    for iOldMain, vOldMain in ipairs(OldMainAttrGrowth) do
      if vOldMain.attrID == v.attrID then
        vOld = vOldMain
        break
      end
    end
    local mainInitValue = chipViewModel:GetMainAttrInitValue(chipBagItemData)
    local item = GetOrCreateItem(self.ScrollBoxAttrChange, idx, self.WBP_ChipUpgradeAttrItem:GetClass())
    local oldValue = 0
    if vOld then
      oldValue = vOld.value
    end
    item:InitUpgradeSuccConfirm({
      attrID = v.attrID,
      value = mainInitValue + v.value
    }, {
      attrID = v.attrID,
      value = oldValue + mainInitValue
    }, true)
    idx = idx + 1
  end
  local subAttrList = {}
  for i, v in ipairs(chipBagItemData.Chip.subAttr) do
    table.insert(subAttrList, v)
  end
  table.sort(subAttrList, function(A, B)
    return A.attrID > B.attrID
  end)
  for i, v in ipairs(subAttrList) do
    local vOld
    for iOldSub, vOldSub in ipairs(OldSubAttr) do
      if vOldSub.attrID == v.attrID then
        vOld = vOldSub
        break
      end
    end
    if not vOld or vOld.value ~= v.value then
      local item = GetOrCreateItem(self.ScrollBoxAttrChange, idx, self.WBP_ChipUpgradeAttrItem:GetClass())
      item:InitUpgradeSuccConfirm(v, vOld)
      idx = idx + 1
    end
  end
  HideOtherItem(self.ScrollBoxAttrChange, idx)
end
return RGChipUpgradeSuccConfirmComMsgWaveWindow
