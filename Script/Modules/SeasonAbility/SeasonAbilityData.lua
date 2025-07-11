local SpecialAbilityStatus = {
  Lock = 0,
  UnLock = 1,
  Activated = 2
}
_G.SpecialAbilityStatus = SpecialAbilityStatus
local SeasonAbilityData = {
  SeasonAbilityInfo = {},
  HeroAbilityPointNumList = {},
  SpecialAbilityInfo = {},
  AllSeasonAbilityRowInfo = {},
  PreAbilityLevelList = {},
  PreCostSeasonAbilityPointNum = 0,
  ExchangeAbilityPointTable = {},
  MaxExchangeAbilityPointNum = 0,
  PreNeedExchangeAbilityPointNum = 0,
  PreNeedCostResourceInfo = {},
  UnLockedSchemeNum = 0
}
function SeasonAbilityData:SetSeasonAbilityInfo(HeroId, InSeasonTalentInfo)
  SeasonAbilityData.SeasonAbilityInfo[HeroId] = InSeasonTalentInfo
  SeasonAbilityData.HeroAbilityPointNumList[HeroId] = InSeasonTalentInfo.totalAcquiredPointNum
  SeasonAbilityData.UnLockedSchemeNum = InSeasonTalentInfo.unlockedSchemeNum
end
function SeasonAbilityData:GetSeasonAbilityInfo(HeroId)
  return SeasonAbilityData.SeasonAbilityInfo[HeroId]
end
function SeasonAbilityData:GetUnlockedSchemeNum(...)
  return SeasonAbilityData.UnLockedSchemeNum
end
function SeasonAbilityData:GetCurEquipSchemeId(HeroId)
  local SeasonAbilityInfo = SeasonAbilityData:GetSeasonAbilityInfo(HeroId)
  if not SeasonAbilityInfo then
    return 0
  end
  return SeasonAbilityInfo.equipedSchemeID
end
function SeasonAbilityData:GetSeasonAbilityInfoBySchemeId(HeroId, SchemeId)
  local CurEquipSchemeInfo
  local SeasonAbilityInfo = SeasonAbilityData:GetSeasonAbilityInfo(HeroId)
  if SeasonAbilityInfo and SeasonAbilityInfo.seasonAbilities then
    CurEquipSchemeInfo = SeasonAbilityInfo.seasonAbilities[tostring(SchemeId)]
  end
  return CurEquipSchemeInfo
end
function SeasonAbilityData:GetCurRemainAbilityPointNum(InHeroId)
  local SeasonAbilityInfo = SeasonAbilityData:GetSeasonAbilityInfo(InHeroId)
  if not SeasonAbilityInfo then
    return 0
  end
  local TargetSchemeAbilityInfo = SeasonAbilityInfo.seasonAbilities[tostring(SeasonAbilityInfo.equipedSchemeID)]
  if not TargetSchemeAbilityInfo then
    return 0
  end
  return TargetSchemeAbilityInfo.currentPointNum
end
function SeasonAbilityData:GetSeasonAbilityLevel(AbilityId, HeroId)
  local Level = 0
  local SeasonAbilityInfo = SeasonAbilityData:GetSeasonAbilityInfo(HeroId)
  if not SeasonAbilityInfo then
    return Level
  end
  local TargetSeasonAbilityInfo = SeasonAbilityInfo.seasonAbilities[tostring(SeasonAbilityInfo.equipedSchemeID)]
  if not TargetSeasonAbilityInfo then
    return Level
  end
  Level = TargetSeasonAbilityInfo.abilities[tostring(AbilityId)] and TargetSeasonAbilityInfo.abilities[tostring(AbilityId)] or 0
  return Level
end
function SeasonAbilityData:SetHeroAbilityPointNumList(InHeroAbilityPointNumList)
  for HeroId, Num in pairs(InHeroAbilityPointNumList) do
    SeasonAbilityData.HeroAbilityPointNumList[HeroId] = Num
  end
end
function SeasonAbilityData:GetTotalExchangeAbilityPointNumByHeroId(HeroId)
  return SeasonAbilityData.HeroAbilityPointNumList[HeroId] and SeasonAbilityData.HeroAbilityPointNumList[HeroId] or 0
end
function SeasonAbilityData:SetSpecialAbilityInfo(InSpecialAbilityInfo)
  SeasonAbilityData.SpecialAbilityInfo = InSpecialAbilityInfo
end
function SeasonAbilityData:GetSpecialAbilityInfo(...)
  return SeasonAbilityData.SpecialAbilityInfo
end
function SeasonAbilityData:GetSpecialAbilityCurrentMaxPointNum(...)
  local SpecialAbilityInfo = SeasonAbilityData:GetSpecialAbilityInfo()
  return SpecialAbilityInfo.currentMaxPointNum and SpecialAbilityInfo.currentMaxPointNum or 0
end
function SeasonAbilityData:GetSpecialAbilityHistoryMaxPointNum(...)
  local SpecialAbilityInfo = SeasonAbilityData:GetSpecialAbilityInfo()
  return SpecialAbilityInfo.historyMaxPointNum and SpecialAbilityInfo.historyMaxPointNum or 0
end
function SeasonAbilityData:GetSpecialAbilityStatus(AbilityId)
  local SpecialAbilityInfo = SeasonAbilityData:GetSpecialAbilityInfo()
  return SpecialAbilityInfo.specialAbilities and SpecialAbilityInfo.specialAbilities[tostring(AbilityId)] or SpecialAbilityStatus.Lock
end
function SeasonAbilityData:DealWithTable(...)
  local SeasonAbilityTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSeasonTalent)
  if SeasonAbilityTable then
    for i, SingleAbilityInfo in pairs(SeasonAbilityTable) do
      local GroupList = SeasonAbilityData.AllSeasonAbilityRowInfo[SingleAbilityInfo.SeasonTalentGroupID]
      if GroupList then
        GroupList[SingleAbilityInfo.Level] = SingleAbilityInfo
      else
        local TempList = {}
        TempList[SingleAbilityInfo.Level] = SingleAbilityInfo
        SeasonAbilityData.AllSeasonAbilityRowInfo[SingleAbilityInfo.SeasonTalentGroupID] = TempList
      end
    end
  end
  local ExchangeAbilityPointTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSeasonAbilityPointExchange)
  if ExchangeAbilityPointTable then
    local MaxExchangeAbilityPointNum = 0
    for index, SingleExchangeAbilityPointInfo in ipairs(ExchangeAbilityPointTable) do
      SeasonAbilityData.ExchangeAbilityPointTable[SingleExchangeAbilityPointInfo.AbilityPointID] = SingleExchangeAbilityPointInfo
      if MaxExchangeAbilityPointNum < SingleExchangeAbilityPointInfo.AbilityPointID then
        MaxExchangeAbilityPointNum = SingleExchangeAbilityPointInfo.AbilityPointID
      end
    end
    SeasonAbilityData.MaxExchangeAbilityPointNum = MaxExchangeAbilityPointNum
  end
end
function SeasonAbilityData:GetMaxExchangeAbilityPointNum(...)
  return SeasonAbilityData.MaxExchangeAbilityPointNum
end
function SeasonAbilityData:GetAbilityTableRow(GroupId)
  return SeasonAbilityData.AllSeasonAbilityRowInfo[GroupId]
end
function SeasonAbilityData:IsMeetPreAbilityGroupCondition(AbilityId, HeroId)
  local AbilityInfo = SeasonAbilityData:GetAbilityTableRow(AbilityId)
  if not AbilityInfo then
    return false
  end
  local PreLevel = SeasonAbilityData:GetPreAbilityLevel(AbilityId, HeroId)
  local TargetLevelAbilityInfo = AbilityInfo[PreLevel + 1]
  if not TargetLevelAbilityInfo then
    return false
  end
  local PreAbilityLevelSum = 0
  for i, SingleAbilityId in ipairs(TargetLevelAbilityInfo.FrontGroupIds) do
    local PreLevel = SeasonAbilityData:GetPreAbilityLevel(SingleAbilityId, HeroId)
    PreAbilityLevelSum = PreAbilityLevelSum + PreLevel
  end
  return PreAbilityLevelSum >= TargetLevelAbilityInfo.FrontGroupsLevel
end
function SeasonAbilityData:GetPreAbilityLevel(AbilityId, HeroId)
  if SeasonAbilityData.PreAbilityLevelList[AbilityId] then
    return SeasonAbilityData.PreAbilityLevelList[AbilityId]
  end
  return SeasonAbilityData:GetSeasonAbilityLevel(AbilityId, HeroId)
end
function SeasonAbilityData:SetPreAbilityLevel(AbilityId, Level, HeroId)
  local CurLevel = SeasonAbilityData:GetSeasonAbilityLevel(AbilityId, HeroId)
  if Level == CurLevel then
    SeasonAbilityData.PreAbilityLevelList[AbilityId] = nil
  else
    SeasonAbilityData.PreAbilityLevelList[AbilityId] = Level
  end
end
function SeasonAbilityData:GetPreAbilityLevelList(...)
  return SeasonAbilityData.PreAbilityLevelList
end
function SeasonAbilityData:GetPreCostSeasonAbilityPointNum(...)
  return SeasonAbilityData.PreCostSeasonAbilityPointNum
end
function SeasonAbilityData:SetPreCostSeasonAbilityPointNum(CostNum, ExchangeNum, HeroId)
  SeasonAbilityData.PreCostSeasonAbilityPointNum = math.max(SeasonAbilityData.PreCostSeasonAbilityPointNum + CostNum, 0)
  SeasonAbilityData.PreNeedExchangeAbilityPointNum = SeasonAbilityData.PreNeedExchangeAbilityPointNum + ExchangeNum
  local TotalHeroAbilityPointNum = SeasonAbilityData:GetTotalExchangeAbilityPointNumByHeroId(HeroId)
  local NeedCostResourceInfo = {}
  for i = 1, SeasonAbilityData.PreNeedExchangeAbilityPointNum do
    local CurExchangePointRowInfo = SeasonAbilityData.ExchangeAbilityPointTable[TotalHeroAbilityPointNum + i]
    if CurExchangePointRowInfo then
      local ResourceNum = NeedCostResourceInfo[CurExchangePointRowInfo.ExchangeResource.key]
      ResourceNum = ResourceNum or 0
      NeedCostResourceInfo[CurExchangePointRowInfo.ExchangeResource.key] = ResourceNum + CurExchangePointRowInfo.ExchangeResource.value
    end
  end
  SeasonAbilityData.PreNeedCostResourceInfo = NeedCostResourceInfo
end
function SeasonAbilityData:GetExchangeAbilityPointTableRow(PointNum)
  return SeasonAbilityData.ExchangeAbilityPointTable[PointNum]
end
function SeasonAbilityData:GetPreNeedExchangeAbilityPointNum(...)
  return SeasonAbilityData.PreNeedExchangeAbilityPointNum
end
function SeasonAbilityData:GetPreRemainCostResourceNum(ResourceId)
  local PreCostResourceNum = SeasonAbilityData.PreNeedCostResourceInfo[ResourceId]
  PreCostResourceNum = PreCostResourceNum or 0
  local CurHaveResourceNum = LogicOutsidePackback.GetResourceNumById(ResourceId)
  return CurHaveResourceNum - PreCostResourceNum
end
function SeasonAbilityData:GetPreRemainSeasonAbilityPointNum(HeroId)
  local CurRemainAbilityPointNum = SeasonAbilityData:GetCurRemainAbilityPointNum(HeroId)
  local PreCostSeasonAbilityPointNum = SeasonAbilityData:GetPreCostSeasonAbilityPointNum()
  return math.max(CurRemainAbilityPointNum - PreCostSeasonAbilityPointNum, 0)
end
function SeasonAbilityData:GetAbilityMaxCanUpgradeLevel(AbilityId, HeroId)
  local AbilityGroupInfo = SeasonAbilityData:GetAbilityTableRow(AbilityId)
  if not AbilityGroupInfo then
    return 0
  end
  local MaxCanUpgradeLevel = 0
  for Level, SingleTalentInfo in pairs(AbilityGroupInfo) do
    local PreTalentLevelSum = 0
    for i, SingleTalentId in ipairs(SingleTalentInfo.FrontGroupIds) do
      local PreLevel = SeasonAbilityData:GetPreAbilityLevel(SingleTalentId, HeroId)
      PreTalentLevelSum = PreTalentLevelSum + PreLevel
    end
    if PreTalentLevelSum < SingleTalentInfo.FrontGroupsLevel then
      break
    end
    MaxCanUpgradeLevel = Level
  end
  return MaxCanUpgradeLevel
end
function SeasonAbilityData:GetAbilityMaxLevel(AbilityId)
  local AbilityGroupInfo = SeasonAbilityData:GetAbilityTableRow(AbilityId)
  local MaxLevel = 0
  if AbilityGroupInfo then
    for Level, value in pairs(AbilityGroupInfo) do
      if Level > MaxLevel then
        MaxLevel = Level
      end
    end
  end
  return MaxLevel
end
function SeasonAbilityData:IsMeetAbilityUpgradeCostCondition(AbilityId, HeroId)
  local Result, NeedExchangePointNum = false, 0
  local AbilityInfo = SeasonAbilityData:GetAbilityTableRow(AbilityId)
  if not AbilityInfo then
    return Result, NeedExchangePointNum
  end
  local Level = SeasonAbilityData:GetPreAbilityLevel(AbilityId, HeroId)
  local TargetLevelAbilityInfo = AbilityInfo[Level + 1]
  if not TargetLevelAbilityInfo then
    return Result, NeedExchangePointNum
  end
  local RemainSeasonAbilityPointNum = SeasonAbilityData:GetPreRemainSeasonAbilityPointNum(HeroId)
  Result = RemainSeasonAbilityPointNum >= TargetLevelAbilityInfo.ConsumerResourceNum
  if not Result then
    local TotalHeroAbilityPointNum = SeasonAbilityData:GetTotalExchangeAbilityPointNumByHeroId(HeroId)
    local NeedExchangePointNum = TargetLevelAbilityInfo.ConsumerResourceNum - RemainSeasonAbilityPointNum
    local CanExchangePointNum = SeasonAbilityData.MaxExchangeAbilityPointNum - (TotalHeroAbilityPointNum + NeedExchangePointNum + SeasonAbilityData.PreNeedExchangeAbilityPointNum)
    if CanExchangePointNum < 0 then
      return Result, 0
    end
    local NeedCostResourceInfo = {}
    for i = 1, NeedExchangePointNum do
      local CurExchangePointRowInfo = SeasonAbilityData.ExchangeAbilityPointTable[TotalHeroAbilityPointNum + i]
      if CurExchangePointRowInfo then
        local ResourceNum = NeedCostResourceInfo[CurExchangePointRowInfo.ExchangeResource.key]
        ResourceNum = ResourceNum or 0
        NeedCostResourceInfo[CurExchangePointRowInfo.ExchangeResource.key] = ResourceNum + CurExchangePointRowInfo.ExchangeResource.value
      end
    end
    for CostResourceId, CostResourceNum in pairs(NeedCostResourceInfo) do
      local CurHaveCurrencyNum = LogicOutsidePackback.GetResourceNumById(CostResourceId)
      local PreCostResourceNum = SeasonAbilityData.PreNeedCostResourceInfo[CostResourceId]
      PreCostResourceNum = PreCostResourceNum or 0
      if CurHaveCurrencyNum < CostResourceNum + PreCostResourceNum then
        return false, 0
      end
    end
    return true, NeedExchangePointNum
  end
  return Result, NeedExchangePointNum
end
function SeasonAbilityData:GetAbilityUpgradeExchangeCostConditionResult(AbilityId, HeroId)
  local AbilityInfo = SeasonAbilityData:GetAbilityTableRow(AbilityId)
  if not AbilityInfo then
    return false, 0
  end
  local Level = SeasonAbilityData:GetPreAbilityLevel(AbilityId, HeroId)
  local TargetLevelAbilityInfo = AbilityInfo[Level + 1]
  if not TargetLevelAbilityInfo then
    return false, 0
  end
end
local function GetPreAbilityIdList(AbilityId, PreAbilityIdList)
  local AbilityGroupInfo = SeasonAbilityData:GetAbilityTableRow(AbilityId)
  if AbilityGroupInfo and AbilityGroupInfo[1] then
    table.insert(PreAbilityIdList, 1, AbilityId)
    for i, SingleFrontGroupId in ipairs(AbilityGroupInfo[1].FrontGroupIds) do
      GetPreAbilityIdList(SingleFrontGroupId, PreAbilityIdList)
    end
    return
  end
  return
end
function SeasonAbilityData:SortUpgradeAbilityList(InAbilityList)
  local AbilityIdList = {}
  for GroupId, Level in pairs(InAbilityList) do
    local TempList = {}
    GetPreAbilityIdList(GroupId, TempList)
    for i, SingleId in ipairs(TempList) do
      if not table.Contain(AbilityIdList, SingleId) and InAbilityList[SingleId] then
        table.insert(AbilityIdList, SingleId)
      end
    end
  end
  local TempConfirmParams = {}
  for i, AbilityId in ipairs(AbilityIdList) do
    local TempTable = {}
    TempTable.groupID = AbilityId
    TempTable.level = InAbilityList[AbilityId]
    table.insert(TempConfirmParams, TempTable)
  end
  return TempConfirmParams
end
function SeasonAbilityData:ResetPreAbilityInfo(...)
  SeasonAbilityData.PreAbilityLevelList = {}
  SeasonAbilityData.PreCostSeasonAbilityPointNum = 0
  SeasonAbilityData.PreNeedExchangeAbilityPointNum = 0
  SeasonAbilityData.PreNeedCostResourceInfo = {}
end
return SeasonAbilityData
