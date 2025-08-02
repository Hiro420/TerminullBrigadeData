local rapidjson = require("rapidjson")
local ClimbTowerData = {
  PassData = {},
  GameMode = 1003,
  WorldId = 38
}

function ClimbTowerData:GetFloor()
  if not ClimbTowerData.Floor then
    ClimbTowerData.Floor = 1
  end
  if 0 == ClimbTowerData.Floor then
    ClimbTowerData.Floor = 1
  end
  return ClimbTowerData.Floor
end

function ClimbTowerData:PassRewardStatus(FloorEnd)
  local FloorsTable = ""
  for i = 1, FloorEnd do
    if 1 == i then
      FloorsTable = "floors=" .. tostring(i)
    else
      FloorsTable = FloorsTable .. "&floors=" .. tostring(i)
    end
  end
  local Path = "activity/climbtower/globalpassrewardstatus?" .. FloorsTable
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      ClimbTowerData.PassRewardStatusTable = JsonTable.globalPassRewardStatusMap
      EventSystem.Invoke(EventDef.ClimbTowerView.OnPassRewardStatusChange)
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
    end
  })
end

function ClimbTowerData:ReceiveGlobalPassReward(Floor, Index)
  local ItemStatus = ClimbTowerData.PassRewardStatusTable[tostring(Floor)].rewardStatusMap[tostring(Index)]
  if 1 ~= ItemStatus then
    return
  end
  local Path = "activity/climbtower/receiveglobalpassreward"
  local JsonParams = {
    floorRewardIndexMap = {}
  }
  JsonParams.floorRewardIndexMap[tostring(Floor)] = {
    rewardIndexes = {Index}
  }
  HttpCommunication.Request(Path, JsonParams, {
    GameInstance,
    function(Target, JsonResponse)
      local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
      ClimbTowerData:PassRewardStatus(#ClimbTowerTable)
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
      local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
      ClimbTowerData:PassRewardStatus(#ClimbTowerTable)
    end
  })
end

function ClimbTowerData:GetFirstPassTeam(FloorStart, FloorEnd)
  local FloorsTable = ""
  for i = FloorStart, FloorEnd do
    if i == FloorStart then
      FloorsTable = "floors=" .. tostring(i)
    else
      FloorsTable = FloorsTable .. "&floors=" .. tostring(i)
    end
  end
  local Path = "activity/climbtower/globalpassteam?" .. FloorsTable
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      ClimbTowerData.PassTeamDataMap = JsonTable.passTeamDataMap
      EventSystem.Invoke(EventDef.ClimbTowerView.OnPassTeamDataChange)
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
    end
  })
end

function ClimbTowerData:GetDailyRewardInfo(SuccessDelegate)
  local Path = "activity/climbtower/dailyrewardinfo"
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      ClimbTowerData.DailyRewardInfo = JsonTable
      if SuccessDelegate then
        SuccessDelegate(JsonTable)
      end
      EventSystem.Invoke(EventDef.ClimbTowerView.OnDailyRewardChange)
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
    end
  })
end

function ClimbTowerData:ReceiveDailyReward()
  local Path = "activity/climbtower/receivedailyreward"
  HttpCommunication.Request(Path, {}, {
    GameInstance,
    function(Target, JsonResponse)
      ClimbTowerData:GetDailyRewardInfo()
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
    end
  })
end

function ClimbTowerData:EquipDailyRewardHero(HeroId, SlotId)
  local Path = "activity/climbtower/equipdailyrewardhero"
  HttpCommunication.Request(Path, {heroID = HeroId, slotID = SlotId}, {
    GameInstance,
    function(Target, JsonResponse)
      ClimbTowerData:GetDailyRewardInfo()
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
    end
  })
end

function ClimbTowerData:UnEquipDailyRewardHero(SlotId)
  local Path = "activity/climbtower/unequipdailyrewardhero"
  HttpCommunication.Request(Path, {slotID = SlotId}, {
    GameInstance,
    function(Target, JsonResponse)
      ClimbTowerData:GetDailyRewardInfo()
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
    end
  })
end

function ClimbTowerData:SetLocalDebuff(Floor, DebuffId, Lv)
  if ClimbTowerData.LocalDebuff == nil then
    ClimbTowerData.LocalDebuff = {}
  end
  if ClimbTowerData.LocalDebuff[Floor] == nil then
    ClimbTowerData.LocalDebuff[Floor] = {}
  end
  local CacheTable = ClimbTowerData.LocalDebuff[Floor]
  if CacheTable[DebuffId] ~= Lv then
    CacheTable[DebuffId] = Lv
    ClimbTowerData.LocalDebuff[Floor] = CacheTable
    EventSystem.Invoke(EventDef.ClimbTowerView.OnDebuffChange)
  end
end

function ClimbTowerData:GetLocalDebuffValue(Floor, DebuffId)
  if ClimbTowerData.LocalDebuff and ClimbTowerData.LocalDebuff[Floor] then
    return ClimbTowerData.LocalDebuff[Floor][DebuffId] or 0
  end
  return 0
end

function ClimbTowerData:GetLocalDebuff(Floor)
  local Path = "activity/climbtower/mydebuffchoices?floor=" .. tostring(Floor)
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if ClimbTowerData.LocalDebuff == nil then
        ClimbTowerData.LocalDebuff = {}
        ClimbTowerData.ServerDebuff = {}
      end
      if 0 == table.count(JsonTable.debuffChoices) then
        if ClimbTowerData.LocalDebuff[Floor - 1] then
          ClimbTowerData.LocalDebuff[Floor] = ClimbTowerData.LocalDebuff[Floor - 1]
        else
          ClimbTowerData.LocalDebuff[Floor] = {}
        end
      else
        ClimbTowerData.LocalDebuff[Floor] = JsonTable.debuffChoices
        ClimbTowerData.ServerDebuff[Floor] = rapidjson.decode(JsonResponse.Content).debuffChoices
      end
      ClimbTowerData.MarkFaultScore = self:GetFaultScoreByFloor(Floor)
      EventSystem.Invoke(EventDef.ClimbTowerView.OnDebuffChange, true)
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
    end
  })
  if ClimbTowerData.LocalDebuff == nil then
    return {}
  end
  if ClimbTowerData.LocalDebuff[Floor] then
    local DebuffChoices = {}
    for key, value in pairs(ClimbTowerData.LocalDebuff[Floor]) do
      DebuffChoices[tostring(key)] = value
    end
    return DebuffChoices
  end
  return {}
end

function ClimbTowerData:SetDebuff(Floor)
  if ClimbTowerData:GetFaultScore() < ClimbTowerData:GetTargetFaultScore() then
    ShowWaveWindow(304003)
    return
  end
  if ClimbTowerData.LocalDebuff[Floor] then
    local DebuffChoices = {}
    for key, value in pairs(ClimbTowerData.LocalDebuff[Floor]) do
      DebuffChoices[tostring(key)] = value
    end
    local GameMode = 1003
    local STable = {}
    local CTable = ClimbTowerData.LocalDebuff[Floor]
    if nil ~= STable and nil ~= CTable then
      for key, value in pairs(CTable) do
        STable[key] = value
      end
    end
    if not ClimbTowerData.ServerDebuff then
      ClimbTowerData.ServerDebuff = {}
    end
    ClimbTowerData.ServerDebuff[Floor] = STable
    HttpCommunication.Request("team/settowerdebuff", {
      debuffChoices = DebuffChoices,
      floor = Floor,
      gameMode = GameMode
    }, {
      GameInstance,
      function(Target, JsonResponse)
        print("\232\174\190\231\189\174\230\136\144\229\138\159")
        EventSystem.Invoke(EventDef.ClimbTowerView.OnDebuffChange)
        ShowWaveWindow(304001)
      end
    }, {
      GameInstance,
      function(Target, JsonResponse)
        print("\232\174\190\231\189\174\229\164\177\232\180\165")
      end
    })
  end
end

function ClimbTowerData:ResettingDebuff()
  ClimbTowerData:GetLocalDebuff(ClimbTowerData:GetFloor())
end

function ClimbTowerData:GetHeteromorphism(Floor)
  local HeteromorphismTable = {}
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  if ClimbTowerTable[Floor] then
    local LobbyAnomaly = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerLobbyAnomaly)
    for index, value in ipairs(ClimbTowerTable[Floor].LobbyAnomalyID) do
      if LobbyAnomaly[value] then
        local SingleHeteromorphism = {}
        SingleHeteromorphism.Name = LobbyAnomaly[value].Content
        SingleHeteromorphism.Icon = LobbyAnomaly[value].Icon
        table.insert(HeteromorphismTable, SingleHeteromorphism)
      end
    end
    for index, value in ipairs(ClimbTowerTable[Floor].BattleAnomalyID) do
      local SingleHeteromorphism = {}
      SingleHeteromorphism.Name = GetLuaInscriptionDesc(value)
      SingleHeteromorphism.Icon = nil
      table.insert(HeteromorphismTable, SingleHeteromorphism)
    end
  end
  return HeteromorphismTable
end

function ClimbTowerData:GameFloorPassData()
  local Path = "playergrowth/gamefloor/gamefloorpassdata?gameMode=" .. tostring(ClimbTowerData.GameMode)
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if JsonTable.floorPassData then
        ClimbTowerData.PassData = JsonTable.floorPassData
      end
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
    end
  })
end

function ClimbTowerData:GetFaultScore()
  if ClimbTowerData.LocalDebuff == nil then
    return nil
  end
  local DebuffTable = ClimbTowerData.LocalDebuff[ClimbTowerData:GetFloor()]
  local ClimbTowerDebuff = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerDebuff)
  local FaultScore = 0
  if nil == DebuffTable then
    return 0
  end
  for DebuffId, Lv in pairs(DebuffTable) do
    if ClimbTowerDebuff[tonumber(DebuffId)] then
      local DebuffValues = ClimbTowerDebuff[tonumber(DebuffId)].DebuffValues
      if DebuffValues[Lv] then
        FaultScore = DebuffValues[Lv] + FaultScore
      end
    end
  end
  return FaultScore
end

function ClimbTowerData:GetFaultScoreByFloor(Floor)
  local DebuffTable = ClimbTowerData.LocalDebuff[Floor]
  local ClimbTowerDebuff = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerDebuff)
  local FaultScore = 0
  if nil == DebuffTable then
    return 0
  end
  for DebuffId, Lv in pairs(DebuffTable) do
    if ClimbTowerDebuff[tonumber(DebuffId)] then
      local DebuffValues = ClimbTowerDebuff[tonumber(DebuffId)].DebuffValues
      if DebuffValues[Lv] then
        FaultScore = DebuffValues[Lv] + FaultScore
      end
    end
  end
  return FaultScore
end

function ClimbTowerData:GetTargetFaultScore()
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  if ClimbTowerTable then
    return ClimbTowerTable[ClimbTowerData:GetFloor()].MinDebuffValue
  end
  return 0
end

function ClimbTowerData:FaultScoreIsChange()
  local STable = ClimbTowerData.ServerDebuff[ClimbTowerData:GetFloor()]
  local CTable = ClimbTowerData.LocalDebuff[ClimbTowerData:GetFloor()]
  if nil == STable and (nil == CTable or 0 == table.count(CTable)) then
    return false
  end
  if nil == STable or nil == CTable then
    return true
  end
  for key, value in pairs(STable) do
    if CTable[key] and CTable[key] ~= value then
      return true
    end
  end
  return false
end

function ClimbTowerData:MeetFaultScore()
  if ClimbTowerData:GetFaultScore() == nil then
    return false
  end
  return ClimbTowerData:GetFaultScore() >= ClimbTowerData:GetTargetFaultScore()
end

return ClimbTowerData
