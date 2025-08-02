require("Rouge.Gameplay.C2SCommunication.Logic_HttpCommunication")
require("Rouge.Gameplay.C2SCommunication.Logic_WSCommunication")
require("Rouge.UI.HUD.Logic.Logic_Lobby")
require("Rouge.UI.Battle.Logic.Logic_AutoRobot")
require("Rouge.UI.Lobby.Logic.Logic_GameSetting")
require("Rouge.UI.Lobby.Logic.Logic_Avatar")
require("Modules.ContactPerson.ContactPersonData")
require("Rouge.UI.IllustratedGuide.Logic_IllustratedGuide")
require("Rouge.UI.Lobby.Logic.Logic_OutsideWeapon")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local rapidjson = require("rapidjson")
local LoginData = require("Modules.Login.LoginData")
local PandoraModule = require("Modules.Pandora.PandoraModule")
local OnlineAntiAddictionModule = require("Modules.OnlineAntiAddiction.OnlineAntiAddictionModule")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local TopupData = require("Modules.Topup.TopupData")
local BP_LoginController_C = UnLua.Class()
local BanTipId = 303005

function BP_LoginController_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if self:IsLocalController() then
    LogicLobby.Init()
    HttpCommunication.Init()
    WSCommunication.Init()
    LogicGameSetting.Init()
    OnlineAntiAddictionModule.InitBindEvent()
    LogicOutsideWeapon.Init()
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
    if UIManager then
      UIManager:Reset(self)
      UIManager:PreloadWithAllScene(UE.EPreLoadScene.Login)
    end
    UE.URGUIEffectMgr.Get(GameInstance):Reset()
    print("by chj BP_LoginController_C ReceiveBeginPlay")
    print("BP_LoginController_C:ReceiveBeginPlay CursorVirtualFocus 0")
    UE.URGBlueprintLibrary.CursorVirtualFocus(0)
    local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
    if RGHttpClientMgr then
      RGHttpClientMgr.OnHttpBusinessErrorTip:Add(self, self.BindOnHttpBusinessErrorTip)
      RGHttpClientMgr.OnHttpBanDelegate:Add(self, self.BindOnHttpBanDelegate)
    end
    DataMgr.Reset()
    ChatDataMgr.ClearData()
    DataMgr.ClearData()
    DataMgr.ClearPlayerInfoData()
    local SkinViewModel = UIModelMgr:Get("SkinViewModel")
    if SkinViewModel then
      SkinViewModel:InitHeroSkinList()
    else
      print("SkinViewModel Is Nil")
    end
    PuzzleData:DealWithTable()
    TopupData:DealWithTable()
    DataMgr.InitData()
    EventSystem.Invoke(EventDef.Login.DataResetWhenLogin)
    UIMgr:Init()
    UIMgr:Reset()
    local GateService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UWSGateService:StaticClass())
    if GateService and (not LogicAutoRobot or not LogicAutoRobot.GetIsAutoBot()) then
      print("BP_LoginController_C DisConnect Websocket")
      GateService:Disconnect()
    end
    if GameInstance.IsNetWorkError then
      print("LoginController StartNetWorkError")
      WSCommunication.StartExecuteReconnectFailLogic()
      local NetWorkErrorTipId = GameInstance:GetNetworkErrorTipId()
      ShowWaveWindow(NetWorkErrorTipId, {
        UE.ENetworkFailure:GetNameByValue(GameInstance.NetErrorType)
      })
      GameInstance.IsNetWorkError = false
    end
    if self:IsAutoProcess() then
      RGUIMgr:OpenUI(UIConfig.WBP_AutoProcessPanel_C.UIName)
    else
      local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
      local RootWidget = UIManager:GetRootWidget()
      if not RootWidget or not RootWidget:IsValid() then
        local RootPanelClass = GetAssetByPath("/Game/Rouge/UI/HUD/WBP_RootPanel.WBP_RootPanel_C", true)
        UIManager:CreateRootWidget(RootPanelClass, 20)
      end
      if WSCommunication.IsNeedShowAnnouncement then
        PandoraModule:OpenAnnounceApp()
        WSCommunication.IsNeedShowAnnouncement = false
      end
      UIMgr:Show(ViewID.UI_Login)
      self.bShowMouseCursor = true
    end
    if UE.UGVoiceSubsystem ~= nil then
      local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
      if GVoice then
        GVoice:QuitTeamRoom()
        GVoice:ReleaseGVoiceEngine()
      end
    end
    local RedDotModule = ModuleManager:Get("RedDotModule")
    if RedDotModule then
      RedDotModule:SaveRedDotDataToLocal()
    end
    local TeamVoiceModule = ModuleManager:Get("TeamVoiceModule")
    if TeamVoiceModule then
      TeamVoiceModule:InitGVoice()
    end
  end
end

function BP_LoginController_C:BindOnHttpBusinessErrorTip(ErrorCode, ErrorMsg)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager or "" == ErrorMsg then
    return
  end
  local TargetId = tonumber(ErrorCode)
  local Params = {}
  local Result, PromptRowInfo = GetRowData(DT.DT_SystemPrompt, ErrorCode)
  if not Result then
    TargetId = 100001
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBErrorCode, tonumber(ErrorCode))
    if Result then
      table.insert(Params, RowInfo.Tips)
    end
  end
  if 30004 == TargetId then
    WaveWindowManager:ShowWaveWindowWithDelegate(TargetId, Params, nil, {
      GameInstance,
      function()
        UE.UKismetSystemLibrary.QuitGame(GameInstance, UE.UGameplayStatics.GetPlayerController(GameInstance, 0), UE.EQuitPreference.Quit, false)
      end
    })
  else
    ShowWaveWindowWithConsoleCheck(TargetId, Params, ErrorCode)
  end
end

function BP_LoginController_C:BindOnHttpBanDelegate(BanInfo)
  ChatDataMgr.UpdateVoiceBanInfo(BanInfo)
  print("BP_LoginController_C:BindOnHttpBanDelegate", BanInfo.BanReasonId, BanInfo.BanEndTime, BanInfo.ErrorCode)
  local BanReason = "BanReason"
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBanReason, BanInfo.BanReasonId)
  if Result then
    BanReason = RowInfo.Tips
  end
  local ErrorCodeDesc = ""
  local Result, ErrorCodeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBErrorCode, BanInfo.ErrorCode)
  if Result then
    ErrorCodeDesc = ErrorCodeRowInfo.Tips
  end
  local BanEndTimeFormat = TimestampToDateTimeText(BanInfo.BanEndTime)
  local Params = {
    BanReason,
    ErrorCodeDesc,
    BanEndTimeFormat
  }
  ShowWaveWindowWithConsoleCheck(BanTipId, Params, BanInfo.ErrorCode)
end

function BP_LoginController_C:OnWindowCloseRequested()
  print("BP_LoginController_C:OnWindowCloseRequested")
  if DataMgr.GetDistributionChannel() == LogicLobby.DistributionChannelList.WeGame then
    print("BP_LoginController_C:OnWindowCloseRequested ExecuteWeGameLogOut")
    local OnlineIdentitySystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UOnlineIdentitySystem:StaticClass())
    if OnlineIdentitySystem then
      local Result = OnlineIdentitySystem:Logout()
      print("WeGame Logout Result:", Result)
    end
  end
  return true
end

function BP_LoginController_C:IsAutoProcess()
  local CmdLine = UE.UKismetSystemLibrary.GetCommandLine()
  local Tokens, Switches, Params = UE.UKismetSystemLibrary.ParseCommandLine(CmdLine, nil, nil, nil)
  local IsAutoBot = Params:Find("bot_switch")
  if not IsAutoBot then
    return false
  end
  if "0" == IsAutoBot then
    return false
  else
    LogicAutoRobot.Init()
    local IsAutoBot = Params:Find("bot_switch")
    if IsAutoBot then
      LogicAutoRobot.SetIsAutoBot(true)
    end
    local NamePrefix = Params:Find("bot_name_prefix")
    if NamePrefix then
      LogicAutoRobot.SetBotNamePrefix(NamePrefix)
    end
    local IsOwner = Params:Find("bot_team_captain")
    if IsOwner then
      LogicAutoRobot.SetIsTeamCaptain("0" ~= IsOwner)
    end
    local IsPlayWithBot = Params:Find("bot_with_bot_only")
    if IsPlayWithBot then
      LogicAutoRobot.SetIsPlayWithBot("0" ~= IsPlayWithBot)
    end
    local StartGameNum = Params:Find("bot_team_count")
    if StartGameNum then
      LogicAutoRobot.SetStartGameNum(tonumber(StartGameNum))
      if 1 == tonumber(StartGameNum) then
        print("\230\156\186\229\153\168\228\186\186\230\137\167\232\161\140\229\141\149\230\156\186\230\168\161\229\188\143")
        UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, "rg.HttpService.SwitchOnGray 1")
      end
    end
    local BotHeroId = Params:Find("bot_heroid")
    if BotHeroId then
      LogicAutoRobot.SetBotHeroId(tonumber(BotHeroId))
    end
    local BotGameModeListStr = Params:Find("bot_gamemodelist")
    if BotGameModeListStr then
      local ModeList = UE.UKismetStringLibrary.ParseIntoArray(BotGameModeListStr, ",", true):ToTable()
      LogicAutoRobot.SetBotGameModeList(ModeList)
    end
    local BotFixedNameStr = Params:Find("bot_fixed_name")
    if BotFixedNameStr then
      LogicAutoRobot.SetBotFixedName(BotFixedNameStr)
    end
    local IsLoopMode = Params:Find("bot_isloopmode")
    if IsLoopMode then
      LogicAutoRobot.SetIsLoopMode("0" ~= IsLoopMode)
    end
    return true
  end
end

function BP_LoginController_C:ReceiveEndPlay()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:Reset(self)
    UIManager:UnloadPreloadWidget(UE.EPreLoadScene.Login)
  end
  UE.URGUIEffectMgr.Get(GameInstance):Reset()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CosCheckTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CosCheckTimer)
  end
  local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
  if RGHttpClientMgr then
    RGHttpClientMgr.OnHttpBusinessErrorTip:Remove(self, self.BindOnHttpBusinessErrorTip)
    RGHttpClientMgr.OnHttpBanDelegate:Remove(self, self.BindOnHttpBanDelegate)
  end
  LogicOutsideWeapon.Clear()
end

function BP_LoginController_C:GetCurSceneStatus()
  return UE.ESceneStatus.ELogin
end

return BP_LoginController_C
