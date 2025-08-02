local EPlayerInfoEquipedState = {
  Equiped = "Equiped",
  UnEquiped = "UnEquiped",
  Lock = "Lock"
}
_G.EPlayerInfoEquipedState = _G.EPlayerInfoEquipedState or EPlayerInfoEquipedState
local EPlayerInfoMatchType = {Alone = "0", Team = "1"}
_G.EPlayerInfoMatchType = _G.EPlayerInfoMatchType or EPlayerInfoMatchType
local HeroStatisticsData = {
  [1010] = {
    maxDebuffValue = 0,
    maxHelp = 0,
    totalBattleCount = 0,
    totalBattleDuration = "",
    totalCollectionCount = 0,
    totalDoubleBlessCount = 0,
    totalHarm = "",
    totalHelpCount = 0,
    totalKills = "",
    totalSkillSuccCount = "",
    totalWinCount = 0,
    winHardest = 0
  }
}
local HeroStatisticsMetatable = {
  __add = function(t1, t2)
    local result = {}
    for heroId, heroData in pairs(t1) do
      result[heroId] = DeepCopy(heroData)
    end
    for heroId, heroData in pairs(t2) do
      if result[heroId] then
        local existingData = result[heroId]
        for k, v in pairs(heroData) do
          if "winHardest" == k then
            if v > existingData[k] then
              existingData[k] = v
            end
          elseif "maxHelp" == k then
            if v > existingData[k] then
              existingData[k] = v
            end
          elseif "maxDebuffValue" == k then
            if v > existingData[k] then
              existingData[k] = v
            end
          elseif type(v) == "number" and type(existingData[k]) == "number" then
            existingData[k] = existingData[k] + v
          elseif type(v) == "string" and tonumber(v) and tonumber(existingData[k]) then
            existingData[k] = tostring(tonumber(existingData[k]) + tonumber(v))
          end
        end
      else
        result[heroId] = DeepCopy(heroData)
      end
    end
    return result
  end
}
setmetatable(HeroStatisticsData, HeroStatisticsMetatable)
local WeaponStatisticsData = {
  [5000] = {totalBattleCount = 0}
}
local WeaponStatisticsMetatable = {
  __add = function(t1, t2)
    local result = {}
    for weaponId, weaponData in pairs(t1) do
      result[weaponId] = DeepCopy(weaponData)
    end
    for weaponId, weaponData in pairs(t2) do
      if result[weaponId] then
        for k, v in pairs(weaponData) do
          if type(v) == "number" and type(result[weaponId][k]) == "number" then
            result[weaponId][k] = result[weaponId][k] + v
          end
        end
      else
        result[weaponId] = DeepCopy(weaponData)
      end
    end
    return result
  end
}
setmetatable(WeaponStatisticsData, WeaponStatisticsMetatable)
local WorldStatisticsData = {
  [23] = {
    totalWinCount = 0,
    worldMatchStatistics = {
      [EPlayerInfoMatchType.Alone] = {leastWinDuration = "", winHardest = 0},
      [EPlayerInfoMatchType.Team] = {leastWinDuration = "", winHardest = 0}
    }
  }
}
local WorldStatisticsMetatable = {
  __add = function(t1, t2)
    local result = {}
    for worldId, worldData in pairs(t1) do
      result[worldId] = DeepCopy(worldData)
    end
    for worldId, worldData in pairs(t2) do
      if result[worldId] then
        local existingData = result[worldId]
        if type(worldData.totalWinCount) == "number" then
          existingData.totalWinCount = existingData.totalWinCount + worldData.totalWinCount
        end
        if type(worldData.worldMatchStatistics) == "table" then
          for matchType, matchData in pairs(worldData.worldMatchStatistics) do
            if not existingData.worldMatchStatistics[matchType] then
              existingData.worldMatchStatistics[matchType] = DeepCopy(matchData)
            else
              for dataKey, dataValue in pairs(matchData) do
                if "winHardest" == dataKey then
                  if dataValue > existingData.worldMatchStatistics[matchType][dataKey] then
                    existingData.worldMatchStatistics[matchType][dataKey] = dataValue
                  end
                elseif "leastWinDuration" == dataKey then
                  if existingData.worldMatchStatistics[matchType][dataKey] == "" then
                    existingData.worldMatchStatistics[matchType][dataKey] = dataValue
                  elseif tonumber(dataValue) < tonumber(existingData.worldMatchStatistics[matchType][dataKey]) then
                    existingData.worldMatchStatistics[matchType][dataKey] = dataValue
                  end
                elseif type(dataValue) == "number" and "number" == type(existingData.worldMatchStatistics[matchType][dataKey]) then
                  existingData.worldMatchStatistics[matchType][dataKey] = existingData.worldMatchStatistics[matchType][dataKey] + dataValue
                elseif type(dataValue) == "string" and tonumber(dataValue) and existingData.worldMatchStatistics[matchType][dataKey] and tonumber(existingData.worldMatchStatistics[matchType][dataKey]) then
                  existingData.worldMatchStatistics[matchType][dataKey] = tostring(tonumber(existingData.worldMatchStatistics[matchType][dataKey]) + tonumber(dataValue))
                end
              end
            end
          end
        end
      else
        result[worldId] = DeepCopy(worldData)
      end
    end
    return result
  end
}
setmetatable(WorldStatisticsData, WorldStatisticsMetatable)
local BattleStatisticData = {
  leastWinDuration = "",
  maxDebuffValue = 0,
  maxHarm = "",
  maxHelp = 0,
  totalBattleCount = 0,
  totalBattleDuration = "",
  totalCollectionCount = 0,
  totalDoubleBlessCount = 0,
  totalHarm = "",
  totalHelpCount = 0,
  totalKills = "",
  totalWinCount = 0,
  winHardest = 0,
  heroStatistics = {},
  weaponStatistics = {},
  worldStatistics = {}
}
local BattleStatisticMetatable = {
  __add = function(t1, t2)
    local result = {
      heroStatistics = {},
      weaponStatistics = {},
      worldStatistics = {}
    }
    for k, v in pairs(t1) do
      if "heroStatistics" ~= k and "weaponStatistics" ~= k and "worldStatistics" ~= k then
        result[k] = v
      end
    end
    for k, v in pairs(t2) do
      if "winHardest" == k then
        if v > result[k] then
          result[k] = v
        end
      elseif "maxHelp" == k then
        if v > result[k] then
          result[k] = v
        end
      elseif "maxDebuffValue" == k then
        if v > result[k] then
          result[k] = v
        end
      elseif "maxHarm" == k then
        local resultMaxHarm = result[k]
        if "" == resultMaxHarm then
          result[k] = v
        elseif "" ~= v and (tonumber(v) or 0) > (tonumber(resultMaxHarm) or 0) then
          result[k] = v
        end
      elseif "leastWinDuration" == k then
        if "" == result[k] then
          result[k] = v
        elseif tonumber(v) < tonumber(result[k]) then
          result[k] = v
        end
      elseif "heroStatistics" ~= k and "weaponStatistics" ~= k and "worldStatistics" ~= k then
        if type(v) == "number" and type(result[k]) == "number" then
          result[k] = result[k] + v
        elseif type(v) == "string" and tonumber(v) and type(result[k]) == "string" and tonumber(result[k]) then
          result[k] = tostring(tonumber(result[k]) + tonumber(v))
        end
      end
    end
    result.heroStatistics = t1.heroStatistics + (t2.heroStatistics or {})
    result.weaponStatistics = t1.weaponStatistics + (t2.weaponStatistics or {})
    result.worldStatistics = t1.worldStatistics + (t2.worldStatistics or {})
    return result
  end
}
setmetatable(BattleStatisticData, BattleStatisticMetatable)
local PlayerInfoData = {
  BattleStatistic = {},
  CurShowHeroId = -1,
  BannerIdToTBBannerData = {},
  CostItemList = {
    {key = 300002, value = 1}
  },
  PortraitIDs = {},
  PortraitData = {},
  BannerIDs = {},
  RecentSeasonID = {},
  PortraitIdToTBPortraitData = {}
}

function PlayerInfoData:DealWithTable()
  local tbBanner = LuaTableMgr.GetLuaTableByName(TableNames.TBBanner)
  if tbBanner then
    for k, v in pairs(tbBanner) do
      self.BannerIdToTBBannerData[v.bannerID] = v
    end
  end
  local tbPortrait = LuaTableMgr.GetLuaTableByName(TableNames.TBPortrait)
  if tbPortrait then
    for k, v in pairs(tbPortrait) do
      self.PortraitIdToTBPortraitData[v.portraitID] = v
    end
  end
end

function PlayerInfoData:ResetWhenLogin()
  self.BattleStatistic = {}
  self.CurShowHeroId = -1
end

function PlayerInfoData:NewStatisticData(tb)
  if not tb then
    return {}
  end
  local battleStatistic = {}
  setmetatable(battleStatistic, BattleStatisticMetatable)
  for k, v in pairs(tb) do
    if "heroStatistics" ~= k and "weaponStatistics" ~= k and "worldStatistics" ~= k then
      battleStatistic[k] = v
    end
  end
  if tb.heroStatistics then
    battleStatistic.heroStatistics = {}
    for heroId, heroData in pairs(tb.heroStatistics) do
      battleStatistic.heroStatistics[heroId] = DeepCopy(heroData)
    end
    setmetatable(battleStatistic.heroStatistics, HeroStatisticsMetatable)
  end
  if tb.weaponStatistics then
    battleStatistic.weaponStatistics = {}
    for weaponId, weaponData in pairs(tb.weaponStatistics) do
      battleStatistic.weaponStatistics[weaponId] = DeepCopy(weaponData)
    end
    setmetatable(battleStatistic.weaponStatistics, WeaponStatisticsMetatable)
  end
  if tb.worldStatistics then
    battleStatistic.worldStatistics = {}
    for worldId, worldData in pairs(tb.worldStatistics) do
      battleStatistic.worldStatistics[worldId] = DeepCopy(worldData)
    end
    setmetatable(battleStatistic.worldStatistics, WorldStatisticsMetatable)
  end
  return battleStatistic
end

function PlayerInfoData:GetPortraitList()
  local tbPortraitSort = {}
  local tbPortrait = LuaTableMgr.GetLuaTableByName(TableNames.TBPortrait)
  if tbPortrait then
    for k, v in pairs(tbPortrait) do
      table.insert(tbPortraitSort, v)
    end
  end
  table.sort(tbPortraitSort, function(A, B)
    local aUnlock = table.Contain(self.PortraitIDs, A.portraitID)
    local bUnlock = table.Contain(self.PortraitIDs, B.portraitID)
    if aUnlock ~= bUnlock then
      return aUnlock
    end
    return A.portraitID < B.portraitID
  end)
  return tbPortraitSort
end

function PlayerInfoData:GetTBBannerDataByBannerId(BannerId)
  if table.IsEmpty(self.BannerIdToTBBannerData) then
    self:DealWithTable()
  end
  return self.BannerIdToTBBannerData[BannerId]
end

function PlayerInfoData:GetTBPortraitDataByPortraitId(PortraitId)
  if table.IsEmpty(self.PortraitIdToTBPortraitData) then
    self:DealWithTable()
  end
  return self.PortraitIdToTBPortraitData[PortraitId]
end

function PlayerInfoData:GetBannerList()
  local tbBannerSort = {}
  local tbBanner = LuaTableMgr.GetLuaTableByName(TableNames.TBBanner)
  if tbBanner then
    for k, v in pairs(tbBanner) do
      table.insert(tbBannerSort, v)
    end
  end
  table.sort(tbBannerSort, function(A, B)
    local aUnlock = table.Contain(PlayerInfoData.BannerIDs, A.bannerID)
    local bUnlock = table.Contain(PlayerInfoData.BannerIDs, B.bannerID)
    if aUnlock ~= bUnlock then
      return aUnlock
    end
    return A.bannerID < B.bannerID
  end)
  return tbBannerSort
end

function PlayerInfoData:GetMostUsedHeroInfo(RoleID)
  local roleID = RoleID or DataMgr.GetUserId()
  local heroId = -1
  local count = 0
  for k, v in pairs(self.BattleStatistic[roleID].heroStatistics) do
    if -1 == heroId then
      heroId = tonumber(k)
      count = v.totalBattleCount
    elseif count < v.totalBattleCount then
      heroId = tonumber(k)
      count = v.totalBattleCount
    end
  end
  return heroId, count
end

function PlayerInfoData:GetMostUsedWeaponIdByHeroId(HeroId, RoleID)
  local roleID = RoleID or DataMgr.GetUserId()
  local weaponResId = -1
  local count = 0
  if not LogicOutsideWeapon.HeroWeaponList[HeroId] then
    return weaponResId, count
  end
  for iWeapon, vWeapon in pairs(LogicOutsideWeapon.HeroWeaponList[HeroId]) do
    local weaponStatisticsData = self.BattleStatistic[roleID].weaponStatistics[tostring(vWeapon)]
    if weaponStatisticsData then
      if -1 == weaponResId then
        weaponResId = vWeapon
        count = weaponStatisticsData.totalBattleCount
      elseif count < weaponStatisticsData.totalBattleCount then
        weaponResId = vWeapon
        count = weaponStatisticsData.totalBattleCount
      end
    end
  end
  return weaponResId, count
end

return PlayerInfoData
