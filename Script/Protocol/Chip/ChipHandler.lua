local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local ChipData = require("Modules.Chip.ChipData")
local ChipHandler = {}

function ChipHandler.RequestGetHeroChipBag(Callback)
end

function ChipHandler.RequestGetChipDetail(ChipIDList, Callback, bIsShowLoading)
end

function ChipHandler.RequestGetChipListByAttrIDs(MainAttrIDs, SubAttrIDs, Callback)
end

function ChipHandler.RequestGetChipUpgradeMat()
end

function ChipHandler.RequestCancelOrDiscard(Id, SuccCallback, FailedCallback)
end

function ChipHandler.RequestDiscardChip(Id, SuccCallback, FailedCallback)
end

function ChipHandler.RequestEquipChip(ChipId, HeroId, Slot)
end

function ChipHandler.RequestLockChip(Id, Callback, FailedCallback)
end

function ChipHandler.RequestMigrateChip(HeroId, Slot, TargetHeroId, TargetSlot)
end

function ChipHandler.RequestUnEquipChip(HeroId, Slot)
end

function ChipHandler.RequestUpgradeChip(EatIdList, ChipId, EatChipUpgradeMatList)
end

return ChipHandler
