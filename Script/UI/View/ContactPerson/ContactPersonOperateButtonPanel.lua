local ContactPersonOperateButtonPanel = UnLua.Class()
local ContactPersonManager = ModuleManager:Get("ContactPersonModule")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local ContactPersonHandler = require("Protocol.ContactPerson.ContactPersonHandler")

function ContactPersonOperateButtonPanel:BindClickHandler()
  self.InviteTeamPanel.Btn_Main.OnClicked:Add(self, self.BindOnInviteTeamButtonClicked)
  self.SizeBoxShield.Btn_Main.OnClicked:Add(self, self.BindOnShieldButtonClicked)
  self.AddFriendPanel.Btn_Main.OnClicked:Add(self, self.BindOnAddFriendButtonClicked)
  self.DeleteFriendPanel.Btn_Main.OnClicked:Add(self, self.BindOnDeleteFriendButtonClicked)
  self.ChatPanel.Btn_Main.OnClicked:Add(self, self.BindOnChatButtonClicked)
  self.AddBlackListPanel.Btn_Main.OnClicked:Add(self, self.BindOnAddBlackListButtonClicked)
  self.RemoveBlackListPanel.Btn_Main.OnClicked:Add(self, self.BindOnRemoveBlackListButtonClicked)
  self.FriendRemarkNamePanel.Btn_Main.OnClicked:Add(self, self.BindOnRemarkNameButtonClicked)
  self.InfoPanel.Btn_Main.OnClicked:Add(self, self.BindOnCheckPlayerInfo)
  self.ReportPanel.Btn_Main.OnClicked:Add(self, self.BindOnReport)
  self.PlatformPanel.Btn_Main.OnClicked:Add(self, self.BindOnPlatformClicked)
end

function ContactPersonOperateButtonPanel:UnBindClickHandler()
  self.InviteTeamPanel.Btn_Main.OnClicked:Remove(self, self.BindOnInviteTeamButtonClicked)
  self.SizeBoxShield.Btn_Main.OnClicked:Remove(self, self.BindOnShieldButtonClicked)
  self.AddFriendPanel.Btn_Main.OnClicked:Remove(self, self.BindOnAddFriendButtonClicked)
  self.DeleteFriendPanel.Btn_Main.OnClicked:Remove(self, self.BindOnDeleteFriendButtonClicked)
  self.ChatPanel.Btn_Main.OnClicked:Remove(self, self.BindOnChatButtonClicked)
  self.AddBlackListPanel.Btn_Main.OnClicked:Remove(self, self.BindOnAddBlackListButtonClicked)
  self.RemoveBlackListPanel.Btn_Main.OnClicked:Remove(self, self.BindOnRemoveBlackListButtonClicked)
  self.FriendRemarkNamePanel.Btn_Main.OnClicked:Remove(self, self.BindOnRemarkNameButtonClicked)
  self.InfoPanel.Btn_Main.OnClicked:Remove(self, self.BindOnCheckPlayerInfo)
  self.ReportPanel.Btn_Main.OnClicked:Remove(self, self.BindOnCheckPlayerInfo)
  self.PlatformPanel.Btn_Main.OnClicked:Remove(self, self.BindOnPlatformClicked)
end

function ContactPersonOperateButtonPanel:OnInit()
  self:BindClickHandler()
  self.IsFirstShow = true
end

function ContactPersonOperateButtonPanel:OnDestroy()
  self:UnBindClickHandler()
end

function ContactPersonOperateButtonPanel:OnShow(MousePosition, PlayerInfo, SourceFromType, ...)
  if not self.IsFirstShow then
    self:SetRenderOpacity(0.0)
  else
    self.IsFirstShow = false
  end
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.PlayerInfo = PlayerInfo
  self.SourceFromType = SourceFromType
  self.MousePosition = MousePosition
  self.PanelPositionTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self:SetRenderOpacity(1.0)
      self:JudgePanelPosition(self.MousePosition)
    end
  }, 0.1, false)
  self:RefreshOperateButtonVis()
  if SourceFromType == EOperateButtonPanelSourceFromType.Chat or SourceFromType == EOperateButtonPanelSourceFromType.PrivateChat then
    self.ChatContent = (...)
  end
end

function ContactPersonOperateButtonPanel:JudgePanelPosition(MousePosition)
  local MainPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MainPanel)
  local Alignment = MainPanelSlot:GetAlignment()
  local ViewportSize = UE.UWidgetLayoutLibrary.GetViewportSize(self) / UE.UWidgetLayoutLibrary.GetViewportScale(self)
  local MainPanelSize = UE.USlateBlueprintLibrary.GetLocalSize(self.MainPanel:GetCachedGeometry())
  if MousePosition.X + MainPanelSize.X > ViewportSize.X then
    Alignment.X = 1.0
  else
    Alignment.X = 0.0
  end
  if MousePosition.Y + MainPanelSize.Y > ViewportSize.Y then
    Alignment.Y = 1.0
  else
    Alignment.Y = 0.0
  end
  MainPanelSlot:SetAlignment(Alignment)
  if MainPanelSlot then
    MainPanelSlot:SetPosition(MousePosition)
  end
end

function ContactPersonOperateButtonPanel:HidePanel()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PanelPositionTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.PanelPositionTimer)
  end
  UIMgr:Hide(ViewID.UI_ContactPersonOperateButtonPanel)
end

function ContactPersonOperateButtonPanel:BindOnInviteTeamButtonClicked()
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics("FriendsInvite")
  end
  local InviteTeamWay = LogicTeam.JoinTeamWay.FriendInvite
  if self.SourceFromType == EOperateButtonPanelSourceFromType.Chat then
    InviteTeamWay = LogicTeam.JoinTeamWay.ChatInvite
  end
  ContactPersonManager:SendInviteOrApplyTeamRequest(self.PlayerInfo, InviteTeamWay)
  self:HidePanel()
end

function ContactPersonOperateButtonPanel:BindOnShieldButtonClicked()
  local bIsSheilded = ChatDataMgr.CheckPlayerIsBeSheilded(tonumber(self.PlayerInfo.roleid))
  LogicChat:SheildPlayerMsg(tonumber(self.PlayerInfo.roleid), not bIsSheilded, self.PlayerInfo.nickname)
  self:HidePanel()
end

function ContactPersonOperateButtonPanel:BindOnAddFriendButtonClicked()
  ContactPersonHandler:RequestAddFriendToServer(self.PlayerInfo.roleid, self.SourceFromType)
  self:HidePanel()
end

function ContactPersonOperateButtonPanel:BindOnDeleteFriendButtonClicked()
  ContactPersonHandler:RequestDeleteFriendToServer(self.PlayerInfo.roleid)
  self:HidePanel()
end

function ContactPersonOperateButtonPanel:BindOnChatButtonClicked()
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics("FriendsChat")
  end
  local PlayerInfo = DeepCopy(self.PlayerInfo)
  if not UIMgr:IsShow(ViewID.UI_ContactPerson) then
    UIMgr:Show(ViewID.UI_ContactPerson)
  end
  ContactPersonData:AddPersonalChatInfo(PlayerInfo.roleid, nil)
  EventSystem.Invoke(EventDef.ContactPerson.UpdatePersonalChatPanelVis, true, PlayerInfo)
  self:HidePanel()
end

function ContactPersonOperateButtonPanel:BindOnAddBlackListButtonClicked()
  ContactPersonHandler:RequestBlackListPlayerToServer(self.PlayerInfo.roleid)
  self:HidePanel()
end

function ContactPersonOperateButtonPanel:BindOnRemoveBlackListButtonClicked()
  ContactPersonHandler:RequestCancelBlackListPlayerToServer(self.PlayerInfo.roleid)
  self:HidePanel()
end

function ContactPersonOperateButtonPanel:BindOnRemarkNameButtonClicked()
  UIMgr:Show(ViewID.UI_FriendRemarkName, nil, self.PlayerInfo)
  self:HidePanel()
end

function ContactPersonOperateButtonPanel:BindOnCheckPlayerInfo()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.CAREER) then
    return
  end
  local roleID = self.PlayerInfo.roleid
  self:HidePanel()
  UIMgr:Show(ViewID.UI_PlayerInfoMain, true, roleID)
end

function ContactPersonOperateButtonPanel:BindOnPlatformClicked()
  DataMgr.ShowPlatformProfile(self.PlayerInfo.roleid, self.PlayerInfo.channelUID)
  self:HidePanel()
end

function ContactPersonOperateButtonPanel:BindOnReport()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.DELATE) then
    return
  end
  if self.SourceFromType == EOperateButtonPanelSourceFromType.Chat then
    UIMgr:Show(ViewID.UI_ReportView, false, 1, self.PlayerInfo.roleid, self.PlayerInfo.nickname, self.ChatContent)
  elseif self.SourceFromType == EOperateButtonPanelSourceFromType.PrivateChat then
    UIMgr:Show(ViewID.UI_ReportView, false, 1, self.PlayerInfo.roleid, self.PlayerInfo.nickname, self.ChatContent)
  else
    UIMgr:Show(ViewID.UI_ReportView, false, 2, self.PlayerInfo.roleid, self.PlayerInfo.nickname)
  end
end

function ContactPersonOperateButtonPanel:RefreshOperateButtonVis()
  local AllChildItem = self.OperateButtonPanel:GetAllChildren()
  for key, SingleItem in pairs(AllChildItem) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if tonumber(self.PlayerInfo.roleid) ~= tonumber(DataMgr.UserId) then
    local Desc = NSLOCTEXT("ContactPersonOperateButtonPanel", "SheildPlayer", "\229\177\143\232\148\189\231\142\169\229\174\182")
    if ChatDataMgr.CheckPlayerIsBeSheilded(tonumber(self.PlayerInfo.roleid)) then
      Desc = NSLOCTEXT("ContactPersonOperateButtonPanel", "UnSheildPlayer", "\229\143\150\230\182\136\229\177\143\232\148\189")
    end
    UpdateVisibility(self.SizeBoxShield, true)
    self.SizeBoxShield.Txt_Desc:SetText(Desc())
  end
  local BasicInfo = DataMgr.GetBasicInfo()
  local IsPlayerCanNotInviteByTargetStatus = self.PlayerInfo.onlineStatus == OnlineStatus.OnlineStatusOffline or self.PlayerInfo.onlineStatus == OnlineStatus.OnlineStatusGame or self.PlayerInfo.onlineStatus == OnlineStatus.OnlineStatusMatch
  if LogicTeam.IsTeammate(self.PlayerInfo.roleid) or BasicInfo.onlineStatus == OnlineStatus.OnlineStatusMatch or self.PlayerInfo.roleid == DataMgr.GetUserId() or IsPlayerCanNotInviteByTargetStatus or LogicTeam.IsFullTeam() then
  else
    self.InviteTeamPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  if BasicInfo.roleid ~= self.PlayerInfo.roleid then
    if ContactPersonData:IsInBlackList(self.PlayerInfo.roleid) then
      self.RemoveBlackListPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      if ContactPersonData:IsFriend(self.PlayerInfo.roleid) then
        self.DeleteFriendPanel:SetVisibility(UE.ESlateVisibility.Visible)
        self.FriendRemarkNamePanel:SetVisibility(UE.ESlateVisibility.Visible)
        self.ChatPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      elseif not ContactPersonData:IsInFriendRequestList(self.PlayerInfo.roleid) then
        self.AddFriendPanel:SetVisibility(UE.ESlateVisibility.Visible)
      end
      self.AddBlackListPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    UpdateVisibility(self.ReportPanel, true, true)
  end
  UpdateVisibility(self.InfoPanel, true, true)
  if self.SourceFromType == EOperateButtonPanelSourceFromType.Rank then
    UpdateVisibility(self.InviteTeamPanel, false)
    UpdateVisibility(self.SizeBoxShield, false)
    UpdateVisibility(self.AddBlackListPanel, false)
  end
  if self.SourceFromType == EOperateButtonPanelSourceFromType.Chat then
  elseif self.SourceFromType == EOperateButtonPanelSourceFromType.RecentList then
  elseif self.SourceFromType == EOperateButtonPanelSourceFromType.PrivateChat then
    UpdateVisibility(self.InfoPanel, false)
    UpdateVisibility(self.InviteTeamPanel, false)
    UpdateVisibility(self.SizeBoxShield, false)
    UpdateVisibility(self.AddFriendPanel, false)
    UpdateVisibility(self.AddBlackListPanel, false)
    UpdateVisibility(self.ChatPanel, false)
    UpdateVisibility(self.FriendRemarkNamePanel, false)
    UpdateVisibility(self.DeleteFriendPanel, false)
  end
  self:UpdatePlatformInfo()
  local IsNeedHide = true
  local AllChildItem = self.OperateButtonPanel:GetAllChildren()
  for key, SingleItem in pairs(AllChildItem) do
    if SingleItem:IsVisible() then
      IsNeedHide = false
    end
  end
  if IsNeedHide then
    self:HidePanel()
  end
end

function ContactPersonOperateButtonPanel:UpdatePlatformInfo()
  if not self.PlatformPanel then
    return
  end
  if self.PlatformPanel.PlatformInfoPanel then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo ContactPersonOperateButtonPanel self.PlayerInfo.roleid: %s", tostring(self.PlayerInfo.roleid)))
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo ContactPersonOperateButtonPanel self.PlayerInfo.channelUID: %s", tostring(self.PlayerInfo.channelUID)))
    self.PlatformPanel.PlatformInfoPanel:UpdateChannelInfo(self.PlayerInfo.roleid, true, self.PlayerInfo.channelUID, function(bIsVisible)
      if not self then
        return
      end
      if bIsVisible then
        UpdateVisibility(self.PlatformPanel, true)
      else
        UpdateVisibility(self.PlatformPanel, false)
      end
    end)
  end
end

function ContactPersonOperateButtonPanel:OnBGMouseButtonDown(MyGeometry, MouseEvent)
  if not UE.UKismetInputLibrary.PointerEvent_IsMouseButtonDown(MouseEvent, self.LeftMouseKey) then
    return UE.UWidgetBlueprintLibrary.Handled()
  end
  self:HidePanel()
  return UE.UWidgetBlueprintLibrary.Handled()
end

function ContactPersonOperateButtonPanel:OnHide()
  self.PlayerInfo = nil
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PanelPositionTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.PanelPositionTimer)
  end
end

function ContactPersonOperateButtonPanel:Destruct()
  self:HidePanel()
end

return ContactPersonOperateButtonPanel
