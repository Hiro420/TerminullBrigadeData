LogicCondition = LogicCondition or {
  IsInit = false,
  Condition = {
    KillAI = 1,
    ReachSomewhere = 2,
    CleanLevel = 3,
    TriggerBossSkill = 4,
    SpawnTaskStart = 5,
    SpawnTaskEnd = 6,
    MonsterAppear = 7,
    TriggerSpecialDislog = 8,
    LevelSequenceFinish = 9,
    MovieFinish = 10,
    BossHealthChanged = 11
  }
}

function LogicCondition.Init()
  if LogicCondition.IsInit then
    print("LogicCondition \229\183\178\229\136\157\229\167\139\229\140\150")
    return
  end
  LogicCondition.IsInit = true
  LogicCondition.AllConditionInfos = {}
  LogicCondition.InitConditionTable()
end

function LogicCondition.InitConditionTable()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local AllConditions = DTSubsystem:GetAllConditions(nil)
  for i, SingleCondition in iterator(AllConditions) do
    local TempTable = {FuncName = ""}
    TempTable.FuncName = SingleCondition.FuncName
    LogicCondition.AllConditionInfos[SingleCondition.ID] = TempTable
  end
end

function LogicCondition.ExecuteConditionFunction(Id, Params, Count)
  local TempParam = {}
  for index, SingleParam in ipairs(Params) do
    table.insert(TempParam, SingleParam)
  end
  local ConditionInfo = LogicCondition.AllConditionInfos[Id]
  if ConditionInfo then
    local Function = LogicCondition[ConditionInfo.FuncName]
    if Function then
      table.insert(TempParam, Count)
      return Function(table.unpack(TempParam))
    else
      print("\230\178\161\230\156\137\230\137\190\229\136\176\230\173\164\230\150\185\230\179\149" .. ConditionInfo.FuncName .. ", \230\157\161\228\187\182id\228\184\186", Id, "\232\175\183\230\163\128\230\159\165DT_Condition\232\161\168!!!")
      return true
    end
  else
    print("\230\178\161\230\156\137\230\173\164\230\157\161\228\187\182" .. Id .. ",\232\175\183\230\163\128\230\159\165DT_Condition\232\161\168!!!")
  end
  return false
end

function LogicCondition.KillAI(AIId, AINum, Count)
  if BattleData.KillAIInfo[tonumber(AIId)] and BattleData.KillAIInfo[tonumber(AIId)] >= tonumber(AINum) + tonumber(AINum) * Count then
    return true
  end
  return false
end

function LogicCondition.LevelClean(LevelId)
  if tonumber(LevelId) == BattleData.CurLevelCleanId then
    return true
  end
  return false
end

function LogicCondition.TriggerSkill(SkillId)
  if SkillId == BattleData.CurTriggerSkillId then
    return true
  end
  return false
end

function LogicCondition.SpawnTaskStart(TaskId)
  return TaskId == BattleData.CurStartTaskId
end

function LogicCondition.SpawnTaskEnd(TaskId)
  return TaskId == BattleData.CurEndTaskId
end

function LogicCondition.MonsterAppear(AIId)
  return tonumber(AIId) == BattleData.CurSpawnAIId
end

function LogicCondition.TriggerSpecialDialog(LevelId, AHeroId, BHeroId, CHeroId, DHeroId)
  local HeroIdList = {}
  table.insert(HeroIdList, tonumber(AHeroId))
  table.insert(HeroIdList, tonumber(BHeroId))
  table.insert(HeroIdList, tonumber(CHeroId))
  table.insert(HeroIdList, tonumber(DHeroId))
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGGameLevelSystem:StaticClass())
  if not GameLevelSystem then
    return false
  end
  local CurLevelId = GameLevelSystem:GetLevelId()
  if CurLevelId ~= tonumber(LevelId) then
    print("not CurrentLevel", CurLevelId)
    return false
  end
  local RoomPlayerHeroIds = {}
  local MyHeroId = 0
  if 3 == UE.URGBlueprintLibrary.RGGetWorldType(GameInstance) then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    if Character then
      MyHeroId = Character:GetTypeID()
    end
    table.insert(RoomPlayerHeroIds, MyHeroId)
  else
    local RoomPlayerInfos = DataMgr.GetRoomPlayers()
    for i, SingleRoomPlayerInfo in ipairs(RoomPlayerInfos) do
      table.insert(RoomPlayerHeroIds, SingleRoomPlayerInfo.hero.id)
    end
    MyHeroId = DataMgr.GetMyHeroInfo().equipHero
  end
  if not table.Contain(HeroIdList, MyHeroId) then
    return false
  end
  for index, SingleHeroId in ipairs(HeroIdList) do
    if not table.Contain(RoomPlayerHeroIds, SingleHeroId) and 0 ~= SingleHeroId then
      print("not contain heroid", SingleHeroId)
      return false
    end
  end
  return true
end

function LogicCondition.PlayLevelSequenceFinish(AnimId)
  return true
end

function LogicCondition.PlayMovieFinish(MovieName)
  return MovieName == BattleData.CurMovieName
end

function LogicCondition.BossHealthChanged(Id, HealthPercent)
  local CurBossHealthPercent = BattleData.BossHealthInfo[tonumber(Id)]
  if not CurBossHealthPercent then
    return false
  end
  return CurBossHealthPercent <= tonumber(HealthPercent)
end
