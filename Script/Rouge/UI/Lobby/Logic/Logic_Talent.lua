local rapidjson = require("rapidjson")
LogicTalent = LogicTalent or {
  TalentList = {}
}
function LogicTalent.Init()
  LogicTalent.TalentList = {}
  LogicTalent.PreCommonTalentLevelList = {}
  LogicTalent.PreCurrencyList = {}
  LogicTalent.PrePackbackList = {}
  LogicTalent.HeroTalentList = {}
  LogicTalent.ItemStyleList = {}
  LogicTalent.DealWithTalentTable()
  LogicTalent.DealWithHeroTalentTable()
  LogicTalent.ResetPreRemainCostList()
end
function LogicTalent.InitTalentItemStyle(InItemStyleList)
  LogicTalent.ItemStyleList = InItemStyleList
end
function LogicTalent.GetTalentStyleItemByType(Type)
  return LogicTalent.ItemStyleList[Type]
end
function LogicTalent.DealWithTalentTable()
  local TalentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTalent)
  if not TalentTable then
    return
  end
  for i, SingleTalentInfo in pairs(TalentTable) do
    local GroupList = LogicTalent.TalentList[SingleTalentInfo.GroupID]
    if GroupList then
      GroupList[SingleTalentInfo.Level] = SingleTalentInfo
    else
      local TempList = {}
      TempList[SingleTalentInfo.Level] = SingleTalentInfo
      LogicTalent.TalentList[SingleTalentInfo.GroupID] = TempList
    end
  end
end
function LogicTalent.DealWithHeroTalentTable()
  local HeroTalentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroTalent)
  if not HeroTalentTable then
    return
  end
  for HeroId, SingleHeroTalentInfo in pairs(HeroTalentTable) do
    local HeroTalentList = {}
    local FinalHeroTalentList = {}
    for i, SingleTalentId in ipairs(SingleHeroTalentInfo.TalentGroupIDS) do
      local TempList = {}
      LogicTalent.GetHeroTalentPre(SingleTalentId, TempList)
      for i, SingleId in ipairs(TempList) do
        if not table.Contain(HeroTalentList, SingleId) then
          table.insert(HeroTalentList, SingleId)
        end
      end
    end
    LogicTalent.HeroTalentList[HeroId] = HeroTalentList
  end
end
function LogicTalent.GetHeroTalentPre(TalentId, HeroTalentList)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if TalentInfo and TalentInfo[1] then
    table.insert(HeroTalentList, 1, TalentId)
    if TalentInfo[1].FrontGroupsId[1] then
      LogicTalent.GetHeroTalentPre(TalentInfo[1].FrontGroupsId[1], HeroTalentList)
    else
      return
    end
  end
  return
end
function LogicTalent.GetTalentTableRow(GroupId)
  return LogicTalent.TalentList[GroupId]
end
function LogicTalent.GetMaxLevelByTalentId(TalentId)
  local TalentRow = LogicTalent.GetTalentTableRow(TalentId)
  local MaxLevel = 0
  if TalentRow then
    for Level, value in pairs(TalentRow) do
      if Level > MaxLevel then
        MaxLevel = Level
      end
    end
  end
  return MaxLevel
end
function LogicTalent.GetHeroTalentList(HeroId)
  return LogicTalent.HeroTalentList[HeroId]
end
function LogicTalent.RequestUpgradeCommonTalentToServer(Params)
  HttpCommunication.Request("hero/upgradecommontalent", Params, {
    GameInstance,
    function(Target, JsonResponse)
      print("LogicTalent.RequestUpgradeCommonTalentToServer", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      DataMgr.SetCommonTalents(JsonTable.Talents)
      DataMgr.SetCommonTalentsAccumulativeCost(JsonTable.Costs)
      for i, SingleTalentInfo in ipairs(JsonTable.Talents) do
        LogicTalent.PreCommonTalentLevelList[SingleTalentInfo.groupId] = SingleTalentInfo.level
      end
      EventSystem.Invoke(EventDef.Lobby.UpdateCommonTalentInfo)
      EventSystem.Invoke(EventDef.Lobby.UpdateCommonTalentPresetCost)
      local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if WaveWindowManager then
        WaveWindowManager:ShowWaveWindow(1038)
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function LogicTalent.RequestGetCommonTalentsToServer()
  HttpCommunication.Request("hero/getcommontalents", {}, {
    GameInstance,
    function(Target, JsonResponse)
      print(JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      DataMgr.SetCommonTalents(JsonTable.Talents)
      DataMgr.SetCommonTalentsAccumulativeCost(JsonTable.Costs)
      if not LogicTalent.PreCommonTalentLevelList then
        LogicTalent.PreCommonTalentLevelList = {}
      end
      for i, SingleTalentInfo in ipairs(JsonTable.Talents) do
        LogicTalent.PreCommonTalentLevelList[SingleTalentInfo.groupId] = SingleTalentInfo.level
      end
      EventSystem.Invoke(EventDef.Lobby.UpdateCommonTalentInfo)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function LogicTalent.RequestGetHeroTalentsToServer(HeroId)
end
function LogicTalent.RequestUpgradeHeroTalentToServer(HeroId, TalentGroupId)
end
function LogicTalent.ResetPreCommonTalentLevelList()
  LogicTalent.PreCommonTalentLevelList = {}
  local CommonTalentInfos = DataMgr.GetCommonTalentInfos()
  for SingleTalentId, SingleTalentInfo in pairs(CommonTalentInfos) do
    LogicTalent.PreCommonTalentLevelList[SingleTalentInfo.groupId] = SingleTalentInfo.level
  end
  EventSystem.Invoke(EventDef.Lobby.UpdateCommonTalentInfo)
end
function LogicTalent.GetPreCommonTalentLevelList()
  return LogicTalent.PreCommonTalentLevelList
end
function LogicTalent.SetPreCommonTalentLevel(TalentId, Level)
  LogicTalent.PreCommonTalentLevelList[TalentId] = Level
end
function LogicTalent.GetPreCommonTalentLevel(TalentId)
  if LogicTalent.PreCommonTalentLevelList[TalentId] then
    return LogicTalent.PreCommonTalentLevelList[TalentId]
  end
  local AllTalentsInfo = DataMgr.GetCommonTalentInfos()
  local TargetTaletInfo = AllTalentsInfo[TalentId]
  if TargetTaletInfo then
    return TargetTaletInfo.level
  end
  return 0
end
function LogicTalent.ResetPreRemainCostList()
  LogicTalent.ResetPreCurrencyList()
  LogicTalent.ResetPrePackbackList()
end
function LogicTalent.ResetPreCurrencyList()
  LogicTalent.PreCurrencyList = {}
  local CurrencyList = DataMgr.GetOutsideCurrencyList()
  for CurrencyId, CurrencyNum in pairs(CurrencyList) do
    LogicTalent.PreCurrencyList[CurrencyId] = CurrencyNum
  end
end
function LogicTalent.GetPreCurrencyNum(CurrencyId)
  return LogicTalent.PreCurrencyList[CurrencyId] and LogicTalent.PreCurrencyList[CurrencyId] or 0
end
function LogicTalent.SetPreCurrencyNum(CurrencyId, CostNum)
  if LogicTalent.PreCurrencyList[CurrencyId] then
    LogicTalent.PreCurrencyList[CurrencyId] = LogicTalent.PreCurrencyList[CurrencyId] + CostNum
  else
    LogicTalent.PreCurrencyList[CurrencyId] = CostNum
  end
end
function LogicTalent.GetPreRemainCostNum(CostId)
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local ResourceRow = ResourceTable[CostId]
  if ResourceRow then
    if ResourceRow.Type == TableEnums.ENUMResourceType.CURRENCY then
      return LogicTalent.GetPreCurrencyNum(CostId)
    else
      return LogicTalent.GetPrePackbackNum(CostId)
    end
  end
  return 0
end
function LogicTalent.GetPreCostNum(CostId)
  local CurHaveNum = 0
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, CostId)
  if Result then
    if RowInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
      CurHaveNum = DataMgr.GetOutsideCurrencyNumById(CostId)
    else
      CurHaveNum = DataMgr.GetPackbackNumById(CostId)
    end
  end
  local PreCostNum = LogicTalent.GetPreRemainCostNum(CostId)
  return CurHaveNum - PreCostNum
end
function LogicTalent.SetPreRemainCostNum(CostId, CostNum)
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local ResourceRow = ResourceTable[CostId]
  if ResourceRow then
    if ResourceRow.Type == TableEnums.ENUMResourceType.CURRENCY then
      LogicTalent.SetPreCurrencyNum(CostId, CostNum)
    else
      LogicTalent.SetPrePackbackNum(CostId, CostNum)
    end
  end
  EventSystem.Invoke(EventDef.Lobby.UpdateCommonTalentPresetCost)
end
function LogicTalent.ResetPrePackbackList()
  LogicTalent.PrePackbackList = {}
  local PackbackList = DataMgr.GetPackbackList()
  for ResourceId, ResourceList in pairs(PackbackList) do
    local Num = DataMgr.GetPackbackNumById(ResourceId)
    LogicTalent.PrePackbackList[ResourceId] = Num
  end
end
function LogicTalent.GetPrePackbackNum(ResourceId)
  return LogicTalent.PrePackbackList[ResourceId] and LogicTalent.PrePackbackList[ResourceId] or 0
end
function LogicTalent.SetPrePackbackNum(ResourceId, CostNum)
  if LogicTalent.PrePackbackList[ResourceId] then
    LogicTalent.PrePackbackList[ResourceId] = LogicTalent.PrePackbackList[ResourceId] + CostNum
  else
    LogicTalent.PrePackbackList[ResourceId] = CostNum
  end
end
function LogicTalent.IsMeetPreTalentGroupCondition(TalentId)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if not TalentInfo then
    return false
  end
  local PreLevel = LogicTalent.GetPreCommonTalentLevel(TalentId)
  local TargetLevelTalentInfo = TalentInfo[PreLevel + 1]
  if not TargetLevelTalentInfo then
    return false
  end
  local PreTalentLevelSum = 0
  for i, SingleTalentId in ipairs(TargetLevelTalentInfo.FrontGroupsId) do
    local PreLevel = LogicTalent.GetPreCommonTalentLevel(SingleTalentId)
    PreTalentLevelSum = PreTalentLevelSum + PreLevel
  end
  return PreTalentLevelSum >= TargetLevelTalentInfo.FrontGroupsLevel
end
function LogicTalent.IsMeetTalentUpgradeCostCondition(TalentId)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if not TalentInfo then
    return false
  end
  local Level = LogicTalent.GetPreCommonTalentLevel(TalentId)
  local TargetLevelTalentInfo = TalentInfo[Level + 1]
  if not TargetLevelTalentInfo then
    return false
  end
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local CostResult = false
  for i, SingleCostInfo in ipairs(TargetLevelTalentInfo.ArrCost) do
    local ResourceRow = ResourceTable[SingleCostInfo.key]
    if ResourceRow then
      local CurCostValue = 0
      if ResourceRow.Type == TableEnums.ENUMResourceType.CURRENCY then
        CurCostValue = LogicTalent.GetPreCurrencyNum(SingleCostInfo.key)
      else
        CurCostValue = LogicTalent.GetPrePackbackNum(SingleCostInfo.key)
      end
      if CurCostValue >= SingleCostInfo.value then
        CostResult = true
        break
      end
    end
  end
  return CostResult
end
function LogicTalent.IsMeetRoleLevelCondition(TalentId)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if not TalentInfo then
    return false
  end
  local PreLevel = LogicTalent.GetPreCommonTalentLevel(TalentId)
  local TargetLevelTalentInfo = TalentInfo[PreLevel + 1]
  if not TargetLevelTalentInfo then
    return false
  end
  return tonumber(DataMgr.GetRoleLevel()) >= TargetLevelTalentInfo.RoleLevel
end
function LogicTalent.GetMaxCanUpgradeLevel(TalentId)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if not TalentInfo then
    return 0
  end
  local MaxCanUpgradeLevel = 0
  for Level, SingleTalentInfo in pairs(TalentInfo) do
    if SingleTalentInfo.TalentType == TableEnums.ENUMTalentType.Accumulative then
      local CanUpgrade = true
      for index, SingleCostInfo in ipairs(SingleTalentInfo.ArrCost) do
        local CurCostNum = DataMgr.GetCommonTalentsAccumulativeCostById(SingleCostInfo.key)
        if CurCostNum < SingleCostInfo.value then
          CanUpgrade = false
        end
      end
      if CanUpgrade then
        MaxCanUpgradeLevel = Level
      end
    else
      local PreTalentLevelSum = 0
      for i, SingleTalentId in ipairs(SingleTalentInfo.FrontGroupsId) do
        local PreLevel = LogicTalent.GetPreCommonTalentLevel(SingleTalentId)
        PreTalentLevelSum = PreTalentLevelSum + PreLevel
      end
      if PreTalentLevelSum < SingleTalentInfo.FrontGroupsLevel then
        break
      end
      MaxCanUpgradeLevel = Level
    end
  end
  return MaxCanUpgradeLevel
end
function LogicTalent.IsMeetPreHeroTalentGroupCondition(HeroId, TalentId, Level)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if not TalentInfo then
    return false
  end
  local PreLevel = Level
  local TargetLevelTalentInfo = TalentInfo[PreLevel]
  if not TargetLevelTalentInfo then
    return false
  end
  local PreTalentLevelSum = 0
  for i, SingleTalentId in ipairs(TargetLevelTalentInfo.FrontGroupsId) do
    local PreLevel = DataMgr.GetHeroTalentLevelById(HeroId, SingleTalentId)
    PreTalentLevelSum = PreTalentLevelSum + PreLevel
  end
  return PreTalentLevelSum >= TargetLevelTalentInfo.FrontGroupsLevel
end
function LogicTalent.IsMeetHeroTalentUpgradeCostCondition(HeroId, TalentId, Level)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if not TalentInfo then
    return false
  end
  local TargetLevelTalentInfo = TalentInfo[Level]
  if not TargetLevelTalentInfo then
    return false
  end
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local CostResult = false
  for i, SingleCostInfo in ipairs(TargetLevelTalentInfo.ArrCost) do
    local ResourceRow = ResourceTable[SingleCostInfo.key]
    if ResourceRow then
      local CurCostValue = 0
      if ResourceRow.Type == TableEnums.ENUMResourceType.CURRENCY then
        CurCostValue = DataMgr.GetOutsideCurrencyNumById(SingleCostInfo.key)
      else
        CurCostValue = DataMgr.GetPackbackNumById(SingleCostInfo.key)
      end
      if CurCostValue >= SingleCostInfo.value then
        CostResult = true
        break
      end
    end
  end
  return CostResult
end
function LogicTalent.IsMeetHeroTalentRoleLevelCondition(HeroId, TalentId, Level)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if not TalentInfo then
    return false
  end
  local PreLevel = Level
  local TargetLevelTalentInfo = TalentInfo[PreLevel]
  if not TargetLevelTalentInfo then
    return false
  end
  return tonumber(DataMgr.GetRoleLevel()) >= TargetLevelTalentInfo.RoleLevel
end
function LogicTalent.GetHeroTalentMaxCanUpgradeLevel(HeroId, TalentId)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if not TalentInfo then
    return 0
  end
  local MaxCanUpgradeLevel = 0
  for Level, SingleTalentInfo in pairs(TalentInfo) do
    local PreTalentLevelSum = 0
    for i, SingleTalentId in ipairs(SingleTalentInfo.FrontGroupsId) do
      local PreLevel = DataMgr.GetHeroTalentLevelById(HeroId, SingleTalentId)
      PreTalentLevelSum = PreTalentLevelSum + PreLevel
    end
    if PreTalentLevelSum < SingleTalentInfo.FrontGroupsLevel then
      break
    end
    MaxCanUpgradeLevel = Level
  end
  return MaxCanUpgradeLevel
end
function LogicTalent.Clear()
  LogicTalent.TalentList = {}
  LogicTalent.PreCommonTalentLevelList = {}
  LogicTalent.PreCurrencyList = {}
  LogicTalent.PrePackbackList = {}
end
