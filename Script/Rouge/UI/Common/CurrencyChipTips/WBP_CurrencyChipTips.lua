local ChipData = require("Modules.Chip.ChipData")
local WBP_CurrencyChipTips = UnLua.Class()

function WBP_CurrencyChipTips:Construct()
end

function WBP_CurrencyChipTips:Destruct()
end

function WBP_CurrencyChipTips:InitCurrencyChipTips()
  self:StopAnimation(self.Ani_out)
  self:PlayAnimation(self.Ani_in)
  UpdateVisibility(self, true)
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if not BagComp then
    return
  end
  local tbPuzzleWorld = LuaTableMgr.GetLuaTableByName(TableNames.TBPuzzleWorld)
  if not tbPuzzleWorld then
    return
  end
  local tbResPuzzle = LuaTableMgr.GetLuaTableByName(TableNames.TBResPuzzle)
  if not tbResPuzzle then
    return
  end
  local worldToChipRareNum = {}
  for k, v in pairs(tbResPuzzle) do
    local vChipId = v.ID
    print("WBP_CurrencyChipItem_C", vChipId)
    local worldID = v.worldID
    local idxRare = -1
    local resultGeneral, rowGeneral = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, tonumber(vChipId))
    if resultGeneral then
      idxRare = rowGeneral.Rare
    end
    local num = BagComp:GetItemByConfigId(tonumber(vChipId)).Stack
    if num > 0 then
      if not worldToChipRareNum[worldID] then
        worldToChipRareNum[worldID] = {}
      end
      if not worldToChipRareNum[worldID][idxRare] then
        worldToChipRareNum[worldID][idxRare] = 0
      end
      worldToChipRareNum[worldID][idxRare] = worldToChipRareNum[worldID][idxRare] + num
    end
  end
  local puzzleWorldList = {}
  for k, v in pairs(tbPuzzleWorld) do
    table.insert(puzzleWorldList, v.WorldId)
  end
  table.sort(puzzleWorldList, function(a, b)
    return a < b
  end)
  local idx = 1
  local lastItem
  for i, worldIdList in ipairs(puzzleWorldList) do
    local v = tbPuzzleWorld[worldIdList]
    if worldToChipRareNum[v.WorldId] then
      local item = GetOrCreateItem(self.VerticalBox_ChipSlotList, idx, self.WBP_CurrencyChipSlotItemList:GetClass())
      item:InitCurrencyChipSlotItemList(v, worldToChipRareNum[v.WorldId])
      lastItem = item
      idx = idx + 1
    end
  end
  HideOtherItem(self.VerticalBox_ChipSlotList, idx)
  if lastItem then
    UpdateVisibility(lastItem.Dec_Line, false)
  end
end

function WBP_CurrencyChipTips:OnAnimationFinished(Ani)
  if self.Ani_out == Ani then
    UpdateVisibility(self, false)
  end
end

function WBP_CurrencyChipTips:Hide()
  self:StopAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_out)
end

return WBP_CurrencyChipTips
