LogicVote = LogicVote or {IsInit = false}
function LogicVote.Init()
  LogicVote.UIWidget = nil
  LogicVote.UIWidgetPath = "/Game/Rouge/UI/LevelReady/WBP_LevelReady.WBP_LevelReady_C"
  LogicVote.CurModeNPC = nil
  LogicVote.BattleModeInteractCompPath = "/Game/Rouge/Gameplay/Level/BattleMode/Base/BP_Interact_BattleMode.BP_Interact_BattleMode_C"
  LogicVote.RefuseOverCountTipId = 1103
  LogicVote.VoteStartTime = GetCurrentTimestamp(true)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not InteractHandle then
    return
  end
  EventSystem.AddListenerNew(EventDef.Interact.OnOptimalTargetChanged, nil, LogicVote.BindOnOptimalTargetChanged)
  InteractHandle.OnBeginInteract:Add(GameInstance, LogicVote.BindOnBeginInteract)
  if not LogicVote.IsInit then
    ListenObjectMessage(nil, GMP.MSG_Interact_VoteChange, GameInstance, LogicVote.OnVoteChanged)
    ListenObjectMessage(nil, GMP.MSG_Level_CheckRewardTip, GameInstance, LogicVote.OnShowOrHideLevelPassCheckPanel)
    ListenObjectMessage(nil, GMP.MSG_Level_CancelCheckRewardTip, GameInstance, LogicVote.OnCancelCheckRewardTip)
    LogicVote.InitVotePanel()
    LogicVote.IsInit = true
  end
end
function LogicVote.InitVotePanel()
  local GS = UE.UGameplayStatics.GetGameState(GameInstance)
  if not GS then
    return false
  end
  local VoteSystemComp = GS:GetComponentByClass(UE.URGVoteSystem:StaticClass())
  if not VoteSystemComp then
    return
  end
  local CurrentVoteData = VoteSystemComp.CurrentVoteData
  if CurrentVoteData.bInProgress and not CurrentVoteData.bFinished then
    LogicVote.ChangeReadyWidgetVis()
    for key, SingleUserId in pairs(CurrentVoteData.UserIds) do
      LogicVote.UIWidget:OnPortalStateChange(UE.EVoteState.Confirm, SingleUserId)
    end
  end
end
function LogicVote.OnVoteChanged(VoteType, State, UserId, ModeId, StartTime)
  print("OnVoteChanged", VoteType, State, UserId, ModeId, StartTime)
  if UE.UKismetSystemLibrary.IsStandalone(GameInstance) then
    return
  end
  LogicVote.CurVoteType = VoteType
  LogicVote.CurVoteModeId = ModeId
  LogicVote.VoteStartTime = StartTime
  if State == UE.EVoteState.Interact then
    LogicVote.ChangeReadyWidgetVis()
  elseif State == UE.EVoteState.Refuse then
    if LogicVote.UIWidget and LogicVote.UIWidget:IsValid() then
      LogicVote.UIWidget:Hide()
    end
  elseif State == UE.EVoteState.Confirm then
    LogicVote.ChangeReadyWidgetVis()
    LogicVote.UIWidget:OnPortalStateChange(State, UserId)
  elseif State == UE.EVoteState.Ready and LogicVote.UIWidget and LogicVote.UIWidget:IsValid() then
    LogicVote.UIWidget:Hide()
  end
end
function LogicVote.OnShowOrHideLevelPassCheckPanel(StartTime, Duration)
  local ModeID = UE.URGLevelLibrary.GetMatchGameMode()
  print("LogicVote.OnShowOrHideLevelPassCheckPanel", StartTime, Duration, ModeID)
  if not RGUIMgr:IsShown(UIConfig.WBP_LevelPassCheck_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_LevelPassCheck_C.UIName)
  end
  local TargetUI = RGUIMgr:GetUI(UIConfig.WBP_LevelPassCheck_C.UIName)
  if TargetUI then
    TargetUI:OnShow(StartTime, Duration, ModeID)
  else
    print("LogicVote.OnShowOrHideLevelPassCheckPanel Show not found ui WBP_LevelPassCheck_C")
  end
end
function LogicVote.OnCancelCheckRewardTip()
  print("LogicVote.OnCancelCheckRewardTip")
  if RGUIMgr:IsShown(UIConfig.WBP_LevelPassCheck_C.UIName) then
    RGUIMgr:HideUI(UIConfig.WBP_LevelPassCheck_C.UIName)
  end
end
function LogicVote.BindOnOptimalTargetChanged(OptimalTarget)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  if OptimalTarget then
    local BattleModeInteractCompClass = UE.UClass.Load(LogicVote.BattleModeInteractCompPath)
    local BattleModeInteractComp = OptimalTarget:GetComponentByClass(BattleModeInteractCompClass)
    if BattleModeInteractComp then
      OptimalTarget:ShowOrHideWidget(true)
      LogicVote.CurModeNPC = OptimalTarget
    elseif LogicVote.CurModeNPC then
      LogicVote.CurModeNPC:ShowOrHideWidget(false)
      LogicVote.CurModeNPC = nil
    end
  elseif LogicVote.CurModeNPC then
    LogicVote.CurModeNPC:ShowOrHideWidget(false)
    LogicVote.CurModeNPC = nil
  end
end
function LogicVote.BindOnBeginInteract(Target, TargetActor)
  if not TargetActor then
    return
  end
  local LevelPortalTarget = TargetActor:Cast(UE.ALevelPortal)
  local BoundPortalTarget = TargetActor:Cast(UE.ABonusLevelPortal)
  local VotePortalTarget = TargetActor:Cast(UE.AVotePortal)
  if not LevelPortalTarget and not BoundPortalTarget and not VotePortalTarget then
    return
  end
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not LogicVote.CanRefuse() and Character:GetUserId() ~= TeamSubsystem:GetCaptain() then
    WaveWindowManager:ShowWaveWindow(LogicVote.RefuseOverCountTipId)
  end
end
function LogicVote.ChangeReadyWidgetVis()
  local WidgetClassObj = UE.UClass.Load(LogicVote.UIWidgetPath)
  if not WidgetClassObj then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_LevelReady_C.UIName) then
    LogicVote.UIWidget = RGUIMgr:GetUI(UIConfig.WBP_LevelReady_C.UIName)
    LogicVote.UIWidget:Show()
    return
  end
  UIManager:OpenUI(WidgetClassObj, false, UE.EUILayer.EUILayer_Modal)
  LogicVote.UIWidget = UIManager:K2_GetUI(WidgetClassObj)
  if not LogicVote.UIWidget or not LogicVote.UIWidget:IsValid() then
    print("LogicVote UIWidget is nil")
    return
  end
  LogicVote.UIWidget:Show()
end
function LogicVote.CanRefuse()
  local GS = UE.UGameplayStatics.GetGameState(GameInstance)
  if not GS then
    return false
  end
  local VoteSystemComp = GS:GetComponentByClass(UE.URGVoteSystem:StaticClass())
  if not VoteSystemComp then
    return
  end
  local VoteData = VoteSystemComp:GetVoteData()
  return VoteData.MaxRefuseCount > VoteData.CurrRefuseCount
end
function LogicVote.Clear()
  UnListenObjectMessage(GMP.MSG_Interact_VoteChange)
  UnListenObjectMessage(GMP.MSG_Level_CheckRewardTip)
  UnListenObjectMessage(GMP.MSG_Level_CancelCheckRewardTip)
  LogicVote.UIWidget = nil
  LogicVote.IsInit = false
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not InteractHandle then
    return
  end
  EventSystem.RemoveListenerNew(EventDef.Interact.OnOptimalTargetChanged, nil, LogicVote.BindOnOptimalTargetChanged)
  InteractHandle.OnBeginInteract:Remove(GameInstance, LogicVote.BindOnBeginInteract)
end
