local ChipData = require("Modules.Chip.ChipData")
local WBP_CurrencyChipItem_C = UnLua.Class()

function WBP_CurrencyChipItem_C:Construct()
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.PostItemChanged:Add(self, WBP_CurrencyChipItem_C.UpdateCurrencyChipItem)
  end
  self:UpdateCurrencyNum()
end

function WBP_CurrencyChipItem_C:Destruct()
  if not self:GetOwningPlayer() then
    return
  end
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.PostItemChanged:Remove(self, WBP_CurrencyChipItem_C.UpdateCurrencyChipItem)
  end
end

function WBP_CurrencyChipItem_C:UpdateCurrencyChipItem(ArticleId, OldStack, NewStack)
  local itemId = UE.URGArticleStatics.GetConfigId(ArticleId)
  local resultItem, rowItem = GetRowData(DT.DT_Item, tostring(itemId))
  if not resultItem then
    print("WBP_CurrencyChipItem_C:UpdateCurrencyNum itemId is InValid", itemId)
    return
  end
  if rowItem.ArticleType ~= UE.EArticleDataType.Mod then
    return
  end
  self:UpdateCurrencyNum()
end

function WBP_CurrencyChipItem_C:UpdateCurrencyNum()
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if not BagComp then
    return
  end
  local tbResPuzzle = LuaTableMgr.GetLuaTableByName(TableNames.TBResPuzzle)
  if not tbResPuzzle then
    return
  end
  local num = 0
  for k, v in pairs(tbResPuzzle) do
    num = BagComp:GetItemByConfigId(tonumber(k)).Stack + num
  end
  print("WBP_CurrencyChipItem_C11", num)
  UpdateVisibility(self, num > 0)
  self.Txt_Price:SetText(num)
end

function WBP_CurrencyChipItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self.WBP_CurrencyChipTips:InitCurrencyChipTips()
end

function WBP_CurrencyChipItem_C:OnMouseLeave(MyGeometry, MouseEvent)
  self.WBP_CurrencyChipTips:Hide()
end

return WBP_CurrencyChipItem_C
