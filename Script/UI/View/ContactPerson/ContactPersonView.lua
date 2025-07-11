local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local ContactPersonHandler = require("Protocol.ContactPerson.ContactPersonHandler")
local EscName = "PauseGame"
local ContactPersonView = Class(ViewBase)
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local CurrentTabList = {}
function ContactPersonView:OnBindUIInput()
  self.WBP_InteractTipWidgetMenuPrev:BindInteractAndClickEvent(self, self.BindOnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:BindInteractAndClickEvent(self, self.BindOnSelectNextMenu)
end
function ContactPersonView:OnUnBindUIInput()
  self.WBP_InteractTipWidgetMenuPrev:UnBindInteractAndClickEvent(self, self.BindOnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:UnBindInteractAndClickEvent(self, self.BindOnSelectNextMenu)
end
function ContactPersonView:BindClickHandler()
  self.MenuButtonToggleGroup.OnCheckStateChanged:Add(self, self.BindOnCheckStateChanged)
  self.Btn_CopyId.OnClicked:Add(self, self.BindOnCopyIdButtonClicked)
  self.Edit_SearchPlayer.OnTextChanged:Add(self, self.BindOnSearchPlayerTextChanged)
  self.Btn_Search.OnClicked:Add(self, self.BindOnSearchButtonClicked)
  self.Btn_ClearSearchInfo.OnClicked:Add(self, self.BindOnClearSearchInfoButtonClicked)
  self.Btn_PersonalChat.OnClicked:Add(self, self.BindOnPersonalChatButtonClicked)
  self.Btn_ExpandFriendList.OnClicked:Add(self, self.BindOnExpandFriendListButtonClicked)
  self.Btn_ExpandBlackList.OnClicked:Add(self, self.BindOnExpandBlackListButtonClicked)
  self.ComboBox_Status.OnSelectionChanged:Add(self, self.BindOnStatusSelectionChanged)
  self.ComboBox_Status.OnOpening:Add(self, self.BindOnStatusComboBoxOpening)
  self.ComboBox_Status.OnClosing:Add(self, self.BindOnStatusComboBoxClosing)
  self.Edit_SearchPlayer.OnTextCommitted:Add(self, self.BindOnSearchPlayerTextCommitted)
  ListenObjectMessage(nil, GMP.MSG_Localization_UpdateCulture, self, self.BindOnUpdateCulture)
end
function ContactPersonView:UnBindClickHandler()
  self.MenuButtonToggleGroup.OnCheckStateChanged:Remove(self, self.BindOnCheckStateChanged)
  self.Btn_CopyId.OnClicked:Remove(self, self.BindOnCopyIdButtonClicked)
  self.Edit_SearchPlayer.OnTextChanged:Remove(self, self.BindOnSearchPlayerTextChanged)
  self.Btn_Search.OnClicked:Remove(self, self.BindOnSearchButtonClicked)
  self.Btn_ClearSearchInfo.OnClicked:Remove(self, self.BindOnClearSearchInfoButtonClicked)
  self.Btn_PersonalChat.OnClicked:Remove(self, self.BindOnPersonalChatButtonClicked)
  self.Btn_ExpandFriendList.OnClicked:Remove(self, self.BindOnExpandFriendListButtonClicked)
  self.ComboBox_Status.OnSelectionChanged:Remove(self, self.BindOnStatusSelectionChanged)
  self.ComboBox_Status.OnOpening:Remove(self, self.BindOnStatusComboBoxOpening)
  self.ComboBox_Status.OnClosing:Remove(self, self.BindOnStatusComboBoxClosing)
  self.Edit_SearchPlayer.OnTextCommitted:Remove(self, self.BindOnSearchPlayerTextCommitted)
  UnListenObjectMessage(GMP.MSG_Localization_UpdateCulture, self)
end
function ContactPersonView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("ContactPersonViewModel")
  self:BindClickHandler()
  self:RefreshSelfOnlineStatusOptions()
end
function ContactPersonView:RefreshSelfOnlineStatusOptions()
  self.ComboBox_Status:ClearOptions()
  for key, SingleItem in pairs(self.SelfOnlineStatusOptions) do
    self.ComboBox_Status:AddOption(SingleItem)
  end
end
function ContactPersonView:BindOnUpdateCulture()
  self:RefreshSelfOnlineStatusOptions()
end
function ContactPersonView:OnDestroy()
  self:UnBindClickHandler()
  if self.ViewModel then
    self.ViewModel:StartOrEndRefreshPlayerInfoList(false)
  end
end
function ContactPersonView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.IsExpandFriendList = true
  self.IsExpandBlackList = true
  self.FriendArrowPanel:SetRenderTransformAngle(180)
  self.BlackListArrowPanel:SetRenderTransformAngle(180)
  self.IsDefaultSelectMenu = true
  self.MenuButtonToggleGroup:SelectId(EContactListType.Friend)
  self.ViewModel:StartOrEndRefreshPlayerInfoList(true)
  self.Edit_SearchPlayer:SetText("")
  self:BindOnSearchPlayerTextChanged("")
  self:InitInfo(DataMgr.GetBasicInfo())
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.ListenForEscInputAction)
  ContactPersonHandler:RequestGetBlackListToServer()
  if DataMgr.GetDistributionChannel() ~= LogicLobby.DistributionChannelList.Normal then
    local OnlineFriendSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UOnlineFriendSystem:StaticClass())
    if OnlineFriendSystem then
      OnlineFriendSystem:RequestGetFriendList()
    end
    self.WBP_SingleContactButton_3:SetVisibility(UE.ESlateVisibility.Visible)
    CurrentTabList = {
      EContactListType.RecentPlayer,
      EContactListType.Friend,
      EContactListType.PlatformFriend,
      EContactListType.FriendRequest
    }
  else
    self.WBP_SingleContactButton_3:SetVisibility(UE.ESlateVisibility.Collapsed)
    CurrentTabList = {
      EContactListType.RecentPlayer,
      EContactListType.Friend,
      EContactListType.FriendRequest
    }
  end
  EventSystem.AddListener(self, EventDef.ContactPerson.UpdatePersonalChatPanelVis, self.BindOnUpdatePersonalChatPanelVis)
  EventSystem.Invoke(EventDef.ContactPerson.UpdatePersonalChatPanelVis, false)
  self:SetEnhancedInputActionBlocking(true)
  self:SetEnhancedInputActionPriority(1)
end
function ContactPersonView:GetCurSelectTabId()
  return self.MenuButtonToggleGroup.CurSelectId
end
function ContactPersonView:InitInfo(BasicInfo)
  self.Txt_Name:SetText(BasicInfo.nickname)
  self.Txt_UserId:SetText(BasicInfo.roleid)
  self.Txt_Level:SetText(BasicInfo.level)
  local tbPortraitData = LogicLobby.GetPlayerPortraitTableRowInfo(BasicInfo.portrait)
  self.ComPortraitItem:InitComPortraitItem(tbPortraitData.portraitIconPath, tbPortraitData.EffectPath)
  if self.ComboBox_Status:GetSelectedIndex() ~= BasicInfo.invisible then
    self.ComboBox_Status:SetSelectedIndex(BasicInfo.invisible)
  end
  if self.PlatformIconPanel then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo ContactPersonView BasicInfo.roleid: %s", tostring(BasicInfo.roleid)))
    self.PlatformIconPanel:UpdateChannelInfo(BasicInfo.roleid, true)
  end
end
function ContactPersonView:BindOnUpdatePersonalChatPanelVis(IsShow, PlayerInfo)
  if IsShow then
    self.WBP_PersonalChat:Show(PlayerInfo)
  else
    self.WBP_PersonalChat:Hide()
  end
end
function ContactPersonView:OnHideByOther()
  self:SetEnhancedInputActionPriority(0)
  self:SetEnhancedInputActionBlocking(false)
end
function ContactPersonView:OnRollback()
  self:SetEnhancedInputActionPriority(1)
  self:SetEnhancedInputActionBlocking(true)
  self:PushInputAction()
end
function ContactPersonView:OnPreHide(...)
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.ListenForEscInputAction)
  EventSystem.RemoveListener(EventDef.ContactPerson.UpdatePersonalChatPanelVis, self.BindOnUpdatePersonalChatPanelVis, self)
  self.ViewModel:StartOrEndRefreshPlayerInfoList(false)
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self:SetEnhancedInputActionBlocking(false)
  self:SetEnhancedInputActionPriority(0)
end
function ContactPersonView:OnHide()
end
function ContactPersonView:ListenForEscInputAction()
  UIMgr:Hide(ViewID.UI_ContactPerson)
  if UIMgr:IsShow(ViewID.UI_ContactPersonOperateButtonPanel) then
    UIMgr:Hide(ViewID.UI_ContactPersonOperateButtonPanel)
  end
end
function ContactPersonView:OnBGMouseButtonDown(MyGeometry, MouseEvent)
  if not UE.UKismetInputLibrary.PointerEvent_IsMouseButtonDown(MouseEvent, self.LeftMouseKey) then
    return UE.UWidgetBlueprintLibrary.Handled()
  end
  self:ListenForEscInputAction()
  return UE.UWidgetBlueprintLibrary.Handled()
end
function ContactPersonView:BindOnCheckStateChanged(SelectIndex)
  self:HideAllPlayerInfoItem()
  if self.IsDefaultSelectMenu then
    self.IsDefaultSelectMenu = false
  elseif not self:IsAnimationPlaying(self.Ani_list_In) then
    self:PlayAnimationForward(self.Ani_list_In)
  else
    self:SetAnimationCurrentTime(self.Ani_list_In, 0)
  end
  self.ViewModel:OnViewTabChanged(SelectIndex)
  if SelectIndex == EContactListType.Friend then
    self.Btn_ExpandFriendList:SetVisibility(UE.ESlateVisibility.Visible)
    if self.IsExpandFriendList then
      self.PlayerInfoList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.PlayerInfoList:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    self.BlackListPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    if SelectIndex == EContactListType.PlatformFriend then
      LuaAddClickStatistics("FriendsPlatform")
    end
    self.Btn_ExpandFriendList:SetVisibility(UE.ESlateVisibility.Collapsed)
    if not self.IsExpandFriendList then
      self.PlayerInfoList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    self.BlackListPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function ContactPersonView:BindOnCopyIdButtonClicked()
  UE.URGBlueprintLibrary.CopyMessageToClipboard(tostring(self.Txt_UserId:GetText()))
  ShowWaveWindow(1097)
end
function ContactPersonView:BindOnSearchPlayerTextChanged(Text)
  local CharacterTable = UE.UKismetStringLibrary.GetCharacterArrayFromString(Text):ToTable()
  if table.count(CharacterTable) > 0 then
    if self:IsAnimationPlaying(self.Ani_Search_Out) then
      self:StopAnimation(self.Ani_Search_Out)
    end
    if not self.IsShowSearchPanel then
      self:PlayAnimationForward(self.Ani_Search_In)
    end
    self.MenuButtonPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.PlayerInfoListPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.SearchFriendPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.SearchResultPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.SearchResultEmptyPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.EmptyPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Btn_Search:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_ClearSearchInfo:SetVisibility(UE.ESlateVisibility.Visible)
    self.SearchFriendResultPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshSearchFriendResultList()
    self.IsShowSearchPanel = true
  else
    self.IsShowSearchPanel = false
    self.MenuButtonPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.PlayerInfoListPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.EmptyPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if self:IsAnimationPlaying(self.Ani_Search_In) then
      self:StopAnimation(self.Ani_Search_In)
    end
    self:PlayAnimationForward(self.Ani_Search_Out)
  end
end
function ContactPersonView:OnAnimationFinished(InAnimation)
  if InAnimation == self.Ani_Search_Out then
    self.SearchFriendPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Btn_ClearSearchInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.SearchFriendResultPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function ContactPersonView:BindOnSearchButtonClicked()
  local NameList = {
    tostring(self.Edit_SearchPlayer:GetText())
  }
  ContactPersonHandler:RequestGetRolesByNameToServer(NameList, {
    self,
    function(self, RoleList)
      self.Btn_Search:SetVisibility(UE.ESlateVisibility.Collapsed)
      if RoleList[1] then
        self.SearchResultPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        ContactPersonData:SetContactListPlayerInfo(RoleList[1])
        self:OnSearchResultPlayerListChanged(RoleList)
      else
        self.SearchResultEmptyPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  })
  self.SearchFriendResultPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function ContactPersonView:BindOnClearSearchInfoButtonClicked()
  self.Edit_SearchPlayer:SetText("")
  self:BindOnSearchPlayerTextChanged("")
end
function ContactPersonView:BindOnPersonalChatButtonClicked()
  EventSystem.Invoke(EventDef.ContactPerson.UpdatePersonalChatPanelVis, true, nil)
end
function ContactPersonView:BindOnExpandFriendListButtonClicked()
  if self.IsExpandFriendList then
    self.PlayerInfoList:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.FriendArrowPanel:SetRenderTransformAngle(0)
  else
    self.PlayerInfoList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.FriendArrowPanel:SetRenderTransformAngle(180)
  end
  self.IsExpandFriendList = not self.IsExpandFriendList
end
function ContactPersonView:BindOnExpandBlackListButtonClicked()
  if self.IsExpandBlackList then
    self.BlackListInfoPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.BlackListArrowPanel:SetRenderTransformAngle(0)
  else
    self.BlackListInfoPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.BlackListArrowPanel:SetRenderTransformAngle(180)
  end
  self.IsExpandBlackList = not self.IsExpandBlackList
end
function ContactPersonView:BindOnStatusSelectionChanged(SelectedItem, SelectionType)
  local Index = self.ComboBox_Status:FindOptionIndex(SelectedItem)
  if -1 == Index then
    return
  end
  ContactPersonHandler:RequestChangeInvisibleToServer(Index)
end
function ContactPersonView:BindOnStatusComboBoxOpening()
  self.StatusArrowPanel:SetRenderTransformAngle(180)
end
function ContactPersonView:BindOnStatusComboBoxClosing()
  self.StatusArrowPanel:SetRenderTransformAngle(0)
end
function ContactPersonView:OnSearchResultPlayerListChanged(Result)
  local AllRecentItem = self.SearchResultPanel:GetAllChildren()
  for key, SingleRecentItem in pairs(AllRecentItem) do
    SingleRecentItem:Hide()
  end
  local Index = 0
  local TargetTextColor, TargetOnlineStatus
  for index, SingleRecentPlayerInfo in ipairs(Result) do
    local Item = self.SearchResultPanel:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.SearchFriendItemTemplate:StaticClass())
      self.SearchResultPanel:AddChild(Item)
    end
    TargetOnlineStatus = 1 == SingleRecentPlayerInfo.invisible and OnlineStatus.OnlineStatusOffline or SingleRecentPlayerInfo.onlineStatus
    TargetTextColor = self.OnlineStatusTextColor:Find(TargetOnlineStatus)
    TargetTextColor = TargetTextColor or self.OnlineStatusTextColor:Find(-1)
    Item:Show(SingleRecentPlayerInfo, self.OnlineStatusText:Find(TargetOnlineStatus), nil, TargetTextColor, self)
    Item:RefreshAddFriendButtonVis()
    Index = Index + 1
  end
end
function ContactPersonView:RefreshSearchFriendResultList()
  local CurSearchText = tostring(self.Edit_SearchPlayer:GetText())
  local AllFriendInfoList = ContactPersonData:GetFriendInfoList()
  local TargetFriendInfoList = {}
  local PlayerInfo
  for RoleId, SinglePlayerInfo in pairs(AllFriendInfoList) do
    PlayerInfo = ContactPersonData:GetPlayerInfoByRoleId(RoleId)
    if string.match(PlayerInfo.nickname, CurSearchText) then
      table.insert(TargetFriendInfoList, PlayerInfo)
    end
  end
  local Index = 0
  local TargetTextColor, TargetOnlineStatus
  for index, SinglePlayerInfo in ipairs(TargetFriendInfoList) do
    local Item = self.SearchFriendResultList:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.RecentPlayerItemTemplate:StaticClass())
      self.SearchFriendResultList:AddChild(Item)
    end
    TargetOnlineStatus = 1 == SinglePlayerInfo.invisible and OnlineStatus.OnlineStatusOffline or SinglePlayerInfo.onlineStatus
    TargetTextColor = self.OnlineStatusTextColor:Find(TargetOnlineStatus)
    TargetTextColor = TargetTextColor or self.OnlineStatusTextColor:Find(-1)
    Item:Show(SinglePlayerInfo, self.OnlineStatusText:Find(TargetOnlineStatus), nil, TargetTextColor, self)
    Index = Index + 1
  end
  HideOtherItem(self.SearchFriendResultList, Index + 1)
end
function ContactPersonView:OnPlayerListChanged(PlayerInfo, ContactListType)
  local Index = 0
  local EndItem, TargetTextColor
  local OnlineFriendCount = 0
  local TargetOnlineStatus
  for index, SinglePlayerInfo in ipairs(PlayerInfo) do
    local Item = self.PlayerInfoList:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.RecentPlayerItemTemplate:StaticClass())
      self.PlayerInfoList:AddChild(Item)
    end
    TargetOnlineStatus = 1 == SinglePlayerInfo.invisible and OnlineStatus.OnlineStatusOffline or SinglePlayerInfo.onlineStatus
    TargetTextColor = self.OnlineStatusTextColor:Find(TargetOnlineStatus)
    TargetTextColor = TargetTextColor or self.OnlineStatusTextColor:Find(-1)
    Item:Show(SinglePlayerInfo, self.OnlineStatusText:Find(TargetOnlineStatus), ContactListType, TargetTextColor, self)
    if TargetOnlineStatus ~= OnlineStatus.OnlineStatusOffline and ContactPersonData:IsFriend(SinglePlayerInfo.roleid) then
      OnlineFriendCount = OnlineFriendCount + 1
    end
    EndItem = Item
    Index = Index + 1
  end
  if ContactListType == EContactListType.PlatformFriend then
    local PlatformFriendsHasNotRoleIdList = ContactPersonData:GetPlatformFriendsHasNotRoleIdInfo()
    if UE.URGBlueprintLibrary.IsPlatformConsole() then
      table.sort(PlatformFriendsHasNotRoleIdList, function(a, b)
        local OnlineStatusA = OnlineStatus.OnlineStatusOffline
        if a.IsOnline then
          OnlineStatusA = OnlineStatus.OnlineStatusFree
        end
        local OnlineStatusB = OnlineStatus.OnlineStatusOffline
        if b.IsOnline then
          OnlineStatusB = OnlineStatus.OnlineStatusFree
        end
        return EOnlineStatusPriority[OnlineStatusA] > EOnlineStatusPriority[OnlineStatusB]
      end)
    end
    for UserId, SingleFriendInfo in pairs(PlatformFriendsHasNotRoleIdList) do
      local Item = self.PlayerInfoList:GetChildAt(Index)
      if not Item then
        Item = UE.UWidgetBlueprintLibrary.Create(self, self.RecentPlayerItemTemplate:StaticClass())
        self.PlayerInfoList:AddChild(Item)
      end
      TargetOnlineStatus = OnlineStatus.OnlineStatusOffline
      if SingleFriendInfo.IsOnline then
        TargetOnlineStatus = OnlineStatus.OnlineStatusFree
      end
      TargetTextColor = self.OnlineStatusTextColor:Find(TargetOnlineStatus)
      TargetTextColor = TargetTextColor or self.OnlineStatusTextColor:Find(-1)
      local PlayerInfo = {
        nickname = SingleFriendInfo.NickName,
        onlineStatus = TargetOnlineStatus,
        userId = SingleFriendInfo.UserId
      }
      Item:Show(PlayerInfo, self.OnlineStatusText:Find(TargetOnlineStatus), ContactListType, TargetTextColor, self)
      Item:SetIsNotHasRoleIdItem()
      Index = Index + 1
    end
  end
  HideOtherItem(self.PlayerInfoList, Index + 1)
  self.Txt_OnlineFriendCount:SetText(tostring(OnlineFriendCount))
  self.Txt_AllFriendCount:SetText(tostring(table.count(ContactPersonData:GetFriendInfoList())))
  if Index > 0 then
    self.FriendRequestEmptyPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.RecentPlayerEmptyPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if EndItem then
    EndItem:HideApplyFriendLine()
  end
end
function ContactPersonView:RefreshBlackList(PlayerInfoList)
  local Index = 0
  local EndItem, TargetTextColor
  local OnlineBlackCount = 0
  local TargetOnlineStatus
  for index, SinglePlayerInfo in ipairs(PlayerInfoList) do
    SinglePlayerInfo = SinglePlayerInfo.playerInfo
    local Item = self.BlackListInfoPanel:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.BlackListItemTemplate:StaticClass())
      self.BlackListInfoPanel:AddChild(Item)
    end
    TargetOnlineStatus = 1 == SinglePlayerInfo.invisible and OnlineStatus.OnlineStatusOffline or SinglePlayerInfo.onlineStatus
    TargetTextColor = self.OnlineStatusTextColor:Find(TargetOnlineStatus)
    TargetTextColor = TargetTextColor or self.OnlineStatusTextColor:Find(-1)
    Item:Show(SinglePlayerInfo, self.OnlineStatusText:Find(TargetOnlineStatus), EContactListType.BlackList, TargetTextColor, self)
    if TargetOnlineStatus ~= OnlineStatus.OnlineStatusOffline then
      OnlineBlackCount = OnlineBlackCount + 1
    end
    EndItem = Item
    Index = Index + 1
  end
  HideOtherItem(self.BlackListInfoPanel, Index + 1)
  self.Txt_OnlineBlackListCount:SetText(tostring(OnlineBlackCount))
  self.Txt_AllBlackListCount:SetText(tostring(table.count(ContactPersonData:GetBlackList())))
end
function ContactPersonView:HideAllPlayerInfoItem()
  local AllRecentItem = self.PlayerInfoList:GetAllChildren()
  for key, SingleRecentItem in pairs(AllRecentItem) do
    SingleRecentItem:Hide()
  end
  self.Txt_OnlineFriendCount:SetText(tostring(0))
  self.Txt_AllFriendCount:SetText(tostring(0))
  self.FriendRequestEmptyPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.RecentPlayerEmptyPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self:GetCurSelectTabId() == EContactListType.FriendRequest then
    self.FriendRequestEmptyPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  elseif self:GetCurSelectTabId() == EContactListType.RecentPlayer then
    self.RecentPlayerEmptyPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ContactPersonView:HideAllBlackListItem()
  local AllItem = self.BlackListInfoPanel:GetAllChildren()
  for key, SingleItem in pairs(AllItem) do
    SingleItem:Hide()
  end
  self.Txt_OnlineBlackListCount:SetText(tostring(0))
  self.Txt_AllBlackListCount:SetText(tostring(0))
end
function ContactPersonView:ShowPlayerInfoTips(bIsShow, PlayerInfo, TargetItem)
  if self:GetCurSelectTabId() == EContactListType.PlatformFriend and UE.URGBlueprintLibrary.IsPlatformConsole() then
    self.WBP_SocialPlayerInfoTips:Hide()
    return
  end
  if bIsShow then
    self.WBP_SocialPlayerInfoTips:InitSocailPlayerInfoTips(PlayerInfo)
    local GeometryItem = TargetItem:GetCachedGeometry()
    local GeometryCanvasPanelTips = self.CanvasPanelTips:GetCachedGeometry()
    local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelTips, GeometryItem)
    local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_SocialPlayerInfoTips)
    slotCanvas:SetPosition(Pos)
  else
    self.WBP_SocialPlayerInfoTips:Hide()
  end
end
function ContactPersonView:BindOnSearchPlayerTextCommitted(Text, CommitMethod)
  if CommitMethod ~= UE.ETextCommit.OnEnter then
    return
  end
  self:BindOnSearchButtonClicked()
end
function ContactPersonView:BindOnSelectPrevMenu()
  local CurrentSelectID = self:GetCurSelectTabId()
  local CurrentIndex = self:GetTabIndex(CurrentSelectID)
  if CurrentIndex > 0 then
    CurrentIndex = CurrentIndex - 1
    if CurrentIndex < 1 then
      CurrentIndex = #CurrentTabList
    end
    self.MenuButtonToggleGroup:SelectId(CurrentTabList[CurrentIndex])
  end
end
function ContactPersonView:BindOnSelectNextMenu()
  local CurrentSelectID = self:GetCurSelectTabId()
  local CurrentIndex = self:GetTabIndex(CurrentSelectID)
  if CurrentIndex > 0 then
    CurrentIndex = CurrentIndex + 1
    if CurrentIndex > #CurrentTabList then
      CurrentIndex = 1
    end
    self.MenuButtonToggleGroup:SelectId(CurrentTabList[CurrentIndex])
  end
end
function ContactPersonView:GetTabIndex(CurrentSelectID)
  for Index, ID in ipairs(CurrentTabList) do
    if CurrentSelectID == ID then
      return Index
    end
  end
  return 0
end
return ContactPersonView
