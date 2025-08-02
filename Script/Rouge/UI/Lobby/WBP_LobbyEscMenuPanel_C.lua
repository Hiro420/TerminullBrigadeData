local WBP_LobbyEscMenuPanel_C = UnLua.Class()
local LoginHandler = require("Protocol.LoginHandler")
local PandoraData = require("Modules.Pandora.PandoraData")
local ExitGameTipId = 303018

function WBP_LobbyEscMenuPanel_C:Construct()
  self.Btn_Exit.OnClicked:Add(self, self.BindOnExitClicked)
  self.Btn_Continue.OnClicked:Add(self, self.BindOnContinueButtonClicked)
  self.Btn_Logout.OnClicked:Add(self, self.BindOnLogoutButtonClicked)
  self.Btn_Setting.OnClicked:Add(self, self.BindOnSettingButtonClicked)
  self.Btn_CustomerService.OnClicked:Add(self, self.BindOnCustomerServiceButtonClicked)
  self.Btn_Announce.OnClicked:Add(self, self.BindOnAnnoceClicked)
  self.Btn_Teach.OnClicked:Add(self, self.BindOnTeachButtonClicked)
  self.Btn_ChangeToNormal.OnClicked:Add(self, self.BindOnChangeToNormalClicked)
  if UE.URGBlueprintLibrary.IsPlatformConsole() then
    self.Btn_Exit:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Btn_Exit:SetVisibility(UE.ESlateVisibility.Visible)
  end
  EventSystem.AddListenerNew(EventDef.Season.SeasonModeChanged, self, self.OnSeasonModeChanged)
  self:OnSeasonModeChanged()
end

function WBP_LobbyEscMenuPanel_C:Destruct()
  EventSystem.RemoveListenerNew(EventDef.Season.SeasonModeChanged, self, self.OnSeasonModeChanged)
end

function WBP_LobbyEscMenuPanel_C:OnSeasonModeChanged(SeasonMode)
  local seasonModule = ModuleManager:Get("SeasonModule")
  local curSeasonID = seasonModule:GetCurSeasonID()
  if seasonModule:GetSeasonMode() == ESeasonMode.SeasonMode and curSeasonID > 1 then
    UpdateVisibility(self.SizeBox_ChangeToNormal, true)
  else
    UpdateVisibility(self.SizeBox_ChangeToNormal, false)
  end
end

function WBP_LobbyEscMenuPanel_C:BindOnExitClicked()
  ShowWaveWindowWithDelegate(ExitGameTipId, {}, {
    self,
    function()
      EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, false)
      LoginHandler.RequestLogoutToServer()
      UE.UKismetSystemLibrary.QuitGame(self, UE.UGameplayStatics.GetPlayerController(self, 0), UE.EQuitPreference.Quit, false)
    end
  })
end

function WBP_LobbyEscMenuPanel_C:BindOnContinueButtonClicked()
  EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, false)
end

function WBP_LobbyEscMenuPanel_C:BindOnLogoutButtonClicked()
  LoginHandler.RequestLogoutToServer()
  local GateService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.UWSGateService:StaticClass())
  if GateService then
    GateService:Disconnect()
  end
end

function WBP_LobbyEscMenuPanel_C:BindOnSettingButtonClicked()
  LogicGameSetting.ShowGameSettingPanel()
end

function WBP_LobbyEscMenuPanel_C:BindOnCustomerServiceButtonClicked()
end

function WBP_LobbyEscMenuPanel_C:BindOnAnnoceClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.ANNOUNCEMENT) then
    return
  end
  if not PandoraData:HasApp() then
    ShowWaveWindow(1140, {})
    return
  end
  local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  PandorSubsystem:OpenApp(PandoraData:GetAnnounceAppId(), "")
end

function WBP_LobbyEscMenuPanel_C:BindOnTeachButtonClicked()
  LuaAddClickStatistics("Tutorial")
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.TUTORIAL) then
    return
  end
  UIMgr:Show(ViewID.UI_BeginnerGuideBookView, true)
end

function WBP_LobbyEscMenuPanel_C:BindOnChangeToNormalClicked()
  ShowWaveWindowWithDelegate(1453, {}, {
    GameInstance,
    function()
      local seasonModule = ModuleManager:Get("SeasonModule")
      seasonModule:SetSeasonMode(ESeasonMode.NormalMode)
      EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, false)
    end
  })
end

return WBP_LobbyEscMenuPanel_C
