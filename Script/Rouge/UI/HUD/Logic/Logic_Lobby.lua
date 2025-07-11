require("UI.UIDef")
LogicLobby = LogicLobby or {
  IsInit = false,
  DistributionChannelList = {
    Normal = 0,
    WeGame = 1,
    LIPass = 2
  },
  IsExecuteBeginnerGuidance = true,
  IsShowModeSelection = false,
  IsFirstTeamInfoUpdate = true,
  IsNeedPlayAfterBeginnerGuidanceMovie = false,
  FliterShowGroundViewList = {
    [ViewID.UI_HttpRequestLoadingView] = 1,
    [ViewID.UI_Loading] = 1,
    [ViewID.UI_Mall_PurchaseConfirm] = 1,
    [ViewID.UI_CommonSmallPopups] = 1
  }
}
local rapidjson = require("rapidjson")
local LobbySaveGameName = "LobbySaveGame"
local BeginnerGuideHandler = require("Protocol.BeginnerGuide.BeginnerGuideHandler")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local LoginHandler = require("Protocol.LoginHandler")
local DealWithPlayerPortraitTable = function()
  if not TableNames.TBPortrait then
    return
  end
  local TableInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBPortrait)
  for ResourceId, SingleRowInfo in pairs(TableInfo) do
    LogicLobby.PlayerPortraitInfoList[SingleRowInfo.portraitID] = SingleRowInfo
  end
end
local DealWithLobbyPanelLabelTable = function()
  local AllRowNames = GetAllRowNames(DT.DT_LobbyPanelLabel)
  local Result, RowInfo, ParentTag = false
  for index, SingleRowName in ipairs(AllRowNames) do
    Result, RowInfo = GetRowData(DT.DT_LobbyPanelLabel, SingleRowName)
    if Result and RowInfo.IsOpen then
      ParentTag = UE.URGBlueprintLibrary.GetGameplayTagDirectParentTag(RowInfo.Tag)
      if not UE.URGBlueprintLibrary.IsEmptyTag(ParentTag) then
        local ParentTagName = UE.UBlueprintGameplayTagLibrary.GetTagName(ParentTag)
        local bResult, ParentRowInfo = GetRowData(DT.DT_LobbyPanelLabel, ParentTagName)
        if bResult then
          if ParentRowInfo.IsOpen then
            local TargetTable = LogicLobby.LabelParentChildTreeStruct[ParentTagName]
            if TargetTable then
              table.insert(TargetTable, SingleRowName)
            else
              LogicLobby.LabelParentChildTreeStruct[ParentTagName] = {SingleRowName}
            end
          end
        elseif not LogicLobby.LabelParentChildTreeStruct[SingleRowName] then
          LogicLobby.LabelParentChildTreeStruct[SingleRowName] = {}
        end
      elseif not LogicLobby.LabelParentChildTreeStruct[SingleRowName] then
        LogicLobby.LabelParentChildTreeStruct[SingleRowName] = {}
      end
      if RowInfo.IsDefaultSelected then
        LogicLobby.DefaultSelectedLabelName = SingleRowName
      end
      LogicLobby.UINameToLabelTagNameList[RowInfo.TargetUIName] = SingleRowName
      if RowInfo.ShelfIndex then
        LogicLobby.ShelfIndexToLabelTagNameList[RowInfo.ShelfIndex] = SingleRowName
      end
      if RowInfo.TargetUIName and RowInfo.TargetUIName ~= "" then
        LogicLobby.UINameToShelfIndex[ViewID[RowInfo.TargetUIName]] = RowInfo.ShelfIndex
      end
    end
  end
end
function LogicLobby.Init()
  if LogicLobby.IsInit then
    return
  end
  LogicLobby.IsUseLobbyDS = false
  LogicLobby.IsInit = true
  LogicLobby.UIWidget = nil
  LogicLobby.AllActorList = {}
  LogicLobby.RoomMemberActorList = {}
  LogicLobby.CanMove3DLobby = true
  LogicLobby.IsGoingBackToBattle = false
  LogicLobby.IsRequestJoinGameFromLogin = false
  LogicLobby.PlayerPortraitInfoList = {}
  LogicLobby.LabelParentChildTreeStruct = {}
  LogicLobby.DefaultSelectedLabelName = nil
  LogicLobby.UINameToLabelTagNameList = {}
  LogicLobby.ShelfIndexToLabelTagNameList = {}
  LogicLobby.UINameToShelfIndex = {}
  LogicLobby.CurSelectedLabelName = nil
  LogicLobby.PendingSelectedLabelName = nil
  LogicLobby.PendingSelectedRowName = nil
  LogicLobby.PendingParamList = nil
  LogicLobby.IsForceOpenBeginnerGuidanceLevel = false
  if UE.URGBlueprintLibrary.CheckWithEditor() then
    LogicLobby.IsExecuteBeginnerGuidance = false
  end
  LogicLobby.ShowGroundLevel = false
  EventSystem.AddListener(nil, EventDef.WSMessage.ConnectBattleServer, LogicLobby.BindOnConnectBattleServer)
  EventSystem.AddListener(nil, EventDef.WSMessage.GlobalAnnouncement, LogicLobby.BindGlobalAnnouncement)
  EventSystem.AddListener(nil, EventDef.Lobby.UpdateMyTeamInfo, LogicLobby.BindOnUpdateMyTeamInfo)
  EventSystem.AddListener(nil, EventDef.Lobby.UpdateResourceInfoByType, LogicLobby.BindOnUpdateResourceInfoByType)
  DealWithPlayerPortraitTable()
  DealWithLobbyPanelLabelTable()
  LogicLobby.InitLobbySaveGame()
end
function LogicLobby.InitLobbySaveGame(...)
  if not UE.UGameplayStatics.DoesSaveGameExist(LobbySaveGameName, 0) then
    local SaveGameObject = UE.UGameplayStatics.CreateSaveGameObject(UE.ULobbySaveGame:StaticClass())
    if SaveGameObject then
      UE.UGameplayStatics.SaveGameToSlot(SaveGameObject, LobbySaveGameName, 0)
    end
  end
end
function LogicLobby.SetIsNeedPlayAfterBeginnerGuidanceMovie(InIsNeed)
  LogicLobby.IsNeedPlayAfterBeginnerGuidanceMovie = InIsNeed
end
function LogicLobby.GetLobbySaveGame(...)
  local SaveGame = UE.UGameplayStatics.LoadGameFromSlot(LobbySaveGameName, 0)
  return SaveGame
end
function LogicLobby.SaveLobbySaveGame(LobbySaveGame)
  UE.UGameplayStatics.SaveGameToSlot(LobbySaveGame, LobbySaveGameName, 0)
end
function LogicLobby.GetPlayerPortraitTableRowInfo(PlayerPortraitId)
  return LogicLobby.PlayerPortraitInfoList[tonumber(PlayerPortraitId)]
end
function LogicLobby.GetLabelParentChildTreeStruct()
  return LogicLobby.LabelParentChildTreeStruct
end
function LogicLobby.GetDefaultSelectedLabelName()
  return LogicLobby.DefaultSelectedLabelName
end
function LogicLobby.SetCurSelectedLabelName(InLabelName)
  LogicLobby.CurSelectedLabelName = InLabelName
end
function LogicLobby.GetCurSelectedLabelName()
  return LogicLobby.CurSelectedLabelName
end
function LogicLobby.SetPendingSelectedLabelTagName(InLabelTagName)
  LogicLobby.PendingSelectedLabelName = InLabelTagName
end
function LogicLobby.GetPendingSelectedLabelTagName()
  return LogicLobby.PendingSelectedLabelName
end
function LogicLobby.SetPendingSelectedRowName(RowName)
  LogicLobby.PendingSelectedRowName = RowName
end
function LogicLobby.GetPendingSelectedRowName()
  return LogicLobby.PendingSelectedRowName
end
function LogicLobby.SetPendingParamList(ParamList)
  LogicLobby.PendingParamList = ParamList
end
function LogicLobby.GetPendingParamList()
  return LogicLobby.PendingParamList
end
function LogicLobby.GetLabelTagNameByUIName(UIName)
  return LogicLobby.UINameToLabelTagNameList[UIName]
end
function LogicLobby.GetLobbyLabelIsOpen(LobbyPanelTagName, showCloseTips)
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr then
    if string.find(LobbyPanelTagName, "LobbyLabel.Talent") then
      if not SystemOpenMgr:IsSystemOpen(SystemOpenID.TALENT, showCloseTips) then
        return false
      end
    elseif string.find(LobbyPanelTagName, "LobbyLabel.Season") then
      if not SystemOpenMgr:IsSystemOpen(SystemOpenID.SEASON, showCloseTips) then
        return false
      end
    elseif string.find(LobbyPanelTagName, "LobbyLabel.Mall") then
      if not SystemOpenMgr:IsSystemOpen(SystemOpenID.MALL, showCloseTips) then
        return false
      end
      if string.find(LobbyPanelTagName, "LobbyLabel.Mall.Recharge") then
        if not SystemOpenMgr:IsSystemOpen(SystemOpenID.PURCHASE, showCloseTips) then
          return false
        end
      elseif string.find(LobbyPanelTagName, "LobbyLabel.Mall.Recommend") then
        if not SystemOpenMgr:IsSystemOpen(SystemOpenID.RECOMMEND, showCloseTips) then
          return false
        end
      elseif string.find(LobbyPanelTagName, "LobbyLabel.Mall.Bundle") then
        if not SystemOpenMgr:IsSystemOpen(SystemOpenID.BUNDLE, showCloseTips) then
          return false
        end
      elseif "LobbyLabel.Mall.Exterior" == LobbyPanelTagName then
        if not SystemOpenMgr:IsSystemOpen(SystemOpenID.EXTERIOR, showCloseTips) then
          return false
        end
      elseif string.find(LobbyPanelTagName, "LobbyLabel.Mall.Props") then
        if not SystemOpenMgr:IsSystemOpen(SystemOpenID.PROPS, showCloseTips) then
          return false
        end
      elseif string.find(LobbyPanelTagName, "LobbyLabel.Mall.Exterior_1") then
        if not SystemOpenMgr:IsSystemOpen(SystemOpenID.EXTERIOR_1, showCloseTips) then
          return false
        end
      elseif string.find(LobbyPanelTagName, "LobbyLabel.Mall.MonthCard") and not SystemOpenMgr:IsSystemOpen(SystemOpenID.MONTHCARD, showCloseTips) then
        return false
      end
    elseif string.find(LobbyPanelTagName, "LobbyLabel.IllustratedGuideMenu") and not SystemOpenMgr:IsSystemOpen(SystemOpenID.TU_JIAN, showCloseTips) then
      return false
    end
  end
  local result, row = GetRowData(DT.DT_LobbyPanelLabel, LobbyPanelTagName)
  if result and row.SystemId >= 0 then
    local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
    if SystemUnlockModule and not SystemUnlockModule:CheckIsSystemUnlock(row.SystemId) then
      return false
    end
  end
  return true
end
function LogicLobby.ChangeLobbyPanelLabelSelected(LobbyPanelTagName, CommonLinkRow, ParamList)
  if LogicLobby.GetLobbyLabelIsOpen(LobbyPanelTagName, true) then
    local CurShowLabelName = LogicLobby.GetCurSelectedLabelName()
    if CurShowLabelName and CurShowLabelName == LobbyPanelTagName then
      print("LogicLobby.ChangeLobbyPanelLabelSelected \229\189\147\229\137\141\233\161\181\231\173\190\230\178\161\230\156\137\228\191\174\230\148\185")
      return false
    end
    if CurShowLabelName then
      local Result, RowInfo = GetRowData(DT.DT_LobbyPanelLabel, CurShowLabelName)
      if Result then
        local View = UIMgr:GetLuaFromActiveView(ViewID[RowInfo.TargetUIName])
        if View and View.CanDirectSwitch and not View:CanDirectSwitch() then
          LogicLobby.SetPendingSelectedLabelTagName(LobbyPanelTagName)
          LogicLobby.SetPendingSelectedRowName(CommonLinkRow)
          LogicLobby.SetPendingParamList(ParamList)
          return false
        end
      end
    end
    EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LobbyPanelTagName, CommonLinkRow)
  end
end
function LogicLobby.InitCameraStateMachine()
  local Class = UE.UClass.Load("/Game/Rouge/Gameplay/Lobby/BP_LobbyCameraState.BP_LobbyCameraState_C")
  LogicLobby.CameraStateMachineInstance = UE.USMBlueprintUtils.CreateStateMachineInstance(Class, GameInstance, true)
  if LogicLobby.CameraStateMachineInstance and LogicLobby.CameraStateMachineInstance:IsValid() then
    LogicLobby.CameraStateMachineInstanceRef = UnLua.Ref(LogicLobby.CameraStateMachineInstance)
    LogicLobby.CameraStateMachineInstance:Start()
  end
  return LogicLobby.CameraStateMachineInstance
end
function LogicLobby.GetCanMove3DLobby()
  return LogicLobby.CanMove3DLobby
end
function LogicLobby.SetCanMove3DLobby(CanMove)
  LogicLobby.CanMove3DLobby = CanMove
end
function LogicLobby.BindOnConnectBattleServer(Json)
  if LogicAutoRobot and LogicAutoRobot.GetIsAutoBot() then
    return
  end
  local JsonTable = rapidjson.decode(Json)
  if JsonTable.method == "connectBattleServer" then
    local ExecCmds = CmdLineMgr.FindParam("ExecCmds")
    local DisableLoadingMovie = ExecCmds and string.find(ExecCmds, "rg.Game.EnableLoadingUI 0")
    if LogicLobby.IsGoingBackToBattle or DisableLoadingMovie then
      UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType()
    else
      UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType("LobbyToBattle")
    end
    local DSInfo = {
      Id = "",
      publicIp = JsonTable.ip,
      innerIp = JsonTable.ip,
      tcpPort = JsonTable.tcpPort,
      udpPort = JsonTable.udpPort,
      name = JsonTable.name,
      BattleId = JsonTable.gameId
    }
    DataMgr.SetDSInfo(DSInfo)
    local LevelName = DSInfo.publicIp .. ":" .. DSInfo.udpPort
    local BasicInfo = DataMgr.GetBasicInfo()
    local DSCheckVersion = GetVersionID()
    local Options = "Version=" .. DSCheckVersion .. "?" .. "UserId=" .. DataMgr.GetUserId()
    if UE.URGGameplayStatics:IsSwitchOnSpectatorMode() then
      Options = Options .. "?SpectatorOnly=1"
    end
    print("LevelName" .. LevelName, "Options", Options)
    local DebugDSName = CmdLineMgr.FindParam("DebugDSName")
    if DSInfo.publicIp == "127.0.0.1" and nil == DebugDSName then
      UE.URGGameplayLibrary.TriggerOnClientStartBattle(GameInstance, DSInfo.name, true)
      LogicLobby.PlayInStandalone(Options)
    else
      UE.URGGameplayLibrary.TriggerOnClientStartBattle(GameInstance, DSInfo.name)
      LogicLobby.OpenLevelByName(LevelName, Options)
    end
    if LogicLobby.IsGoingBackToBattle then
    end
    LogicLobby.IsGoingBackToBattle = false
    LogicRole.RequestMyHeroInfoToServer()
    local ContactPersonManager = ModuleManager:Get("ContactPersonModule")
    if ContactPersonManager then
      local TeamIdList = {}
      local TeamInfo = DataMgr.GetTeamInfo()
      if TeamInfo.players then
        for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
          if SinglePlayerInfo.id ~= DataMgr.GetUserId() then
            table.insert(TeamIdList, SinglePlayerInfo.id)
          end
        end
      end
      ContactPersonManager:SaveRecentPlayerList(DataMgr.GetUserId(), TeamIdList)
    end
  end
end
function LogicLobby.BindGlobalAnnouncement(Json)
  local JsonTable = rapidjson.decode(Json)
  ShowWaveWindow(15029, {
    JsonTable.announcement
  })
end
function LogicLobby.CheckReConBattle()
  HttpCommunication.RequestByGet("team/getmyteamdata", {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if JsonTable.state == LogicTeam.TeamState.Battle and not LogicLobby.IsRequestJoinGameFromLogin then
        local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
        if not WaveWindowManager then
          return
        end
        if JsonTable.gameMode == TableEnums.ENUMGameMode.BEGINERGUIDANCE then
          WaveWindowManager:ShowWaveWindowWithDelegate(20002, {}, nil, {
            GameInstance,
            LogicLobby.GiveUpBattle
          })
        else
          WaveWindowManager:ShowWaveWindowWithDelegate(20000, {}, nil, {
            GameInstance,
            LogicLobby.GoBackBattle
          }, {
            GameInstance,
            LogicLobby.GiveUpBattle
          })
        end
      end
    end
  })
end
function LogicLobby.GoBackBattle(Target, JsonResponse)
  if LogicTeam.CurTeamState ~= LogicTeam.TeamState.Battle then
    return
  end
  LogicLobby.IsGoingBackToBattle = true
  UIMgr:Show(ViewID.UI_GoingToBattle)
  HttpCommunication.Request("playerservice/gobackbattle", {}, {
    GameInstance,
    function(self, JsonResponse)
      print("GoBackBattle Success!")
    end
  }, {
    GameInstance,
    function()
      print("GoBackBattle Fail!")
      local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if not WaveWindowManager then
        return
      end
      UIMgr:Hide(ViewID.UI_GoingToBattle)
      WaveWindowManager:ShowWaveWindowWithDelegate(20000, {}, nil, {
        GameInstance,
        LogicLobby.GoBackBattle
      }, {
        GameInstance,
        LogicLobby.GiveUpBattle
      })
    end
  })
end
function LogicLobby.GiveUpBattle(Target, JsonResponse)
  if LogicTeam.CurTeamState ~= LogicTeam.TeamState.Battle then
    return
  end
  HttpCommunication.Request("playerservice/giveupbattle", {}, {
    GameInstance,
    function(self, JsonResponse)
      print("GiveUpBattle Success")
      LogicTeam.RequestGetMyTeamDataToServer()
    end
  }, {
    GameInstance,
    function()
      print("GiveUpBattle fail")
      LogicTeam.RequestGetMyTeamDataToServer()
    end
  })
end
function LogicLobby.RequestAllGameModeFloorDataToServer()
  LogicLobby.RequestGetGameFloorDataToServer()
end
function LogicLobby.RequestGetGameFloorDataToServer(Callback)
  local url = "playergrowth/gamefloor/rolesgamefloordata"
  HttpCommunication.Request(url, {
    roleIDs = {
      DataMgr.GetUserId()
    }
  }, {
    GameInstance,
    function(Target, JsonResponse)
      print("SendRolesGameFloorData Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      local MyGameFloorData = JsonTable.rolesGameFloorData[DataMgr.GetUserId()]
      if MyGameFloorData then
        for modeid, modeinfo in pairs(MyGameFloorData.gameModeAndWorldAndFloorData) do
          DataMgr.SetGameFloorInfo(tonumber(modeid), modeinfo.gameWorldAndFloorData)
        end
        EventSystem.Invoke(EventDef.Lobby.OnUpdateGameFloorInfo)
      end
      if Callback then
        Callback()
      end
      if MyGameFloorData then
        for ModeId, ModeInfo in pairs(MyGameFloorData.gameModeAndWorldAndFloorData) do
          LogicLobby.SaveGameFloorData(tonumber(ModeId), ModeInfo.gameWorldAndFloorData)
        end
      end
      EventSystem.Invoke(EventDef.Lobby.GetRolesGameFloorData, LogicTeam.RolesGameFloorInfo)
    end
  }, {
    GameInstance,
    function()
      print("SendRolesGameFloorData fail!")
    end
  })
end
function LogicLobby.SaveGameFloorData(ModeId, ModeData)
  local LobbySaveGame = LogicLobby.GetLobbySaveGame()
  if LobbySaveGame then
    LobbySaveGame:SetGameFloorData(DataMgr.GetUserId(), ModeId, ModeData)
    UE.UGameplayStatics.SaveGameToSlot(LobbySaveGame, LobbySaveGameName, 0)
  end
end
function LogicLobby.BindOnUpdateMyTeamInfo()
  print("LogicLobby.BindOnUpdateMyTeamInfo")
  if LogicLobby.IsRequestJoinGameFromLogin then
    print("LogicLobby.BindOnUpdateMyTeamInfo IsRequestJoinGameFromLogin")
    return
  end
  local LevelName = UE.UGameplayStatics.GetCurrentLevelName(GameInstance, true)
  if "Lobby" ~= LevelName and "Login" ~= LevelName then
    print("LogicLobby.BindOnUpdateMyTeamInfo \229\189\147\229\137\141\229\156\176\229\155\190\228\184\141\229\156\168Login\230\136\150Lobby")
    return
  end
  local TeamInfo = DataMgr.GetTeamInfo()
  local IsNeedJoinGame = false
  for index, SingleTeamPlayerInfo in ipairs(TeamInfo.players) do
    if SingleTeamPlayerInfo.id == DataMgr.GetUserId() and 1 == SingleTeamPlayerInfo.battleState then
      IsNeedJoinGame = true
      break
    end
  end
  if IsNeedJoinGame then
    print("LogicLobby.BindOnUpdateMyTeamInfo \232\161\165\229\143\145JoinGame\232\175\183\230\177\130")
    LogicLobby.IsRequestJoinGameFromLogin = true
    LogicTeam.RequestJoinGameToServer()
  end
end
function LogicLobby.BindOnUpdateResourceInfoByType(Type)
  if Type == TableEnums.ENUMResourceType.HERO then
    print("LogicLobby.BindOnUpdateResourceInfoByType")
    LogicRole.RequestMyHeroInfoToServer()
  end
end
function LogicLobby.GetCombatPowerCoefficcent(WorldId, Floor)
  local CurCombatPower = 0
  local CommonTalentInfo = DataMgr.GetCommonTalentInfos()
  if CommonTalentInfo then
    local SumLevel = 0
    for TalentGroupId, TalentGroupInfo in pairs(CommonTalentInfo) do
      SumLevel = SumLevel + DataMgr.GetCommonTalentLevelById(TalentGroupId)
    end
    CurCombatPower = CurCombatPower + SumLevel * 100
  end
  local CurEquipHeroId = DataMgr.GetMyHeroInfo().equipHero
  local RarityScoreList = {}
  local RowNames = GetAllRowNames(DT.DT_ItemRarity)
  for k, SingleRowName in pairs(RowNames) do
    local Result, RowInfo = GetRowData(DT.DT_ItemRarity, SingleRowName)
    RarityScoreList[RowInfo.ItemRarity] = RowInfo.CombatPowerScore
  end
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  for PuzzleId, PuzzlePackageInfo in pairs(AllPackageInfo) do
    if PuzzlePackageInfo.equipHeroID == CurEquipHeroId then
      local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(PuzzleId)
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
      if Result then
        CurCombatPower = CurCombatPower + RarityScoreList[RowInfo.Rare] * (1 + PuzzlePackageInfo.level * 0.2)
      end
    end
  end
  print("LogicLobby.CalculateCombatPowerCoefficcent", CurCombatPower)
  local WorldId = WorldId or LogicTeam.GetWorldId()
  local Floor = Floor or LogicTeam.GetFloor()
  local TargetLevelIndex
  local AllLevels = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  for LevelID, LevelFloorInfo in pairs(AllLevels) do
    if LevelFloorInfo.gameWorldID == WorldId and LevelFloorInfo.floor == Floor then
      TargetLevelIndex = LevelID
      break
    end
  end
  if not TargetLevelIndex then
    return -1
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, TargetLevelIndex)
  local CombatPowerCondition = RowInfo.CombatPowerCondition
  local TargetText
  if 0 == CombatPowerCondition then
    return -1
  else
    local Coefficient = CurCombatPower / CombatPowerCondition
    return Coefficient
  end
end
function LogicLobby.GetHeroIndex()
  local HeroInfo = DataMgr.GetMyHeroInfo()
  return HeroInfo.equipHero and HeroInfo.equipHero or 0
end
function LogicLobby.SetVersionCosCheckTimer()
  local TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    LogicLobby.CheckCosVersion
  }, 30.0, true)
  return TimerHandle
end
function LogicLobby.CheckCosVersion()
  local Hash = 0
  local FilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "PersistentDownloadDir/Script/Tables/VersionMd5.txt"
  if UE.UBlueprintPathsLibrary.FileExists(FilePath) then
    local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(FilePath, nil)
    if Result and not UE.UKismetStringLibrary.IsEmpty(FileStr) then
      Hash = FileStr
    end
  end
  local Version = GetVersionID()
  local RGLobbySettings = UE.URGLobbySettings.GetLobbySettings()
  local Path = "http://127.0.0.1:" .. RGLobbySettings.RGLocalServerPort .. "/check_mod?version=" .. Version .. "&hash=" .. Hash
  if HttpCommunication then
    HttpCommunication.RequestByGetWithCosCheck(Path, {
      GameInstance,
      function(Target, JsonResponse)
        print("Check_Mod" .. JsonResponse.Content)
        local JsonTable = rapidjson.decode(JsonResponse.Content)
        if JsonTable.content.result then
          local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
          if RGWaveWindowManager then
            RGWaveWindowManager:ShowWaveWindowWithDelegate(1800001, {}, nil, {
              GameInstance,
              function()
                UE.UKismetSystemLibrary.QuitGame(self, UE.UGameplayStatics.GetPlayerController(self, 0), UE.EQuitPreference.Quit, false)
              end
            })
          end
        end
      end
    })
  end
end
function LogicLobby.HandleOnLIWebViewResult(INTLWebViewResult)
  print("LogicLobby.HandleOnLIWebViewResult", INTLWebViewResult.MsgType, INTLWebViewResult.MsgJsonData)
  local JsonData = rapidjson.decode(INTLWebViewResult.MsgJsonData)
  if JsonData.type == "request_delete_account_success" then
    print("LogicLobby.HandleOnLIWebViewResult \229\136\160\233\153\164\232\180\166\229\143\183\231\148\179\232\175\183\230\136\144\229\138\159, 5\231\167\146\229\144\142\233\128\128\229\135\186\230\184\184\230\136\143")
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
        if PC and PC.LeaveFromMatch then
          PC:LeaveFromMatch()
        end
        LoginHandler.RequestLogoutToServer()
        UE.UKismetSystemLibrary.QuitGame(GameInstance, UE.UGameplayStatics.GetPlayerController(GameInstance, 0), UE.EQuitPreference.Quit, false)
      end
    }, 5.0, false)
  end
end
function LogicLobby.DeleteAccount()
  if UE.URGPlatformFunctionLibrary.IsLIPassEnabled() then
    local LIPassSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.ULIPassSubsystem:StaticClass())
    if LIPassSystem then
      LIPassSystem:DeleteAccount(DataMgr.GetPlayerNickNameById(DataMgr.GetUserId()))
    end
  end
end
function LogicLobby.Clear()
  LogicLobby.UIWidget = nil
  LogicLobby.AllActorList = {}
  LogicLobby.RoomMemberActorList = {}
  LogicLobby.LastDSURL = ""
  LogicLobby.IsInit = false
  LogicLobby.IsRequestJoinGameFromLogin = false
  LogicLobby.CurSelectedLabelName = nil
  LogicLobby.PendingSelectedLabelName = nil
  LogicLobby.PendingSelectedRowName = nil
  LogicLobby.PendingParamList = nil
  LogicLobby.IsForceOpenBeginnerGuidanceLevel = false
  if LogicLobby.CameraStateMachineInstance and LogicLobby.CameraStateMachineInstance:IsValid() then
    UnLua.Unref(LogicLobby.CameraStateMachineInstance)
    LogicLobby.CameraStateMachineInstanceRef = nil
    LogicLobby.CameraStateMachineInstance:Stop()
    LogicLobby.CameraStateMachineInstance = nil
  end
  EventSystem.RemoveEventAllListener(EventDef.WSMessage.ConnectBattleServer)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, LogicLobby.BindOnUpdateMyTeamInfo)
  EventSystem.RemoveListener(EventDef.WSMessage.GlobalAnnouncement, LogicLobby.BindGlobalAnnouncement)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateResourceInfoByType, LogicLobby.BindOnUpdateResourceInfoByType)
end
function LogicLobby.GetVersionID()
  return GetVersionID()
end
function LogicLobby.GetBrunchType()
  local VersionSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URGVersionSubsystem:StaticClass())
  if not VersionSubsystem then
    return "trunk"
  end
  return VersionSubsystem.Branch ~= "" and VersionSubsystem.Branch or "trunk"
end
function LogicLobby:InitWidgetBindEvent()
end
function LogicLobby:ChangeLobbyBGVis(IsHide)
  local RoleBGList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "RoleBG", nil)
  local RoleBG
  for i, SingleRoleBG in iterator(RoleBGList) do
    RoleBG = SingleRoleBG
    break
  end
  if RoleBG then
    RoleBG:SetActorHiddenInGame(not IsHide)
  end
  local LobbyBGList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "LobbyBG", nil)
  local LobbyBG
  for i, SingleLobbyBG in iterator(LobbyBGList) do
    LobbyBG = SingleLobbyBG
    break
  end
  if LobbyBG then
    LobbyBG:SetActorHiddenInGame(IsHide)
  end
end
function LogicLobby.PlayInStandalone(Options)
  HttpCommunication.RequestByGet("team/getplayerbattledata", {
    GameInstance,
    function(Target, JsonResponse)
      print("PlayInStandalone Json =" .. JsonResponse.Content)
      print("PlayInStandalone Options=" .. Options)
      local LevelName = "Server_Default"
      LogicLobby.OpenLevelByName(LevelName, Options)
      local MatchSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGMatchSubsystem:StaticClass())
      MatchSubsystem:StartMatchFromJsonString(JsonResponse.Content, LogicTeam.GetModeId(), LogicTeam.GetWorldId(), LogicTeam.GetFloor(), DataMgr.GetDSInfo().BattleId)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function LogicLobby.OpenLobbyLevel()
  if not LogicAutoRobot or not LogicAutoRobot.GetIsAutoBot() then
    LogicLobby.OpenLevelByName("Lobby")
  else
    LogicLobby.OpenLevelByName("Login")
  end
end
function LogicLobby.OpenLevelByName(LevelName, Options)
  Options = Options or ""
  DataMgr.SetPreSceneStatus(GetCurSceneStatus())
  UE.URGProfilerLibrary.SetApmEnteringNewScene(GameInstance)
  UE.UGameplayStatics.OpenLevel(GameInstance, LevelName, true, Options)
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  if not RGGameUserSettings then
    return
  end
  if "Lobby" == LevelName then
    RGGameUserSettings:SetForceDisableDLSS(true)
    RGGameUserSettings:SetForceDisableFSR2(true)
  else
    RGGameUserSettings:SetForceDisableDLSS(false)
    RGGameUserSettings:SetForceDisableFSR2(false)
  end
end
function LogicLobby.CheckNeedOpenBeginGuidanceLevel()
  print("LogicLobby.CheckNeedOpenBeginGuidanceLevel")
  BeginnerGuideHandler.RequestGetFinishedGuideListFromServer({
    GameInstance,
    function(Target, JsonResponse)
      if UE.UKismetStringLibrary.IsEmpty(HttpCommunication.GetToken()) then
        print("LogicLobby.CheckNeedOpenBeginGuidanceLevel Token is empty")
        return
      end
      local JsonTable = rapidjson.decode(JsonResponse)
      BeginnerGuideData.freshmanFightFinished = JsonTable.freshmanFightFinished
      if not JsonTable.freshmanFightFinished or LogicLobby.IsForceOpenBeginnerGuidanceLevel then
        local RGTutorialLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
        if RGTutorialLevelSystem then
          RGTutorialLevelSystem:SetIsFreshPlayer(true)
        end
        local RGMovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGMovieSubSystem:StaticClass())
        local MoviePlayerObj = RGMovieSubsystem:GetDefaultMoviePlayer()
        if not MoviePlayerObj then
          print("not MoviePlayer Object")
          return
        end
        local CurrentMovieId = MoviePlayerObj:GetCurrentMovieId()
        print("CurrentMovieId", CurrentMovieId)
        local Settings = UE.URGLobbySettings.GetLobbySettings()
        if CurrentMovieId ~= Settings.AfterSetUserNickNameCGMovieId then
          print("\229\189\147\229\137\141\230\178\161\230\156\137\230\146\173\230\148\190\232\174\190\231\189\174\229\144\141\229\173\151\229\144\142\233\156\128\232\166\129\231\154\132cg, \231\155\180\230\142\165\229\136\135\230\141\162\229\136\176\230\150\176\230\137\139\229\133\179")
          LogicLobby.OpenBeginnerGuidanceLevel()
        else
          print("\230\150\176\230\137\139\229\133\179\230\173\163\229\156\168\230\146\173\232\167\134\233\162\145\228\184\173")
        end
      else
        print("LogicLobby.CheckNeedOpenBeginGuidanceLevel \230\150\176\230\137\139\229\133\179\229\183\178\229\174\140\230\136\144\239\188\140\229\136\135\230\141\162\229\136\176\229\164\167\229\142\133")
        LogicLobby.OpenLobbyLevel()
      end
    end
  }, {
    GameInstance,
    function()
      LogicLobby.OpenLobbyLevel()
    end
  })
end
function LogicLobby.OpenBeginnerGuidanceLevel()
  print("LogicLobby.OpenBeginnerGuidanceLevel")
  local RGTutorialLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
  if not RGTutorialLevelSystem then
    print("LogicLobby.OpenBeginnerGuidanceLevel not RGTutorialLevelSystem")
    return
  end
  LogicLobby.NeedRefreshModeToBD = true
  UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType("LoginToTutorial")
  local UserId = DataMgr.GetUserId()
  local PlayerInfo = DataMgr.GetBasicInfo()
  RGTutorialLevelSystem:SetRoleId(tonumber(UserId), PlayerInfo.nickname)
  RGTutorialLevelSystem:StartLevel()
  UE.URGGameplayLibrary.TriggerOnClientStartBattle(GameInstance, "Local")
end
function LogicLobby.RequestGetRoleListInfoToServer(RoleList, SuccessFuncCallback)
  DataMgr.GetOrQueryPlayerInfo(RoleList, true, function(PlayerCacheInfoList)
    local PlayerInfoList = DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoList)
    if SuccessFuncCallback then
      SuccessFuncCallback[2](SuccessFuncCallback[1], PlayerInfoList)
    end
  end, function()
  end)
end
function LogicLobby.IsInLobbyLevel()
  local LevelName = UE.UGameplayStatics.GetCurrentLevelName(GameInstance, true)
  return "Lobby" == LevelName
end
function LogicLobby.ChangeLobbyMainModelVis(IsVis)
  local MaxTeamNum = 3
  local LobbySettings = UE.URGLobbySettings.GetSettings()
  if LobbySettings then
    MaxTeamNum = LobbySettings.LobbyRoomMaxMember
  end
  for i = 1, MaxTeamNum do
    local OutActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "LobbyMain" .. i):ToTable()
    if OutActors[1] then
      OutActors[1].ChildActor:SetHiddenInGame(not IsVis)
      if OutActors[1].ChildActor.ChildActor then
        OutActors[1].ChildActor.ChildActor:SetHiddenInGame(not IsVis)
      end
    end
  end
end
function LogicLobby.ShowOrHideGround(IsShow)
  if UE.RGUtil.IsUObjectValid(LogicLobby.GroundLevel) then
    if LogicLobby.ShowGroundLevel ~= IsShow then
      LogicLobby.GroundLevel:SetShouldBeVisible(IsShow)
      LogicLobby.ShowGroundLevel = IsShow
    end
  else
    LogicLobby.GroundLevel = UE.UGameplayStatics.GetStreamingLevel(GameInstance, "Hero_Ground")
    if UE.RGUtil.IsUObjectValid(LogicLobby.GroundLevel) then
      LogicLobby.GroundLevel:SetShouldBeLoaded(true)
      LogicLobby.GroundLevel:SetShouldBeVisible(IsShow)
      LogicLobby.ShowGroundLevel = IsShow
    end
  end
end
function LogicLobby.ShowOrHideDrawCardLevel(IsShow)
  if UE.RGUtil.IsUObjectValid(LogicLobby.DrawCardLevel) then
    if LogicLobby.DrawCardLevel.bShouldBeVisible ~= IsShow then
      LogicLobby.DrawCardLevel:SetShouldBeVisible(IsShow)
    end
  else
    LogicLobby.DrawCardLevel = UE.UGameplayStatics.GetStreamingLevel(GameInstance, "Draw")
    if UE.RGUtil.IsUObjectValid(LogicLobby.DrawCardLevel) then
      LogicLobby.DrawCardLevel:SetShouldBeLoaded(true)
      LogicLobby.DrawCardLevel:SetShouldBeVisible(IsShow)
    end
  end
end
function LogicLobby.ChangeHeroSelectionModelVis(IsVis)
  local MaxTeamNum = 3
  local LobbySettings = UE.URGLobbySettings.GetSettings()
  if LobbySettings then
    MaxTeamNum = LobbySettings.LobbyRoomMaxMember
  end
  for i = 1, MaxTeamNum do
    local OutActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "HeroSelectRole" .. i):ToTable()
    if OutActors[1] then
      OutActors[1].ChildActor:SetHiddenInGame(not IsVis)
    end
  end
  local OutActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "CloseShotHeroSelectRole"):ToTable()
  if OutActors[1] then
    OutActors[1].ChildActor:SetHiddenInGame(not IsVis)
  end
end
function LogicLobby.ChangeModeSelectionVideoState(IsPlay)
  LogicLobby.IsShowModeSelection = IsPlay
end
function LogicLobby.InitModeSelectionMaterialParamValue()
  local OutActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "ModeSelectionScreenVideo"):ToTable()
  local TargetActor = OutActors[1]
  if not TargetActor then
    print("LogicLobby.InitModeSelectionMaterialParamValue not found actor")
    return
  end
  local StaticMeshComp = TargetActor:GetComponentByClass(UE.UStaticMeshComponent:StaticClass())
  if not StaticMeshComp then
    return
  end
  local AllMaterials = StaticMeshComp:GetMaterials()
  for Index, SingleMaterial in pairs(AllMaterials) do
    local MaterialInstance = StaticMeshComp:CreateDynamicMaterialInstance(Index - 1, SingleMaterial, "None")
    if MaterialInstance then
      MaterialInstance:SetScalarParameterValue("Tex2Vedio", 0.0)
    end
  end
end
function LogicLobby.ShowLobbyStreamLevelByName(Name)
  LogicLobby.HideAllLobbyStreamLevel(Name)
  local Result, RowInfo = GetRowData(DT.DT_LobbyStreamLevel, Name)
  if not Result then
    print("LogicLobby.ShowLobbyStreamLevelByName not found RowInfo, RowName:", Name)
    return
  end
  local LevelPath = UE.UKismetSystemLibrary.BreakSoftObjectPath(RowInfo.Level, nil)
  local PathPart, FileNamePart, ExtensionPart = UE.UBlueprintPathsLibrary.Split(LevelPath, nil, nil, nil)
  local TargetStreamLevel = UE.UGameplayStatics.GetStreamingLevel(GameInstance, FileNamePart)
  if TargetStreamLevel and not TargetStreamLevel.bShouldBeVisible then
    TargetStreamLevel:SetShouldBeVisible(true)
  end
end
function LogicLobby.HideLobbyStreamLevelByName(Name)
  local Result, RowInfo = GetRowData(DT.DT_LobbyStreamLevel, Name)
  if not Result then
    print("LogicLobby.HideLobbyStreamLevelByName not found RowInfo, RowName:", Name)
    return
  end
  local LevelPath = UE.UKismetSystemLibrary.BreakSoftObjectPath(RowInfo.Level, nil)
  local PathPart, FileNamePart, ExtensionPart = UE.UBlueprintPathsLibrary.Split(LevelPath, nil, nil, nil)
  local TargetStreamLevel = UE.UGameplayStatics.GetStreamingLevel(GameInstance, FileNamePart)
  if TargetStreamLevel and TargetStreamLevel.bShouldBeVisible then
    TargetStreamLevel:SetShouldBeVisible(false)
  end
end
function LogicLobby.HideAllLobbyStreamLevel(ExculdeName)
  local AllRowNames = GetAllRowNames(DT.DT_LobbyStreamLevel)
  local PathPart, FileNamePart, ExtensionPart = "", "", ""
  local TargetStreamLevel
  for index, SingleRowName in ipairs(AllRowNames) do
    local Result, RowInfo = GetRowData(DT.DT_LobbyStreamLevel, SingleRowName)
    if Result and (not ExculdeName or ExculdeName ~= SingleRowName) then
      local LevelPath = UE.UKismetSystemLibrary.BreakSoftObjectPath(RowInfo.Level, nil)
      PathPart, FileNamePart, ExtensionPart = UE.UBlueprintPathsLibrary.Split(LevelPath, nil, nil, nil)
      TargetStreamLevel = UE.UGameplayStatics.GetStreamingLevel(GameInstance, FileNamePart)
      if TargetStreamLevel and TargetStreamLevel.bShouldBeVisible then
        TargetStreamLevel:SetShouldBeVisible(false)
      end
    end
  end
end
function LogicLobby.GetAppearanceActor(WorldContextObject)
  if not UE.RGUtil.IsUObjectValid(LogicLobby.AppearanceActor) then
    local AppearanceActorCls = UE.UClass.Load("/Game/Rouge/UI/Appearance/AppearanceActor/BP_Appearance.BP_Appearance_C")
    local CameraActorList = UE.UGameplayStatics.GetAllActorsOfClass(WorldContextObject, AppearanceActorCls, nil)
    if CameraActorList:Num() >= 1 then
      LogicLobby.AppearanceActor = CameraActorList:Get(1)
    end
  end
  return LogicLobby.AppearanceActor
end
function LogicLobby.IsLIPassLogin()
  local DistChannel = DataMgr.GetDistributionChannel()
  return DistChannel == LogicLobby.DistributionChannelList.LIPass
end
