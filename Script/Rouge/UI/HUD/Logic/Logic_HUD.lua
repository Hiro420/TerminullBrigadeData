require("Rouge.UI.HUD.Logic.Logic_Occupancy")
require("Rouge.UI.HUD.Logic.Logic_BattleMode")
local TORNADO_DURATION = 15
LogicHUD = LogicHUD or {
  OldValue = -1,
  ActiveAwardNpcNum = 0,
  TeamIndexColor = {
    [1] = UE.FLinearColor(0.116971, 0.730461, 0.095307, 1.0),
    [2] = UE.FLinearColor(0.799103, 0.623961, 0.028426, 1.0),
    [3] = UE.FLinearColor(0.412543, 0.042311, 0.799103, 1.0),
    [4] = UE.FLinearColor(0.020289, 0.287441, 0.896269, 1.0)
  },
  LevelAffixTips = {
    [0] = NSLOCTEXT("LogicHUD", "LevelAffixTips0", "\230\153\174\233\128\154\229\164\169\230\176\148"),
    [1] = NSLOCTEXT("LogicHUD", "LevelAffixTips1", "\233\154\143\230\156\186\229\164\169\230\176\148"),
    [2] = NSLOCTEXT("LogicHUD", "LevelAffixTips2", "\229\176\143\233\155\168\229\164\169\230\176\148"),
    [3] = NSLOCTEXT("LogicHUD", "LevelAffixTips3", "\229\164\167\233\155\168\229\164\169\230\176\148"),
    [4] = NSLOCTEXT("LogicHUD", "LevelAffixTips4", "\229\176\143\233\155\170\229\164\169\230\176\148"),
    [5] = NSLOCTEXT("LogicHUD", "LevelAffixTips5", "\229\164\167\233\155\170\229\164\169\230\176\148"),
    [6] = NSLOCTEXT("LogicHUD", "LevelAffixTips6", "\229\176\143\230\178\153\230\154\180\229\164\169\230\176\148"),
    [7] = NSLOCTEXT("LogicHUD", "LevelAffixTips7", "\229\164\167\230\178\153\230\154\180\229\164\169\230\176\148")
  },
  HUDWidgetList = {},
  bHadShowBattleLagacy = false
}

function LogicHUD:Init()
  LogicHUD.UIWidget = nil
  LogicHUD.IsLogInteract = false
  LogicHUD.SkillFailedTypeTip = {
    [UE.EActiveSkillFailedType.NoCount] = 105,
    [UE.EActiveSkillFailedType.NoEnergy] = 103,
    [UE.EActiveSkillFailedType.InCooldown] = 104
  }
  LogicHUD.ActiveAwardNpcNum = 0
  ListenObjectMessage(nil, GMP.MSG_UI_HUD_ShowOrHideHUDWidget, GameInstance, LogicHUD.BindOnShowOrHideHUDWidget)
  ListenObjectMessage(nil, GMP.MSG_Level_PlayerLeaveBattle, GameInstance, LogicHUD.BindOnPlayerLeaveBattle)
  ListenObjectMessage(nil, GMP.MSG_Level_DisplayLevels, GameInstance, LogicHUD.BindOnShowDisplayLevelsWidget)
  ListenObjectMessage(nil, GMP.MSG_World_Time_StatusChange, GameInstance, LogicHUD.BindOnWorldTimeStatusChange)
  LogicBattleMode:Init()
  LogicHUD.RiftMap = {}
end

function LogicHUD:RegistWidgetToManager(WidgetObj)
  if not WidgetObj or not WidgetObj:IsValid() then
    return
  end
  local WidgetName = UE.UKismetSystemLibrary.GetDisplayName(WidgetObj)
  LogicHUD.HUDWidgetList[WidgetName] = WidgetObj
end

function LogicHUD:UnRegistWidgetToManager(WidgetObj)
  if not WidgetObj or not WidgetObj:IsValid() then
    return
  end
  local WidgetName = UE.UKismetSystemLibrary.GetDisplayName(WidgetObj)
  LogicHUD.HUDWidgetList[WidgetName] = nil
end

function LogicHUD.BindOnShowOrHideHUDWidget(IsShow, WidgetName)
  local TargetWidget = LogicHUD.HUDWidgetList[WidgetName]
  if not TargetWidget then
    print("LogicHUD:BindOnShowOrHideHUDWidget not found HUD Widget, WidgetName:", WidgetName)
    return
  end
  UpdateVisibility(TargetWidget, IsShow)
end

function LogicHUD.BindOnPlayerLeaveBattle(InUserId)
  print("LogicHUD.BindOnPlayerLeaveBattle", InUserId)
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return
  end
  local PlayerInfo = TeamSubsystem:GetPlayerInfo(InUserId)
  ShowWaveWindow(1153, {
    PlayerInfo.name
  })
end

function LogicHUD.BindOnShowDisplayLevelsWidget()
  RGUIMgr:OpenUI(UIConfig.WBP_DisplayLevels_C.UIName)
end

function LogicHUD.BindOnWorldTimeStatusChange(status)
  if status then
    return
  end
  if not RGUIMgr:IsShown(UIConfig.WBP_Survival_Tips_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_Survival_Tips_C.UIName)
  end
  local SurvivalTips = RGUIMgr:GetUI(UIConfig.WBP_Survival_Tips_C.UIName)
  if SurvivalTips then
    SurvivalTips:InitTitle(1623)
  end
end

local GetOptimalTargetInteractTipId = function(OptimalTarget)
  local InteractComp = OptimalTarget:GetComponentByClass(UE.URGInteractComponent:StaticClass())
  if not InteractComp then
    return 0
  end
  local TipId = InteractComp.TipId
  if OptimalTarget.GetInteractTipId then
    TipId = OptimalTarget:GetInteractTipId()
  end
  return TipId
end

function LogicHUD:BindPCEvent()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character then
    Character.OnCharacterDying:Add(GameInstance, LogicHUD.BindOnCharacterDying)
    Character.OnCharacterDeath:Add(GameInstance, LogicHUD.BindOnCharacterDeath)
    Character.OnCharacterRescue:Add(GameInstance, LogicHUD.BindOnCharacterRescue)
    Character.OnCharacterPauseDying:Add(GameInstance, LogicHUD.BindOnCharacterPauseDying)
    Character.OnCharacterUnPauseDying:Add(GameInstance, LogicHUD.BindOnCharacterUnPauseDying)
    Character.OnCharacterWillBeingAttackStateChange:Add(GameInstance, LogicHUD.BindOnCharacterWillBeingAttackStateChange)
    if Character.OnCharacterEnterStateFailed then
      Character.OnCharacterEnterStateFailed:Add(GameInstance, LogicHUD.BindOnCharacterEnterStateFailed)
    end
    local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
    if InteractHandle then
      InteractHandle.OnBeginInteract:Add(GameInstance, LogicHUD.BindOnBeginInteractChanged)
      InteractHandle.OnFinishInteract:Add(GameInstance, LogicHUD.BindOnFinishInteractChanged)
      InteractHandle.OnCancelInteract:Add(GameInstance, LogicHUD.BindOnCancelInteractChanged)
    end
    if Character.AbilitySystemComponent then
    end
  end
end

function LogicHUD.Clear()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character then
    Character.OnCharacterDying:Remove(GameInstance, LogicHUD.BindOnCharacterDying)
    Character.OnCharacterDeath:Remove(GameInstance, LogicHUD.BindOnCharacterDeath)
    Character.OnCharacterRescue:Remove(GameInstance, LogicHUD.BindOnCharacterRescue)
    Character.OnCharacterPauseDying:Remove(GameInstance, LogicHUD.BindOnCharacterPauseDying)
    Character.OnCharacterUnPauseDying:Remove(GameInstance, LogicHUD.BindOnCharacterUnPauseDying)
    Character.OnCharacterWillBeingAttackStateChange:Remove(GameInstance, LogicHUD.BindOnCharacterWillBeingAttackStateChange)
    if Character.OnCharacterEnterStateFailed then
      Character.OnCharacterEnterStateFailed:Remove(GameInstance, LogicHUD.BindOnCharacterEnterStateFailed)
    end
    local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
    if not InteractHandle then
      return
    end
    InteractHandle.OnBeginInteract:Remove(GameInstance, LogicHUD.BindOnBeginInteractChanged)
    InteractHandle.OnFinishInteract:Remove(GameInstance, LogicHUD.BindOnFinishInteractChanged)
    InteractHandle.OnCancelInteract:Remove(GameInstance, LogicHUD.BindOnCancelInteractChanged)
  end
  LogicHUD.OldValue = -1
  LogicHUD.OldMainSkillEnergyValue = -1
  LogicHUD.OldMainSkillMaxEnergyValue = -1
  LogicHUD.TeamBoxTriggeredTb = {}
  LogicHUD.BeingAttackList = {}
  LogicHUD.HUDWidgetList = {}
  LogicHUD.RiftMap = {}
  LogicOccupancy.Clear()
  LogicBattleMode.Clear()
  UnListenObjectMessage(GMP.MSG_World_LevelGameplay_EnterOccupancyLevel, GameInstance)
  UnListenObjectMessage(GMP.MSG_World_Mechanism_Chest_Activate, GameInstance)
  UnListenObjectMessage(GMP.MSG_World_Mechanism_TeamBox_UpdatePlayer, GameInstance)
  UnListenObjectMessage(GMP.MSG_World_Mechanism_TeamBox_Trigger, GameInstance)
  UnListenObjectMessage(GMP.MSG_Interact_ClientPickupFailed, GameInstance)
  UnListenObjectMessage(GMP.MSG_World_Pickup_OnFailedReasonChanged, GameInstance)
  UnListenObjectMessage(GMP.MSG_Level_LevelAffix_LightingWarning, GameInstance)
  UnListenObjectMessage(GMP.MSG_Level_LevelAffix_TornadoWarning, GameInstance)
  UnListenObjectMessage(GMP.MSG_Level_OnLevelAffix, GameInstance)
  UnListenObjectMessage(GMP.MSG_UI_HUD_ShowOrHideHUDWidget, GameInstance)
  UnListenObjectMessage(GMP.MSG_Level_PlayerLeaveBattle, GameInstance)
  UnListenObjectMessage(GMP.MSG_Level_DisplayLevels, GameInstance)
  UnListenObjectMessage(GMP.MSG_World_Time_StatusChange, GameInstance)
  UnListenObjectMessage(GMP.MSG_Level_Rift_Spawn, GameInstance)
  UnListenObjectMessage(GMP.MSG_Level_Rift_Timeoff, GameInstance)
  UnListenObjectMessage(GMP.MSG_Level_Rift_Destroyed, GameInstance)
  EventSystem.RemoveListenerNew(EventDef.Chip.PickUpChip, nil, LogicHUD.OnChipListPickUp)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzlePickup, nil, LogicHUD.OnChipListPickUp)
  LogicAudio.OnTreasureBoxStopCharge()
end

function LogicHUD:BindOnCharacterDying(Character, CountDown)
end

function LogicHUD:BindOnCharacterDeath(Character)
end

function LogicHUD:BindOnCharacterRescue(Character)
end

function LogicHUD:BindOnCharacterPauseDying(Character)
end

function LogicHUD:BindOnCharacterUnPauseDying(Character)
end

function LogicHUD:BindOnCharacterWillBeingAttackStateChange(State)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  if not LogicHUD.BeingAttackList then
    LogicHUD.BeingAttackList = {}
  end
  if State then
    table.insert(LogicHUD.BeingAttackList, UE.UGameplayStatics.GetTimeSeconds(self))
    HUD.RedWarningTip:ShowRedWarning()
  else
    LogicHUD.RemoveBeingAttackList()
  end
end

function LogicHUD.RemoveBeingAttackList()
  if LogicHUD.BeingAttackList[1] then
    table.remove(LogicHUD.BeingAttackList, 1)
  end
  local HUD = RGUIMgr:GetUI("WBP_HUD_C")
  if table.count(LogicHUD.BeingAttackList) <= 0 then
    if HUD then
      HUD.RedWarningTip:HideRedWarning()
    end
  elseif HUD then
    HUD.RedWarningTip:ShowRedWarning()
  end
end

function LogicHUD:BindOnCharacterEnterStateFailed(Character, StateTag)
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveManager then
  end
end

function LogicHUD:BindOnOptimalTargetChanged(OptimalTargetParam)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local targetList = LogicHUD:GetCanInteractTargetList()
  local OptimalTarget = OptimalTargetParam
  if targetList and targetList:IsValidIndex(1) then
    OptimalTarget = targetList:Get(1)
    LogicHUD.CurInteractIdx = 1
  end
  if OptimalTarget then
    local InteractComp = OptimalTarget:GetComponentByClass(UE.URGInteractComponent:StaticClass())
    if InteractComp then
      local TipId = GetOptimalTargetInteractTipId(OptimalTarget)
      if 0 ~= TipId and InteractComp:CanInteractWith(Character) then
        local bResult, InteractTipRow = DTSubsystem:GetInteractTipRowByID(TipId, nil)
        if bResult then
          HUD:UpdateInteractWidget(InteractTipRow, OptimalTarget, true)
        end
      end
      LogicHUD.PreOptimalTarget = OptimalTarget
      EventSystem.Invoke(EventDef.Interact.OnOptimalTargetChanged, OptimalTarget)
      return
    end
  end
  LogicHUD.CurInteractIdx = -1
  HUD:UpdateInteractWidget(nil, OptimalTarget, false)
  LogicHUD.PreOptimalTarget = nil
  EventSystem.Invoke(EventDef.Interact.OnOptimalTargetChanged, nil)
end

function LogicHUD:CheckCanScrollInteract()
  if not LogicHUD:GetCanInteractTargetList() then
    return false
  end
  return LogicHUD:GetCanInteractTargetList():Num() > 1
end

function LogicHUD:GetCanInteractTargetList()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("LogicHUD:GetCanInteractTargetList Character Is Nil")
    return nil
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not InteractHandle then
    print("LogicHUD:GetCanInteractTargetList InteractHandle Is Nil")
    return nil
  end
  local OutTargetList = UE.TArray(UE.AActor)
  InteractHandle:GetSortedTargets(OutTargetList)
  if LogicHUD.IsLogInteract then
    print("LogicHUD:GetCanInteractTargetList OutTargetList Num:", OutTargetList:Num())
  end
  local TargetList = UE.TArray(UE.AActor)
  TargetList:Reserve(OutTargetList:Num())
  for i, v in iterator(OutTargetList) do
    local InteractComp = v:GetComponentByClass(UE.URGInteractComponent:StaticClass())
    if InteractComp and InteractComp:CanInteractWith(Character) then
      local TipId = GetOptimalTargetInteractTipId(v)
      local bResult, InteractTipRow = GetRowData(DT.DT_InteractTip, tostring(TipId))
      if bResult and InteractTipRow.InteractTipOperatorType == UE.EInteractTipOperatorType.Scroll then
        TargetList:Add(v)
      end
    end
  end
  if LogicHUD.IsLogInteract then
    print("LogicHUD:GetCanInteractTargetList TargetList Num:", TargetList:Num())
  end
  return TargetList
end

function LogicHUD.UpdateScrollInteract()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not InteractHandle then
    return
  end
  local TargetList = LogicHUD:GetCanInteractTargetList()
  if not TargetList then
    return
  end
  if TargetList:Num() < 1 then
    return
  end
  if TargetList:IsValidIndex(LogicHUD.CurInteractIdx) then
    local Target = TargetList:Get(LogicHUD.CurInteractIdx)
    if Target ~= LogicHUD.PreOptimalTarget then
      local InteractComp = Target:GetComponentByClass(UE.URGInteractComponent:StaticClass())
      local TipId = GetOptimalTargetInteractTipId(Target)
      if InteractComp and 0 ~= TipId and InteractComp:CanInteractWith(Character) then
        local bResult, InteractTipRow = GetRowData(DT.DT_InteractTip, tostring(TipId))
        if bResult then
          HUD:UpdateInteractWidget(InteractTipRow, Target, true)
          InteractHandle:SetNextTimeCustomOptimalTarget(Target)
        end
      end
      LogicHUD.PreOptimalTarget = Target
      EventSystem.Invoke(EventDef.Interact.OnOptimalTargetChanged, Target)
    end
  else
    local Target = TargetList:Get(1)
    if Target ~= LogicHUD.PreOptimalTarget then
      local InteractComp = Target:GetComponentByClass(UE.URGInteractComponent:StaticClass())
      local TipId = GetOptimalTargetInteractTipId(Target)
      if InteractComp and 0 ~= TipId and InteractComp:CanInteractWith(Character) then
        local bResult, InteractTipRow = GetRowData(DT.DT_InteractTip, tostring(TipId))
        if bResult then
          HUD:UpdateInteractWidget(InteractTipRow, Target, true)
          InteractHandle:SetNextTimeCustomOptimalTarget(Target)
        end
      end
      LogicHUD.PreOptimalTarget = Target
      LogicHUD.CurInteractIdx = 1
      EventSystem.Invoke(EventDef.Interact.OnOptimalTargetChanged, Target)
    end
  end
end

function LogicHUD:ScrollInteract(bIsNext)
  local CurIdx = LogicHUD.CurInteractIdx
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not InteractHandle then
    return
  end
  local TargetList = LogicHUD:GetCanInteractTargetList()
  if not TargetList then
    return
  end
  if TargetList:Num() <= 1 then
    return
  end
  local NextIdx = -1
  if bIsNext then
    NextIdx = CurIdx + 1
  else
    NextIdx = CurIdx - 1
  end
  if NextIdx < 1 then
    NextIdx = TargetList:Num()
  end
  if NextIdx > TargetList:Num() then
    NextIdx = 1
  end
  if TargetList:IsValidIndex(NextIdx) then
    LogicHUD.CurInteractIdx = NextIdx
    local Target = TargetList:Get(NextIdx)
    local InteractComp = Target:GetComponentByClass(UE.URGInteractComponent:StaticClass())
    local TipId = GetOptimalTargetInteractTipId(Target)
    if InteractComp and 0 ~= TipId and InteractComp:CanInteractWith(Character) then
      local bResult, InteractTipRow = GetRowData(DT.DT_InteractTip, tostring(TipId))
      if bResult then
        HUD:UpdateInteractWidget(InteractTipRow, Target, true)
        InteractHandle:SetNextTimeCustomOptimalTarget(Target)
      end
    end
    LogicHUD.PreOptimalTarget = Target
    EventSystem.Invoke(EventDef.Interact.OnOptimalTargetChanged, Target)
  end
end

function LogicHUD:BindOnBeginInteractChanged(Target)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  if Target then
    local InteractComp = Target:GetComponentByClass(UE.URGInteractComponent:StaticClass())
    local TipId = GetOptimalTargetInteractTipId(Target)
    if InteractComp and 0 ~= TipId and InteractComp.InteractConfig.Behavior == UE.ERGInteractBehavior.Duration then
      HUD:UpdateInteractStatues(true, InteractComp)
      LogicAudio.OnTreasureBoxOpenCharge()
    end
  end
end

function LogicHUD:BindOnCancelInteractChanged(Target, Instigator, bTryInteractFailed)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  if Target then
    local InteractComp = Target:GetComponentByClass(UE.URGInteractComponent:StaticClass())
    local TipId = GetOptimalTargetInteractTipId(Target)
    if InteractComp and 0 ~= TipId and InteractComp.InteractConfig.Behavior == UE.ERGInteractBehavior.Duration then
      HUD:UpdateInteractStatues(false, InteractComp)
      LogicAudio.OnTreasureBoxStopCharge()
    end
  end
end

function LogicHUD:BindOnFinishInteractChanged(Target, Instigator)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  if Target then
    local InteractComp = Target:GetComponentByClass(UE.URGInteractComponent:StaticClass())
    local TipId = GetOptimalTargetInteractTipId(Target)
    if InteractComp and 0 ~= TipId and InteractComp.InteractConfig.Behavior == UE.ERGInteractBehavior.Duration then
      HUD:UpdateInteractStatues(false, InteractComp)
      UE.URGBlueprintLibrary.RemoveInteractMark(Target)
      LogicAudio.OnTreasureBoxStopCharge()
    end
  end
end

function LogicHUD:BindOnAbilityActivatedFailed(AbilityID, TipId)
  LogicAudio.OnSkillLack(AbilityID)
  if -1 ~= TipId then
    local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    if WaveManager then
      WaveManager:ShowWaveWindow(TipId)
    end
  else
    print("LogicHUD:BindOnAbilityActivatedFailed not found Skill Failed Tip Id, Fail Type is", FailType)
  end
end

function LogicHUD:UpdateGenericModifyListShow(bIsShow)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
  local HUD = UIManager:K2_GetUI(HUDWidgetClass)
  if not HUD then
    return
  end
  HUD:UpdateGenericModifyListShow(bIsShow)
end

function LogicHUD:CreateHUD()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    local HUDWidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C")
    LogicHUD.UIWidget = UIManager:K2_GetUI(HUDWidgetClass)
    if not LogicHUD.UIWidget then
      return
    end
    LogicHUD.UIWidget:InitCharacterInfo()
    LogicHUD:BindPCEvent()
    LogicHUD:InitWidgetBindEvent()
    LogicHUD:InitAffiliatedWidget()
    LogicRadio.TriggerStartRadio()
  end
end

function LogicHUD.RefreshHUDEvent()
  if not LogicHUD.UIWidget then
    return
  end
  LogicHUD.UIWidget:InitCharacterInfo()
  LogicHUD:BindPCEvent()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  EventSystem.Invoke(EventDef.Battle.OnControlledPawnChanged, Character)
end

function LogicHUD:InitAffiliatedWidget()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    RGUIMgr:OpenUI(UIConfig.WBP_NormalPickTipList_C.UIName)
  end
end

function LogicHUD:InitWidgetBindEvent()
  if not LogicHUD.UIWidget then
    return
  end
  LogicHUD.UIWidget.Button_GM.OnClicked:Add(GameInstance, LogicHUD.BindOnGMButtonClicked)
  LogicHUD.UIWidget.Button_DSName.OnClicked:Add(GameInstance, LogicHUD.BindOnDSNameButtonClicked)
  ListenObjectMessage(nil, "World.LevelGameplay.EnterOccupancyLevel", GameInstance, LogicHUD.OnEnterOccupancyLevel)
  ListenObjectMessage(nil, "World.Mechanism.Chest.Activate", GameInstance, LogicHUD.OnChestActivate)
  ListenObjectMessage(nil, "World.Mechanism.TeamBox.UpdatePlayer", GameInstance, LogicHUD.OnTeamBoxUpdatePlayerNum)
  ListenObjectMessage(nil, "World.Mechanism.TeamBox.Trigger", GameInstance, LogicHUD.OnTeamBoxTrigger)
  ListenObjectMessage(nil, GMP.MSG_Interact_ClientPickupFailed, GameInstance, LogicHUD.OnPickupFailed)
  ListenObjectMessage(nil, GMP.MSG_World_Pickup_OnFailedReasonChanged, GameInstance, LogicHUD.OnPickupReasonChanged)
  ListenObjectMessage(nil, GMP.MSG_Level_LevelAffix_LightingWarning, GameInstance, LogicHUD.OnLightingWarning)
  ListenObjectMessage(nil, GMP.MSG_Level_LevelAffix_VirusWarning, GameInstance, LogicHUD.OnVirusWarning)
  ListenObjectMessage(nil, GMP.MSG_Level_LevelAffix_TornadoWarning, GameInstance, LogicHUD.OnTornadoWarning)
  ListenObjectMessage(nil, GMP.MSG_Level_OnLevelAffix, GameInstance, LogicHUD.OnLevelAffix)
  ListenObjectMessage(nil, GMP.MSG_Level_Rift_Spawn, GameInstance, LogicHUD.OnLevelRiftSpawn)
  ListenObjectMessage(nil, GMP.MSG_Level_Rift_Timeoff, GameInstance, LogicHUD.OnLevelRiftTimeOff)
  ListenObjectMessage(nil, GMP.MSG_Level_Rift_Destroyed, GameInstance, LogicHUD.OnLevelRiftDestroyed)
  ListenObjectMessage(nil, GMP.MSG_Level_LevelAffix_VirusFirstTrace, GameInstance, LogicHUD.OnVirusFirstTrace)
  ListenObjectMessage(nil, GMP.MSG_Level_LevelAffix_VirusInit, GameInstance, LogicHUD.OnVirusInit)
  EventSystem.RemoveListenerNew(EventDef.Chip.PickUpChip, nil, LogicHUD.OnChipListPickUp)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzlePickup, nil, LogicHUD.OnChipListPickUp)
  EventSystem.AddListenerNew(EventDef.Chip.PickUpChip, nil, LogicHUD.OnChipListPickUp)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzlePickup, nil, LogicHUD.OnChipListPickUp)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager.ReadyDelegate:Broadcast(LogicHUD.UIWidget)
  end
end

function LogicHUD:BindOnGMButtonClicked()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    local GMClass = UE.UClass.Load("/Game/Rouge/UI/GM/WBP_GMWindow.WBP_GMWindow_C")
    UIManager:Switch(GMClass)
    LogicHUD.UIWidget:ChangeGMButtonVisibility(false)
  end
end

function LogicHUD:BindOnDSNameButtonClicked()
  UE.URGBlueprintLibrary.CopyMessageToClipboard(tostring(LogicHUD.UIWidget.Txt_DSName:GetText()))
end

function LogicHUD.OnEnterOccupancyLevel()
  LogicOccupancy:CreateWidget()
end

function LogicHUD.OnChestActivate(ChestActor)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local InteractComp = ChestActor:GetComponentByClass(UE.URGInteractComponent:StaticClass())
  if InteractComp and 0 ~= InteractComp.TipId and InteractComp.InteractConfig.Behavior == UE.ERGInteractBehavior.Duration then
    local bResult, InteractTipRow = DTSubsystem:GetInteractTipRowByID(InteractComp.TipId, nil)
    if bResult then
      local WidgetCls
      local Result, MarkRow = DTSubsystem:GetMarkDataByName(InteractTipRow.MarkRowName, nil)
      if Result and UE.UKismetSystemLibrary.IsValidSoftClassReference(MarkRow.MarkUIItemCls) then
        WidgetCls = UE.UKismetSystemLibrary.LoadClassAsset_Blocking(MarkRow.MarkUIItemCls)
      end
      print("LogicHUD.OnChestActivate", ChestActor)
      local InteractWidget = UE.URGBlueprintLibrary.GetMarkItem(GameInstance, ChestActor, WidgetCls)
      if InteractWidget then
        InteractWidget:SetIsShowMark(true)
      else
        UE.URGBlueprintLibrary.TriggerInteractMark(ChestActor, InteractTipRow.MarkRowName)
        InteractWidget = UE.URGBlueprintLibrary.GetMarkItem(GameInstance, ChestActor, WidgetCls)
        if InteractWidget then
          InteractWidget:SetIsShowMark(true)
          InteractWidget:UpdateInteractItem(false)
        end
      end
    end
  end
end

function LogicHUD.OnTeamBoxUpdatePlayerNum(TargetActor, MaxPlayerNum, CurPlayerNum)
  if LogicHUD.TeamBoxTriggeredTb and table.Contain(LogicHUD.TeamBoxTriggeredTb, TargetActor) then
    return
  end
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveManager and CurPlayerNum < MaxPlayerNum then
    local Str1 = tostring(CurPlayerNum)
    local Str2 = tostring(MaxPlayerNum)
    local Param = {Str1, Str2}
    WaveManager:ShowWaveWindow(1080, Param)
  end
end

function LogicHUD.OnTeamBoxTrigger(TargetActor)
  if not LogicHUD.TeamBoxTriggeredTb then
    LogicHUD.TeamBoxTriggeredTb = {}
  end
  table.insert(LogicHUD.TeamBoxTriggeredTb, TargetActor)
end

function LogicHUD.OnPickupFailed(TargetActor)
end

function LogicHUD.OnPickupReasonChanged(Instigator, PickupFailedReason)
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("LogicHUD.OnPickupReasonChanged", PickupFailedReason.TagName)
  if not LogicHUD.UIWidget then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character ~= Instigator then
    return
  end
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if LogicHUD.UIWidget.ToastData ~= nil then
    local id = LogicHUD.UIWidget.ToastData.ReasonTagToPromptId:Find(PickupFailedReason)
    print("LogicHUD.OnPickupReasonChanged id", id)
    if WaveManager and id then
      WaveManager:ShowWaveWindow(id)
    end
  end
  if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(LogicHUD.UIWidget.FullAttrModifyTag, PickupFailedReason) then
    if UE.URGLevelLibrary.IsSurvivorMode() then
      local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if WaveManager then
        WaveManager:ShowWaveWindow(3206010)
      end
    else
      LogicHUD.UIWidget:ShowScrollView()
    end
  end
end

function LogicHUD.OnLightingWarning(Character)
  print("LogicHUD.OnLightingWarning1", Character)
  local ownerCharacter = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if ownerCharacter ~= Character then
    return
  end
  print("LogicHUD.OnLightingWarning2", ownerCharacter)
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveManager then
    WaveManager:ShowWaveWindow(1132)
  end
end

function LogicHUD.OnVirusWarning(Character)
  print("LogicHUD.OnVirusWarning1", Character)
  local ownerCharacter = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if ownerCharacter ~= Character then
    return
  end
  print("LogicHUD.OnVirusWarning2", ownerCharacter)
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveManager then
    WaveManager:ShowWaveWindow(1177)
  end
end

function LogicHUD.OnTornadoWarning(Character)
  print("LogicHUD.OnTornadoWarning1", Character)
  local ownerCharacter = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if ownerCharacter ~= Character then
    return
  end
  print("LogicHUD.OnTornadoWarning2", ownerCharacter)
  local GS = UE.UGameplayStatics.GetGameState(GameInstance)
  if LogicHUD.TriggerTornadoWarningTime and GS:GetServerWorldTimeSeconds() - LogicHUD.TriggerTornadoWarningTime <= TORNADO_DURATION then
    return
  end
  LogicHUD.TriggerTornadoWarningTime = GS:GetServerWorldTimeSeconds()
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveManager then
    WaveManager:ShowWaveWindow(1131)
  end
end

function LogicHUD.OnVirusFirstTrace(Character)
  local ownerCharacter = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if ownerCharacter ~= Character then
    return
  end
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveManager then
    WaveManager:ShowWaveWindow(1233)
  end
end

function LogicHUD.OnVirusInit(Character)
  local ownerCharacter = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if ownerCharacter ~= Character then
    return
  end
  local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveManager then
    WaveManager:ShowWaveWindow(1234)
  end
end

function LogicHUD.OnLevelAffix(Name, WeatherType, Id)
  print("LogicHUD:OnLevelAffix1", Name, Id)
  LogicHUD.ShowLevelRadioWidow(Id)
  local riftID = "20"
  if tostring(Id) == riftID then
    print("LogicHUD:OnLevelAffix1 Rift Rtn", Name, Id)
    return
  end
  local result, row = GetRowData(DT.DT_LevelAffixes, tostring(Id))
  if result then
    local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if WaveManager then
      local str = ""
      for i, v in iterator(row.WeatherTypes) do
        if v == WeatherType and LogicHUD.LevelAffixTips[v] then
          str = LogicHUD.LevelAffixTips[v]()
        end
      end
      str = string.format("%s", row.Name)
      WaveManager:ShowWaveWindow(1133, {str})
      print("LogicHUD:OnLevelAffix2", str, row.Name)
    end
  end
end

function LogicHUD.ShowLevelRadioWidow(LevelAffixesID)
  local result, row = GetRowData(DT.DT_LevelAffixes, tostring(LevelAffixesID))
  if result then
    local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if WaveManager and row.RadioEventID > 0 then
      WaveManager:ShowRadioWindow(row.RadioEventID)
    end
  end
end

function LogicHUD.OnLevelRiftSpawn(SpawnID, TimeOffStamp, SpawnTimeStamp, TimeOffUTCStamp)
  LogicHUD.RiftMap[SpawnID] = TimeOffStamp
  local customTask = LogicTaskPanel.CreatCustomTaskData("Rift" .. SpawnID, "Rift", TimeOffUTCStamp, SpawnTimeStamp)
  customTask.Status = UE.ERGActionEventTaskStatus.Running
  LogicTaskPanel.UpdateCustomTaskData({customTask}, true)
  ShowWaveWindow(1192)
  local hudWidget = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
  if hudWidget then
    hudWidget:ShowRift(TimeOffUTCStamp, SpawnTimeStamp, TimeOffStamp)
  end
end

function LogicHUD.OnLevelRiftTimeOff(SpawnID, bNotCleanedLevel)
  local customTask = LogicTaskPanel.CreatCustomTaskData("Rift" .. SpawnID, "Rift")
  customTask.Status = UE.ERGActionEventTaskStatus.Fail
  LogicTaskPanel.RemoveCustomTaskData({customTask})
  LogicHUD.RiftMap[SpawnID] = nil
  if table.IsEmpty(LogicHUD.RiftMap) then
    UE.URGUIEffectMgr.Get(GameInstance):CreateEffect("8")
    local hudWidget = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
    if hudWidget then
      hudWidget:ShowRiftTimeOff(customTask)
    end
  end
end

function LogicHUD.OnChipListPickUp(Picker, ChipList)
  local PC = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if PC ~= Picker then
    return
  end
  local Param = UE.FWaveWindowParam()
  Param.IntArray0 = ChipList
  ShowWaveWindowWithDelegate(1205, {}, nil, nil, Param)
end

function LogicHUD.OnLevelRiftDestroyed(SpawnID, bNotCleanedLevel)
  local customTask = LogicTaskPanel.CreatCustomTaskData("Rift" .. SpawnID, "Rift")
  customTask.Status = UE.ERGActionEventTaskStatus.Complete
  LogicTaskPanel.RemoveCustomTaskData({customTask})
  LogicHUD.RiftMap[SpawnID] = nil
  if table.IsEmpty(LogicHUD.RiftMap) then
    UE.URGUIEffectMgr.Get(GameInstance):CreateEffect("7")
    local hudWidget = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
    if hudWidget then
      hudWidget:ShowRiftDestroyed(customTask)
    end
  end
end

function LogicHUD:UpdateActiveAwardNpcNum(ChangeNum)
  LogicHUD.ActiveAwardNpcNum = LogicHUD.ActiveAwardNpcNum + ChangeNum
  if ChangeNum > 0 then
    EventSystem.Invoke(EventDef.NPCAward.NPCAwardNumAdd)
  end
end

function LogicHUD:GetActiveAwardNpcNum()
  return LogicHUD.ActiveAwardNpcNum
end

function LogicHUD.GetUIWidget()
  return LogicHUD.UIWidget
end

function LogicHUD.GetHUDActor()
  local UIWidget = LogicHUD.UIWidget
  if not UIWidget then
    return
  end
  local HUDActor = {
    RGWidgetRight = UIWidget.WBP_HUD_Right,
    RGWidgetLeft = UIWidget.WBP_HUD_Left,
    RGWidgetNormal = UIWidget.WBP_HUD_Normal,
    RGWidgetMiddleTop = UIWidget.WBP_HUD_MiddleTop
  }
  return HUDActor
end
