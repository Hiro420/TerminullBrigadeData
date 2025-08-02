local TeamVoiceModule = require("Modules.TeamVoice.TeamVoiceModule")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local ContactPersonHandler = require("Protocol.ContactPerson.ContactPersonHandler")
local WBP_TeamOperateButtonPanel_C = UnLua.Class()

function WBP_TeamOperateButtonPanel_C:Construct()
  self.NotFreeChatPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnNotFreeChatButtonClicked
  }
  self.FreeChatPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnFreeChatButtonClicked
  }
  self.ChangeCaptainPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnChangeCaptainButtonClikced
  }
  self.LeaveTeamPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnLeaveTeamButtonClicked
  }
  self.AddFriendPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnAddFriendButtonClicked
  }
  self.DeleteFriendPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnDeleteFriendButtonClicked
  }
  self.BlockVoicePanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnBlockVoiceButtonClicked
  }
  self.ReportPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnReportButtonClicked
  }
  self.KickTeamPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnKickTeamButtonClicked
  }
  self.CheckInfoPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnCheckInfoButtonClicked
  }
  self.PlatformPanel.OnMainButtonClickedFuncList = {
    self,
    self.BindOnPlatformClicked
  }
  self.Btn_Recruit_01.OnClicked:Add(self, self.BindOnRecruitClicked)
  self.Btn_InviteFriend_01.OnClicked:Add(self, self.BindOnInviteFriendClicked)
end

function WBP_TeamOperateButtonPanel_C:BindOnNotFreeChatButtonClicked()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    TeamVoiceModule:SetMicMode(0, true)
  end
  self:ChangeChatPanelVisByChatMode()
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:BindOnFreeChatButtonClicked()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    TeamVoiceModule:SetMicMode(1, true)
  end
  self:ChangeChatPanelVisByChatMode()
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:BindOnLeaveTeamButtonClicked()
  LogicTeam.RequestQuitTeamToServer()
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:BindOnChangeCaptainButtonClikced()
  LogicTeam.RequestChangeCaptainToServer(self.PlayerInfo.id)
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:BindOnAddFriendButtonClicked()
  ContactPersonHandler:RequestAddFriendToServer(self.PlayerInfo.id, EOperateButtonPanelSourceFromType.RecentList)
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:BindOnDeleteFriendButtonClicked(...)
  ContactPersonHandler:RequestDeleteFriendToServer(self.PlayerInfo.id)
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:BindOnBlockVoiceButtonClicked()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys and self.PlayerInfo then
    local MemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.id)
    local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
    TeamVoiceSubSys:ForbidMemberVoice(MemberId, not bIsMute)
  end
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:BindOnReportButtonClicked()
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:BindOnKickTeamButtonClicked()
  DataMgr.GetOrQueryPlayerInfo({
    self.PlayerInfo.id
  }, false, function(PlayerCacheInfoList)
    local PlayerInfoList = DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoList)
    UIMgr:Show(ViewID.UI_KickTeamTip, nil, PlayerInfoList[1])
  end)
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:BindOnCheckInfoButtonClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.CAREER) then
    return
  end
  local roleID = self.PlayerInfo.id
  self:Hide()
  UIMgr:Show(ViewID.UI_PlayerInfoMain, true, roleID)
end

function WBP_TeamOperateButtonPanel_C:BindOnRecruitClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.RECRUIT) then
    return
  end
  self:Hide()
  UIMgr:Show(ViewID.UI_RecruitMainView, true)
end

function WBP_TeamOperateButtonPanel_C:BindOnInviteFriendClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.FRIENDS) then
    return
  end
  self:Hide()
  UIMgr:Show(ViewID.UI_ContactPerson)
end

function WBP_TeamOperateButtonPanel_C:BindOnPlatformClicked()
  DataMgr.ShowPlatformProfile(self.PlayerInfo.id, self.PlayerInfo.channelUID)
  self:Hide()
end

function WBP_TeamOperateButtonPanel_C:Show(PlayerInfo)
  self.PlayerInfo = PlayerInfo
  self:RefreshOperateButtonVis()
  self:StopAllAnimations()
  self:PlayAnimation(self.Ani_in)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_TeamOperateButtonPanel_C:RefreshOperateButtonVis()
  for key, SinglePanel in pairs(self.AllOperatePanel:GetAllChildren()) do
    SinglePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.PlayerInfo then
    if DataMgr.GetUserId() == self.PlayerInfo.id then
      self:ChangeChatPanelVisByChatMode()
      local TeamInfo = DataMgr.GetTeamInfo()
      if DataMgr.IsInTeam() and table.count(TeamInfo.players) > 1 then
        self.LeaveTeamPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      if not UE.URGBlueprintLibrary.IsPlatformConsole() then
        self.BlockVoicePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      else
        UpdateVisibility(self.BlockVoicePanel, false)
      end
      if LogicTeam.IsCaptain() then
        self.ChangeCaptainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.KickTeamPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
      if not ContactPersonData:IsInBlackList(self.PlayerInfo.id) then
        if ContactPersonData:IsFriend(self.PlayerInfo.id) then
          self.DeleteFriendPanel:SetVisibility(UE.ESlateVisibility.Visible)
        elseif not ContactPersonData:IsInFriendRequestList(self.PlayerInfo.id) then
          self.AddFriendPanel:SetVisibility(UE.ESlateVisibility.Visible)
        end
      end
    end
    UpdateVisibility(self.CheckInfoPanel, true)
    if UE.URGTeamVoiceSubsystem then
      local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
      if TeamVoiceSubSys then
        if self.PlayerInfo then
          local MemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.id)
          local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
          if bIsMute then
            self.BlockVoicePanel:SetTxtName(NSLOCTEXT("WBP_TeamOperateButtonPanel_C", "CancelBlockVoice", "\229\143\150\230\182\136\229\177\143\232\148\189")())
          else
            self.BlockVoicePanel:SetTxtName(NSLOCTEXT("WBP_TeamOperateButtonPanel_C", "BlockVoice", "\229\177\143\232\148\189\232\175\173\233\159\179")())
          end
        else
          UpdateVisibility(self.ImageMuteVoice, false)
        end
      end
    end
  else
    UpdateVisibility(self.Btn_Recruit, true)
    UpdateVisibility(self.Btn_InviteFriend, true)
  end
  self:UpdatePlatformInfo()
end

function WBP_TeamOperateButtonPanel_C:UpdatePlatformInfo()
  if not self.PlatformPanel then
    return
  end
  if self.PlatformPanel.PlatformInfoPanel and self.PlayerInfo then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_TeamOperateButtonPanel_C self.PlayerInfo.id: %s", tostring(self.PlayerInfo.id)))
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_TeamOperateButtonPanel_C self.PlayerInfo.channelUID: %s", tostring(self.PlayerInfo.channelUID)))
    self.PlatformPanel.PlatformInfoPanel:UpdateChannelInfo(self.PlayerInfo.id, false, self.PlayerInfo.channelUID, function(bIsVisible)
      if not self then
        return
      end
      if bIsVisible then
        UpdateVisibility(self.PlatformPanel.HorizontalBoxInfo, false)
        UpdateVisibility(self.PlatformPanel, true)
      else
        UpdateVisibility(self.PlatformPanel, false)
      end
    end)
  end
end

function WBP_TeamOperateButtonPanel_C:ChangeChatPanelVisByChatMode()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
    if TeamVoiceSubSys then
      local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
      local CurValue = GameUserSettings:GetGameSettingByTag(Tag)
      if 0 == CurValue then
        self.FreeChatPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.NotFreeChatPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      elseif 1 == CurValue then
        self.FreeChatPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.NotFreeChatPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  else
    UpdateVisibility(self.FreeChatPanel, false)
    UpdateVisibility(self.NotFreeChatPanel, false)
  end
end

function WBP_TeamOperateButtonPanel_C:UpdatePosition(InPosition)
  local MainSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MainPanel)
  if MainSlot then
    MainSlot:SetPosition(InPosition)
  end
end

function WBP_TeamOperateButtonPanel_C:Hide()
  self.PlayerInfo = nil
  self:StopAllAnimations()
  self:PlayAnimation(self.Ani_out)
end

function WBP_TeamOperateButtonPanel_C:OnBGMouseButtonDown(MyGeometry, MouseEvent)
  if not UE.UKismetInputLibrary.PointerEvent_IsMouseButtonDown(MouseEvent, self.LeftMouseKey) then
    return UE.UWidgetBlueprintLibrary.Handled()
  end
  EventSystem.Invoke(EventDef.Lobby.OnModelAreaClickedChanged, false)
  self:Hide()
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_TeamOperateButtonPanel_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end

return WBP_TeamOperateButtonPanel_C
