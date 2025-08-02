require("Utils.LuaCommon")
local OrderedMap = require("Framework.DataStruct.OrderedMap")
local EChipState = {
  Normal = 0,
  Lock = 1,
  Discard = 2
}
_G.EChipState = _G.EChipState or EChipState
local EChipAttrListTipSComparetate = {
  BeCompared = "BeCompared",
  Compare = "Compare",
  NoOperator = "NoOperator"
}
_G.EChipAttrListTipSComparetate = _G.EChipAttrListTipSComparetate or EChipAttrListTipSComparetate
local EChipFilterType = {Ascend = 1, Descend = 2}
_G.EChipFilterType = _G.EChipFilterType or EChipFilterType
local EChipFilterRule = {
  Acquisition = 1,
  Level = 2,
  Rarity = 3,
  Exp = 4
}
_G.EChipFilterRule = _G.EChipFilterRule or EChipFilterRule
local EChipAttrChange = {
  Normal = 1,
  Add = 2,
  Minus = 3
}
_G.EChipAttrChange = _G.EChipAttrChange or EChipAttrChange
local EChipAttrAniChange = {
  Normal = 1,
  New = 2,
  Add = 3
}
_G.EChipAttrAniChange = _G.EChipAttrAniChange or EChipAttrAniChange
local EChipViewState = {Normal = "Normal", Strength = "Strength"}
_G.EChipViewState = _G.EChipViewState or EChipViewState
local EChipListState = {
  Normal = "Normal",
  Empty = "Empty",
  Lock = "Lock",
  EmptyAndLock = "EmptyAndLock"
}
_G.EChipListState = _G.EChipListState or EChipListState
local EChipFilter = {Normal = "Normal", Filter = "Filter"}
_G.EChipFilter = _G.EChipFilter or EChipFilter
local EChipSlotLock = {SlotLock = "SlotLock", Normal = "Normal"}
_G.EChipSlotLock = _G.EChipSlotLock or EChipSlotLock
local EChipAttrType = {CoreAttr = "CoreAttr", RandomAttr = "RandomAttr"}
_G.EChipAttrType = _G.EChipAttrType or EChipAttrType
local ChipData = {
  ChipBags = {},
  ChipUpgradeMatList = OrderedMap.New(),
  RarityToChipItemIdList = {},
  DefaultNormalFilterData = {
    MainAttrFilter = {},
    SubAttrFilter = {},
    RuleFilter = EChipFilterRule.Level,
    TypeFilter = EChipFilterType.Descend
  },
  NormalFilterData = {
    MainAttrFilter = {},
    SubAttrFilter = {},
    RuleFilter = EChipFilterRule.Level,
    TypeFilter = EChipFilterType.Descend
  },
  DefaultStrengthFilterData = {
    MainAttrFilter = {},
    SubAttrFilter = {},
    RuleFilter = EChipFilterRule.Rarity,
    TypeFilter = EChipFilterType.Ascend
  },
  StrengthFilterData = {
    MainAttrFilter = {},
    SubAttrFilter = {},
    RuleFilter = EChipFilterRule.Rarity,
    TypeFilter = EChipFilterType.Ascend
  },
  StrengthOnlyCheckDiscard = false,
  MaxMainAttrFilterNum = 1000,
  RandSubAttrLvGap = 3,
  ChipNameFmt = NSLOCTEXT("ChipData", "ChipNameFmt", "{0}\232\174\176\229\191\134\194\183{1}\231\162\142\231\137\135"),
  MaxChipNum = 999,
  CurRareLimit = UE.ERGItemRarity.EIR_Excellent
}

function ChipData:DealWithTable()
  local allRowNames = GetAllRowNames(DT.DT_Item)
  for indexRowName, vRowName in ipairs(allRowNames) do
    local result, row = GetRowData(DT.DT_Item, vRowName)
    if result and row.ArticleType == UE.EArticleDataType.Chip then
      for i = UE.ERGItemRarity.EIR_Normal, UE.ERGItemRarity.EIR_Max do
        if row.ItemRarity == i then
          if not ChipData.RarityToChipItemIdList[i] then
            ChipData.RarityToChipItemIdList[i] = {}
          end
          table.insert(ChipData.RarityToChipItemIdList[i], row.ID)
        end
      end
    end
  end
end

function ChipData:UpdateChipBagsSlot()
  if not self.ChipBags then
    return
  end
  if not DataMgr.GetMyHeroInfo() then
    return
  end
  local bIsUpdate = false
  local equipedChipIDs = {}
  for k, v in pairs(self.ChipBags) do
    for iHero, vHero in ipairs(DataMgr.GetMyHeroInfo().heros) do
      for kSlot, vChipId in pairs(vHero.chipsInfo) do
        if tonumber(v.Chip.id) and vChipId == v.Chip.id and v.Slot ~= tonumber(kSlot) then
          v.Slot = tonumber(kSlot)
          bIsUpdate = true
          if not v.bRequestedDetail then
            table.insert(equipedChipIDs, v.Chip.id)
          end
        end
        if tonumber(v.Chip.id) and vChipId == v.Chip.id and not v.bRequestedDetail then
          table.insert(equipedChipIDs, v.Chip.id)
        end
      end
    end
  end
  if not table.IsEmpty(equipedChipIDs) then
    EventSystem.Invoke(EventDef.Chip.UpdateEquipedChipDetail, equipedChipIDs)
  end
  if bIsUpdate then
    EventSystem.Invoke(EventDef.Chip.UpdateChipEquipSlot)
  end
end

function ChipData:GetEquipedChipListByHeroId(HeroId)
  local chipList = {}
  for k, v in pairs(self.ChipBags) do
    if v.Chip.equipHeroID == HeroId then
      table.insert(chipList, v)
    end
  end
  return chipList
end

function ChipData:GetEquipedSlotToChipByHeroId(HeroId)
  local chipList = {}
  for k, v in pairs(self.ChipBags) do
    if v.Chip.equipHeroID == HeroId then
      chipList[v.TbChipData.Slot] = v
    end
  end
  return chipList
end

function ChipData:CheckSlotIsUnLock(Slot)
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if tbChipSlot and tbChipSlot[Slot] then
    if 0 == tbChipSlot[Slot].UnlockWorld then
      return true
    end
    local maxUnLockFloor = DataMgr.GetFloorByGameModeIndex(tbChipSlot[Slot].UnlockWorld)
    return maxUnLockFloor > 0
  end
  return false
end

function ChipData:GetEquipedChipsByHeroId(HeroId)
  local slotToChipData = {}
  for k, v in pairs(self.ChipBags) do
    if v.Slot > 0 and tonumber(v.equipHeroID) == HeroId then
      slotToChipData[v.Slot] = v
    end
  end
  return slotToChipData
end

function ChipData:GetMainAttrValueByChipBagItemData(ChipBagItemData)
  if not ChipBagItemData then
    return -1, 0
  end
  local value = ChipBagItemData.TbChipData.AttrValue
  if ChipBagItemData.Chip and ChipBagItemData.Chip.mainAttrGrowth[1] then
    value = value + ChipBagItemData.Chip.mainAttrGrowth[1].value
  end
  return ChipBagItemData.TbChipData.AttrID, value
end

function ChipData:GetChipItemIdListByRarity(ItemRarity)
  if table.IsEmpty(ChipData.RarityToChipItemIdList) then
    ChipData:DealWithTable()
  end
  return ChipData.RarityToChipItemIdList[ItemRarity] or {}
end

function ChipData:GetChipMaxLvByRarity(Rarity)
  local tbChipLevelUp = LuaTableMgr.GetLuaTableByName(TableNames.TBChipLevelUp)
  if not tbChipLevelUp then
    return 0
  end
  for i = #tbChipLevelUp, 0, -1 do
    for idx, vLvUp in ipairs(tbChipLevelUp[i].upgradeExp) do
      if vLvUp.key == Rarity then
        return i
      end
    end
  end
  return 0
end

function ChipData:IsChip(ConfigId)
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if tbGeneral and tbGeneral[ConfigId] and 21 == tbGeneral[ConfigId].Type then
    return true
  end
  return false
end

function ChipData:CreateChipBagItemData(ChipResId, SubAttr, MainAttrGrowth, bindheroID, equipHeroID, Inscription, Slot, level, exp, state, UniqueID)
  local chipBagItemData = {
    Chip = {}
  }
  local tbChipData = LuaTableMgr.GetLuaTableByName(TableNames.TBResChip)
  if tbChipData and tbChipData[ChipResId] then
    chipBagItemData.TbChipData = tbChipData[ChipResId]
  end
  chipBagItemData.Chip.id = UniqueID or ChipResId
  chipBagItemData.Chip.subAttr = SubAttr or {}
  chipBagItemData.Chip.mainAttrGrowth = MainAttrGrowth or {}
  chipBagItemData.Chip.equipHeroID = equipHeroID or 0
  chipBagItemData.Chip.inscription = Inscription or 0
  chipBagItemData.Chip.bindHeroID = bindheroID or 0
  chipBagItemData.Chip.resourceID = ChipResId
  chipBagItemData.Chip.level = level or 0
  chipBagItemData.Chip.exp = exp or 0
  chipBagItemData.Slot = Slot
  chipBagItemData.Chip.state = state or 0
  chipBagItemData.ChipUpgradeMat = nil
  return chipBagItemData
end

function ChipData:CreateChipBagItemDataByUpgradeMat(ChipUpgradeMatResIdD, Num)
  local chipBagItemData = {Chip = nil}
  chipBagItemData.TbChipData = nil
  chipBagItemData.Slot = nil
  chipBagItemData.ChipUpgradeMat = {
    ResID = ChipUpgradeMatResIdD,
    amount = Num,
    SelectAmount = 0
  }
  return chipBagItemData
end

function ChipData:CheckChipEqual(FirstChipBagItem, SecondChipBagItem)
  if not FirstChipBagItem or not SecondChipBagItem then
    print("CheckChipEqual: FirstChipBagItem or SecondChipBagItem is nil")
    return false
  end
  if FirstChipBagItem.Chip.id == SecondChipBagItem.Chip.id then
    print("CheckChipEqual: FirstChipBagItem.Chip.id == SecondChipBagItem.Chip.id")
    return true
  end
  if FirstChipBagItem.Chip.subAttr and SecondChipBagItem.Chip.subAttr then
    if #FirstChipBagItem.Chip.subAttr == #SecondChipBagItem.Chip.subAttr then
      for i = 1, #FirstChipBagItem.Chip.subAttr do
        if FirstChipBagItem.Chip.subAttr[i].attrID ~= SecondChipBagItem.Chip.subAttr[i].attrID or FirstChipBagItem.Chip.subAttr[i].value ~= SecondChipBagItem.Chip.subAttr[i].value then
          print("CheckChipEqual: FirstChipBagItem.Chip.subAttr[i].attrID ~= SecondChipBagItem.Chip.subAttr[i].attrID or FirstChipBagItem.Chip.subAttr[i].value ~= SecondChipBagItem.Chip.subAttr[i].value")
          return false
        end
      end
    else
      print("CheckChipEqual: #FirstChipBagItem.Chip.subAttr ~= #SecondChipBagItem.Chip.subAttr")
      return false
    end
  end
  if FirstChipBagItem.Chip.bindHeroID ~= SecondChipBagItem.Chip.bindHeroID then
    print("CheckChipEqual: FirstChipBagItem.Chip.bindHeroID ~= SecondChipBagItem.Chip.bindHeroID")
    return false
  end
  if tostring(FirstChipBagItem.Chip.resourceID) ~= SecondChipBagItem.Chip.resourceID then
    print("CheckChipEqual: tostring(FirstChipBagItem.Chip.resourceID) ~= SecondChipBagItem.Chip.resourceID")
    return false
  end
  return true
end

function ChipData:UpdateChipBagDataByChipDetail(ChipBagData, ChipDetail)
  if ChipDetail then
    ChipBagData.Chip.id = ChipDetail.id
    ChipBagData.Chip.mainAttrGrowth = ChipDetail.mainAttrGrowth
    ChipBagData.Chip.subAttr = ChipDetail.subAttr
  end
  ChipBagData.bRequestedDetail = true
end

function ChipData:GetEquipedChipIDs()
  local equipedChipIDs = {}
  for iHero, vHero in ipairs(DataMgr.GetMyHeroInfo().heros) do
    if vHero and vHero.chipsInfo then
      for kSlot, vChipId in pairs(vHero.chipsInfo) do
        table.insert(equipedChipIDs, vChipId)
      end
    end
  end
  return equipedChipIDs
end

function ChipData:CheckBagIsEmpty()
  return table.IsEmpty(ChipData.ChipBags)
end

function ChipData:CreateChipAttrGrowth(AttrGrowth)
  if not AttrGrowth then
    return {}
  end
  local AttrGrowthData = {}
  for k, v in pairs(AttrGrowth) do
    table.insert(AttrGrowthData, {attrID = k, value = v})
  end
  return AttrGrowthData
end

return ChipData
