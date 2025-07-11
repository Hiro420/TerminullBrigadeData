local SinglePersonItemView = UnLua.Class()
local ContactPersonManager = ModuleManager:Get("ContactPersonModule")
local ContactPersonHandler = require("Protocol.ContactPerson.ContactPersonHandler")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
function SinglePersonItemView:Construct()
  self.Btn_MainButton.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_MainButton.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_MainButton.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  self.Btn_InviteTeam.OnClicked:Add(self, self.BindOnInviteTeamButtonClicked)
  self.Btn_InviteTeam.OnHovered:Add(self, self.BindOnInviteTeamButtonHovered)
  self.Btn_InviteTeam.OnUnhovered:Add(self, self.BindOnInviteTeamButtonUnhovered)
  self.Btn_Agree.OnClicked:Add(self, self.BindOnAgreeButtonClicked)
  self.Btn_Agree.OnHovered:Add(self, self.BindOnAgreeButtonHovered)
  self.Btn_Agree.OnUnhovered:Add(self, self.BindOnAgreeButtonUnhovered)
  self.Btn_Refuse.OnClicked:Add(self, self.BindOnRefuseButtonClicked)
  self.Btn_Refuse.OnHovered:Add(self, self.BindOnRefuseButtonHovered)
  self.Btn_Refuse.OnUnhovered:Add(self, self.BindOnRefuseButtonUnhovered)
  self.BP_ButtonWithSoundHeadHover.OnHovered:Add(self, self.BindOnHeadHovered)
  self.BP_ButtonWithSoundHeadHover.OnUnhovered:Add(self, self.BindOnHeadUnhovered)
  self.Btn_AddFriend.OnClicked:Add(self, self.BindOnAddFriendButtonClicked)
end
function SinglePersonItemView:Show(PlayerInfo, StatusText, ContactListType, StatusTextColor, ParentView)
  self.ParentView = ParentView
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.PlayerInfo = PlayerInfo
  self.CurContactListType = ContactListType
  self.IsNotHasRoleIdItem = false
  local NameText = self.PlayerInfo.nickname
  self.Img_PlatformFriendSign:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self.PlayerInfo.roleid then
    local FriendInfo = ContactPersonData:GetFriendInfoById(self.PlayerInfo.roleid)
    if FriendInfo and not UE.UKismetStringLibrary.IsEmpty(FriendInfo.remarkName) then
      NameText = NameText .. "(" .. FriendInfo.remarkName .. ")"
      if ContactPersonData:IsPlatformFriend(self.PlayerInfo.roleid) then
        self.Img_PlatformFriendSign:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
    elseif ContactPersonData:IsPlatformFriend(self.PlayerInfo.roleid) then
      local FriendInfo = ContactPersonData:GetPlatformFriendInfoByRoleId(self.PlayerInfo.roleid)
      NameText = NameText .. "(" .. FriendInfo.NickName .. ")"
      self.Img_PlatformFriendSign:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    local PrivacySubSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserPrivacySubsystem:StaticClass())
    if PrivacySubSystem then
      local ChannelUserID = DataMgr.GetPlayerChannelUserIdById(self.PlayerInfo.roleid)
      if "" ~= ChannelUserID then
        local IsAllowed = PrivacySubSystem:IsCommunicateUsingTextOrVoiceAllowed(ChannelUserID, true)
        UpdateVisibility(self.Icon_Shield, IsAllowed ~= UE.EPermissionsResult.denied)
      end
    end
  else
    self.Img_PlatformFriendSign:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Txt_Name:SetText(NameText)
  self.Txt_Status:SetText(StatusText)
  self.Txt_Status:SetColorAndOpacity(StatusTextColor)
  local CurOnlineStatus = 1 == self.PlayerInfo.invisible and OnlineStatus.OnlineStatusOffline or self.PlayerInfo.onlineStatus
  if CurOnlineStatus == OnlineStatus.OnlineStatusOffline then
    self.Txt_Name:SetColorAndOpacity(StatusTextColor)
    self.ComPortraitItem:SetIsEnabled(false)
  else
    self.Txt_Name:SetColorAndOpacity(self.NameDefaultColor)
    self.ComPortraitItem:SetIsEnabled(true)
  end
  local PortraitRowInfo = LogicLobby.GetPlayerPortraitTableRowInfo(self.PlayerInfo.portrait)
  if PortraitRowInfo then
    self.ComPortraitItem:InitComPortraitItem(PortraitRowInfo.portraitIconPath, PortraitRowInfo.EffectPath)
  end
  self:RefreshInviteTeamButtonVis()
  UpdateVisibility(self.Btn_AddFriend, false)
  if self.CurContactListType == EContactListType.FriendRequest then
    self.FriendApplyOperatePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_Line:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:ChangeFriendRequestStatus()
  else
    self.FriendApplyOperatePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_Line:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.PlatformIconPanel then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo SinglePersonItemView PlayerInfo.roleid: %s", tostring(PlayerInfo.roleid)))
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo SinglePersonItemView PlayerInfo.channelUID: %s", tostring(PlayerInfo.channelUID)))
    if not self.PlayerInfo.roleid or ContactPersonData:IsPlatformFriend(self.PlayerInfo.roleid) then
      local PlatformName = UE.URGBlueprintLibrary.GetPlatformName()
      self.PlatformIconPanel:UpdateChannelInfoByPlatform(PlatformName, true)
    else
      self.PlatformIconPanel:UpdateChannelInfo(PlayerInfo.roleid, true, PlayerInfo.channelUID)
    end
  end
end
function SinglePersonItemView:SetIsNotHasRoleIdItem()
  self.IsNotHasRoleIdItem = true
end
function SinglePersonItemView:HideApplyFriendLine()
  self.Img_Line:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function SinglePersonItemView:ChangeFriendRequestStatus()
  local FriendApplyInfo = ContactPersonData:GetFriendApplyInfoById(self.PlayerInfo.roleid)
  local Text = ""
  if FriendApplyInfo then
    Text = self.SourceText:Find(FriendApplyInfo.addSource)
    if nil == Text then
      Text = ""
    end
  end
  self.Txt_Status:SetText(Text)
end
function SinglePersonItemView:RefreshInviteTeamButtonVis()
  self.Btn_InviteTeam:SetVisibility(UE.ESlateVisibility.Hidden)
  if self.CurContactListType == EContactListType.FriendRequest then
    return
  end
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    if self.IsNotHasRoleIdItem then
      return
    end
    if self.PlayerInfo.roleid == DataMgr.GetUserId() then
      return
    end
    if LogicTeam.IsTeammate(self.PlayerInfo.roleid) then
      return
    end
  end
  local BasicInfo = DataMgr.GetBasicInfo()
  if BasicInfo.onlineStatus == OnlineStatus.OnlineStatusMatch then
    return
  end
  if DataMgr.IsInTeam() and LogicTeam.IsFullTeam() then
    return
  end
  local CurOnlineStatus = 1 == self.PlayerInfo.invisible and OnlineStatus.OnlineStatusOffline or self.PlayerInfo.onlineStatus
  if CurOnlineStatus == OnlineStatus.OnlineStatusFree or CurOnlineStatus == OnlineStatus.OnlineStatusTeam then
    self.Btn_InviteTeam:SetVisibility(UE.ESlateVisibility.Visible)
  end
end
function SinglePersonItemView:RefreshAddFriendButtonVis(...)
  UpdateVisibility(self.Btn_AddFriend, false)
  if self.CurContactListType == EContactListType.FriendRequest then
    return
  end
  if self.IsNotHasRoleIdItem then
    return
  end
  if ContactPersonData:IsInBlackList(self.PlayerInfo.roleid) or ContactPersonData:IsFriend(self.PlayerInfo.roleid) then
  elseif self.PlayerInfo.roleid ~= DataMgr.GetUserId() and not ContactPersonData:IsInFriendRequestList(self.PlayerInfo.roleid) then
    UpdateVisibility(self.Btn_AddFriend, true, true)
  end
end
function SinglePersonItemView:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.PlayerInfo = nil
end
function SinglePersonItemView:BindOnMainButtonClicked()
  if self.IsNotHasRoleIdItem then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
    if UserOnlineSubsystem then
      if UserOnlineSubsystem:CheckRequestLoginStatus() ~= true then
        print("SinglePersonItemView - CheckRequestLoginStatus Failed")
        return
      end
      UserOnlineSubsystem:ShowPlayerProfile(self.PlayerInfo.userId)
    else
      print("SinglePersonItemView - UserOnlineSubsystem is nil")
    end
    return
  end
  local CurMousePosition = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
  local Type = EOperateButtonPanelSourceFromType.RecentList
  if self.CurContactListType == nil then
    Type = EOperateButtonPanelSourceFromType.Search
  end
  EventSystem.Invoke(EventDef.ContactPerson.OnContactPersonItemClicked, CurMousePosition, self.PlayerInfo, Type)
end
function SinglePersonItemView:BindOnMainButtonHovered()
  self.MainHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if self:IsAnimationPlaying(self.Ani_Hover_Out) then
    self:StopAnimation(self.Ani_Hover_Out)
  end
  if not self:IsAnimationPlaying(self.Ani_Hover_In) then
    self:PlayAnimationForward(self.Ani_Hover_In)
  end
end
function SinglePersonItemView:BindOnMainButtonUnhovered()
  self.MainHoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self:IsAnimationPlaying(self.Ani_Hover_In) then
    self:StopAnimation(self.Ani_Hover_In)
  end
  if not self:IsAnimationPlaying(self.Ani_Hover_Out) then
    self:PlayAnimationForward(self.Ani_Hover_Out)
  end
end
function SinglePersonItemView:BindOnInviteTeamButtonClicked()
  if UE.URGBlueprintLibrary.IsPlatformConsole() and (self.PlayerInfo.roleid == nil or DataMgr:IsPlayerCurrentPlatform(self.PlayerInfo.roleid)) then
    ContactPersonManager:SendInviteOrApplyTeamRequestPlatformConsole(self.PlayerInfo, LogicTeam.JoinTeamWay.FriendInvite)
  else
    ContactPersonManager:SendInviteOrApplyTeamRequest(self.PlayerInfo, LogicTeam.JoinTeamWay.FriendInvite)
  end
end
function SinglePersonItemView:BindOnInviteTeamButtonHovered()
  self.InviteTeamHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function SinglePersonItemView:BindOnInviteTeamButtonUnhovered()
  self.InviteTeamHoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function SinglePersonItemView:BindOnAgreeButtonClicked()
  ContactPersonHandler:RequestAgreeAddFriendToServer(self.PlayerInfo.roleid)
end
function SinglePersonItemView:BindOnAgreeButtonHovered()
  self.AgreeHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function SinglePersonItemView:BindOnAgreeButtonUnhovered()
  self.AgreeHoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function SinglePersonItemView:BindOnRefuseButtonClicked()
  ContactPersonHandler:RequestRejectAddFriendToServer(self.PlayerInfo.roleid)
end
function SinglePersonItemView:BindOnRefuseButtonHovered()
  self.RefuseHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function SinglePersonItemView:BindOnRefuseButtonUnhovered()
  self.RefuseHoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function SinglePersonItemView:BindOnHeadHovered()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowPlayerInfoTips(true, self.PlayerInfo, self.BP_ButtonWithSoundHeadHover)
  end
end
function SinglePersonItemView:BindOnHeadUnhovered()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowPlayerInfoTips(false)
  end
end
function SinglePersonItemView:BindOnAddFriendButtonClicked(...)
  ContactPersonHandler:RequestAddFriendToServer(self.PlayerInfo.roleid, EOperateButtonPanelSourceFromType.Search)
end
return SinglePersonItemView
