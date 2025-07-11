local WBP_CurrencyChipSlotItemList = UnLua.Class()
function WBP_CurrencyChipSlotItemList:Construct()
end
function WBP_CurrencyChipSlotItemList:Destruct()
end
function WBP_CurrencyChipSlotItemList:InitCurrencyChipSlotItemList(PuzzleWorld, RarityToChipCurrencyData)
  local tbPuzzleWorld = LuaTableMgr.GetLuaTableByName(TableNames.TBPuzzleWorld)
  if not tbPuzzleWorld then
    return
  end
  UpdateVisibility(self.Dec_Line, true)
  SetImageBrushByPath(self.Img_Icon, PuzzleWorld.Icon)
  local index = 1
  for i = UE.ERGItemRarity.EIR_Normal, UE.ERGItemRarity.EIR_Immortal do
    local rare = i
    if RarityToChipCurrencyData[rare] then
      local item = GetOrCreateItem(self.VerticalBox_ChipList, index, self.WBP_CurrencyChipSlotItem:GetClass())
      item:InitCurrencyChipSlotItem(rare, RarityToChipCurrencyData[rare])
      index = index + 1
    end
  end
  HideOtherItem(self.VerticalBox_ChipList, index)
end
return WBP_CurrencyChipSlotItemList
