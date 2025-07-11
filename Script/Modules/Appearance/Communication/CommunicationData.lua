local ECommunicationToggleStatus = {
  None = 0,
  Spray = 1,
  Voice = 2
}
_G.ECommunicationToggleStatus = _G.ECommunicationToggleStatus or ECommunicationToggleStatus
local CommunicationData = {
  HeroCommMap = {},
  HeroCommBag = {},
  HeroCommEquip = {},
  RouletteIdToTBCommonicationData = {}
}
function CommunicationData.ClearData()
  CommunicationData.HeroCommMap = {}
  CommunicationData.HeroCommBag = {}
  CommunicationData.HeroCommEquip = {}
end
function CommunicationData.InitData()
  CommunicationData.ClearData()
  local CommunicationList = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  for k, v in pairs(CommunicationList) do
    if not CommunicationData.HeroCommMap[v.HeroID] then
      CommunicationData.HeroCommMap[v.HeroID] = {
        EquipedList = {},
        SprayList = {},
        VoiceList = {}
      }
    end
    if 1 == v.Type then
      table.insert(CommunicationData.HeroCommMap[v.HeroID].SprayList, v)
    elseif 3 == v.Type then
      table.insert(CommunicationData.HeroCommMap[v.HeroID].VoiceList, v)
    end
  end
end
function CommunicationData.CheckCommIsUnlock(CommId)
  if table.Contain(CommunicationData.HeroCommBag, CommunicationData.GetRoulleteIdByCommId(CommId)) then
    return true
  end
  return false
end
function CommunicationData.CheckCommIsEquiped(CommId)
  if table.Contain(CommunicationData.HeroCommEquip, CommunicationData.GetRoulleteIdByCommId(CommId)) then
    return true
  end
  return false
end
function CommunicationData.GetSprayListByHeroId(HeroId)
  local SprayList = {}
  if CommunicationData.HeroCommMap[HeroId] and CommunicationData.HeroCommMap[HeroId].SprayList then
    for i, v in ipairs(CommunicationData.HeroCommMap[HeroId].SprayList) do
      table.insert(SprayList, v)
    end
  end
  if CommunicationData.HeroCommMap[0] and CommunicationData.HeroCommMap[0].SprayList then
    for i, v in ipairs(CommunicationData.HeroCommMap[0].SprayList) do
      table.insert(SprayList, v)
    end
  end
  return SprayList
end
function CommunicationData.GetVoiceListByHeroId(HeroId)
  local VoiceList = {}
  if CommunicationData.HeroCommMap[HeroId] and CommunicationData.HeroCommMap[HeroId].VoiceList then
    for i, v in ipairs(CommunicationData.HeroCommMap[HeroId].VoiceList) do
      table.insert(VoiceList, v)
    end
  end
  if CommunicationData.HeroCommMap[0] and CommunicationData.HeroCommMap[0].VoiceList then
    for i, v in ipairs(CommunicationData.HeroCommMap[0].VoiceList) do
      table.insert(VoiceList, v)
    end
  end
  return VoiceList
end
function CommunicationData.GetRoulleteIdByCommId(CommId)
  local CommunicationList = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  if CommunicationList and CommunicationList[CommId] then
    return CommunicationList[CommId].RouletteID
  end
  return nil
end
function CommunicationData.GetCommIdByRoulleteId(RoulleteId)
  local CommunicationList = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  for k, v in pairs(CommunicationList) do
    if v.RouletteID == RoulleteId then
      return v.ID
    end
  end
  return nil
end
function CommunicationData.GetTypeByCommId(CommId)
  local CommunicationList = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  if CommunicationList and CommunicationList[CommId] then
    return CommunicationList[CommId].Type
  end
  return nil
end
function CommunicationData.GetHeroNameByCommId(CommId)
  local CommunicationList = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  if CommunicationList and CommunicationList[CommId] then
    local HeroId = CommunicationList[CommId].HeroID
    local result, row = GetRowData(DT.DT_CharacterSound, HeroId)
    if result then
      return row.CharName
    end
  end
  return nil
end
function CommunicationData.GetTBCommonicationDataByRouletteId(RouletteID)
  if table.IsEmpty(CommunicationData.RouletteIdToTBCommonicationData) then
    local tbCommonication = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
    if tbCommonication then
      for k, v in pairs(tbCommonication) do
        CommunicationData.RouletteIdToTBCommonicationData[v.RouletteID] = v
      end
    end
  end
  return CommunicationData.RouletteIdToTBCommonicationData[RouletteID]
end
return CommunicationData
