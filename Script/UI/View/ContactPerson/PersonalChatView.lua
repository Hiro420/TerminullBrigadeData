local PersonalChatView = UnLua.Class()
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local ContactPersonHandler = require("Protocol.ContactPerson.ContactPersonHandler")
local EscName = "PauseGame"

function PersonalChatView:Construct()
  self.Edit_ChatInfo.OnTextCommitted:Add(self, self.BindOnChatInfoTextCommitted)
  self.Btn_Close.OnClicked:Add(self, self.BindOnCloseButtonClicked)
  self.Btn_EnterMsg.OnClicked:Add(self, self.BindOnEnterMsgButtonClicked)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.BindOnCloseButtonClicked)
end

function PersonalChatView:Show(SelectPlayerInfo)
  self:SetFocus()
  self:StopAllAnimations()
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimationForward(self.Anim_IN)
  self.ChatItemListView.BP_OnItemSelectionChanged:Add(self, self.BindOnChatItemSelectionChanged)
  EventSystem.AddListener(self, EventDef.ContactPerson.OnRemovePersonalChatInfo, self.BindOnRemovePersonalChatInfo)
  EventSystem.AddListener(self, EventDef.ContactPerson.OnPersonalChatInfoUpdate, self.BindOnPersonalChatInfoUpdate)
  EventSystem.AddListener(self, EventDef.PlayerInfo.QueryPlayerInfoSucc, self.BindOnQueryPlayerInfoSucc)
  self:RefreshChatList(SelectPlayerInfo)
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      PersonalChatView.ListenForEscInputAction
    })
  end
  self:SetEnhancedInputActionBlocking(true)
  self:PushInputAction()
end

function PersonalChatView:ShowEmptyChatItemPanel()
  self.EmptyChatPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.ChatItemListView:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_EmptyChatBG:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Edit_ChatInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function PersonalChatView:OnAnimationFinished(InAnimation)
  if InAnimation == self.Anim_OUT then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.ChatInfoListView:SetRGListItems({}, false, true)
    self.ChatItemListView:SetRGListItems({}, false, true)
  end
end

function PersonalChatView:Hide()
  self:PlayAnimationForward(self.Anim_OUT)
  if UIMgr:IsShow(ViewID.UI_ContactPersonOperateButtonPanel) then
    UIMgr:Hide(ViewID.UI_ContactPersonOperateButtonPanel)
  end
  self.ChatItemListView.BP_OnItemSelectionChanged:Remove(self, self.BindOnChatItemSelectionChanged)
  EventSystem.RemoveListener(EventDef.ContactPerson.OnRemovePersonalChatInfo, self.BindOnRemovePersonalChatInfo, self)
  EventSystem.RemoveListener(EventDef.ContactPerson.OnPersonalChatInfoUpdate, self.BindOnPersonalChatInfoUpdate, self)
  EventSystem.RemoveListener(EventDef.PlayerInfo.QueryPlayerInfoSucc, self.BindOnQueryPlayerInfoSucc, self)
  if IsListeningForInputAction(self, EscName) then
    StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  end
  self:SetEnhancedInputActionBlocking(false)
  self:PopInputAction()
end

function PersonalChatView:ListenForEscInputAction()
  self:BindOnCloseButtonClicked()
end

function PersonalChatView:BindOnQueryPlayerInfoSucc(Params)
  local IsNeedRefresh = false
  local PersonalChatInfoList = ContactPersonData:GetPersonalChatInfo()
  local TargetPlayerInfo
  for PersonalRoleId, PersonalChatInfo in pairs(PersonalChatInfoList) do
    TargetPlayerInfo = ContactPersonData:GetPlayerInfoByRoleId(PersonalRoleId)
    if not TargetPlayerInfo then
      IsNeedRefresh = true
    end
  end
  if IsNeedRefresh then
    self:RefreshChatList()
  end
end

function PersonalChatView:RefreshChatList(SelectPlayerInfo)
  local PersonalChatInfo = ContactPersonData:GetPersonalChatInfo()
  if next(PersonalChatInfo) == nil and not SelectPlayerInfo then
    self.EmptyChatPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.ChatItemListView:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_EmptyChatBG:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Edit_ChatInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.HeadIconPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_ChatPartnerName:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.ChatInfoListView:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self.Edit_ChatInfo:SetVisibility(UE.ESlateVisibility.Visible)
  self.EmptyChatPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ChatItemListView:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Img_EmptyChatBG:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.HeadIconPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_ChatPartnerName:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local TargetPlayerInfo
  self.ChatItemListView:RecyleAllData()
  local DataObjList = {}
  local CurSelectedItem
  local RoleIdList = {}
  for PersonalRoleId, PersonalChatInfo in pairs(PersonalChatInfo) do
    table.insert(RoleIdList, PersonalRoleId)
  end
  table.sort(RoleIdList, function(a, b)
    local AInfoList = PersonalChatInfo[a]
    local BInfoList = PersonalChatInfo[b]
    if AInfoList[table.count(AInfoList)] and BInfoList[table.count(BInfoList)] then
      return AInfoList[table.count(AInfoList)].ReceiveTime > BInfoList[table.count(BInfoList)].ReceiveTime
    else
      return not AInfoList[table.count(AInfoList)] and BInfoList[table.count(BInfoList)]
    end
  end)
  for i, PersonalRoleId in pairs(RoleIdList) do
    local SinglePersonalChatInfo = PersonalChatInfo[PersonalRoleId]
    if SelectPlayerInfo and PersonalRoleId == SelectPlayerInfo.roleid then
      TargetPlayerInfo = SelectPlayerInfo
    else
      TargetPlayerInfo = ContactPersonData:GetPlayerInfoByRoleId(PersonalRoleId)
      if not TargetPlayerInfo and "nil" ~= PersonalRoleId then
        local Result, PlayerInfoList = DataMgr.GetOrQueryPlayerInfo({PersonalRoleId})
        if Result then
          TargetPlayerInfo = PlayerInfoList[1] and PlayerInfoList[1].playerInfo or nil
        end
      end
    end
    if TargetPlayerInfo then
      local SingleDataObj = self.ChatItemListView:GetOrCreateDataObj()
      local TempTable = {PlayerInfo = TargetPlayerInfo, ChatInfo = SinglePersonalChatInfo}
      SingleDataObj.Info = TempTable
      table.insert(DataObjList, SingleDataObj)
      if SelectPlayerInfo and SelectPlayerInfo.roleid == PersonalRoleId then
        CurSelectedItem = SingleDataObj
      end
    end
  end
  self.ChatItemListView:SetRGListItems(DataObjList, false, true)
  CurSelectedItem = CurSelectedItem or DataObjList[1]
  if CurSelectedItem then
    self.ChatItemListView:BP_ScrollItemIntoView(CurSelectedItem)
    self.ChatItemListView:BP_SetSelectedItem(CurSelectedItem)
  end
end

function PersonalChatView:BindOnChatItemSelectionChanged(DataObj, IsSelected)
  if not IsSelected then
    return
  end
  self.SelectItem = DataObj
  self.Txt_ChatPartnerName:SetText(DataObj.Info.PlayerInfo.nickname)
  local PortraitRowInfo = LogicLobby.GetPlayerPortraitTableRowInfo(DataObj.Info.PlayerInfo.portrait)
  if PortraitRowInfo then
    SetImageBrushByPath(self.Img_ChatPartnerHeadIcon, PortraitRowInfo.portraitIconPath)
  end
  self:RefreshChatInfoList(DataObj.Info.ChatInfo, DataObj.Info.PlayerInfo)
end

function PersonalChatView:BindOnRemovePersonalChatInfo(RoleId)
  ContactPersonData:RemovePersonalChatInfo(RoleId)
  local ContactPersonManager = ModuleManager:Get("ContactPersonModule")
  if ContactPersonManager then
    ContactPersonManager:RemovePlayerHistoryChatInfo(RoleId)
  end
  self:RefreshChatList()
end

function PersonalChatView:BindOnPersonalChatInfoUpdate(RoleId, IsSendMsg)
  if IsSendMsg then
    self.Edit_ChatInfo:SetText("")
  end
  local CurSelectedItem = self.ChatItemListView:BP_GetSelectedItem()
  if not CurSelectedItem then
    return
  end
  if CurSelectedItem.Info.PlayerInfo.roleid ~= RoleId then
    return
  end
  local ChatInfo = ContactPersonData:GetPersonalChatInfoById(RoleId)
  self:RefreshChatInfoList(ChatInfo, CurSelectedItem.Info.PlayerInfo)
end

function PersonalChatView:RefreshChatInfoList(ChatInfo, ChatPartnerPlayerInfo)
  if not ChatInfo then
    self.ChatInfoListView:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_EmptyChatBG:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:ShowEmptyChatItemPanel()
  else
    self.Img_EmptyChatBG:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.ChatInfoListView:SetVisibility(UE.ESlateVisibility.Visible)
    local ListItems = self.ChatInfoListView:GetListItems()
    self.ChatInfoListView:RecyleAllData()
    local DataObjList = {}
    for index, SingleChatInfo in ipairs(ChatInfo) do
      local SingleDataObj = self.ChatInfoListView:GetOrCreateDataObj()
      SingleDataObj.Info = SingleChatInfo
      if SingleChatInfo.IsReceive then
        SingleDataObj.PlayerInfo = ChatPartnerPlayerInfo
      else
        SingleDataObj.PlayerInfo = DataMgr.GetBasicInfo()
      end
      SingleDataObj.IsPlayInAnim = index == #ChatInfo
      table.insert(DataObjList, SingleDataObj)
    end
    self.ChatInfoListView:SetRGListItems(DataObjList)
    self.ChatInfoListView:ScrollToBottom()
  end
end

function PersonalChatView:BindOnChatInfoTextCommitted(Text, CommitMethod)
  if CommitMethod ~= UE.ETextCommit.OnEnter then
    return
  end
  self:BindOnEnterMsgButtonClicked()
end

function PersonalChatView:BindOnCloseButtonClicked()
  EventSystem.Invoke(EventDef.ContactPerson.UpdatePersonalChatPanelVis, false)
end

function PersonalChatView:BindOnEnterMsgButtonClicked()
  local CurSelectedItem = self.ChatItemListView:BP_GetSelectedItem()
  if not CurSelectedItem then
    return
  end
  if not CheckIsChannelCommunicateAllowed() then
    ShowWaveWindow(400001)
    return
  end
  if self.LastSendMsgTime and os.clock() - self.LastSendMsgTime <= 0.3 then
    print("PersonalChatView:BindOnEnterMsgButtonClicked \229\143\145\232\168\128\229\164\170\233\162\145\231\185\129")
    return
  end
  self.LastSendMsgTime = os.clock()
  if ContactPersonData:IsInBlackList(CurSelectedItem.Info.PlayerInfo.roleid) then
    ShowWaveWindow(self.InBlackListTipId)
    return
  end
  local InputText = tostring(self.Edit_ChatInfo:GetText())
  if UE.UKismetStringLibrary.IsEmpty(InputText) then
    return
  end
  local TextLength = 0
  local CharArray = UE.UKismetStringLibrary.GetCharacterArrayFromString(InputText)
  for k, Char in pairs(CharArray) do
    if HaveChineseChar(Char) then
      TextLength = TextLength + 2
    else
      TextLength = TextLength + 1
    end
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBChat, TableEnums.ENUMChannel.Friend)
  if Result and TextLength > RowInfo.TextLimit then
    local Result, ChatContentRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBChatContent, TableEnums.ENUMChatContent.ContentTooLong)
    if Result then
      ShowWaveWindow(100001, {
        ChatContentRowInfo.Content
      })
    end
    return
  end
  self:SendPersonalMsg(InputText, CurSelectedItem.Info.PlayerInfo)
end

function PersonalChatView:SendPersonalMsg(InputText, PlayerInfo, bSkipCheckAdult)
  if UE.UKismetStringLibrary.IsEmpty(InputText) then
    return
  end
  if not bSkipCheckAdult and not UE.URGBlueprintLibrary.IsPlatformConsole() then
    local CallBack = function(Obj)
      if IsValidObj(Obj) then
        Obj:SendPersonalMsg(InputText, PlayerInfo, true)
      end
    end
    local VoiceControlModule = ModuleManager:Get("VoiceControlModule")
    if VoiceControlModule and VoiceControlModule:CheckIsVoiceControl(self, function(Obj, evt)
      local VoiceControlModuleTemp = ModuleManager:Get("VoiceControlModule")
      if VoiceControlModuleTemp then
        VoiceControlModuleTemp:OnLiPassEvent(evt, Obj, CallBack)
      end
    end) then
      return
    end
  end
  ContactPersonHandler:RequestSendPersonalMessageToServer(InputText, PlayerInfo)
end

function PersonalChatView:Destruct()
  self:Hide()
end

return PersonalChatView
