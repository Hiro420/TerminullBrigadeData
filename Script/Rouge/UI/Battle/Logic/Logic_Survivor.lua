LogicSurvivor = LogicSurvivor or {IsInit = false}
function LogicSurvivor.Init()
  LogicSurvivor.UIWidget = nil
  LogicSurvivor.UIWidgetPath = "/Game/Rouge/UI/Survivor/WBP_SurvivorProgressBar.WBP_SurvivorProgressBar_C"
  if not LogicSurvivor.IsInit then
    ListenObjectMessage(nil, GMP.MSG_LevelM_SpawnWave_Start, GameInstance, LogicSurvivor.OnSpawnWaveStart)
    LogicSurvivor.IsInit = true
  end
  if UE.URGLevelLibrary.IsSurvivorMode() then
    local GS = UE.UGameplayStatics.GetGameState(GameInstance)
    if GS then
      local SurvivorSpawnManager = GS:GetComponentByClass(UE.URGSurvivorSpawnManager:StaticClass())
      if SurvivorSpawnManager and SurvivorSpawnManager.WaveInfo then
        LogicSurvivor.ShowProgressBarByRule(SurvivorSpawnManager.WaveInfo.CurrentWave + 1, SurvivorSpawnManager.WaveInfo.RuleID)
      end
    end
  end
end
function LogicSurvivor.OnSpawnWaveStart(WaveIndex, SurvivorSpawnStage)
  local WaveIndex = WaveIndex + 1
  local RuleID = SurvivorSpawnStage.RuleID
  LogicSurvivor.ShowProgressBarByRule(WaveIndex, RuleID)
end
function LogicSurvivor.ShowProgressBarByRule(WaveIndex, RuleID)
  if LogicSurvivor.CanShowProgressBar(WaveIndex, RuleID) then
    LogicSurvivor.ChangeSurWidgetVis(WaveIndex, RuleID)
  else
    LogicSurvivor.ChangeInVis()
  end
end
function LogicSurvivor.CanShowProgressBar(WaveIndex, RuleID)
  if not WaveIndex then
    return false
  end
  if not RuleID then
    return false
  end
  local result, row = GetRowData(DT.DT_SurvivorSpawnRule, RuleID)
  if not result then
    return false
  end
  if not row.WaveIds then
    return false
  end
  if WaveIndex > #row.WaveIds:ToTable() then
    return false
  end
  local WaveId = row.WaveIds:ToTable()[WaveIndex]
  local resultWave, rowWave = GetRowData(DT.DT_SurvivorSpawnWave, WaveId)
  if not resultWave then
    return false
  end
  return rowWave.ShowProgressBar
end
function LogicSurvivor.GetWaveIds(RuleID)
  local result, row = GetRowData(DT.DT_SurvivorSpawnRule, RuleID)
  if not result then
    return {}
  end
  if not row.WaveIds then
    return {}
  end
  return row.WaveIds:ToTable()
end
function LogicSurvivor.GetTotalWave(RuleID)
  local result, row = GetRowData(DT.DT_SurvivorSpawnRule, RuleID)
  if not result then
    return 20
  end
  return row.TotalWaveForSur
end
function LogicSurvivor.GetWaveTypeByIndex(RuleID, WaveIndex)
  local result, row = GetRowData(DT.DT_SurvivorSpawnRule, RuleID)
  if not result then
    return UE.ESurvivorWaveType.Default
  end
  if not row.WaveIds then
    return UE.ESurvivorWaveType.Default
  end
  if WaveIndex > #row.WaveIds:ToTable() then
    return UE.ESurvivorWaveType.Default
  end
  local WaveId = row.WaveIds:ToTable()[WaveIndex]
  local resultWave, rowWave = GetRowData(DT.DT_SurvivorSpawnWave, WaveId)
  if not resultWave then
    return UE.ESurvivorWaveType.Default
  end
  return rowWave.WaveType
end
function LogicSurvivor.ChangeInVis()
  if LogicSurvivor.UIWidget and LogicSurvivor.UIWidget:IsValid() then
    LogicSurvivor.UIWidget:HideBar()
  end
end
function LogicSurvivor.ChangeSurWidgetVis(WaveIndex, RuleID)
  local WidgetClassObj = UE.UClass.Load(LogicSurvivor.UIWidgetPath)
  if not WidgetClassObj then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  LogicSurvivor.RuleID = RuleID
  LogicSurvivor.WaveIndex = WaveIndex
  if RGUIMgr:IsShown(UIConfig.WBP_SurvivorProgressBar_C.UIName) then
    LogicSurvivor.UIWidget = RGUIMgr:GetUI(UIConfig.WBP_SurvivorProgressBar_C.UIName)
    LogicSurvivor.UIWidget:ShowBar(WaveIndex, RuleID)
    return
  end
  UIManager:OpenUI(WidgetClassObj, false, UE.EUILayer.EUILayer_Low)
  LogicSurvivor.UIWidget = UIManager:K2_GetUI(WidgetClassObj)
  if not LogicSurvivor.UIWidget or not LogicSurvivor.UIWidget:IsValid() then
    print("LogicSurvivor UIWidget is nil")
    return
  end
  LogicSurvivor.UIWidget:ShowBar(WaveIndex, RuleID)
end
function LogicSurvivor.IsSurvivalMode()
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local WorldId = LevelSubSystem:GetGameMode()
  local ResultWorldMode, RowWorldMode = GetRowData(DT.DT_GameMode, tostring(WorldId))
  local IsSurvival = false
  if ResultWorldMode then
    IsSurvival = RowWorldMode.ModeType == UE.EGameModeType.Survivor
  end
  return IsSurvival
end
function LogicSurvivor.Clear()
  UnListenObjectMessage(GMP.MSG_LevelM_SpawnWave_Start)
  LogicSurvivor.UIWidget = nil
  LogicSurvivor.IsInit = false
end
