LogicBattleMode = LogicBattleMode or {
  BattleModeStage = {Assembly = 1, Challenge = 2}
}
local HappyJumpBattleModeId = 1002

function LogicBattleMode:Init()
  LogicBattleMode.UIWidget = nil
  if UE.URGGameplayStatics.GetStartedUpBattleMode(UE.RGUtil.GetWorld()) then
    LogicBattleMode.BindOnBattleStartUp(UE.URGGameplayStatics.GetStartedUpBattleMode(UE.RGUtil.GetWorld()))
  end
  ListenObjectMessage(nil, GMP.MSG_World_BattleMode_Startup, GameInstance, LogicBattleMode.BindOnBattleStartUp)
  ListenObjectMessage(nil, GMP.MSG_World_BattleMode_Shutdown, GameInstance, LogicBattleMode.BindOnBattleShutdown)
end

function LogicBattleMode:InitWidgetBindEvent()
  if not self.UIWidget then
    return
  end
end

function LogicBattleMode.Clear()
  if LogicBattleMode.BattleMode then
    LogicBattleMode.BattleMode.OnFinished:Remove(GameInstance, LogicBattleMode.BindOnFinished)
    LogicBattleMode.BattleMode.OnFailed:Remove(GameInstance, LogicBattleMode.BindOnFailed)
    if LogicBattleMode.BattleMode.StageArray:IsValidIndex(LogicBattleMode.BattleModeStage.Assembly) then
      local AssemblyStage = LogicBattleMode.BattleMode.StageArray:Get(LogicBattleMode.BattleModeStage.Assembly)
      AssemblyStage.OnBeginStage:Remove(GameInstance, LogicBattleMode.BindOnAssemblyStageBegin)
      AssemblyStage.OnEndStage:Remove(GameInstance, LogicBattleMode.BindOnAssemblyStageEnd)
    end
    if LogicBattleMode.BattleMode.StageArray:IsValidIndex(LogicBattleMode.BattleModeStage.Challenge) then
      local ChallengeStage = LogicBattleMode.BattleMode.StageArray:Get(LogicBattleMode.BattleModeStage.Challenge)
      ChallengeStage.OnBeginStage:Remove(GameInstance, LogicBattleMode.BindOnChallengeStageBegin)
      ChallengeStage.OnEndStage:Remove(GameInstance, LogicBattleMode.BindOnChallengeStageEnd)
    end
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    if LogicBattleMode.BattleModeConfig then
      local BattleModeWidgetName = LogicBattleMode.BattleModeConfig.WidgetClassName
      local Occupancy = UIManager:GetUIByName(BattleModeWidgetName)
      if Occupancy then
        Occupancy:OnDeInit()
      end
      UIManager:K2_CloseUIByName(BattleModeWidgetName)
    end
    LogicBattleMode.BattleMode = nil
  end
  UnListenObjectMessage("World.BattleMode.Startup")
end

function LogicBattleMode.CreateWidget()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    if LogicBattleMode.BattleModeConfig == nil then
      return
    end
    local BattleModeWidgetName = LogicBattleMode.BattleModeConfig.WidgetClassName
    UIManager:OpenUIByName(BattleModeWidgetName)
    LogicBattleMode.UIWidget = UIManager:GetUIByName(BattleModeWidgetName)
    if LogicBattleMode.UIWidget then
      LogicBattleMode.UIWidget:OnInit(LogicBattleMode.BattleMode:GetBattleModeId())
      LogicBattleMode:InitWidgetBindEvent()
    end
  end
end

function LogicBattleMode.GetUIWidget()
  return LogicBattleMode.UIWidget
end

function LogicBattleMode.BindOnBattleStartUp(BattleMode)
  if not BattleMode then
    return
  end
  print("[LJS] : OnBattleStartUp", BattleMode:GetBattleModeId())
  LogicBattleMode.BattleMode = BattleMode
  local Resul, RowInfo = GetRowData(DT.DT_BattleMode, BattleMode:GetBattleModeId())
  if not Resul then
    print("ERROE~ERROE~ERROR", BattleMode:GetBattleModeId(), "Not Find In DT_BattleMode")
  end
  LogicBattleMode.BattleModeConfig = RowInfo
  LogicBattleMode.CreateWidget()
  if BattleMode then
    BattleMode.OnFinished:Add(GameInstance, LogicBattleMode.BindOnFinished)
    BattleMode.OnFailed:Add(GameInstance, LogicBattleMode.BindOnFailed)
    if BattleMode.StageArray:IsValidIndex(LogicBattleMode.BattleModeStage.Assembly) then
      local AssemblyStage = BattleMode.StageArray:Get(LogicBattleMode.BattleModeStage.Assembly)
      AssemblyStage.OnBeginStage:Add(GameInstance, LogicBattleMode.BindOnAssemblyStageBegin)
      AssemblyStage.OnEndStage:Add(GameInstance, LogicBattleMode.BindOnAssemblyStageEnd)
      if 0 == BattleMode.CurrentStageIndex then
        LogicBattleMode.BindOnAssemblyStageBegin()
      end
    end
    if BattleMode.StageArray:IsValidIndex(LogicBattleMode.BattleModeStage.Challenge) then
      local ChallengeStage = BattleMode.StageArray:Get(LogicBattleMode.BattleModeStage.Challenge)
      ChallengeStage.OnBeginStage:Add(GameInstance, LogicBattleMode.BindOnChallengeStageBegin)
      ChallengeStage.OnEndStage:Add(GameInstance, LogicBattleMode.BindOnChallengeStageEnd)
    end
  end
end

function LogicBattleMode.BindOnBattleShutdown(BattleMode)
  if not BattleMode or LogicBattleMode.BattleMode == nil then
    return
  end
  LogicBattleMode.BattleMode = nil
  local HUDActor = LogicHUD.GetHUDActor()
  if not HUDActor then
    return
  end
  local WidgetLeftCom = HUDActor.RGWidgetLeft
  if not WidgetLeftCom then
    return
  end
  UpdateVisibility(WidgetLeftCom.WBP_HUDInfo, true)
  UpdateVisibility(WidgetLeftCom.WBP_BattleMode_EnergyBar, false)
end

function LogicBattleMode:BindOnAssemblyStageBegin()
  if LogicBattleMode.UIWidget then
    LogicBattleMode.UIWidget:BeginAssembly()
    local Result, BattleModeTableRow = GetRowData(DT.DT_BattleMode, LogicBattleMode.BattleMode:GetBattleModeId())
    if Result and BattleModeTableRow.bShowRuleTip == false then
      return
    end
    if UE.URGLevelLibrary.IsAllPlayedMiniGame() then
      return
    end
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
    if UIManager then
      UIManager:OpenUIByName("WBP_BattleMode_RuleTip_C")
      local RuleTip = UIManager:GetUIByName("WBP_BattleMode_RuleTip_C")
      if nil ~= RuleTip then
        RuleTip:DoOpen(LogicBattleMode.BattleMode:GetBattleModeId())
      end
    end
  end
end

function LogicBattleMode:BindOnAssemblyStageEnd()
  print(LogicBattleMode.UIWidget)
  if LogicBattleMode.UIWidget then
    LogicBattleMode.UIWidget:EndAssembly()
  end
end

function LogicBattleMode:BindOnChallengeStageBegin()
  if LogicBattleMode.UIWidget then
    LogicBattleMode.UIWidget:BeginChanllenge()
    if LogicBattleMode.BattleMode:GetCurrentStage().OnPlayerOut then
      UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetLeft.WBP_HUDInfo, false)
      UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetLeft.WBP_BattleMode_EnergyBar, true)
      LogicHUD.GetHUDActor().RGWidgetLeft.WBP_BattleMode_EnergyBar:Init()
    end
  end
  if LogicBattleMode.BattleMode:GetCurrentStage() then
    if not LogicBattleMode.UIWidget then
      return
    end
    local PlayerPawn = LogicBattleMode.UIWidget:GetOwningPlayerPawn()
    if LogicBattleMode.BattleMode:GetCurrentStage().OnPlayerOut then
      LogicBattleMode.BattleMode:GetCurrentStage().OnPlayerOut:Add(self, function(GameIns, Player, Num)
        if Player.PlayerState.PlayerID == PlayerPawn.PlayerState.PlayerID then
          UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetNormal.WBP_MiniGame, true)
          UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetRight.SkillPanel, false)
          UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetNormal.WBP_MainSkillCoolDown_C_1, false)
          UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetRight.WBP_WeaponList, false)
        end
      end)
    end
  end
end

function LogicBattleMode:BindOnChallengeStageEnd()
  if LogicBattleMode.UIWidget then
    LogicBattleMode.UIWidget:EndChallenge()
  end
end

function LogicBattleMode:BindOnFinished()
  if LogicBattleMode.UIWidget then
    LogicBattleMode.UIWidget:ShowSuccess()
    UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetNormal.WBP_MiniGame, false)
    UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetRight.SkillPanel, true)
    UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetNormal.WBP_MainSkillCoolDown_C_1, true)
    UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetRight.WBP_WeaponList, true)
  end
end

function LogicBattleMode:BindOnFailed(LevelGameplay)
  if LogicBattleMode.UIWidget then
    LogicBattleMode.UIWidget:ShowFailed()
    UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetNormal.WBP_MiniGame, false)
    UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetRight.SkillPanel, true)
    UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetNormal.WBP_MainSkillCoolDown_C_1, true)
    UpdateVisibility(LogicHUD.GetHUDActor().RGWidgetRight.WBP_WeaponList, true)
  end
end

function LogicBattleMode:BindOnShutdown(LevelGameplay)
  if LogicBattleMode.UIWidget then
    LogicBattleMode.UIWidget:OccupancyShutdown()
  end
end

function LogicBattleMode:GetDuration(BattleModeStageParam)
  if LogicBattleMode.BattleMode and LogicBattleMode.BattleMode.StageArray:IsValidIndex(BattleModeStageParam) then
    local Stage = LogicBattleMode.BattleMode.StageArray:Get(BattleModeStageParam)
    if Stage then
      local Time = math.floor(Stage:GetTotalProgress() - Stage:GetElapsedProgress())
      return Time
    end
  end
  return 0
end

function LogicBattleMode:GetDurationProgress(BattleModeStageParam)
  if LogicBattleMode.BattleMode and LogicBattleMode.BattleMode.StageArray:IsValidIndex(BattleModeStageParam) then
    local Stage = LogicBattleMode.BattleMode.StageArray:Get(BattleModeStageParam)
    if Stage then
      return Stage:GetElapsedProgress() / Stage:GetTotalProgress()
    end
  end
  return 0
end
