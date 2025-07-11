local ChipData = require("Modules.Chip.ChipData")
local WBP_CurrencyGemTips = UnLua.Class()
function WBP_CurrencyGemTips:Construct()
end
function WBP_CurrencyGemTips:Destruct()
end
function WBP_CurrencyGemTips:InitCurrencyGemTips()
  self:StopAnimation(self.Ani_out)
  self:PlayAnimation(self.Ani_in)
  UpdateVisibility(self, true)
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if not BagComp then
    return
  end
  local tbResGem = LuaTableMgr.GetLuaTableByName(TableNames.TBResGem)
  if not tbResGem then
    return
  end
  local RareToGemNum = {}
  for k, v in pairs(tbResGem) do
    local vGemId = v.ID
    print("WBP_CurrencyGemTips:InitCurrencyGemTips", vGemId)
    local idxRare = -1
    local resultGeneral, rowGeneral = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, tonumber(vGemId))
    if resultGeneral then
      idxRare = rowGeneral.Rare
    end
    local num = BagComp:GetItemByConfigId(tonumber(vGemId)).Stack
    if num > 0 then
      if not RareToGemNum[idxRare] then
        RareToGemNum[idxRare] = num
      else
        RareToGemNum[idxRare] = num + RareToGemNum[idxRare]
      end
    end
  end
  local Idx = 1
  for i = UE.ERGItemRarity.EIR_Normal, UE.ERGItemRarity.EIR_Max - 1 do
    if RareToGemNum[i] then
      local Item = GetOrCreateItem(self.VerticalBox_GemTipsItem, Idx, self.WBP_CurrencyGemTipsItem:GetClass())
      Item:InitGemTipsItem(i, RareToGemNum[i])
      Idx = Idx + 1
    end
  end
  HideOtherItem(self.VerticalBox_GemTipsItem, Idx, true)
end
function WBP_CurrencyGemTips:OnAnimationFinished(Ani)
  if self.Ani_out == Ani then
    UpdateVisibility(self, false)
  end
end
function WBP_CurrencyGemTips:Hide()
  self:StopAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_out)
end
return WBP_CurrencyGemTips
