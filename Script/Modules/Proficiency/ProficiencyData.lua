local ProficiencyData = {
  AllHeroProficiencyInfo = {}
}
function ProficiencyData:DealWithTable()
  local ProfyGeneralTable = LuaTableMgr.GetLuaTableByName(TableNames.TBProfyGeneral)
  if not ProfyGeneralTable then
    return
  end
  for RowId, RowInfo in pairs(ProfyGeneralTable) do
    local HeroProficiencyInfo = ProficiencyData.AllHeroProficiencyInfo[RowInfo.HeroID]
    if not HeroProficiencyInfo then
      HeroProficiencyInfo = {}
      ProficiencyData.AllHeroProficiencyInfo[RowInfo.HeroID] = HeroProficiencyInfo
    end
    HeroProficiencyInfo[RowInfo.Level] = RowId
  end
end
function ProficiencyData:GetAllProficiencyInfoByHeroId(HeroId)
  return ProficiencyData.AllHeroProficiencyInfo[HeroId]
end
function ProficiencyData:GetProficiencyRowInfoByHeroIdAndLevel(HeroId, Level)
  local HeroProficiencyInfo = ProficiencyData.AllHeroProficiencyInfo[HeroId]
  local RowId = HeroProficiencyInfo[Level]
  if not RowId then
    print("ProficiencyData:GetProficiencyRowInfoByHeroIdAndLevel invalid Level", Level)
    return false, nil
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyGeneral, RowId)
  return Result, RowInfo
end
function ProficiencyData:GetMaxProfyLevel(HeroId)
  local MaxLevel = 0
  local AllProficiencyInfo = ProficiencyData.AllHeroProficiencyInfo[HeroId]
  if AllProficiencyInfo then
    for Level, value in pairs(AllProficiencyInfo) do
      if Level > MaxLevel then
        MaxLevel = Level
      end
    end
  end
  return MaxLevel
end
function ProficiencyData:GetMaxUnlockProfyLevel(HeroId)
  local MyHeroInfo = DataMgr.GetMyHeroInfo()
  for index, SingleHeroInfo in ipairs(MyHeroInfo.heros) do
    if SingleHeroInfo.id == HeroId then
      return SingleHeroInfo.profy
    end
  end
  return 0
end
function ProficiencyData:GetAllInscriptionReward(HeroId)
  local InscriptionList = {}
  local MaxUnlockLevel = ProficiencyData:GetMaxUnlockProfyLevel(HeroId)
  local Result, RowInfo = false
  for i = 1, MaxUnlockLevel do
    if ProficiencyData:IsCurProfyLevelRewardReceived(HeroId, i) then
      Result, RowInfo = ProficiencyData:GetProficiencyRowInfoByHeroIdAndLevel(HeroId, i)
      if Result and not RowInfo.LvRewardList[1] and RowInfo.inscriptions[1] then
        table.insert(InscriptionList, RowInfo.inscriptions[1])
      end
    end
  end
  return InscriptionList
end
function ProficiencyData:GetCurProfyExp(HeroId)
  local MyHeroInfo = DataMgr.GetMyHeroInfo()
  for index, SingleHeroInfo in ipairs(MyHeroInfo.heros) do
    if SingleHeroInfo.id == HeroId then
      return SingleHeroInfo.profyExp
    end
  end
  return 0
end
function ProficiencyData:GetNextLevelProfyMaxExp(HeroId)
  local MaxUnlockLevel = ProficiencyData:GetMaxUnlockProfyLevel(HeroId)
  local MaxLevel = ProficiencyData:GetMaxProfyLevel(HeroId)
  local TargetLevel = math.min(MaxUnlockLevel + 1, MaxLevel)
  local Result, NextLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, TargetLevel)
  return Result and NextLevelRowInfo.Exp or 0
end
function ProficiencyData:IsCurProfyLevelRewardReceived(HeroId, Level)
  local MyHeroInfo = DataMgr.GetMyHeroInfo()
  for index, SingleHeroInfo in ipairs(MyHeroInfo.heros) do
    if SingleHeroInfo.id == HeroId then
      return table.Contain(SingleHeroInfo.profyLvReward, Level)
    end
  end
  return false
end
function ProficiencyData:IsCurProfyStoryRewardReceived(HeroId, Level)
  local MyHeroInfo = DataMgr.GetMyHeroInfo()
  for index, SingleHeroInfo in ipairs(MyHeroInfo.heros) do
    if SingleHeroInfo.id == HeroId then
      return table.Contain(SingleHeroInfo.profyStoryReward, Level)
    end
  end
  return false
end
function ProficiencyData:ShowReceiveAwardPanel(HeroId, Level, IsStoryReward)
  local AllAttachmentList = {}
  local Result, RowInfo = ProficiencyData:GetProficiencyRowInfoByHeroIdAndLevel(HeroId, Level)
  if Result and not IsStoryReward and not RowInfo.LvRewardList[1] then
    for index, Id in ipairs(RowInfo.inscriptions) do
      local TempTable = {
        Id = Id,
        Num = 1,
        IsInscription = true
      }
      table.insert(AllAttachmentList, TempTable)
    end
  end
  if next(AllAttachmentList) ~= nil then
    EventSystem.Invoke(EventDef.Lobby.OnGetPropTip, AllAttachmentList)
  end
end
return ProficiencyData
