local rapidjson = require("rapidjson")
local TeamVoiceModule = require("Modules.TeamVoice.TeamVoiceModule")
local MAX_MSG_NUM = 100
local RELEASE_MSG_NUM = 10
local ShieldTxt = NSLOCTEXT("ChatDataMgr", "ShieldTxt", "\229\183\178\229\177\143\232\148\189[{0}]")
local UnShieldTxt = NSLOCTEXT("ChatDataMgr", "UnShieldTxt", "\229\143\150\230\182\136\229\177\143\232\148\189[{0}]")
ChatDataMgr = {
  ChatChannelToContentList = {
    [0] = {},
    [1] = {},
    [2] = {}
  },
  ChatCompositeDataList = {},
  UserIdToName = {},
  EMsgType = {
    Normal = 1,
    Person = 2,
    Error = 3,
    Recruit = 4,
    System = 5
  },
  SheildPlayerList = {},
  EChatType = {Lobby = 1, Battle = 2},
  SendLobbyChannelDic = {
    [UE.EChatChannel.Lobby] = true,
    [UE.EChatChannel.Composite] = true,
    [UE.EChatChannel.Recruit] = true,
    [UE.EChatChannel.System] = true
  }
}

function ChatDataMgr.Init()
  EventSystem.AddListener(nil, EventDef.WSMessage.ChatMsg, ChatDataMgr.OnChatMsg)
  EventSystem.AddListener(nil, EventDef.WSMessage.SystemMsg, ChatDataMgr.OnChatMsg)
  EventSystem.AddListener(nil, EventDef.Lobby.OnTeamStateChanged, ChatDataMgr.BindOnTeamStateChanged)
  EventSystem.AddListenerNew(EventDef.WSMessage.DeletePersonalMsg, nil, ChatDataMgr.OnDeletePersonalMsg)
  EventSystem.AddListenerNew(EventDef.WSMessage.worldChatChannel, nil, ChatDataMgr.OnWorldChatChannel)
  ListenObjectMessage(nil, GMP.MSG_UI_Chat_ReceiveChatMsg, GameInstance, ChatDataMgr.BindDsReceiveChatMsg)
end

function ChatDataMgr.UpdateVoiceBanInfo(BanInfo)
  if BanInfo.ErrorCode == 17010 then
    ChatDataMgr.BanInfo = {
      BanReasonId = BanInfo.BanReasonId,
      BanEndTime = BanInfo.BanEndTime,
      ErrorCode = 17010
    }
  end
end

function ChatDataMgr.ShowBanTips()
end

function ChatDataMgr.OnChatMsg(MsgJson)
  local Response = rapidjson.decode(MsgJson)
  if not Response then
    return
  end
  DataMgr.SetUserIDChannelUserId(Response.sender, Response.channelUID)
  if ChatDataMgr.CheckPlayerIsBeSheilded(Response.sender) then
    print("ChatDataMgr.OnChatMsg Sheild Player Msg", Response.sender)
    return
  end
  local ChannelId = Response.channelId
  local systemMsgId = Response.SystemMsgID
  if GetCurSceneStatus() == UE.ESceneStatus.EBattle and ChannelId == UE.EChatChannel.System then
    local resultChatSystem, rowChatSystem = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSystemMsg, systemMsgId)
    if resultChatSystem and rowChatSystem.SystemChatShow ~= TableEnums.ENUMSystemShow.Battle and rowChatSystem.SystemChatShow ~= TableEnums.ENUMSystemShow.All then
      return
    end
  end
  if Response.extra and ChannelId ~= UE.EChatChannel.System then
    Response.extra = rapidjson.decode(Response.extra)
  end
  local nickName = ""
  if Response.senderInfo then
    nickName = Response.senderInfo.nickname
  end
  local bOnlyShowInBattle = false
  local ChatContentData = {
    MsgType = ChatDataMgr.EMsgType.Normal,
    Content = Response,
    ChannelId = ChannelId,
    NickName = nickName
  }
  if ChannelId == UE.EChatChannel.Recruit then
    ChatContentData.Content.sender = tonumber(ChatContentData.Content.extra.roleID)
    local fmt = UE.URGBlueprintLibrary.TextFromStringTable("1251")
    local worldName = ""
    local resultWorld, rowWorld = GetRowData(DT.DT_GameMode, ChatContentData.Content.extra.worldID)
    if resultWorld then
      worldName = rowWorld.Name
    end
    local modName = ""
    local resultMod, rowMod = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, ChatContentData.Content.extra.gameMode)
    if resultMod then
      modName = rowMod.Name
    end
    local modeDiffcultTxt = LogicTeam.GetModeDifficultDisplayText(ChatContentData.Content.extra.gameMode, ChatContentData.Content.extra.floor)
    ChatContentData.Content.msg = UE.FTextFormat(fmt, modName, worldName, modeDiffcultTxt, ChatContentData.Content.extra.num)
  elseif ChannelId == UE.EChatChannel.System then
    ChatContentData.Content.sender = 0
    ChatContentData.MsgType = ChatDataMgr.EMsgType.System
    local bShowInBattle = false
    local resultChatSystem, rowChatSystem = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSystemMsg, tonumber(systemMsgId))
    if resultChatSystem then
      local params = {}
      for i, v in ipairs(Response.extra.params) do
        if rowChatSystem.params[i] then
          local param = ChatDataMgr.TranslateChatParams(v, rowChatSystem.params[i].paramType)
          table.insert(params, param)
        else
          table.insert(params, v)
        end
      end
      ChatContentData.Content.msg = UE.FTextFormat(rowChatSystem.Msg, table.unpack(params))
      bShowInBattle = rowChatSystem.SystemChatShow == TableEnums.ENUMSystemShow.Battle or rowChatSystem.SystemChatShow == TableEnums.ENUMSystemShow.All
      bOnlyShowInBattle = rowChatSystem.SystemChatShow == TableEnums.ENUMSystemShow.Battle
    end
    if GetCurSceneStatus() == UE.ESceneStatus.EBattle and bShowInBattle then
      local teamChannelId = UE.EChatChannel.Team
      if not ChatDataMgr.ChatChannelToContentList[teamChannelId] then
        ChatDataMgr.ChatChannelToContentList[teamChannelId] = {}
      end
      ChatDataMgr.BufferMsg(teamChannelId)
      ChatContentData.ChannelId = teamChannelId
      table.insert(ChatDataMgr.ChatChannelToContentList[teamChannelId], ChatContentData)
      table.insert(ChatDataMgr.ChatCompositeDataList, {
        ChannelId = teamChannelId,
        Index = #ChatDataMgr.ChatChannelToContentList[teamChannelId]
      })
      EventSystem.Invoke(EventDef.Chat.ReciveNewMsg, ChatContentData)
      ChatContentData.ChannelId = UE.EChatChannel.System
    end
  end
  if not bOnlyShowInBattle then
    if not ChatDataMgr.ChatChannelToContentList[ChannelId] then
      ChatDataMgr.ChatChannelToContentList[ChannelId] = {}
    end
    ChatDataMgr.BufferMsg(ChannelId)
    table.insert(ChatDataMgr.ChatChannelToContentList[ChannelId], ChatContentData)
    table.insert(ChatDataMgr.ChatCompositeDataList, {
      ChannelId = ChannelId,
      Index = #ChatDataMgr.ChatChannelToContentList[ChannelId]
    })
  end
  EventSystem.Invoke(EventDef.Chat.ReciveNewMsg, ChatContentData)
end

function ChatDataMgr.TranslateChatParams(Param, paramType)
  if paramType then
    if paramType == TableEnums.ENUMSystemMsgParamType.GachaPond then
      local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGachaPond, tonumber(Param))
      if result then
        return row.Name
      else
        return Param
      end
    elseif paramType == TableEnums.ENUMSystemMsgParamType.ResourceID then
      local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, tonumber(Param))
      if result then
        return row.Name
      else
        return Param
      end
    elseif paramType == TableEnums.ENUMSystemMsgParamType.RoleID then
    else
      return Param
    end
  end
  return Param
end

function ChatDataMgr.BindDsReceiveChatMsg(UserId, Msg)
  local msgJsonDecode = rapidjson.decode(Msg)
  if ChatDataMgr.CheckPlayerIsBeSheilded(UserId) then
    print("ChatDataMgr.BindDsReceiveChatMsg Sheild Player Msg", UserId)
    return
  end
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return
  end
  local bShowInBattle = false
  local nickName = ""
  local ChannelId = UE.EChatChannel.Team
  local systemMsgId = msgJsonDecode.SystemMsgID
  local Content = {sender = UserId}
  local resultChatSystem, rowChatSystem = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSystemMsg, systemMsgId)
  if resultChatSystem then
    Content.msg = UE.FTextFormat(rowChatSystem.Msg, table.unpack(msgJsonDecode.extra.params))
    bShowInBattle = rowChatSystem.SystemChatShow == TableEnums.ENUMSystemShow.Battle or rowChatSystem.SystemChatShow == TableEnums.ENUMSystemShow.All
  end
  if not bShowInBattle then
    ChannelId = UE.EChatChannel.System
  end
  local ChatContentData = {
    MsgType = ChatDataMgr.EMsgType.System,
    Content = Content,
    ChannelId = ChannelId,
    NickName = nickName
  }
  ChatDataMgr.BufferMsg(ChannelId)
  if not ChatDataMgr.ChatChannelToContentList[ChannelId] then
    ChatDataMgr.ChatChannelToContentList[ChannelId] = {}
  end
  table.insert(ChatDataMgr.ChatChannelToContentList[ChannelId], ChatContentData)
  table.insert(ChatDataMgr.ChatCompositeDataList, {
    ChannelId = ChannelId,
    Index = #ChatDataMgr.ChatChannelToContentList[ChannelId]
  })
  EventSystem.Invoke(EventDef.Chat.ReciveNewMsg, ChatContentData)
end

function ChatDataMgr.OnPersonalChatMsg(MsgJson)
  local Response = rapidjson.decode(MsgJson)
  if not Response then
    return
  end
  if ChatDataMgr.CheckPlayerIsBeSheilded(Response.sender) then
    return
  end
  local ChatContentData = {
    MsgType = ChatDataMgr.EMsgType.Person,
    Content = Response,
    ChannelId = Response.sender
  }
  if not ChatDataMgr.ChatChannelToContentList[Response.sender] then
    ChatDataMgr.ChatChannelToContentList[Response.sender] = {}
  end
  table.insert(ChatDataMgr.ChatChannelToContentList[Response.sender], ChatContentData)
  table.insert(ChatDataMgr.ChatCompositeDataList, {
    ChannelId = Response.sender,
    Index = #ChatDataMgr.ChatChannelToContentList[Response.sender]
  })
  EventSystem.Invoke(EventDef.Chat.ReciveNewMsg, ChatContentData)
end

function ChatDataMgr.OnWorldChatChannel(ChatChannelData)
  print("ChatDataMgr.OnWorldChatChannel", ChatChannelData)
  if not ChatChannelData then
    return
  end
  local Response = rapidjson.decode(ChatChannelData)
  if not Response then
    print("ChatDataMgr.OnWorldChatChannel Response Is Nil")
    return
  end
  if not Response.chatChannel then
    print("ChatDataMgr.OnWorldChatChannel Response.chatChannel Is Nil")
    return
  end
  ChatDataMgr.ChatChannel = Response.chatChannel
end

function ChatDataMgr.OnDeletePersonalMsg(MsgJson)
  local Response = rapidjson.decode(MsgJson)
  if not Response then
    print("hatDataMgr.OnDeletePersonalMsg Response Is Nil")
    return
  end
  local removeList = {}
  for k, v in pairs(ChatDataMgr.ChatChannelToContentList) do
    for idxContent = #v, 1, -1 do
      local vContent = v[idxContent]
      if vContent.MsgType == ChatDataMgr.EMsgType.Error or type(vContent.Content) == "table" and tonumber(vContent.Content.sender) == tonumber(Response.roleID) then
        local removeData = {ChannelId = k, Idx = idxContent}
        table.insert(removeList, removeData)
        table.remove(v, idxContent)
        print("ChatDataMgr.OnDeletePersonalMsg ChatChannelToContentList", k, idxContent)
      end
    end
  end
  for i = #ChatDataMgr.ChatCompositeDataList, 1, -1 do
    local v = ChatDataMgr.ChatCompositeDataList[i]
    for iRemoveData, vRemoveData in ipairs(removeList) do
      if v.ChannelId == vRemoveData.ChannelId and v.Index == vRemoveData.Idx then
        table.remove(ChatDataMgr.ChatCompositeDataList, i)
        print("ChatDataMgr.OnDeletePersonalMsg ChatChannelToContentList11", v.ChannelId, i)
      end
    end
  end
  local preIdxTb = {}
  for i, v in ipairs(ChatDataMgr.ChatCompositeDataList) do
    if not preIdxTb[v.ChannelId] then
      preIdxTb[v.ChannelId] = 1
    end
    if v.Index > preIdxTb[v.ChannelId] then
      v.Index = preIdxTb[v.ChannelId]
    end
    preIdxTb[v.ChannelId] = preIdxTb[v.ChannelId] + 1
  end
  EventSystem.Invoke(EventDef.Chat.ReciveNewMsg, nil)
end

function ChatDataMgr.SendChatMsg(Id, ChannelId, Msg)
  HttpCommunication.Request("chatservice/message", {
    group = {id = Id, channelId = ChannelId},
    msg = Msg,
    channelUID = DataMgr.ChannelUserIdWithPrefix,
    worldChatChannel = ChatDataMgr.ChatChannel or 0
  }, {
    GameInstance,
    function(Target, JsonResponse)
      local Response = rapidjson.decode(JsonResponse.Content)
      if 0 == Response.errcode then
        EventSystem.Invoke(EventDef.Chat.SendChatMsgSucc)
      else
        local SendData = {
          sender = tonumber(DataMgr.GetUserId()),
          ChannelId = ChannelId,
          msg = Msg,
          groupId = 1,
          senderInfo = {
            nickname = DataMgr.GetBasicInfo().nickname
          }
        }
        EventSystem.Invoke(EventDef.Chat.SendChatMsgFailed, Response.errcode, Response.lastTime, Response.period, SendData)
      end
    end
  }, {
    GameInstance,
    function(Target, Error)
    end
  })
end

function ChatDataMgr.CheckVoiceBan(bNeedTips)
  if ChatDataMgr.BanInfo and 0 ~= ChatDataMgr.BanInfo.BanReasonId then
    if bNeedTips then
      TeamVoiceModule:ShowBanTips()
    end
    return true
  end
  return false
end

function ChatDataMgr.GetVoiceBanStatus(Callback, bIsNoTips)
  local needRequest = true
  if ChatDataMgr.BanInfo then
    local curTimeStamp = UE.URGStatisticsLibrary.GetTimestamp(true)
    if 0 == ChatDataMgr.BanInfo.BanReasonId or curTimeStamp < tonumber(ChatDataMgr.BanInfo.BanEndTime) then
      needRequest = false
    end
  end
  if not needRequest then
    if 0 == ChatDataMgr.BanInfo.BanReasonId then
      if Callback then
        Callback()
      end
    elseif not bIsNoTips then
      TeamVoiceModule:ShowBanTips()
    end
  else
    HttpCommunication.RequestByGet("chatservice/voicebanstatus", {
      GameInstance,
      function(Target, JsonResponse)
        local Response = rapidjson.decode(JsonResponse.Content)
        print("ChatDataMgr.GetVoiceBanStatus1", Response.banInfo)
        ChatDataMgr.BanInfo = {
          BanReasonId = Response.banInfo.banReason,
          BanEndTime = tonumber(Response.banInfo.banEndTime),
          ErrorCode = 17010
        }
        if Response.banInfo and 0 ~= Response.banInfo.banReason then
          print("ChatDataMgr.GetVoiceBanStatus", Response.banInfo.banEndTime, Response.banInfo.banReason)
          if Callback then
            Callback()
          end
        else
          TeamVoiceModule:SetMicMode(1, true)
        end
      end
    })
  end
end

function ChatDataMgr.BufferMsg(ChannelId)
  local bNeedShrink = false
  local removeList = {}
  if not ChatDataMgr.ChatChannelToContentList[ChannelId] then
    return
  end
  if #ChatDataMgr.ChatChannelToContentList[ChannelId] >= MAX_MSG_NUM then
    for i = 1, RELEASE_MSG_NUM do
      local removeData = {ChannelId = ChannelId, Idx = i}
      table.insert(removeList, removeData)
      table.remove(ChatDataMgr.ChatChannelToContentList[ChannelId], 1)
    end
    bNeedShrink = true
  end
  if bNeedShrink then
    for i = #ChatDataMgr.ChatCompositeDataList, 1, -1 do
      local v = ChatDataMgr.ChatCompositeDataList[i]
      for iRemoveData, vRemoveData in ipairs(removeList) do
        if v.ChannelId == vRemoveData.ChannelId and v.Index == vRemoveData.Idx then
          table.remove(ChatDataMgr.ChatCompositeDataList, i)
          print("ChatDataMgr.OnChatMsg ChatChannelToContentList11", i)
        end
      end
    end
    local preIdxTb = {}
    for i, v in ipairs(ChatDataMgr.ChatCompositeDataList) do
      if not preIdxTb[v.ChannelId] then
        preIdxTb[v.ChannelId] = 1
      end
      if v.Index > preIdxTb[v.ChannelId] then
        v.Index = preIdxTb[v.ChannelId]
      end
      preIdxTb[v.ChannelId] = preIdxTb[v.ChannelId] + 1
    end
  end
end

function ChatDataMgr.AddErroMsgToChannel(ChannelIdParam, ErroMsg)
  local ChannelId = ChannelIdParam
  if ChannelId == UE.EChatChannel.Composite then
    ChannelId = UE.EChatChannel.Lobby
  end
  local ChatContentData = {
    MsgType = ChatDataMgr.EMsgType.Error,
    Content = ErroMsg,
    ChannelId = ChannelId,
    NickName = ""
  }
  if not ChatDataMgr.ChatChannelToContentList[ChannelId] then
    ChatDataMgr.ChatChannelToContentList[ChannelId] = {}
  end
  ChatDataMgr.BufferMsg(ChannelId)
  table.insert(ChatDataMgr.ChatChannelToContentList[ChannelId], ChatContentData)
  table.insert(ChatDataMgr.ChatCompositeDataList, {
    ChannelId = ChannelId,
    Index = #ChatDataMgr.ChatChannelToContentList[ChannelId]
  })
  EventSystem.Invoke(EventDef.Chat.ReciveNewMsg, ChatContentData)
end

function ChatDataMgr.AddCustomMsg(SendData)
  if ChatDataMgr.CheckPlayerIsBeSheilded(SendData.sender) then
    print("ChatDataMgr.AddCustomMsg Sheild Player Msg", SendData.sender)
    return
  end
  local ChannelId = SendData.ChannelId
  local ChatContentData = {
    MsgType = ChatDataMgr.EMsgType.Normal,
    Content = SendData,
    ChannelId = ChannelId,
    NickName = SendData.senderInfo.nickname
  }
  if not ChatDataMgr.ChatChannelToContentList[ChannelId] then
    ChatDataMgr.ChatChannelToContentList[ChannelId] = {}
  end
  ChatDataMgr.BufferMsg(ChannelId)
  table.insert(ChatDataMgr.ChatChannelToContentList[ChannelId], ChatContentData)
  table.insert(ChatDataMgr.ChatCompositeDataList, {
    ChannelId = ChannelId,
    Index = #ChatDataMgr.ChatChannelToContentList[ChannelId]
  })
  EventSystem.Invoke(EventDef.Chat.ReciveNewMsg, ChatContentData)
end

function ChatDataMgr.SheildPlayerMsg(UserId, ChannelId, bIsSheild, NikcName)
  print("ChatDataMgr.SheildPlayerMsg UserId:", UserId, DataMgr.GetPlayerNickNameById(UserId))
  if bIsSheild then
    ChatDataMgr.SheildPlayerList[UserId] = true
    local Content = UE.FTextFormat(ShieldTxt(), NikcName)
    ChatDataMgr.AddErroMsgToChannel(ChannelId, Content)
  else
    ChatDataMgr.SheildPlayerList[UserId] = false
    local Content = UE.FTextFormat(UnShieldTxt(), NikcName)
    ChatDataMgr.AddErroMsgToChannel(ChannelId, Content)
  end
end

function ChatDataMgr.CheckPlayerIsBeSheilded(UserId)
  print("CheckPlayerIsBeSheilded:", UserId)
  if not UserId then
    return false
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local PrivacySubSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserPrivacySubsystem:StaticClass())
  if PrivacySubSystem then
    local ChannelUserID = DataMgr.GetPlayerChannelUserIdById(UserId)
    if nil ~= ChannelUserID and "" ~= ChannelUserID then
      local IsAllowed = PrivacySubSystem:IsCommunicateUsingTextOrVoiceAllowed(ChannelUserID, false)
      if IsAllowed == UE.EPermissionsResult.denied then
        return true
      end
    end
  end
  return ChatDataMgr.SheildPlayerList[UserId]
end

function ChatDataMgr.BindOnTeamStateChanged(OldState, NewState)
  if NewState == LogicTeam.TeamState.None then
    ChatDataMgr.ClearDataWhenExitTeam()
  end
end

function ChatDataMgr.ClearDataWhenEnterBattle()
  print("ChatDataMgr.ClearDataWhenEnterBattle")
  local ChatCompositeDataListTemp = {}
  for i, v in ipairs(ChatDataMgr.ChatCompositeDataList) do
    if v.ChannelId == UE.EChatChannel.Team then
      table.insert(ChatCompositeDataListTemp, v)
    end
  end
  ChatDataMgr.ChatCompositeDataList = ChatCompositeDataListTemp
  for k, v in pairs(ChatDataMgr.ChatChannelToContentList) do
    if k ~= UE.EChatChannel.Team then
      ChatDataMgr.ChatChannelToContentList[k] = {}
    end
  end
end

function ChatDataMgr.ClearDataWhenExitTeam()
  print("ChatDataMgr.ClearDataWhenExitTeam")
  local ChatCompositeDataListTemp = {}
  for i, v in ipairs(ChatDataMgr.ChatCompositeDataList) do
    if v.ChannelId ~= UE.EChatChannel.Team then
      table.insert(ChatCompositeDataListTemp, v)
    end
  end
  ChatDataMgr.ChatCompositeDataList = ChatCompositeDataListTemp
  ChatDataMgr.ChatChannelToContentList[UE.EChatChannel.Team] = {}
  EventSystem.Invoke(EventDef.Chat.ReciveNewMsg, nil)
end

function ChatDataMgr.ClearData()
  print("ChatDataMgr.ClearData")
  ChatDataMgr.ChatChannelToContentList = {}
  ChatDataMgr.ChatCompositeDataList = {}
  ChatDataMgr.SheildPlayerList = {}
end

function ChatDataMgr.Clear()
  ChatDataMgr.ClearData()
  EventSystem.RemoveListener(EventDef.WSMessage.ChatMsg, ChatDataMgr.OnChatMsg)
  EventSystem.RemoveListener(EventDef.WSMessage.SystemMsg, ChatDataMgr.OnChatMsg)
  EventSystem.RemoveListener(EventDef.Lobby.OnTeamStateChanged, ChatDataMgr.BindOnTeamStateChanged)
  EventSystem.RemoveListenerNew(EventDef.WSMessage.DeletePersonalMsg, nil, ChatDataMgr.OnDeletePersonalMsg)
  EventSystem.RemoveListenerNew(EventDef.WSMessage.worldChatChannel, nil, ChatDataMgr.OnWorldChatChannel)
  UnListenObjectMessage(GMP.MSG_UI_Chat_ReceiveChatMsg, GameInstance)
end
