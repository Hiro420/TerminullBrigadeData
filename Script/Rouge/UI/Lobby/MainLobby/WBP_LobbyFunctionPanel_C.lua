local rapidjson = require("rapidjson")
local WBP_LobbyFunctionPanel_C = UnLua.Class()
local PandoraData = require("Modules.Pandora.PandoraData")
local LoginHandler = require("Protocol.LoginHandler")
function WBP_LobbyFunctionPanel_C:Construct()
  self.BP_ButtonWithSound__Friends.OnClicked:Add(self, WBP_LobbyFunctionPanel_C.BindOnFriendsButtonClicked)
  self.BP_ButtonWithSound_Email.OnClicked:Add(self, WBP_LobbyFunctionPanel_C.BindOnEmailButtonClicked)
  self.Btn_Announcement.OnClicked:Add(self, self.BindOnAnnouncementButtonClicked)
  self.Btn_GuideBook.OnClicked:Add(self, self.BindOnGuideBookButtonClicked)
  self.Btn_CustomerService.OnClicked:Add(self, self.BindOnCustomerServiceClicked)
  self.Btn_ESC.OnClicked:Add(self, self.BindOnESCClicked)
  self.BP_ButtonWithSound_Friend.OnClicked:Add(self, self.BindOnFriendsButtonClicked)
  self.BP_ButtonWithSound_Active.OnClicked:Add(self, self.BindOnActiveButtonClicked)
  self.BP_ButtonWithSound_Rank.OnClicked:Add(self, self.BindOnRankButtonClicked)
  EventSystem.AddListener(self, EventDef.Pandora.NotifyPandoraADPositionReady, self.BindOnNotifyPandoraADPositionReady)
end
function WBP_LobbyFunctionPanel_C:BindOnFriendsButtonClicked()
  LuaAddClickStatistics("Friends")
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.FRIENDS) then
    return
  end
  UIMgr:Show(ViewID.UI_ContactPerson)
end
function WBP_LobbyFunctionPanel_C:BindOnActiveButtonClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.SEVEN_DAYS_ACTIVITE) then
    return
  end
  UIMgr:Show(ViewID.UI_ActivityPanel, true)
end
function WBP_LobbyFunctionPanel_C:BindOnRankButtonClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.RANK) then
    return
  end
  UIMgr:Show(ViewID.UI_RankView_Nor, true)
end
function WBP_LobbyFunctionPanel_C:BindOnLogoutSuccess(JsonResponse)
  print("LogoutSuccess ", JsonResponse.Content)
  local JsonTable = rapidjson.decode(JsonResponse.Content)
  HttpCommunication.SetToken("")
  UE.URGGameplayLibrary.TriggerOnClientLogoutFromLobby(self)
  UE.UAsyncLoadingScreenLibrary.ResetLoadingScreenType()
  LogicLobby.OpenLevelByName("Login")
  DataMgr.ClearData()
end
function WBP_LobbyFunctionPanel_C:BindOnLogoutFail(ErrorMessage)
  print("LogoutFail ", ErrorMessage.ErrorMessage)
end
local MicOpened = false
local CurrentVoiceRoom
function TryJoinGVoiceTeamRoom()
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice and not CurrentVoiceRoom then
      CurrentVoiceRoom = "RGTestRoom0001"
      GVoice:JoinTeamRoom(CurrentVoiceRoom, 6000)
      GVoice:OpenSpeaker()
    end
  end
end
function WBP_LobbyFunctionPanel_C:BindOnEmailButtonClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.MAIL) then
    return
  end
  UIMgr:Show(ViewID.UI_Mail, true)
  self.WBP_RedDotView:BindOnClick()
end
function WBP_LobbyFunctionPanel_C:BindOnNotifyPandoraADPositionReady()
end
function WBP_LobbyFunctionPanel_C:ChangeAnnouncementButtonVis()
end
function WBP_LobbyFunctionPanel_C:BindOnAnnouncementButtonClicked()
  local PandorSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPandoraSubsystem:StaticClass())
  local openAppId = PandoraData:GetAnnounceAppId()
  if "" ~= openAppId then
    PandorSubsystem:OpenApp(openAppId, "")
  else
    ShowWaveWindow(1140, {})
  end
end
function WBP_LobbyFunctionPanel_C:BindOnGuideBookButtonClicked()
  LuaAddClickStatistics("Tutorial")
  self.WBP_RedDotView_Learn:BindOnClick()
  UIMgr:Show(ViewID.UI_BeginnerGuideBookView, true)
end
function WBP_LobbyFunctionPanel_C:BindOnCustomerServiceClicked()
  UIMgr:Show(ViewID.UI_CustomerServiceView, true)
end
function WBP_LobbyFunctionPanel_C:BindOnESCClicked()
  EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, true)
end
function WBP_LobbyFunctionPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.Pandora.NotifyPandoraADPositionReady, self.BindOnNotifyPandoraADPositionReady, self)
end
return WBP_LobbyFunctionPanel_C
