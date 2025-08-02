BattleData = BattleData or {IsInit = false}

function BattleData.Init()
  if BattleData.IsInit then
    print("BattleData \229\183\178\229\136\157\229\167\139\229\140\150")
    return
  end
  BattleData.IsInit = true
  BattleData.KillAIInfo = {}
  BattleData.CurLevelCleanId = 0
  BattleData.CurTriggerSkillId = 0
  BattleData.CurStartTaskId = 0
  BattleData.CurEndTaskId = 0
  BattleData.CurSpawnAIId = 0
  BattleData.CurMovieName = "None"
  BattleData.BossHealthInfo = {}
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if PC and PC.DamageComponent then
    PC.DamageComponent.OnMakeDamage:Add(GameInstance, BattleData.BindOnMakeDamage)
  end
  if PC and PC.MiscHelper then
    PC.MiscHelper.OnSpawnTaskStart:Add(GameInstance, BattleData.BindOnSpawnTaskStart)
    PC.MiscHelper.OnSpawnTaskFinish:Add(GameInstance, BattleData.BindOnSpawnTaskFinish)
  end
  if PC and PC.SequenceHelper then
    PC.SequenceHelper.OnSequenceFinished:Add(GameInstance, BattleData.BindOnSequenceFinished)
  end
  ListenObjectMessage(nil, "AI.OnAISpawned", GameInstance, BattleData.BindOnAISpawned)
  ListenObjectMessage(nil, "FinishPlayMovie", GameInstance, BattleData.BindOnFinishPlayMovie)
end

function BattleData:BindOnMakeDamage(SourceActor, TargetActor, Params)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not SourceActor then
    return
  end
  local RGMechanism = SourceActor:Cast(UE.ARGMechanism)
  if (not Character or Character ~= SourceActor) and not RGMechanism then
    return
  end
  if not TargetActor then
    return
  end
  local AICharacter = TargetActor:Cast(UE.AAICharacterBase)
  if not AICharacter then
    return
  end
  local IsKill = UE.URGDamageStatics.IsKill(Params)
  local TypeId = TargetActor:GetTypeID()
  if IsKill then
    if BattleData.KillAIInfo[TypeId] then
      BattleData.KillAIInfo[TypeId] = BattleData.KillAIInfo[TypeId] + 1
    else
      BattleData.KillAIInfo[TypeId] = 1
    end
    local PS = Character.PlayerState
    local RadioParams = {}
    if PS then
      table.insert(RadioParams, PS:GetUserNickName())
    end
    LogicRadio.ExecuteRadioConditionByConditionId(LogicCondition.Condition.KillAI, RadioParams)
  end
end

function BattleData:BindOnSpawnTaskStart(TaskId)
  BattleData.CurStartTaskId = TaskId
  LogicRadio.ExecuteRadioConditionByConditionId(LogicCondition.Condition.SpawnTaskStart, {})
end

function BattleData:BindOnSpawnTaskFinish(TaskId)
  BattleData.CurEndTaskId = TaskId
  LogicRadio.ExecuteRadioConditionByConditionId(LogicCondition.Condition.SpawnTaskEnd, {})
end

function BattleData.BindOnAISpawned(AI)
  BattleData.CurSpawnAIId = AI:GetTypeID()
  LogicRadio.ExecuteRadioConditionByConditionId(LogicCondition.Condition.MonsterAppear, {})
end

function BattleData.BindOnFinishPlayMovie(MovieName)
  print("Current finish movie name:", MovieName)
  BattleData.CurMovieName = MovieName
  LogicRadio.ExecuteRadioConditionByConditionId(LogicCondition.Condition.MovieFinish, {})
end

function BattleData.BindOnSequenceFinished(SequenceId)
  LogicRadio.ExecuteRadioConditionByConditionId(LogicCondition.Condition.LevelSequenceFinish, {})
end

function BattleData.SetCurLevelCleanId(Id)
  BattleData.CurLevelCleanId = Id
  LogicRadio.ExecuteRadioConditionByConditionId(LogicCondition.Condition.CleanLevel, {})
end

function BattleData.SetCurTriggerSkillId(SkillId)
  BattleData.CurTriggerSkillId = SkillId
  LogicRadio.ExecuteRadioConditionByConditionId(LogicCondition.Condition.TriggerBossSkill, {})
end

function BattleData.SetBossHealthInfo(Id, HealthPercent)
  if not BattleData.BossHealthInfo then
    BattleData.BossHealthInfo = {}
  end
  BattleData.BossHealthInfo[Id] = HealthPercent
  LogicRadio.ExecuteRadioConditionByConditionId(LogicCondition.Condition.BossHealthChanged, {})
end

function BattleData.Clear()
  BattleData.KillAIInfo = {}
  BattleData.CurLevelCleanId = 0
  BattleData.CurTriggerSkillId = 0
  BattleData.CurStartTaskId = 0
  BattleData.CurEndTaskId = 0
  BattleData.BossHealthInfo = {}
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if PC and PC.DamageComponent then
    PC.DamageComponent.OnMakeDamage:Remove(GameInstance, BattleData.BindOnMakeDamage)
  end
  if PC and PC.MiscHelper then
    PC.MiscHelper.OnSpawnTaskStart:Remove(GameInstance, BattleData.BindOnSpawnTaskStart)
    PC.MiscHelper.OnSpawnTaskFinish:Remove(GameInstance, BattleData.BindOnSpawnTaskFinish)
  end
  if PC and PC.SequenceHelper then
    PC.SequenceHelper.OnSequenceFinished:Remove(GameInstance, BattleData.BindOnSequenceFinished)
  end
  UnListenObjectMessage("AI.OnAISpawned", GameInstance)
  UnListenObjectMessage("FinishPlayMovie", GameInstance)
  BattleData.IsInit = false
end
