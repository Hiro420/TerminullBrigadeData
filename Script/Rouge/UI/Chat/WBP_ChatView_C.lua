local WBP_ChatView_C = UnLua.Class()
local rapidjson = require("rapidjson")
local HideChatDelay = 6
local TickRate = 0.2
function WBP_ChatView_C:Construct()
  self.Overridden.Construct(self)
  LogicChat:Init(self)
  EventSystem.AddListener(self, EventDef.Chat.SendChatMsgSucc, self.OnSendChatMsgSucc)
  EventSystem.AddListener(self, EventDef.Chat.SendChatMsgFailed, self.OnSendChatMsgFailed)
  self.SendMsgName = "EnterKeyEvent"
  self.Tab = "ScanWeakness"
  self.BP_ButtonWithSoundBack.OnClicked:Add(self, self.OnBackClick)
  self.RGEditableTextInput.OnTextCommitted:Add(self, self.OnTextInputCommit)
  self.RGEditableTextInput.OnHandleKeyDown:Add(self, self.OnHandleKeyDown)
  self.BP_ButtonWithSoundChannel.OnClicked:Add(self, self.OnShowChannelListClick)
  self.BP_ButtonWithSoundEnter.OnClicked:Add(self, self.OnEnterClick)
  self.BP_ButtonWithSoundEnter.OnHovered:Add(self, self.OnChatHover)
  self.BP_ButtonWithSoundEnter.OnUnhovered:Add(self, self.OnUnChatHover)
  self.BP_ButtonWithSoundScrollToBottom.OnClicked:Add(self, self.ScrollToBottom)
  self.RGListViewChatList.ListViewScrolledChanged:Add(self, self.OnListViewScrolledChanged)
  if self.ChatType == ChatDataMgr.EChatType.Lobby then
    self:SetCurSelectChannel(UE.EChatChannel.Composite)
  elseif self.ChatType == ChatDataMgr.EChatType.Battle then
    self:SetCurSelectChannel(UE.EChatChannel.Team)
    if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ChatTimer) then
      self.ChatTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        WBP_ChatView_C.ChatTick
      }, TickRate, true)
    end
  end
  self:FocusChatView(false)
end
function WBP_ChatView_C:OnBindUIInput()
  self.WBP_InteractTipWidgetChat:BindInteractAndClickEvent(self, self.SendMsg)
end
function WBP_ChatView_C:OnUnBindUIInput()
  self.WBP_InteractTipWidgetChat:UnBindInteractAndClickEvent(self, self.SendMsg)
end
function WBP_ChatView_C:ChatTick()
  if self.bIsFocus then
    return
  end
  if self.bIsHide then
    return
  end
  if self.ChatTime < HideChatDelay then
    self.ChatTime = self.ChatTime + TickRate
  else
    UpdateVisibility(self, false)
    self.bIsHide = true
  end
end
function WBP_ChatView_C:FocusInput()
  if not IsListeningForInputAction(self, self.SendMsgName) then
    ListenForInputAction(self.SendMsgName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.SendMsg
    })
  end
  if self.ChatType == ChatDataMgr.EChatType.Lobby and not IsListeningForInputAction(self, self.Tab) then
    ListenForInputAction(self.Tab, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ChangeChannel
    })
  end
end
function WBP_ChatView_C:UnfocusInput()
  if IsListeningForInputAction(self, self.SendMsgName) then
    StopListeningForInputAction(self, self.SendMsgName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.Tab) then
    StopListeningForInputAction(self, self.Tab, UE.EInputEvent.IE_Pressed)
  end
  print("WBP_ChatView_C:UnfocusInput")
  self:FocusChatView(false)
end
function WBP_ChatView_C:FocusChatView(bIsFocus, bSkipCheckAdult)
  if bIsFocus and not bSkipCheckAdult and not UE.URGBlueprintLibrary.IsPlatformConsole() then
    local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
    if VoiceControlModule and VoiceControlModule:CheckIsVoiceControl(self, self.OnLIPassEvent) then
      return
    end
  end
  self.bIsFocus = bIsFocus
  UpdateVisibility(self.CanvasPanelComplete, bIsFocus)
  UpdateVisibility(self.BP_ButtonWithSoundBack, bIsFocus, true)
  UpdateVisibility(self.BP_ButtonWithSoundEnter, not bIsFocus, true)
  if bIsFocus then
    self.SizeBoxChatList:SetMaxDesiredHeight(self.UnFoldingHeight)
    if self.ChatType == ChatDataMgr.EChatType.Battle then
      local InputChatTxt = NSLOCTEXT("WBP_ChatView_C", "InputChatTxt", "\232\190\147\229\133\165\232\129\138\229\164\169\229\134\133\229\174\185")
      self.RGEditableTextInput:SetHintText(InputChatTxt())
      UpdateVisibility(self.WBP_ChatChannelList, false)
      UE.UWidgetBlueprintLibrary.SetInputMode_UIOnlyEx(self:GetOwningPlayer(), self, UE.EMouseLockMode.LockAlways)
      local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SizeBoxChatList)
      if CanvasPanelSlot then
        CanvasPanelSlot:SetPosition(UE.FVector2D(CanvasPanelSlot:GetPosition().X, self.ListViewPosYWithOutChannelList))
      end
      self.ChatTime = 0
      self.bIsHide = false
      UpdateVisibility(self, true)
    elseif self.ChatType == ChatDataMgr.EChatType.Lobby then
      local ChangeChannelTxt = NSLOCTEXT("WBP_ChatView_C", "ChangeChannelTxt", "\230\140\137TAB\229\136\135\230\141\162\233\162\145\233\129\147")
      self.RGEditableTextInput:SetHintText(ChangeChannelTxt())
      self.WBP_ChatChannelList:ShowChannelList(self)
      UpdateVisibility(self.WBP_ChatChannelList, true)
      local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SizeBoxChatList)
      if CanvasPanelSlot then
        CanvasPanelSlot:SetPosition(UE.FVector2D(CanvasPanelSlot:GetPosition().X, self.ListViewPosYWithChannelList))
      end
    end
    self.RGEditableTextInput:SetFocus()
    self.RGListViewChatList:SetScrollbarVisibility(UE.ESlateVisibility.Visible)
    self:DelayUpdateBtnScrollToBottomVisible()
    UpdateVisibility(self.CanvasPanelPreview, false)
  else
    if self.ChatType == ChatDataMgr.EChatType.Battle then
      UpdateVisibility(self.CanvasPanelPreview, false)
      UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(self:GetOwningPlayer())
      self.bIsHide = false
      self.ChatTime = 0
      UpdateVisibility(self, true)
    elseif self.ChatType == ChatDataMgr.EChatType.Lobby then
      UpdateVisibility(self.CanvasPanelPreview, true)
    end
    self.RGListViewChatList:SetScrollbarVisibility(UE.ESlateVisibility.Collapsed)
    if not UE.RGUtil or not UE.RGUtil.IsEditor() then
      self:SetFocus()
    end
    self.SizeBoxChatList:SetMaxDesiredHeight(self.FoldingHeight)
    local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SizeBoxChatList)
    if CanvasPanelSlot then
      CanvasPanelSlot:SetPosition(UE.FVector2D(CanvasPanelSlot:GetPosition().X, self.ListViewPosYWithOutChannelList))
    end
    self:DelayScrollToBottom()
  end
end
function WBP_ChatView_C:DelayUpdateBtnScrollToBottomVisible()
  self.UpdateBtnTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.UpdateBtnScrollToBottomVisible
  }, 0.05, false)
end
function WBP_ChatView_C:UpdateBtnScrollToBottomVisible()
  if self and self.HaveNewMsg then
    local Num = self.RGListViewChatList:GetNumItems()
    if 0 == Num then
      self:HideBtnScrollToBottom()
    elseif not self.RGListViewChatList:BP_IsItemVisible(self.RGListViewChatList:GetItemAt(Num - 1)) then
      UpdateVisibility(self.BP_ButtonWithSoundScrollToBottom, true, true)
    else
      self:HideBtnScrollToBottom()
    end
  end
  if self and self.bIsFocus then
    self:UpdateListViewScrollBarVisible()
  end
end
function WBP_ChatView_C:UpdateListViewScrollBarVisible()
  if NearlyEquals(self.SizeBoxChatList:GetDesiredSize().Y, self.SizeBoxChatList.MaxDesiredHeight) then
    self.RGListViewChatList:SetScrollbarVisibility(UE.ESlateVisibility.Visible)
  else
    self.RGListViewChatList:SetScrollbarVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_ChatView_C:HideBtnScrollToBottom()
  UpdateVisibility(self.BP_ButtonWithSoundScrollToBottom, false, true)
  self.HaveNewMsg = false
end
function WBP_ChatView_C:ScrollToBottom()
  if self then
    if self.SizeBoxChatList:GetDesiredSize().Y - self.SizeBoxChatList.MaxDesiredHeight >= -1.0E-8 then
      self.RGListViewChatList:ScrollToBottom()
    end
    self:HideBtnScrollToBottom()
  end
end
function WBP_ChatView_C:OnListViewScrolledChanged(ItemOffset, DistanceRemaining)
  self:UpdateBtnScrollToBottomVisible()
end
function WBP_ChatView_C:SetCurSelectChannel(SelectIndex)
  LogicChat.CurSelectChannel = SelectIndex
  local Channel = LogicChat.CurSelectChannel
  if ChatDataMgr.SendLobbyChannelDic[LogicChat.CurSelectChannel] then
    Channel = UE.EChatChannel.Lobby
  end
  local ChannelRow = LogicChat:GetChannelRow(Channel)
  local Name = ""
  if ChannelRow then
    Name = ChannelRow.ChannelName
    self.RGTextChannel:SetColorAndOpacity(ChannelRow.ChannelColor)
  end
  self.RGTextChannel:SetText(Name)
  print("WBP_ChatView_C:SetCurSelectChannel", SelectIndex)
  self:UpdateChatList()
  self:DelayScrollToBottom()
end
function WBP_ChatView_C:DelayScrollToBottom()
  if self.bIsFocus then
    self.RGListViewChatList:ScrollToBottom()
  else
    UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
      self,
      function()
        UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
          self,
          function()
            if self then
              self:ScrollToBottom()
            end
          end
        })
      end
    })
  end
end
function WBP_ChatView_C:ReceiveMsg(ChatContentData, needScrollToBottom)
  self:UpdateChatList(needScrollToBottom)
  self.HaveNewMsg = true
  if ChatContentData and ChatContentData.ChannelId == UE.EChatChannel.Team and self.ChatType == ChatDataMgr.EChatType.Battle then
    self.ChatTime = 0
    self.bIsHide = false
    UpdateVisibility(self, true)
  end
end
function WBP_ChatView_C:UpdateChatList(needScrollToBottom)
  local ContentList
  if LogicChat.CurSelectChannel == UE.EChatChannel.Composite then
    ContentList = {}
    for i, v in ipairs(ChatDataMgr.ChatCompositeDataList) do
      table.insert(ContentList, ChatDataMgr.ChatChannelToContentList[v.ChannelId][v.Index])
    end
  else
    ContentList = ChatDataMgr.ChatChannelToContentList[LogicChat.CurSelectChannel] or {}
  end
  local ChatDataObjList = UE.TArray(UE.UObject)
  ChatDataObjList:Reserve(#ContentList)
  for i, v in ipairs(ContentList) do
    if self.ChatType ~= ChatDataMgr.EChatType.Lobby or v.ChannelId ~= UE.EChatChannel.Team or v.MsgType ~= ChatDataMgr.EMsgType.System then
      if v.MsgType ~= ChatDataMgr.EMsgType.Error and (v.NickName == "" or v.NickName == nil) then
        v.NickName = DataMgr.GetPlayerNickNameById(v.Content.sender)
      end
      if v.MsgType == ChatDataMgr.EMsgType.Error then
        local ChatDataObj = self.RGListViewChatList:GetOrCreateDataObj()
        ChatDataObj.SenderId = -1
        ChatDataObj.Msg = v.Content
        ChatDataObj.MsgType = v.MsgType
        ChatDataObj.ChannelId = v.ChannelId
        ChatDataObj.Name = ""
        ChatDataObj.ChatType = self.ChatType
        ChatDataObjList:Add(ChatDataObj)
      else
        local ChatDataObj = self.RGListViewChatList:GetOrCreateDataObj()
        ChatDataObj.SenderId = v.Content.sender
        ChatDataObj.Msg = v.Content.msg
        ChatDataObj.MsgType = v.MsgType
        local ChannelId = v.ChannelId
        local NickName = v.NickName
        if self.ChatType == ChatDataMgr.EChatType.Battle and v.MsgType == ChatDataMgr.EMsgType.System then
          ChannelId = UE.EChatChannel.System
          NickName = ""
        end
        ChatDataObj.ChannelId = ChannelId
        ChatDataObj.Name = NickName
        ChatDataObj.ChatType = self.ChatType
        if v.Content.extra then
          ChatDataObj.TeamID = v.Content.extra.teamID
          ChatDataObj.Version = v.Content.extra.version
        end
        ChatDataObjList:Add(ChatDataObj)
      end
    end
  end
  self.RGListViewChatList:SetRGListItems(ChatDataObjList, true, true)
  if not self.bIsFocus then
    self:ScrollToBottom()
  end
  if needScrollToBottom then
    self.RGListViewChatList:ScrollToBottom()
  end
  if self.bIsFocus then
    self:UpdateListViewScrollBarVisible()
    self:UpdateBtnScrollToBottomVisible()
  end
end
function WBP_ChatView_C:OnBackClick()
  print("WBP_ChatView_C:OnBackClick")
  self:FocusChatView(false)
end
function WBP_ChatView_C:OnEnterClick()
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics("LobbyChatOpen")
  end
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.TEAM_INVITE) then
    return
  end
  self:FocusChatView(true)
end
function WBP_ChatView_C:OnChatHover()
  self.URGImagePreviewInputBg:SetRenderOpacity(0.7)
  UpdateVisibility(self.URGImagePreviewInputBg_Hover, true)
end
function WBP_ChatView_C:OnUnChatHover()
  self.URGImagePreviewInputBg:SetRenderOpacity(0.4)
  UpdateVisibility(self.URGImagePreviewInputBg_Hover, false)
end
function WBP_ChatView_C:OnTextInputCommit(TextParam, CommitMethod)
  if CommitMethod == UE.ETextCommit.OnEnter then
    self:SendMsg()
  end
end
function WBP_ChatView_C:OnHandleKeyDown(Geometry, KeyEvent)
  if UE.URGBlueprintLibrary.GetInputKey(KeyEvent).KeyName == "Tab" then
    self:ChangeChannel()
  end
end
function WBP_ChatView_C:OnShowChannelListClick()
  if CheckIsVisility(self.WBP_ChatChannelList) then
    UpdateVisibility(self.WBP_ChatChannelList, false)
  else
    UpdateVisibility(self.WBP_ChatChannelList, true)
    self.WBP_ChatChannelList:ShowChannelList(self)
  end
end
function WBP_ChatView_C:OnSendChatMsgSucc()
  self.RGEditableTextInput:SetText("")
end
function WBP_ChatView_C:OnSendChatMsgFailed(errcode, lastTime, period)
end
function WBP_ChatView_C:SendMsg()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.TEAM_INVITE) then
    return
  end
  if not CheckIsChannelCommunicateAllowed() then
    ShowWaveWindow(400001)
    return
  end
  if self.bIsFocus then
    local Content = tostring(self.RGEditableTextInput:GetText())
    if "" == Content then
      self:FocusChatView(false)
    elseif LogicChat.CurSelectChannel == UE.EChatChannel.Team then
      LogicChat:SendChatMsg(tostring(DataMgr.MyTeamInfo.teamid), LogicChat.CurSelectChannel, Content)
    else
      local Channel = LogicChat.CurSelectChannel
      if ChatDataMgr.SendLobbyChannelDic[LogicChat.CurSelectChannel] then
        Channel = UE.EChatChannel.Lobby
      end
      LogicChat:SendChatMsg("0", Channel, Content)
    end
  else
    local canFocus = true
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
    if UIManager and GetCurSceneStatus() == UE.ESceneStatus.EBattle then
      canFocus = UIManager.CurrentFocusUI == RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
    end
    if canFocus then
      self:FocusChatView(true)
    end
  end
end
function WBP_ChatView_C:ChangeChannel()
  if self.ChatType == ChatDataMgr.EChatType.Lobby and self.bIsFocus then
    local Channel = LogicChat.CurSelectChannel + 1
    if Channel > UE.EChatChannel.Composite or Channel >= UE.EChatChannel.EChatChannel_MAX then
      Channel = UE.EChatChannel.Lobby
    end
    local bIsValid = UE.EChatChannel:IsValidEnumValue(Channel)
    while not bIsValid do
      Channel = Channel + 1
      if Channel > UE.EChatChannel.Composite or Channel >= UE.EChatChannel.EChatChannel_MAX then
        Channel = UE.EChatChannel.Lobby
      end
      bIsValid = UE.EChatChannel:IsValidEnumValue(Channel)
    end
    self.WBP_ChatChannelList.RGToggleGroupChannel:SelectId(Channel)
  end
end
function WBP_ChatView_C:OnLIPassEvent(evt)
  local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
  VoiceControlModule:RemoveLiEvent()
  print("============WBP_ChatView_C:OnLIPassEven1", evt.EventType, evt.ExtraJson)
  if evt.EventType == UE.ELIEventType.SOCIAL_FEATURE_APPROVE_STATUS then
    local EventParams = rapidjson.decode(evt.ExtraJson)
    print("============WBP_ChatView_C:OnLIPassEven2", 0 == EventParams.needVoiceControl, 1 == EventParams.voiceControlStatus)
    if 0 == EventParams.needVoiceControl and 1 == EventParams.voiceControlStatus then
      print("=============WBP_ChatView_C:OnLIPassEven3")
      self:FocusChatView(true, true)
    elseif 1 == EventParams.needVoiceControl and (1 == EventParams.voiceControlStatus or 0 == EventParams.voiceControlStatus) then
      local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
      if VoiceControlModule and not VoiceControlModule.LocalVoiceControlData then
        ShowWaveWindow(1552)
        VoiceControlModule.LocalVoiceControlData = true
      end
      self:FocusChatView(true, true)
    elseif -1 == EventParams.voiceControlStatus then
      ShowWaveWindow(1551)
    end
  end
end
function WBP_ChatView_C:OnRollback()
  print("WBP_LobbyPanel_C:OnRollback")
  self:PlayInLobbyPanelAnimation()
  self:BindConsoleKeys()
end
function WBP_ChatView_C:OnHideByOther()
  print("WBP_LobbyPanel_C:OnHideByOther")
  self:UnBindConsoleKeys()
end
function WBP_ChatView_C:Destruct()
  self.Overridden.Destruct(self)
  EventSystem.RemoveListener(EventDef.Chat.SendChatMsgSucc, self.OnSendChatMsgSucc, self)
  EventSystem.RemoveListener(EventDef.Chat.SendChatMsgFailed, self.OnSendChatMsgFailed, self)
  self.RGEditableTextInput.OnTextCommitted:Remove(self, self.OnTextInputCommit)
  self.RGEditableTextInput.OnHandleKeyDown:Remove(self, self.OnHandleKeyDown)
  self.BP_ButtonWithSoundChannel.OnClicked:Remove(self, self.OnShowChannelListClick)
  self.BP_ButtonWithSoundBack.OnClicked:Remove(self, self.OnBackClick)
  self.BP_ButtonWithSoundEnter.OnClicked:Remove(self, self.OnEnterClick)
  self.BP_ButtonWithSoundEnter.OnHovered:Remove(self, self.OnChatHover)
  self.BP_ButtonWithSoundEnter.OnUnhovered:Remove(self, self.OnUnChatHover)
  self.BP_ButtonWithSoundScrollToBottom.OnClicked:Remove(self, self.ScrollToBottom)
  self.RGListViewChatList.ListViewScrolledChanged:Remove(self, self.OnListViewScrolledChanged)
  if IsListeningForInputAction(self, self.SendMsgName) then
    StopListeningForInputAction(self, self.SendMsgName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.Tab) then
    StopListeningForInputAction(self, self.Tab, UE.EInputEvent.IE_Pressed)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.UpdateBtnTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.UpdateBtnTimer)
    self.UpdateBtnTimer = nil
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ChatTimer) then
    print("WBP_ChatView_C:ClearChatTimer")
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ChatTimer)
    self.ChatTimer = nil
  end
  LogicChat:UnBindWidget(self)
  self.BP_ButtonWithSoundChannel.OnClicked:Remove(self, self.OnShowChannelListClick)
  local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
  if VoiceControlModule then
    VoiceControlModule:RemoveLiEvent()
  end
end
return WBP_ChatView_C
