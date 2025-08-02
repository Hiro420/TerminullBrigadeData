local ChipData = require("Modules.Chip.ChipData")
local WBP_CurrencyGemItem = UnLua.Class()

function WBP_CurrencyGemItem:Construct()
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.PostItemChanged:Add(self, WBP_CurrencyGemItem.UpdateCurrencyChipItem)
  end
  self:UpdateCurrencyNum()
end

function WBP_CurrencyGemItem:Destruct()
  if not self:GetOwningPlayer() then
    return
  end
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.PostItemChanged:Remove(self, WBP_CurrencyGemItem.UpdateCurrencyChipItem)
  end
end

function WBP_CurrencyGemItem:UpdateCurrencyChipItem(ArticleId, OldStack, NewStack)
  local itemId = UE.URGArticleStatics.GetConfigId(ArticleId)
  local resultItem, rowItem = GetRowData(DT.DT_Item, tostring(itemId))
  if not resultItem then
    print("WBP_CurrencyGemItem:UpdateCurrencyNum itemId is InValid", itemId)
    return
  end
  if rowItem.ArticleType ~= UE.EArticleDataType.Gem then
    return
  end
  self:UpdateCurrencyNum()
end

function WBP_CurrencyGemItem:UpdateCurrencyNum()
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if not BagComp then
    return
  end
  local tbResGem = LuaTableMgr.GetLuaTableByName(TableNames.TBResGem)
  if not tbResGem then
    return
  end
  local num = 0
  for k, v in pairs(tbResGem) do
    num = BagComp:GetItemByConfigId(tonumber(k)).Stack + num
  end
  print("WBP_CurrencyGemItem_C11", num)
  UpdateVisibility(self, num > 0)
  self.Txt_Price:SetText(num)
end

function WBP_CurrencyGemItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.WBP_CurrencyGemTips:InitCurrencyGemTips()
end

function WBP_CurrencyGemItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.WBP_CurrencyGemTips:Hide()
end

return WBP_CurrencyGemItem
