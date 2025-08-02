local ChipAttrTips = UnLua.Class()

function ChipAttrTips:Construct()
end

function ChipAttrTips:Destruct()
end

function ChipAttrTips:InitChipAttrTips(ChipOrderedMap)
  local idx = 1
  for i, v in ipairs(ChipOrderedMap) do
    local item = GetOrCreateItem(self.ScrollBoxAttrRoot, idx, self.WBP_ChipAttrItem:GetClass())
    local result, row = GetRowData(DT.DT_AttributeModifyOp, tostring(i))
    local desc = ""
    if result then
      desc = row.Desc
    end
    item:InitChipAttrItem(desc, v.Value, v.ChangeState, i, v.ChangeAniState)
    idx = idx + 1
  end
  HideOtherItem(self.ScrollBoxAttrRoot, idx)
end

function ChipAttrTips:Hide()
end

return ChipAttrTips
