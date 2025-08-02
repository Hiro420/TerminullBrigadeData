local WBP_CurrencyItemTip_C = UnLua.Class()

function WBP_CurrencyItemTip_C:InitInfo(ItemId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemId)
  if not Result then
    Result, RowInfo = GetRowData(DT.DT_Item, tostring(ItemId))
  end
  if not Result then
    return
  end
  self.TextBlock_Title:SetText(RowInfo.Name)
  self.TextBlock_Des:SetText(RowInfo.Desc)
end

function WBP_CurrencyItemTip_C:InitInfoByNameAndDesc(Name, Desc)
  self.TextBlock_Title:SetText(Name)
  self.TextBlock_Des:SetText(Desc)
end

return WBP_CurrencyItemTip_C
