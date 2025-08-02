local WBP_CurrencyChipSlotItem = UnLua.Class()

function WBP_CurrencyChipSlotItem:Construct()
end

function WBP_CurrencyChipSlotItem:Destruct()
end

function WBP_CurrencyChipSlotItem:InitCurrencyChipSlotItem(Rare, Num)
  UpdateVisibility(self, true)
  self.Txt_ChipNum:SetText(Num)
  local result, row = GetRowData(DT.DT_ItemRarity, Rare)
  if result then
    local name = UE.FTextFormat(self.NameFmt, row.DisplayName)
    self.Txt_ChipRareName:SetText(name)
    self.Txt_ChipRareName:SetColorAndOpacity(row.DisplayNameColor)
  end
end

function WBP_CurrencyChipSlotItem:Hide()
  UpdateVisibility(self, false)
end

return WBP_CurrencyChipSlotItem
