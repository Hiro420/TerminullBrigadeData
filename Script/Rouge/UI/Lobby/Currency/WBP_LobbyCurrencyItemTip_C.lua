local WBP_LobbyCurrencyItemTip_C = UnLua.Class()

function WBP_LobbyCurrencyItemTip_C:InitInfo(ItemId)
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(ItemId)
  if not CurrencyInfo then
    print("not found CurrencyId", self.CurrencyId)
    return
  end
  self.TextBlock_Title:SetText(CurrencyInfo.Name)
  self.TextBlock_Des:SetText(CurrencyInfo.Desc)
end

return WBP_LobbyCurrencyItemTip_C
