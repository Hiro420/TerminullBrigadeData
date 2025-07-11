local TeamVoiceModule = require("Modules.TeamVoice.TeamVoiceModule")
local WBP_LobbyRoleName_C = UnLua.Class()
function WBP_LobbyRoleName_C:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.QuickChangeHeroPanelHide, WBP_LobbyRoleName_C.OnQuickChangeHeroPanelHide)
  self.Button_Exit.OnClicked:Add(self, WBP_LobbyRoleName_C.OnClicked_Exit)
  self.Button_Exit.OnHovered:Add(self, WBP_LobbyRoleName_C.OnClicked_ExitHovered)
  self.Button_Exit.OnUnhovered:Add(self, WBP_LobbyRoleName_C.OnClicked_ExitUnhovered)
  self.Button_Mic.OnClicked:Add(self, WBP_LobbyRoleName_C.OnClicked_Mic)
  self.Button_Expand.OnClicked:Add(self, WBP_LobbyRoleName_C.OnClicked_Expand)
  UE.UGameUserSettings.GetGameUserSettings().OnGameUserSettingsChanged:Add(self, WBP_LobbyRoleName_C.UpdateTeamVoiceUI)
  self.ClickedChange = false
end
function WBP_LobbyRoleName_C:Show(PlayerInfo, Index)
  self.Index = Index
  self.PlayerInfo = PlayerInfo
  self.TextBlock_Name:SetText(self.PlayerInfo.nickname)
  self:UpdateRoomOwnerTag(self.PlayerInfo.roleid)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.WBP_MonthCardIcon:Show(self.PlayerInfo.roleid, false)
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    UpdateVisibility(self.HorizontalBox_Voice, true)
  else
    UpdateVisibility(self.HorizontalBox_Voice, false)
  end
  if DataMgr.GetUserId() == self.PlayerInfo.roleid then
    self.TextBlock_Name:SetColorAndOpacity(self.OwnerColor)
  else
    self.TextBlock_Name:SetColorAndOpacity(self.NormalColor)
  end
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    TeamVoiceSubSys.VoiceMuteDelegate:Add(self, WBP_LobbyRoleName_C.UpdateMuteTag)
  end
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      GVoice.RoomMemberVoiceStatusDelegate:Add(self, WBP_LobbyRoleName_C.UpdateSpeakingTag)
      GVoice.JoinRoomDelegate:Add(self, WBP_LobbyRoleName_C.UpdateMicStatus)
    end
  end
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_LobbyRoleName_C self.PlayerInfo.roleid: %s", tostring(self.PlayerInfo.roleid)))
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_LobbyRoleName_C self.PlayerInfo.channelUID: %s", tostring(self.PlayerInfo.channelUIDv)))
  if self.PlatformIconPanel then
    self.PlatformIconPanel:UpdateChannelInfo(self.PlayerInfo.roleid, true, self.PlayerInfo.channelUID)
  end
end
function WBP_LobbyRoleName_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.WBP_MonthCardIcon:Hide()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    TeamVoiceSubSys.VoiceMuteDelegate:Remove(self, WBP_LobbyRoleName_C.UpdateMuteTag)
  end
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      GVoice.RoomMemberVoiceStatusDelegate:Remove(self, WBP_LobbyRoleName_C.UpdateSpeakingTag)
      GVoice.JoinRoomDelegate:Remove(self, WBP_LobbyRoleName_C.UpdateMicStatus)
    end
  end
end
function WBP_LobbyRoleName_C:Destruct()
  self.Button_Exit.OnClicked:Remove(self, WBP_LobbyRoleName_C.OnClicked_Exit)
  self.Button_Exit.OnHovered:Remove(self, WBP_LobbyRoleName_C.OnClicked_ExitHovered)
  self.Button_Exit.OnUnhovered:Remove(self, WBP_LobbyRoleName_C.OnClicked_ExitUnhovered)
  self.Button_Mic.OnClicked:Remove(self, WBP_LobbyRoleName_C.OnClicked_Mic)
  self.Button_Expand.OnClicked:Remove(self, WBP_LobbyRoleName_C.OnClicked_Expand)
  self:Hide()
  UE.UGameUserSettings.GetGameUserSettings().OnGameUserSettingsChanged:Remove(self, WBP_LobbyRoleName_C.UpdateTeamVoiceUI)
  EventSystem.RemoveListener(EventDef.Lobby.QuickChangeHeroPanelHide, WBP_LobbyRoleName_C.OnQuickChangeHeroPanelHide)
end
function WBP_LobbyRoleName_C:UpdateTeamVoiceUI()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
    local CurValue = GameUserSettings:GetGameSettingByTag(Tag)
    UpdateVisibility(self.Image_Mic, 0 == CurValue)
    UpdateVisibility(self.Image_Mic_Close, 1 == CurValue)
  end
end
function WBP_LobbyRoleName_C:UpdateRoomOwnerTag()
  local IsOwner = false
  local TeamInfo = DataMgr.GetTeamInfo()
  if DataMgr.IsInTeam() then
    IsOwner = TeamInfo.captain == self.PlayerInfo.roleid
  else
    IsOwner = DataMgr.GetUserId() == self.PlayerInfo.roleid
  end
  UpdateVisibility(self.Image_Ready, not IsOwner)
  UpdateVisibility(self.Image_OwnerReady, IsOwner)
  local bIsShow = DataMgr.IsInTeam() and DataMgr.GetUserId() == self.PlayerInfo.roleid
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    UpdateVisibility(self.Overlay_Mic, bIsShow)
  else
    UpdateVisibility(self.Overlay_Mic, false)
  end
  UpdateVisibility(self.CanvasPanel_Expand, DataMgr.GetUserId() ~= self.PlayerInfo.roleid)
  self:UpdateTeamVoiceUI()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local MemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.roleid)
    local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
    UpdateVisibility(self.URGImageMuteVoice, bIsMute)
  end
  if DataMgr.GetUserId() == self.PlayerInfo.roleid then
    self.bLocalShow = true
    local TeamInfo = DataMgr.GetTeamInfo()
    local TeamStateCanExit = TeamInfo.state ~= LogicTeam.TeamState.Matching and TeamInfo.state ~= LogicTeam.TeamState.Preparing
    if DataMgr.IsInTeam() and TeamInfo.players and table.count(TeamInfo.players) > 1 and TeamStateCanExit then
      UpdateVisibility(self.Overlay_Exit, true)
    else
      UpdateVisibility(self.URGImageMuteVoice, false)
      UpdateVisibility(self.Overlay_Exit, false)
    end
  else
    UpdateVisibility(self.Overlay_Exit, false)
  end
end
function WBP_LobbyRoleName_C:UpdateMuteTag(Result, RoomName, MemberId)
  if not LogicTeam.CheckIsOwnerVoiceRoom(RoomName) then
    return
  end
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys and 0 == Result then
    local SelfMemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.roleid)
    if SelfMemberId == MemberId then
      local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
      UpdateVisibility(self.URGImageMuteVoice, bIsMute)
    end
  end
end
function WBP_LobbyRoleName_C:UpdateSpeakingTag(RoomName, OpenId, MemberId, Status)
  if not LogicTeam.CheckIsOwnerVoiceRoom(RoomName) then
    return
  end
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
    if bIsMute then
      self:UpdateSpeakingStatus(false)
    elseif Status == UE.EVoiceRoomMemberStatus.SayingFromSilence or Status == UE.EVoiceRoomMemberStatus.ContinueSaying then
      local SelfMemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.roleid)
      if SelfMemberId == MemberId then
        self:UpdateSpeakingStatus(true)
      end
    elseif Status == UE.EVoiceRoomMemberStatus.SilenceFromSaying then
      local SelfMemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.roleid)
      if SelfMemberId == MemberId then
        self:UpdateSpeakingStatus(false)
      end
    end
  end
end
function WBP_LobbyRoleName_C:UpdateSpeakingStatus(bIsShow)
  UpdateVisibility(self.URGImageSpeaking, bIsShow)
  if bIsShow then
    math.randomseed(os.time())
    local Amplitude = math.random() * 0.5
    local Mat = self.URGImageSpeaking:GetDynamicMaterial()
    if Mat then
      print("WBP_LobbyRoleName_C:UpdateSpeakingStatus", Amplitude)
      Mat:SetScalarParameterValue("amplitude", Amplitude)
    end
  end
end
function WBP_LobbyRoleName_C:UpdateMicStatus(Code, RoomName, MemberId)
end
function WBP_LobbyRoleName_C:OnClicked_Exit()
  LogicTeam.RequestQuitTeamToServer()
end
function WBP_LobbyRoleName_C:OnClicked_Mic()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
    local CurValue = GameUserSettings:GetGameSettingByTag(Tag)
    TeamVoiceModule:SetMicMode(1 - CurValue, true)
  end
end
function WBP_LobbyRoleName_C:OnClicked_Expand()
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaClickedChanged, true, self.Index)
end
function WBP_LobbyRoleName_C:OnClicked_Change()
  self.ClickedChange = not self.ClickedChange
  EventSystem.Invoke(EventDef.Lobby.LobbyHeroClicked, self.ClickedChange)
end
function WBP_LobbyRoleName_C:OnClicked_ExitHovered()
  SetImageBrushBySoftObject(self.Image_Back_ExitBack, self.ChangeHovered, {
    X = math.ceil(self.IconSize.X),
    Y = math.ceil(self.IconSize.Y)
  })
  self.Image_Back_ExitBack:SetColorAndOpacity(self.HoveredColor)
  self.Image_Back_Exit:SetColorAndOpacity(self.HoveredColor)
end
function WBP_LobbyRoleName_C:OnClicked_ExitUnhovered()
  SetImageBrushBySoftObject(self.Image_Back_ExitBack, self.ChangeUnHovered, {
    X = math.ceil(self.IconSize.X),
    Y = math.ceil(self.IconSize.Y)
  })
  self.Image_Back_ExitBack:SetColorAndOpacity(self.UnHoveredColor)
  self.Image_Back_Exit:SetColorAndOpacity(self.UnHoveredColor)
end
function WBP_LobbyRoleName_C:OnQuickChangeHeroPanelHide()
  self.ClickedChange = false
end
return WBP_LobbyRoleName_C
