LogicBeginnerGuidance = LogicBeginnerGuidance or {IsInit = false, IsExecuteBeginGuideDecide = true}
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")

function LogicBeginnerGuidance.Init()
  if LogicBeginnerGuidance.IsInit then
    LogicBeginnerGuidance.HUDTipList = {}
    LogicBeginnerGuidance.BindCharacterDelegate()
    return
  end
  LogicBeginnerGuidance.IsInit = true
  LogicBeginnerGuidance.HUDTipList = {}
  LogicBeginnerGuidance.BindCharacterDelegate()
  ListenObjectMessage(nil, GMP.MSG_Level_Guide_LevelFinished, GameInstance, LogicBeginnerGuidance.BindOnGuideLevelFinished)
  ListenObjectMessage(nil, GMP.MSG_Level_Guide_ReturnToLobby, GameInstance, LogicBeginnerGuidance.BindOnGuideLevelReturnToLobby)
  ListenObjectMessage(nil, GMP.MSG_Level_Guide_ChangeWhetherExecuteBeginGuideDecide, GameInstance, LogicBeginnerGuidance.BindOnChangeWhetherExecuteBeginGuideDecide)
end

function LogicBeginnerGuidance.BindCharacterDelegate()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character or not Character.PlayerState then
    print("LogicBeginnerGuidance.BindCharacterDelegate not Character or not PlayerState")
    if Character and Character.OnNotifyPlayerStateRep then
      print("LogicBeginnerGuidance.BindCharacterDelegate Bind OnNotifyPlayerStateRep")
      Character.OnNotifyPlayerStateRep:Add(GameInstance, LogicBeginnerGuidance.BindCharacterDelegate)
    end
    return
  end
  local MissionComp = Character.PlayerState:GetComponentByClass(UE.URGPlayerMissionComponent:StaticClass())
  if not MissionComp then
    return
  end
  MissionComp.OnMissionStarted:Add(GameInstance, LogicBeginnerGuidance.BindOnMissionStarted)
  MissionComp.OnMissionFinished:Add(GameInstance, LogicBeginnerGuidance.BindOnMissionFinished)
  MissionComp.OnMissionFailed:Add(GameInstance, LogicBeginnerGuidance.BindOnMissionFailed)
end

function LogicBeginnerGuidance.BindOnGuideLevelFinished()
  print("LogicBeginnerGuidance.BindOnGuideLevelFinished")
  if not BeginnerGuideData.freshmanFightFinished then
    HttpCommunication.Request("playergrowth/freshmanguide/finishfreshmanfight", {})
  end
end

function LogicBeginnerGuidance.BindOnGuideLevelReturnToLobby()
  print("LogicBeginnerGuidance.BindOnGuideLevelReturnToLobby")
  UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType("BattleToLobby")
  LogicLobby.SetIsNeedPlayAfterBeginnerGuidanceMovie(true)
  LogicLobby.OpenLobbyLevel()
end

function LogicBeginnerGuidance.BindOnChangeWhetherExecuteBeginGuideDecide(IsExecute)
  LogicBeginnerGuidance.IsExecuteBeginGuideDecide = IsExecute
end

function LogicBeginnerGuidance.RegisterHUDTip(BeginnerRowId, Widget)
  LogicBeginnerGuidance.HUDTipList[BeginnerRowId] = Widget
end

function LogicBeginnerGuidance.UnRegisterHUDTip(BeginnerRowId, Widget)
  LogicBeginnerGuidance.HUDTipList[BeginnerRowId] = nil
end

function LogicBeginnerGuidance:BindOnMissionStarted(Handle)
  if not LogicBeginnerGuidance.IsExecuteBeginGuideDecide then
    print("LogicBeginnerGuidance:BindOnMissionStarted not Execute Begin Guide Decide")
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character or not Character.PlayerState then
    print("LogicBeginnerGuidance.BindOnMissionStarted not Character or not PlayerState")
    return
  end
  local MissionComp = Character.PlayerState:GetComponentByClass(UE.URGPlayerMissionComponent:StaticClass())
  if not MissionComp then
    print("LogicBeginnerGuidance.BindOnMissionStarted not MissionComp")
    return
  end
  local Instance = MissionComp:FindInstanceByHandle(Handle)
  print("LogicBeginnerGuidance.BindOnMissionStarted", Instance:GetMissionId())
  local BeginnerGuidanceMainPanel = RGUIMgr:GetUI(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName)
  if not BeginnerGuidanceMainPanel or not RGUIMgr:IsShown(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName)
  end
  BeginnerGuidanceMainPanel = RGUIMgr:GetUI(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName)
  if BeginnerGuidanceMainPanel then
    BeginnerGuidanceMainPanel:RefreshInfo(Instance:GetMissionId())
  end
  local Result, RowInfo = GetRowData(DT.DT_Mission, tostring(Instance:GetMissionId()))
  if Result then
    local TargetHUDTipWidget
    for key, SingleTipId in pairs(RowInfo.TipIdList) do
      TargetHUDTipWidget = LogicBeginnerGuidance.HUDTipList[tonumber(SingleTipId)]
      if TargetHUDTipWidget then
        TargetHUDTipWidget:Show()
      end
    end
  end
end

function LogicBeginnerGuidance.HideBeginnerGuidanceMainPanel(MissionId)
  local BeginnerGuidanceMainPanel = RGUIMgr:GetUI(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName)
  if BeginnerGuidanceMainPanel and RGUIMgr:IsShown(UIConfig.WBP_RGBeginnerGuidancePanel_C.UIName) then
    BeginnerGuidanceMainPanel:OnMissionFinished(MissionId)
  end
end

function LogicBeginnerGuidance:BindOnMissionFinished(Handle)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character or not Character.PlayerState then
    print("LogicBeginnerGuidance.BindOnMissionFinished not Character or not PlayerState")
    return
  end
  local MissionComp = Character.PlayerState:GetComponentByClass(UE.URGPlayerMissionComponent:StaticClass())
  if not MissionComp then
    print("LogicBeginnerGuidance.BindOnMissionFinished not MissionComp")
    return
  end
  local Instance = MissionComp:FindInstanceByHandle(Handle)
  print("LogicBeginnerGuidance.BindOnMissionFinished", Instance:GetMissionId())
  LogicBeginnerGuidance.HideBeginnerGuidanceMainPanel(Instance:GetMissionId())
  local Result, RowInfo = GetRowData(DT.DT_Mission, tostring(Instance:GetMissionId()))
  if Result then
    local TargetHUDTipWidget
    for key, SingleTipId in pairs(RowInfo.TipIdList) do
      TargetHUDTipWidget = LogicBeginnerGuidance.HUDTipList[tonumber(SingleTipId)]
      if TargetHUDTipWidget then
        TargetHUDTipWidget:Hide()
      end
    end
  end
end

function LogicBeginnerGuidance:BindOnMissionFailed(Handle)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character or not Character.PlayerState then
    print("LogicBeginnerGuidance.BindOnMissionFailed not Character or not PlayerState")
    return
  end
  local MissionComp = Character.PlayerState:GetComponentByClass(UE.URGPlayerMissionComponent:StaticClass())
  if not MissionComp then
    print("LogicBeginnerGuidance.BindOnMissionFailed not MissionComp")
    return
  end
  local Instance = MissionComp:FindInstanceByHandle(Handle)
  print("LogicBeginnerGuidance.BindOnMissionFailed", Instance:GetMissionId())
  LogicBeginnerGuidance.HideBeginnerGuidanceMainPanel(Instance:GetMissionId())
end

function LogicBeginnerGuidance.Clear()
  LogicBeginnerGuidance.IsInit = false
  UnListenObjectMessage(GMP.MSG_Level_Guide_LevelFinished, self)
  UnListenObjectMessage(GMP.MSG_Level_Guide_ReturnToLobby, self)
  UnListenObjectMessage(GMP.MSG_Level_Guide_ChangeWhetherExecuteBeginGuideDecide, self)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character or not Character.PlayerState then
    print("not Character or not PlayerState")
    return
  end
  local MissionComp = Character.PlayerState:GetComponentByClass(UE.URGPlayerMissionComponent:StaticClass())
  if not MissionComp then
    return
  end
  MissionComp.OnMissionStarted:Remove(GameInstance, LogicBeginnerGuidance.BindOnMissionStarted)
  MissionComp.OnMissionFinished:Remove(GameInstance, LogicBeginnerGuidance.BindOnMissionStarted)
  MissionComp.OnMissionFailed:Remove(GameInstance, LogicBeginnerGuidance.BindOnMissionStarted)
end
