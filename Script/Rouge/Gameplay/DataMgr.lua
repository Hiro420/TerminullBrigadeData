local rapidjson = require("rapidjson")
local PandoraData = require("Modules.Pandora.PandoraData")
local LoginData = require("Modules.Login.LoginData")
local ChipData = require("Modules.Chip.ChipData")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local GemData = require("Modules.Gem.GemData")
local MonthCardData = require("Modules.MonthCard.MonthCardData")
local PandoraHandler = require("Protocol.Pandora.PandoraHandler")
local MAX_PLAYER_INFO_LIST_NUM = 120
local PLAYER_INFO_CACHE_DURATION = 5
local M = {
  AccountName = "",
  UserId = "",
  UserIDToChannelUserIdMap = {},
  ChannelUserId = "",
  ChannelUserIdWithPrefix = "",
  ServerOpenTime = 0,
  RoomInfo = {},
  DSInfo = {},
  BasicInfo = {},
  HeroInfo = {
    bNotInited = true,
    equipHero = 1003,
    heros = {
      {Id = 1004, Star = 1},
      {
        Id = 1004,
        skills = {type = 0, level = 0}
      }
    },
    pos = {}
  },
  FetterHeroInfo = {
    [1003] = {
      {pos = 0, heroId = 1003}
    }
  },
  OutsideCurrencyList = {},
  OutsidePackbackList = {},
  CommonTalents = {},
  HeroTalents = {},
  OldLevel = -1,
  OldExp = -1,
  EquippedWeaponList = {
    {
      uuid = "156",
      resourceId = 200202,
      acc = {
        {resourceId = 5006},
        {resourceId = 200203},
        {resourceId = 200204}
      }
    },
    {
      uuid = "111",
      resourceId = 100902,
      acc = {
        {resourceId = 5005},
        {resourceId = 100907}
      }
    }
  },
  AllWeaponList = {},
  AllAccessoryList = {},
  MyTeamInfo = {teamid = "0"},
  TeamMemberNameList = {},
  AvatarInfo = {},
  LobbyDSInfo = {},
  ServerTimeDelta = 0,
  InitClientTime = 0,
  InitServerTime = 0,
  TimeVelocityDifference = 0,
  DistributionChannel = 0,
  TalentsAccumulativeCost = {},
  TeamHeroIdList = {},
  TeamHeroSkinIdList = {},
  TeamMembersInfo = {},
  DefalutSkin = 0,
  PreventFreezeTimestamp = -10000,
  UserIdToPlayerInfo = {},
  GameFloorInfo = {},
  ServerTimeZoneId = "",
  PreSceneStatus = UE.ESceneStatus.None,
  NetBarPrivilegeType = 0,
  EnableChannelInfoLog = false
}
_G.DataMgr = _G.DataMgr or M
DataMgr.RoomStatus = {
  Init = "INIT",
  CountDown = "CountDown",
  Match = "MATCH"
}
local MaxLevel = 80
function DataMgr.InitData(...)
  MonthCardData:DealWithTable()
end
function DataMgr.ClearData()
  DataMgr.CommonTalents = {}
  DataMgr.HeroTalents = {}
  DataMgr.ClearRoomData()
  DataMgr.ClearTeamInfo()
  DataMgr.AccountIcon = nil
  DataMgr.EquippedWeaponList = {}
  DataMgr.AllWeaponList = {}
  DataMgr.AllAccessoryList = {}
  DataMgr.AvatarInfo = {}
  DataMgr.ServerTimeDelta = 0
  DataMgr.InitClientTime = 0
  DataMgr.InitServerTime = 0
  DataMgr.TimeVelocityDifference = 0
  DataMgr.TalentsAccumulativeCost = {}
  DataMgr.GameFloorInfo = {}
  LoginData:ClearData()
  DataMgr.RewardIncreaseCount = 0
  PuzzleData:ClearData()
  GemData:ClearData()
end
function DataMgr.SetServerTimeZone(InServerTimeZone)
  DataMgr.ServerTimeZoneId = InServerTimeZone
end
function DataMgr.GetServerTimeZone(...)
  return DataMgr.ServerTimeZoneId
end
function DataMgr.SetServerTimeDelta(InServerTime)
  DataMgr.ServerTimeDelta = InServerTime - UE.URGStatisticsLibrary.GetTimestamp(true)
  DataMgr.InitClientTime = UE.URGStatisticsLibrary.GetTimestamp(true)
  DataMgr.InitServerTime = InServerTime
end
function GetTimeWithServerDelta()
  return UE.URGStatisticsLibrary.GetTimestamp(true) + DataMgr.ServerTimeDelta + DataMgr.TimeVelocityDifference
end
function DataMgr.SetTimeVelocityDifferenceByServer(CurServerTime)
  local CurClientTime = UE.URGStatisticsLibrary.GetTimestamp(true)
  DataMgr.TimeVelocityDifference = CurServerTime - DataMgr.InitServerTime - (CurClientTime - DataMgr.InitClientTime)
end
function DataMgr.SetTeamMemberNameList(InNameList)
  DataMgr.TeamMemberNameList = InNameList
end
function DataMgr.SetAccountName(AccountName)
  DataMgr.AccountName = AccountName
end
function DataMgr.GetAccountName()
  return DataMgr.AccountName
end
function DataMgr.SetUserId(UserId)
  if not UserId then
    UnLua.LogError("DataMgr.SetUserId - UserId is nil.")
    return
  end
  DataMgr.UserId = UserId
end
function DataMgr.SetNetBarPrivilegeType(PrivilegeType)
  DataMgr.NetBarPrivilegeType = PrivilegeType
end
function DataMgr.SetServerOpenTime(ServerOpenTime)
  if not ServerOpenTime then
    UnLua.LogError("DataMgr.ServerOpenTime - ServerOpenTime is nil.")
    return
  end
  DataMgr.ServerOpenTime = ServerOpenTime
end
function DataMgr.GetServerOpenTime()
  return DataMgr.ServerOpenTime
end
function DataMgr.GetUserId()
  return DataMgr.UserId
end
function DataMgr.GetNetBarPrivilegeType()
  return DataMgr.NetBarPrivilegeType
end
function DataMgr.SetPortraitId(PortraitId)
  DataMgr.GetBasicInfo().portrait = PortraitId
  DataMgr.SetBasicInfo(DataMgr.GetBasicInfo())
end
function DataMgr.SetNickName(NickName)
  DataMgr.GetBasicInfo().nickname = NickName
  DataMgr.SetBasicInfo(DataMgr.GetBasicInfo())
end
function DataMgr.SetUserIDChannelUserId(UserID, ChannelUserId)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo SetUserIDChannelUserId: UserID: %s", tostring(UserID)))
  if nil == UserID or nil == ChannelUserId then
    return
  end
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo SetUserIDChannelUserId: Success"))
  DataMgr.UserIDToChannelUserIdMap[UserID] = ChannelUserId
end
function DataMgr.PrintChannelInfoLog(LogString)
  if DataMgr.EnableChannelInfoLog then
    print(LogString)
  end
end
function DataMgr.SetChannelUserId(ChannelUserId)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo SetChannelUserId ChannelUserId: %s", tostring(ChannelUserId)))
  DataMgr.ChannelUserId = ChannelUserId
  EventSystem.Invoke(EventDef.Login.OnGetUserID)
end
function DataMgr.GetChannelUserId()
  return DataMgr.ChannelUserId
end
function DataMgr.SetChannelUserIdWithPrefix(ChannelUserIdWithPrefix)
  DataMgr.ChannelUserIdWithPrefix = ChannelUserIdWithPrefix
end
function DataMgr.GetChannelUserIdWithPrefix()
  return DataMgr.ChannelUserIdWithPrefix
end
function DataMgr.SetBannerId(BannerId)
  DataMgr.GetBasicInfo().banner = BannerId
  DataMgr.SetBasicInfo(DataMgr.GetBasicInfo())
end
function DataMgr.SetInvisible(IsInvisible)
  DataMgr.GetBasicInfo().invisible = IsInvisible
  DataMgr.SetBasicInfo(DataMgr.GetBasicInfo())
end
function DataMgr.SetCurSelectPastSeasonID(PastSeasonID)
  DataMgr.GetBasicInfo().selectedPastGrowthSeasonID = PastSeasonID
  DataMgr.SetBasicInfo(DataMgr.GetBasicInfo())
end
function DataMgr.SetBasicInfo(Info)
  local bIsTriggerExpChange = false
  if -1 ~= DataMgr.OldLevel and tonumber(Info.level) > DataMgr.OldLevel then
    Logic_Level.OnLevelUpNew(tonumber(Info.level), tonumber(Info.exp))
    PandoraHandler.SendGameEventToPandora("levelup", {
      oldLevel = DataMgr.OldLevel,
      newLevel = tonumber(Info.level),
      oldExp = DataMgr.OldExp,
      newExp = tonumber(Info.exp)
    })
    bIsTriggerExpChange = true
  end
  DataMgr.OldLevel = tonumber(Info.level)
  DataMgr.OldExp = tonumber(Info.exp)
  DataMgr.BasicInfo = Info
  EventSystem.Invoke(EventDef.Lobby.UpdateBasicInfo)
  if bIsTriggerExpChange then
    EventSystem.Invoke(EventDef.Lobby.ExpChanged)
  end
  local JsonTable = rapidjson.decode(Info.appearance)
  for key, value in pairs(JsonTable) do
    DataMgr.AvatarInfo[tonumber(key)] = value
  end
  if DataMgr.BasicInfo.onlineStatus >= 3 and 5 ~= DataMgr.BasicInfo.onlineStatus then
    DataMgr.SetInRoom(true)
  else
    DataMgr.SetInRoom(false)
  end
  local RGAccountSubsystem = UE.URGAccountSubsystem.Get()
  if RGAccountSubsystem then
    RGAccountSubsystem:SetNickName(Info.nickname)
  else
    UnLua.LogError("DataMgr.SetBasicInfo - Get RGAccountSubsystem failed!!!")
  end
  EventSystem.Invoke(EventDef.Lobby.OnBasicInfoUpdated)
end
function DataMgr.SetRewardIncreaseCount(Count)
  DataMgr.RewardIncreaseCount = Count
end
function DataMgr.GetBasicInfo()
  return DataMgr.BasicInfo
end
function DataMgr.SetGameFloorInfo(GameMode, GameFloorData)
  DataMgr.GameFloorInfo[GameMode] = GameFloorData
end
function DataMgr.GetGameFloorInfoByGameMode(GameModeId)
  return DataMgr.GameFloorInfo[GameModeId]
end
function DataMgr.GetFloorByGameModeIndex(WorldId, GameModeId)
  if not GameModeId then
    local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(WorldId))
    if Result then
      if RowInfo.ModeType == UE.EGameModeType.Survivor then
        GameModeId = TableEnums.ENUMGameMode.SURVIVAL
      elseif RowInfo.ModeType == UE.EGameModeType.BossRush then
        GameModeId = TableEnums.ENUMGameMode.BOSSRUSH
      elseif RowInfo.ModeType == UE.EGameModeType.TowerClimb then
        GameModeId = TableEnums.ENUMGameMode.TOWERClIMBING
      else
        GameModeId = GetCurNormalMode()
      end
    else
      GameModeId = GetCurNormalMode()
    end
  end
  local unlock_floor = 0
  local GameFloorInfo = DataMgr.GameFloorInfo[GameModeId]
  if GameFloorInfo then
    unlock_floor = GameFloorInfo[tostring(WorldId)] and GameFloorInfo[tostring(WorldId)] or 0
  end
  local TBGameFloor = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  if TBGameFloor then
    for LevelId, LevelInfo in pairs(TBGameFloor) do
      if LevelInfo.initUnlock and LevelInfo.gameWorldID == WorldId and unlock_floor < LevelInfo.floor then
        unlock_floor = LevelInfo.floor
      end
    end
  end
  return unlock_floor
end
function DataMgr.GetExp()
  local BasicInfo = DataMgr.GetBasicInfo()
  return BasicInfo and BasicInfo.exp or 0
end
function DataMgr.GetRoleLevel()
  local BasicInfo = DataMgr.GetBasicInfo()
  return BasicInfo and tonumber(BasicInfo.level) or 0
end
function DataMgr.SetRoomInfo(RoomInfo)
  DataMgr.RoomInfo = RoomInfo
  DataMgr.SetInRoom(true)
end
function DataMgr.GetRoomInfo()
  return DataMgr.RoomInfo
end
function DataMgr.GetRoomPlayers()
  return DataMgr.RoomInfo.players
end
function DataMgr.ClearRoomData()
  DataMgr.RoomInfo = {}
  DataMgr.SetInRoom(false)
end
function DataMgr.SetInRoom(InRoom)
  DataMgr.InRoom = InRoom
end
function DataMgr.IsInRoom()
  return DataMgr.InRoom
end
function DataMgr.SetTeamInfo(InTeamInfo)
  if UE.URGBlueprintLibrary.CheckWithEditor() and LogicLobby.IsFakeTeamData and InTeamInfo.players and next(InTeamInfo.players) ~= nil then
    local IdDiffValue = 1
    while table.count(InTeamInfo.players) < 3 do
      local TargetPlayerInfo = DeepCopy(InTeamInfo.players[1])
      TargetPlayerInfo.id = tostring(tonumber(InTeamInfo.players[1].id) + IdDiffValue)
      table.insert(InTeamInfo.players, TargetPlayerInfo)
      IdDiffValue = IdDiffValue + 1
    end
  end
  DataMgr.OldMyTeamInfo = DataMgr.MyTeamInfo
  DataMgr.MyTeamInfo = InTeamInfo
  local TeamHeroIdList = {}
  local TeamHeroSkinIdList = {}
  if InTeamInfo.players then
    for index, SinglePlayerInfo in ipairs(InTeamInfo.players) do
      if not table.Contain(TeamHeroIdList, SinglePlayerInfo.pickHeroInfo.id) then
        table.insert(TeamHeroIdList, SinglePlayerInfo.pickHeroInfo.id)
      end
      if not table.Contain(TeamHeroSkinIdList, SinglePlayerInfo.pickHeroInfo.skinId) then
        table.insert(TeamHeroSkinIdList, SinglePlayerInfo.pickHeroInfo.skinId)
      end
      if SinglePlayerInfo.id == DataMgr.UserId then
        DataMgr.DefalutSkin = SinglePlayerInfo.pickHeroInfo.skinId
      end
    end
  end
  DataMgr.SetTeamHeroIdList(TeamHeroIdList)
  DataMgr.SetTeamHeroSkinIdList(TeamHeroSkinIdList)
end
function DataMgr.SetTeamHeroIdList(InTeamHeroIdList)
  DataMgr.TeamHeroIdList = InTeamHeroIdList
end
function DataMgr.GetTeamHeroIdList()
  return DataMgr.TeamHeroIdList
end
function DataMgr.SetTeamHeroSkinIdList(InTeamHeroSkinIdList)
  DataMgr.TeamHeroSkinIdList = InTeamHeroSkinIdList
end
function DataMgr.GetTeamHeroSkinIdList()
  return DataMgr.TeamHeroSkinIdList
end
function DataMgr.GetDefaultSkin()
  return DataMgr.DefalutSkin
end
function DataMgr.SetTeamMembersInfo(InPlayerList)
  DataMgr.TeamMembersInfo = InPlayerList
end
function DataMgr.GetTeamMembersInfo()
  return DataMgr.TeamMembersInfo
end
function DataMgr.GetTeamMemberCount()
  if DataMgr.IsInTeam() then
    return #DataMgr.GetTeamMembersInfo()
  else
    return 1
  end
end
local GetUnlockFloorByModeAndWorld = function(InGameFloorInfo, GameModeId, WorldId)
  local unlock_floor = 0
  local GameFloorInfo = InGameFloorInfo[tostring(GameModeId)]
  if GameFloorInfo then
    unlock_floor = GameFloorInfo[tostring(WorldId)] and GameFloorInfo[tostring(WorldId)] or 0
  end
  local TBGameFloor = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  if TBGameFloor then
    for LevelId, LevelInfo in pairs(TBGameFloor) do
      if LevelInfo.initUnlock and LevelInfo.gameWorldID == WorldId and unlock_floor < LevelInfo.floor then
        unlock_floor = LevelInfo.floor
      end
    end
  end
  return unlock_floor
end
function DataMgr.GetTeamMemberGameFloorByModeAndWorld(RoleId, GameModeId, WorldId)
  local TargetTeamMembersGameFloorInfo = LogicTeam.RolesGameFloorInfo[RoleId]
  if not TargetTeamMembersGameFloorInfo then
    return 0
  end
  return GetUnlockFloorByModeAndWorld(TargetTeamMembersGameFloorInfo, GameModeId, WorldId)
end
function DataMgr.GetTeamInfo()
  return DataMgr.MyTeamInfo
end
function DataMgr.GetOldTeamInfo()
  return DataMgr.OldMyTeamInfo
end
function DataMgr.ClearTeamInfo()
  DataMgr.OldMyTeamInfo = {}
  DataMgr.OldMyTeamInfo.players = {}
  DataMgr.MyTeamInfo = {}
  DataMgr.MyTeamInfo.players = {}
  DataMgr.TeamMembersInfo = {}
end
function DataMgr.IsInTeam()
  return DataMgr.MyTeamInfo.teamid and DataMgr.MyTeamInfo.teamid ~= "0" or false
end
function DataMgr.GetTeamState()
  return DataMgr.MyTeamInfo.state
end
function DataMgr.GetRewardIncreaseCount()
  return DataMgr.RewardIncreaseCount
end
function DataMgr.SetDSInfo(DSInfo)
  DataMgr.DSInfo = DSInfo
  print("DS\230\156\141\229\144\141\229\173\151:" .. DSInfo.name)
end
function DataMgr.GetDSInfo()
  return DataMgr.DSInfo
end
function DataMgr.SetLobbyDSInfo(LobbyDSInfo)
  DataMgr.LobbyDSInfo = LobbyDSInfo
  print("LobbyDS\230\156\141\229\144\141\229\173\151:" .. LobbyDSInfo.name)
end
function DataMgr.GetLobbyDSInfo()
  return DataMgr.LobbyDSInfo
end
function DataMgr.UpdateEquipHero(EquipHeroId)
  local HeroInfo = DeepCopy(DataMgr.GetMyHeroInfo())
  HeroInfo.equipHero = EquipHeroId
  DataMgr.SetMyHeroInfo(HeroInfo)
end
function DataMgr.UpdateHeroInfoSkin(HeroId, SkinId)
  local HeroInfo = DeepCopy(DataMgr.GetMyHeroInfo())
  for i, SingleHeroInfo in ipairs(HeroInfo.heros) do
    if SingleHeroInfo.id == tonumber(HeroId) then
      SingleHeroInfo.skinId = tonumber(SkinId)
      break
    end
  end
  DataMgr.SetMyHeroInfo(HeroInfo)
end
function DataMgr.SetMyHeroInfo(HeroInfo)
  DataMgr.HeroInfo = HeroInfo
end
function DataMgr.GetMyHeroInfo()
  return DataMgr.HeroInfo
end
function DataMgr.GetSkillLevelByType(HeroId, Type)
  local Skills
  for i, SingleHeroInfo in ipairs(DataMgr.HeroInfo.heros) do
    if SingleHeroInfo.id == HeroId then
      Skills = SingleHeroInfo.skills
    end
  end
  if Skills then
    for i, SingleSkillInfo in ipairs(Skills) do
      if Type == SingleSkillInfo.type then
        return SingleSkillInfo.level
      end
    end
  end
  return 1
end
function DataMgr.GetHeroProfyByHeroId(HeroId)
  if not DataMgr.HeroInfo then
    print("DataMgr.GetHeroProfyByHeroId HeroInfo Is Nil")
    return 1
  end
  if not DataMgr.HeroInfo.heros then
    print("DataMgr.GetHeroProfyByHeroId HeroInfo.heros Is Nil")
    return 1
  end
  for i, SingleHeroInfo in ipairs(DataMgr.HeroInfo.heros) do
    if SingleHeroInfo.id == HeroId then
      return SingleHeroInfo.profy and SingleHeroInfo.profy or 1
    end
  end
  return 1
end
function DataMgr.GetHeroLevelByHeroId(HeroId)
  if not DataMgr.HeroInfo then
    print("DataMgr.GetHeroLevelByHeroId HeroInfo Is Nil")
    return 1
  end
  if not DataMgr.HeroInfo.heros then
    print("DataMgr.GetHeroLevelByHeroId HeroInfo.heros Is Nil")
    return 1
  end
  for i, SingleHeroInfo in ipairs(DataMgr.HeroInfo.heros) do
    if SingleHeroInfo.id == HeroId then
      return SingleHeroInfo.star and SingleHeroInfo.star or 1
    end
  end
  return 1
end
function DataMgr.IsOwnHero(HeroId)
  if not DataMgr.HeroInfo then
    print("DataMgr.IsOwnHero HeroInfo Is Nil")
    return false
  end
  if not DataMgr.HeroInfo.heros then
    print("DataMgr.IsOwnHero HeroInfo.heros Is Nil")
    return false
  end
  for i, SingleHeroInfo in ipairs(DataMgr.HeroInfo.heros) do
    if HeroId == SingleHeroInfo.id then
      if DataMgr.IsExpiredHero(HeroId) then
        return false
      end
      return true
    end
  end
  return false
end
function DataMgr.IsExpiredHero(HeroId)
  for i, SingleHeroInfo in ipairs(DataMgr.HeroInfo.heros) do
    if HeroId == SingleHeroInfo.id and SingleHeroInfo.expireAt ~= nil and nil ~= tonumber(SingleHeroInfo.expireAt) and tonumber(SingleHeroInfo.expireAt) > 0 then
      local CurTimeTemp = tonumber(os.time())
      if CurTimeTemp > tonumber(SingleHeroInfo.expireAt) then
        return true
      end
    end
  end
  return false
end
function DataMgr.IsLimitedHeroe(HeroId)
  for i, SingleHeroInfo in ipairs(DataMgr.HeroInfo.heros) do
    if HeroId == SingleHeroInfo.id and SingleHeroInfo.expireAt ~= nil and nil ~= tonumber(SingleHeroInfo.expireAt) and tonumber(SingleHeroInfo.expireAt) > 0 then
      return SingleHeroInfo.expireAt
    end
  end
  return nil
end
function DataMgr.SetOutsideCurrencyList(InCurrencyList)
  for index, value in ipairs(InCurrencyList) do
    local bIsExist = false
    for i, v in ipairs(DataMgr.OutsideCurrencyList) do
      if v.currencyId == value.currencyId then
        v.number = value.number
        v.expireAt = value.expireAt
        bIsExist = true
      end
    end
    if not bIsExist then
      table.insert(DataMgr.OutsideCurrencyList, value)
    end
  end
end
function DataMgr.GetOutsideCurrencyList()
  local List = {}
  for index, value in ipairs(DataMgr.OutsideCurrencyList) do
    if List[value.currencyId] == nil then
      List[value.currencyId] = 0
    end
    List[value.currencyId] = List[value.currencyId] + value.number
  end
  return List
end
function DataMgr.GetOutsideCurrencyNumById(CurrencyId)
  local Sum = 0
  for index, value in ipairs(DataMgr.OutsideCurrencyList) do
    if value.currencyId == CurrencyId then
      Sum = Sum + value.number
    end
  end
  return Sum
end
function DataMgr.GetOutsideCurrencyTableById(CurrencyId)
  local Table = {}
  for index, value in ipairs(DataMgr.OutsideCurrencyList) do
    if value.currencyId == CurrencyId then
      table.insert(Table, value)
    end
  end
  table.sort(Table, function(a, b)
    return a.expireAt < b.expireAt
  end)
  return Table
end
function DataMgr.SetOutsidePackbackList(InPackbackList)
  DataMgr.OutsidePackbackList = InPackbackList
end
function DataMgr.GetPackbackNumById(ResourceId)
  local TargetResourceList = DataMgr.OutsidePackbackList[ResourceId]
  local Sum = 0
  if TargetResourceList then
    for i, SingleResourceList in ipairs(TargetResourceList) do
      Sum = Sum + SingleResourceList.amount
    end
  end
  return Sum
end
function DataMgr.GetPackbackTableById(ResourceId)
  local TargetResourceList = DataMgr.OutsidePackbackList[ResourceId]
  return TargetResourceList
end
function DataMgr.GetPackbackNumByType(ItemType)
  local sum = 0
  for k, v in pairs(DataMgr.OutsidePackbackList) do
    if v.Type == ItemType then
      sum = sum + 1
    end
  end
  return sum
end
function DataMgr.GetPackbackList()
  return DataMgr.OutsidePackbackList
end
function DataMgr.SetFetterHeroInfoById(HeroId, FetterHeroInfo)
  DataMgr.FetterHeroInfo[HeroId] = FetterHeroInfo
end
function DataMgr.GetFetterHeroInfoById(HeroId)
  return DataMgr.FetterHeroInfo[HeroId]
end
function DataMgr.SetCommonTalents(InTalents)
  for i, SingleTalentInfo in ipairs(InTalents) do
    DataMgr.CommonTalents[SingleTalentInfo.groupId] = SingleTalentInfo
  end
end
function DataMgr.SetCommonTalentsAccumulativeCost(InCost)
  if not InCost then
    return
  end
  for i, CostInfo in ipairs(InCost) do
    DataMgr.TalentsAccumulativeCost[CostInfo.rid] = CostInfo
  end
end
function DataMgr.GetCommonTalentsAccumulativeCostById(CostId)
  return DataMgr.TalentsAccumulativeCost[CostId] and DataMgr.TalentsAccumulativeCost[CostId].amount or 0
end
function DataMgr.GetCommonTalentInfos()
  return DataMgr.CommonTalents
end
function DataMgr.GetCommonTalentLevelById(TalentGroupId)
  local CommonTalentInfo = DataMgr.CommonTalents[TalentGroupId]
  return CommonTalentInfo and CommonTalentInfo.level or 0
end
function DataMgr.SetHeroTalents(InHeroId, InTalents)
  local HeroTalents = {}
  for i, SingleTalentInfo in ipairs(InTalents) do
    HeroTalents[SingleTalentInfo.groupId] = SingleTalentInfo
  end
  DataMgr.HeroTalents[InHeroId] = HeroTalents
end
function DataMgr.GetHeroTalentLevelById(HeroId, TalentGroupId)
  local TalentList = DataMgr.HeroTalents[HeroId]
  if TalentList then
    return TalentList[TalentGroupId] and TalentList[TalentGroupId].level or 0
  end
  return 0
end
function DataMgr.GetHeroTalentByHeroId(HeroId)
  return DataMgr.HeroTalents[HeroId]
end
function DataMgr.GetLevelTableRow(Level)
  local LevelTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPlayerLevel)
  if not LevelTable then
    return 0
  end
  local LevelNumber = tonumber(Level)
  if LevelNumber > MaxLevel then
    LevelNumber = MaxLevel
  end
  local NextLv = LevelNumber + 1
  if NextLv > MaxLevel then
    NextLv = MaxLevel
  end
  if not LevelTable[LevelNumber] or not LevelTable[NextLv] then
    return 0
  end
  return LevelTable[NextLv].Exp - LevelTable[LevelNumber].Exp
end
function DataMgr.GetTotalExpToLevel(Level)
  local LevelTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPlayerLevel)
  if not LevelTable then
    return 0
  end
  local LevelNumber = tonumber(Level)
  if LevelNumber > MaxLevel then
    LevelNumber = MaxLevel
  end
  return LevelTable[LevelNumber].Exp
end
function DataMgr.GetNextLv(Lv)
  local NextLv = Lv + 1
  if NextLv > MaxLevel then
    NextLv = MaxLevel
  end
  return NextLv
end
function DataMgr.CalcLevelExp(TotalExp)
  local LevelTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPlayerLevel)
  if not LevelTable then
    return 0
  end
  for i = 1, MaxLevel - 1 do
    if LevelTable[i] and TotalExp >= LevelTable[i].Exp and LevelTable[i + 1] and TotalExp < LevelTable[i + 1].Exp then
      return TotalExp - LevelTable[i].Exp
    end
  end
  return TotalExp - LevelTable[MaxLevel].Exp
end
function DataMgr.CalcUpLevel(Exp)
  local LevelTemp = tonumber(DataMgr.GetRoleLevel())
  if LevelTemp >= MaxLevel then
    return MaxLevel
  end
  local ExpTemp = DataMgr.GetTotalExpToLevel(LevelTemp + 1)
  Exp = Exp + tonumber(DataMgr.GetExp())
  while ExpTemp <= Exp do
    Exp = Exp - ExpTemp
    LevelTemp = LevelTemp + 1
    ExpTemp = DataMgr.GetLevelTableRow(LevelTemp)
  end
  return tonumber(LevelTemp), Exp
end
function DataMgr.GetLocalAccountIcon()
  if DataMgr.AccountIcon then
    return DataMgr.AccountIcon
  end
  DataMgr.AccountIcon = DataMgr.GetRandomAccountIcon()
  if DataMgr.AccountIcon then
    return DataMgr.AccountIcon
  end
  return nil
end
function DataMgr.GetRandomAccountIcon()
  local settings = UE.URGLobbySettings.GetSettings()
  if settings then
    return settings:GetRandomAccountIcon()
  end
  return nil
end
function DataMgr.UpdateEquippedWeaponList(HeroId, WeaponUUId, WeaponResId)
  local EquippedWeaponList = DataMgr.EquippedWeaponList[HeroId]
  EquippedWeaponList = EquippedWeaponList or {}
  if not EquippedWeaponList[1] then
    EquippedWeaponList[1] = {}
  end
  EquippedWeaponList[1].uuid = tostring(WeaponUUId)
  EquippedWeaponList[1].resourceId = tostring(WeaponResId)
  EquippedWeaponList[1].equip = HeroId
  for iAllWeaponList = 1, #DataMgr.AllWeaponList do
    if WeaponUUId == DataMgr.AllWeaponList[iAllWeaponList].uuid then
      EquippedWeaponList[1].skin = DataMgr.AllWeaponList[iAllWeaponList].skin
      break
    end
  end
  DataMgr.SetEquippedWeaponList(HeroId, EquippedWeaponList)
end
function DataMgr.SetEquippedWeaponList(HeroId, InWeaponList)
  DataMgr.EquippedWeaponList[HeroId] = InWeaponList
  if InWeaponList and DataMgr.AllWeaponList then
    local bIsUpdateSucc = false
    for i, v in ipairs(InWeaponList) do
      for iAllWeaponList = 1, #DataMgr.AllWeaponList do
        if v.uuid == DataMgr.AllWeaponList[iAllWeaponList].uuid then
          DataMgr.AllWeaponList[iAllWeaponList] = DeepCopy(v)
          bIsUpdateSucc = true
        end
      end
    end
    if not bIsUpdateSucc and InWeaponList[1] then
      table.insert(DataMgr.AllWeaponList, DeepCopy(InWeaponList[1]))
    end
  end
end
function DataMgr.GetEquippedWeaponList(HeroId)
  return DataMgr.EquippedWeaponList[HeroId]
end
function DataMgr.UpdateWeaponListBySkinId(SkinId, UUId)
  local weaponList = DataMgr.GetWeaponList()
  if weaponList then
    for i, v in ipairs(weaponList) do
      if v.uuid == tostring(UUId) then
        v.skin = tonumber(SkinId)
        break
      end
    end
  end
  DataMgr.SetWeaponList(weaponList)
end
function DataMgr.SetWeaponList(InWeaponList)
  DataMgr.AllWeaponList = InWeaponList
  if InWeaponList and DataMgr.EquippedWeaponList then
    for i, v in ipairs(InWeaponList) do
      local bFind = false
      for kEquipedWeaponList, vEquipedWeaponList in pairs(DataMgr.EquippedWeaponList) do
        for iEquipedWeaponList = 1, #vEquipedWeaponList do
          if v.uuid == vEquipedWeaponList[iEquipedWeaponList].uuid and v.equip == kEquipedWeaponList then
            vEquipedWeaponList[iEquipedWeaponList] = DeepCopy(v)
            bFind = true
            break
          end
        end
      end
      if not bFind then
        if not DataMgr.EquippedWeaponList[v.equip] then
          DataMgr.EquippedWeaponList[v.equip] = {}
        end
        table.insert(DataMgr.EquippedWeaponList[v.equip], DeepCopy(v))
      end
    end
  end
end
function DataMgr.GetWeaponList()
  local AllWeaponList = {
    {
      uuid = "156",
      resourceId = 200202,
      acc = {
        {resourceId = 5006},
        {resourceId = 200203},
        {resourceId = 200204}
      }
    },
    {
      uuid = "157",
      resourceId = 200302,
      acc = {
        {resourceId = 5006},
        {resourceId = 200203}
      }
    },
    {
      uuid = "111",
      resourceId = 100902,
      acc = {
        {resourceId = 5005},
        {resourceId = 100907}
      }
    },
    {
      uuid = "112",
      resourceId = 100802,
      acc = {
        {resourceId = 5005}
      }
    },
    {
      uuid = "113",
      resourceId = 100902,
      acc = {
        {resourceId = 5005}
      }
    },
    {
      uuid = "114",
      resourceId = 100102,
      acc = {
        {resourceId = 5001}
      }
    }
  }
  return DataMgr.AllWeaponList
end
function DataMgr.SetAccessoryList(InAccessoryList)
  DataMgr.AllAccessoryList = InAccessoryList
end
function DataMgr.GetAccessoryList()
  return DataMgr.AllAccessoryList
end
function DataMgr.GetAvatarInfo()
  return DataMgr.AvatarInfo
end
function DataMgr.SetAvatarInfo(InAvatarInfo)
  DataMgr.AvatarInfo = InAvatarInfo
end
function DataMgr.SetDistributionChannel(InDistributionChannel)
  DataMgr.DistributionChannel = InDistributionChannel
end
function DataMgr.GetDistributionChannel()
  return DataMgr.DistributionChannel
end
function DataMgr.Reset()
  DataMgr.OldExp = -1
  DataMgr.OldLevel = -1
end
function DataMgr.SetPreventFreezeTimestamp(Timestamp)
  DataMgr.PreventFreezeTimestamp = Timestamp
end
function DataMgr.ResetFreezeTimestamp()
  DataMgr.PreventFreezeTimestamp = -10000
end
function DataMgr.GetPlayerNickNameById(UserId)
  if DataMgr.UserIdToPlayerInfo[UserId] then
    return DataMgr.UserIdToPlayerInfo[UserId].nickname
  end
  if UserId == DataMgr.GetUserId() then
    return DataMgr.GetBasicInfo().nickname
  end
end
function DataMgr.GetPlayerInvisibleById(UserIdParam, Type)
  local UserId = tonumber(UserIdParam)
  if DataMgr.UserIdToPlayerInfo[UserId] then
    if 0 == Type then
      return DataMgr.UserIdToPlayerInfo[UserId].playerInfo.invisible or 0
    elseif 1 == Type then
      return DataMgr.UserIdToPlayerInfo[UserId].playerInfo.battleHistoryInvisible or 0
    elseif 2 == Type then
      return DataMgr.UserIdToPlayerInfo[UserId].playerInfo.rankInvisible or 0
    else
      print("DataMgr.GetPlayerInvisible Type Error:", Type)
      return 0
    end
  end
  if UserId == DataMgr.GetUserId() then
    DataMgr.GetPlayerInvisible(Type)
  end
  return 0
end
function DataMgr.IsPlayerCurrentPlatform(UserId)
  local ChannelUserIDWithPrefix = DataMgr.GetPlayerChannelUserIdById(UserId, true)
  local PlatformName = UE.URGBlueprintLibrary.GetPlatformName()
  if nil == ChannelUserIDWithPrefix or "" == ChannelUserIDWithPrefix then
    return "Windows" == PlatformName
  end
  local slashIdx = string.find(ChannelUserIDWithPrefix, "-")
  if nil == slashIdx then
    return "Windows" == PlatformName
  end
  local PlatformPrefix = string.sub(ChannelUserIDWithPrefix, 1, slashIdx - 1)
  if "sony" == PlatformPrefix then
    return "PS5" == PlatformName
  elseif "ms" == PlatformPrefix then
    return "XSX" == PlatformName
  end
  return false
end
function DataMgr.GetPlayerChannelUserIdById(UserId, bWithPrefix)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo GetPlayerChannelUserIdById: UserId: %s", tostring(UserId)))
  local UserIDNum = tonumber(UserId)
  if DataMgr.UserIdToPlayerInfo[UserIDNum] then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo GetPlayerChannelUserIdById: UserIdToPlayerInfo: "))
    if DataMgr.UserIdToPlayerInfo[UserIDNum].playerInfo.channelUID then
      DataMgr.PrintChannelInfoLog(string.format("ChannelInfo GetPlayerChannelUserIdById: DataMgr.UserIdToPlayerInfo[UserIDNum].playerInfo.channelUID: %s", tostring(DataMgr.UserIdToPlayerInfo[UserIDNum].playerInfo.channelUID)))
      if bWithPrefix then
        return DataMgr.UserIdToPlayerInfo[UserIDNum].playerInfo.channelUID
      else
        return UE.URGBlueprintLibrary.ConvertToChannelUserID(DataMgr.UserIdToPlayerInfo[UserIDNum].playerInfo.channelUID)
      end
    end
  end
  if UserId == DataMgr.GetUserId() then
    if bWithPrefix then
      return DataMgr.GetChannelUserIdWithPrefix()
    end
    return DataMgr.GetChannelUserId()
  end
  if DataMgr.UserIDToChannelUserIdMap[UserIDNum] then
    if bWithPrefix then
      DataMgr.PrintChannelInfoLog(string.format("ChannelInfo GetPlayerChannelUserIdById: DataMgr.UserIDToChannelUserIdMap[UserIDNum]: %s", tostring(DataMgr.UserIDToChannelUserIdMap[UserIDNum])))
      return DataMgr.UserIDToChannelUserIdMap[UserIDNum]
    else
      DataMgr.PrintChannelInfoLog(string.format("ChannelInfo GetPlayerChannelUserIdById: UE.URGBlueprintLibrary.ConvertToChannelUserID(DataMgr.UserIDToChannelUserIdMap[UserIDNum]): %s", tostring(UE.URGBlueprintLibrary.ConvertToChannelUserID(DataMgr.UserIDToChannelUserIdMap[UserIDNum]))))
      return UE.URGBlueprintLibrary.ConvertToChannelUserID(DataMgr.UserIDToChannelUserIdMap[UserIDNum])
    end
  end
end
function DataMgr.GetChannelUserInfo(UserID, ChannelUID)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo DataMgr.GetChannelUserInfo UserID: %s", tostring(UserID)))
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo DataMgr.GetChannelUserInfo ChannelUID: %s", tostring(ChannelUID)))
  local ChannelInfo = {
    ChannelUserId = nil,
    PlatformName = nil,
    IsSamePlatform = false
  }
  local CurChannelID = DataMgr.GetPlayerChannelUserIdById(UserID, true)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo DataMgr.GetPlayerChannelUserIdById CurChannelID: %s", tostring(CurChannelID)))
  if (not CurChannelID or string.len(CurChannelID) <= 0) and ChannelUID then
    CurChannelID = ChannelUID
  end
  if not CurChannelID or string.len(CurChannelID) <= 0 then
    ChannelInfo.PlatformName = "Windows"
  else
    ChannelInfo.ChannelUserId = UE.URGBlueprintLibrary.ConvertToChannelUserID(CurChannelID)
    if string.find(CurChannelID, "sony-") then
      ChannelInfo.PlatformName = "PS5"
    elseif string.find(CurChannelID, "ms-") then
      ChannelInfo.PlatformName = "XSX"
    end
  end
  local platformName = UE.URGBlueprintLibrary.GetPlatformName()
  ChannelInfo.IsSamePlatform = platformName == ChannelInfo.PlatformName
  return ChannelInfo
end
function DataMgr.CanChannelIDShow(ChannelInfo)
  local PlatformName = UE.URGBlueprintLibrary.GetPlatformName()
  if "PS5" ~= PlatformName and "XSX" ~= PlatformName then
    return false
  end
  if not (ChannelInfo and ChannelInfo.ChannelUserId) or not ChannelInfo.IsSamePlatform then
    return false
  end
  return true
end
function DataMgr.CanChannelIconShow(ChannelInfo)
  local PlatformName = UE.URGBlueprintLibrary.GetPlatformName()
  if "PS5" ~= PlatformName and "XSX" ~= PlatformName then
    return false
  end
  return true
end
function DataMgr.ShowPlatformProfile(UserID, ChannelUID)
  local ChannelInfo = DataMgr.GetChannelUserInfo(UserID, ChannelUID)
  local CurChannelID = ChannelInfo.ChannelUserId
  if (not CurChannelID or string.len(CurChannelID) <= 0) and ChannelUID then
    CurChannelID = ChannelUID
  end
  if ChannelInfo.IsSamePlatform and CurChannelID then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
    if UserOnlineSubsystem then
      if UserOnlineSubsystem:CheckRequestLoginStatus() ~= true then
        print("LoginHandler.UserOnlineSubsystem - CheckRequestLoginStatus Failed")
        return
      end
      UserOnlineSubsystem:ShowPlayerProfile(CurChannelID)
    else
      print("UserOnlineSubsystem is nil")
    end
  end
end
function DataMgr.GetOrQueryPlayerInfo(UserIdList, bForceQuery, Callback, FailedCallback, CacheDuration, bFromUpdateConsoleIcon, ...)
  local queryUserIdList = {}
  local playerInfoList = {}
  local UserIdCache = {}
  local cacheDurationTemp = CacheDuration or PLAYER_INFO_CACHE_DURATION
  for i = #UserIdList, 1, -1 do
    local v = tonumber(UserIdList[i])
    if not ((not DataMgr.UserIdToPlayerInfo[v] or not (cacheDurationTemp < os.time() - DataMgr.UserIdToPlayerInfo[v].timeStamp)) and DataMgr.UserIdToPlayerInfo[v]) or bForceQuery then
      if DataMgr.UserIdToPlayerInfo[v] and cacheDurationTemp < os.time() - DataMgr.UserIdToPlayerInfo[v].timeStamp then
        print("GetOrQueryPlayerInfo Reson Timeout", v, os.time())
      end
      if not DataMgr.UserIdToPlayerInfo[v] then
        print("GetOrQueryPlayerInfo Reson DataMgr.UserIdToPlayerInfo[v] is nil", v)
      end
      if bForceQuery then
        print("GetOrQueryPlayerInfo Reson ForceQuery")
      end
      if not UserIdCache[v] then
        table.insert(queryUserIdList, v)
        UserIdCache[v] = true
      else
        print("GetOrQueryPlayerInfo Reson Repeat", v)
      end
    elseif #queryUserIdList <= 0 then
      table.insert(playerInfoList, DataMgr.UserIdToPlayerInfo[v])
    end
  end
  if #queryUserIdList > 0 then
    local params = {
      ...
    }
    playerInfoList = {}
    HttpCommunication.Request("playerservice/roles", {idList = queryUserIdList}, {
      GameInstance,
      function(Target, JsonResponse)
        local Response = rapidjson.decode(JsonResponse.Content)
        for i, v in ipairs(Response.players) do
          DataMgr.PrintChannelInfoLog(string.format("ChannelInfo UserIdToPlayerInfo Add: %s", tostring(v.roleid)))
          DataMgr.UserIdToPlayerInfo[tonumber(v.roleid)] = {
            playerInfo = v,
            nickname = v.nickname,
            timeStamp = os.time()
          }
          DataMgr.SetUserIDChannelUserId(tonumber(v.roleid), v.channelUID)
          if v.roleid == DataMgr.GetUserId() and not bFromUpdateConsoleIcon then
            DataMgr.SetBasicInfo(v)
          end
        end
        if Callback then
          for i = #UserIdList, 1, -1 do
            local v = tonumber(UserIdList[i])
            table.insert(playerInfoList, DataMgr.UserIdToPlayerInfo[v])
          end
          Callback(playerInfoList)
        end
        EventSystem.Invoke(EventDef.PlayerInfo.QueryPlayerInfoSucc, params)
        local userIdTb = {}
        for k, v in pairs(DataMgr.UserIdToPlayerInfo) do
          if DataMgr.UserIdToPlayerInfo[k] and os.time() - DataMgr.UserIdToPlayerInfo[k].timeStamp > cacheDurationTemp then
            DataMgr.UserIdToPlayerInfo[k] = nil
          else
            table.insert(userIdTb, k)
          end
        end
        if #userIdTb > MAX_PLAYER_INFO_LIST_NUM then
          local needReleaseNum = #userIdTb - MAX_PLAYER_INFO_LIST_NUM
          local result = DataMgr.CheckOutEarliestInfo(userIdTb, needReleaseNum)
          for i, v in ipairs(result) do
            if DataMgr.UserIdToPlayerInfo[v] then
              DataMgr.UserIdToPlayerInfo[v] = nil
            end
          end
        end
      end
    }, {
      GameInstance,
      function(ErrorMsg)
        if FailedCallback then
          FailedCallback(ErrorMsg)
        end
      end
    })
    return false, nil
  else
    if Callback then
      Callback(playerInfoList)
    end
    return true, playerInfoList
  end
end
function DataMgr.CheckOutEarliestInfo(userIdTb, k)
  local partition = function(left, right)
    local pivot = DataMgr.UserIdToPlayerInfo[userIdTb[right]].timeStamp
    local i = left - 1
    for j = left, right - 1 do
      if pivot >= DataMgr.UserIdToPlayerInfo[userIdTb[j]].timeStamp then
        i = i + 1
        userIdTb[i], userIdTb[j] = userIdTb[j], userIdTb[i]
      end
    end
    userIdTb[i + 1], userIdTb[right] = userIdTb[right], userIdTb[i + 1]
    return i + 1
  end
  local function quickSelect(left, right, k)
    if left == right then
      return
    end
    local pivotIndex = partition(left, right)
    local count = pivotIndex - left + 1
    if count == k then
      return
    elseif k < count then
      quickSelect(left, pivotIndex - 1, k)
    else
      quickSelect(pivotIndex + 1, right, k - count)
    end
  end
  quickSelect(1, #userIdTb, k)
  local result = {}
  for i = 1, k do
    table.insert(result, userIdTb[i])
  end
  return result
end
function DataMgr.ClearPlayerInfoData()
  DataMgr.UserIdToPlayerInfo = {}
end
function DataMgr.GetShowWeaponId(HeroId)
  local WeaponId = -1
  if DataMgr.GetEquippedWeaponList(HeroId) ~= nil and DataMgr.GetEquippedWeaponList(HeroId)[1] then
    WeaponId = DataMgr.GetEquippedWeaponList(HeroId)[1].resourceId
  end
  local TBHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if TBHeroMonster[HeroId] then
    WeaponId = TBHeroMonster[HeroId].WeaponID
  end
  local TBWeapon = LuaTableMgr.GetLuaTableByName(TableNames.TBWeapon)
  if TBWeapon[WeaponId] then
    return TBWeapon[WeaponId].SkinID
  end
end
function DataMgr.GetRouletteSlotsByHeroId(HeroId)
  if not DataMgr.HeroInfo then
    print("DataMgr.GetRouletteSlotsByHeroId HeroInfo Is Nil")
    return {
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0
    }
  end
  if not DataMgr.HeroInfo.heros then
    print("DataMgr.GetRouletteSlotsByHeroId HeroInfo.heros Is Nil")
    return {
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0
    }
  end
  for i, SingleHeroInfo in ipairs(DataMgr.HeroInfo.heros) do
    if SingleHeroInfo.id == HeroId then
      return SingleHeroInfo.rouletteSlots
    end
  end
  return {
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  }
end
function DataMgr.GetPreSceneStatus()
  return DataMgr.PreSceneStatus
end
function DataMgr.SetPreSceneStatus(PreSceneStatusParam)
  DataMgr.PreSceneStatus = PreSceneStatusParam
end
function DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoLst)
  local PlayerInfoList = {}
  for i, SinglePlayerCacheInfo in ipairs(PlayerCacheInfoLst) do
    table.insert(PlayerInfoList, SinglePlayerCacheInfo.playerInfo)
  end
  return PlayerInfoList
end
function DataMgr.SetPlayerInvisible(Type, Invisible)
  HttpCommunication.Request("playerservice/invisible", {invisible = Invisible, type = Type}, {
    GameInstance,
    function()
      print("RequestChangeInvisibleToServer Success!")
      DataMgr.GetOrQueryPlayerInfo({
        DataMgr.GetUserId()
      }, true)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function DataMgr.GetPlayerInvisible(Type)
  print("DataMgr.GetPlayerInvisible Type:", Type)
  if 0 == Type then
    return DataMgr.BasicInfo.invisible or 0
  elseif 1 == Type then
    return DataMgr.BasicInfo.battleHistoryInvisible or 0
  elseif 2 == Type then
    return DataMgr.BasicInfo.rankInvisible or 0
  else
    print("DataMgr.GetPlayerInvisible Type Error:", Type)
    return 0
  end
end
