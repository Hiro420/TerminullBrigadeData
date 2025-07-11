local WBP_CurrencyGemTipsItem = UnLua.Class()
function WBP_CurrencyGemTipsItem:Construct()
end
function WBP_CurrencyGemTipsItem:Destruct()
end
function WBP_CurrencyGemTipsItem:InitGemTipsItem(Rare, Num)
  UpdateVisibility(self, true)
  self.Txt_Num:SetText(Num)
  local result, row = GetRowData(DT.DT_ItemRarity, Rare)
  if result then
    local name = UE.FTextFormat(self.NameFmt, row.DisplayName)
    self.Txt_GemRareName:SetText(name)
    self.Txt_GemRareName:SetColorAndOpacity(row.DisplayNameColor)
  end
end
function WBP_CurrencyGemTipsItem:Hide()
  UpdateVisibility(self, false)
end
return WBP_CurrencyGemTipsItem
