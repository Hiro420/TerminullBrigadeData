local rapidjson = require("rapidjson")
LogicChat = LogicChat or {}
local ChatCDTxt = NSLOCTEXT("LogicChat", "ChatCDTxt", "\229\143\145\232\168\128\233\162\145\231\142\135\229\164\170\233\171\152\239\188\140\232\175\183{0}\231\167\146\229\144\142\229\134\141\232\175\149")
local NoTeamTxt = NSLOCTEXT("LogicChat", "NoTeamTxt", "\230\130\168\232\191\152\230\156\170\229\138\160\229\133\165\233\152\159\228\188\141")
local UnlockTxt = NSLOCTEXT("LogicChat", "UnlockTxt", "\232\175\165\232\129\138\229\164\169\233\162\145\233\129\147\232\191\152\230\156\170\232\167\163\233\148\129,{0}\231\186\167\232\167\163\233\148\129")
local SensitiveTxt = NSLOCTEXT("LogicChat", "SensitiveTxt", "\229\134\133\230\156\137\230\149\143\230\132\159\232\175\141\239\188\140\229\143\145\233\128\129\229\164\177\232\180\165")
function LogicChat:Init(WidgetParam)
  if not self.bIsInited then
    EventSystem.AddListener(nil, EventDef.Chat.ReciveNewMsg, LogicChat.OnReciveNewMsg)
    EventSystem.AddListener(nil, EventDef.Chat.SendChatMsgFailed, LogicChat.OnSendChatMsgFailed)
    self.bIsInited = true
  end
  if not LogicChat.Widgets then
    LogicChat.Widgets = {}
  end
  table.insert(LogicChat.Widgets, WidgetParam)
end
function LogicChat.OnReciveNewMsg(ChatContentData)
  if LogicChat.Widgets then
    for i, v in ipairs(LogicChat.Widgets) do
      if UE.RGUtil.IsUObjectValid(v) then
        local needScrollToBottom = false
        if ChatContentData and (ChatContentData.ChannelId == LogicChat.CurSelectChannel or LogicChat.CurSelectChannel == UE.EChatChannel.Composite) then
          if ChatContentData.MsgType ~= ChatDataMgr.EMsgType.Error and ChatContentData.Content.sender == tonumber(DataMgr.GetUserId()) then
            needScrollToBottom = true
          elseif ChatContentData.MsgType == ChatDataMgr.EMsgType.Error then
            needScrollToBottom = true
          end
        end
        v:ReceiveMsg(ChatContentData, needScrollToBottom)
      end
    end
  end
  if ChatContentData and ChatContentData.MsgType ~= ChatDataMgr.EMsgType.Error and ChatContentData.Content and ChatContentData.Content.sender and tonumber(ChatContentData.Content.sender) == tonumber(DataMgr.GetUserId()) then
    if not LogicChat.CDData then
      LogicChat.CDData = {}
    end
    local ResultChat, RowChat = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBChat, ChatContentData.ChannelId)
    if ResultChat and RowChat.Period and RowChat.Period > 0 then
      LogicChat.CDData[ChatContentData.ChannelId] = {
        TimeStamp = os.time(),
        Period = RowChat.Period
      }
    end
  end
end
function LogicChat.OnSendChatMsgFailed(errcode, lastTimeStr, period, SendData)
  local lastTime = tonumber(lastTimeStr)
  print("OnSendChatMsgFailed", errcode, os.time(), lastTime, period)
  if 3 == errcode or 4 == errcode then
    if lastTime > 0 and period > 0 then
      local Diff = os.time() - lastTime
      if period > Diff then
        if not LogicChat.CDData then
          LogicChat.CDData = {}
        end
        LogicChat.CDData[LogicChat.CurSelectChannel] = {
          TimeStamp = os.time(),
          Period = period - Diff
        }
        ChatDataMgr.AddErroMsgToChannel(LogicChat.CurSelectChannel, UE.FTextFormat(ChatCDTxt(), period - Diff))
      end
    end
  elseif 6 == errcode then
    ChatDataMgr.AddCustomMsg(SendData)
  elseif 0 == errcode then
    ChatDataMgr.AddErroMsgToChannel(LogicChat.CurSelectChannel, SensitiveTxt())
  else
    local tbChatContent = LuaTableMgr.GetLuaTableByName(TableNames.TBChatContent)
    for i, v in ipairs(tbChatContent) do
      if errcode == v.ID then
        ChatDataMgr.AddErroMsgToChannel(LogicChat.CurSelectChannel, v.Content)
      end
    end
  end
end
function LogicChat:SendChatMsg(Id, ChannelId, Msg)
  print("LogicChat:SendChatMsg11", Msg, Id, ChannelId)
  local IsUnLock, OpenLevel = LogicChat:CheckChannelUnLock(ChannelId)
  if IsUnLock then
    ChatDataMgr.AddErroMsgToChannel(ChannelId, UE.FTextFormat(UnlockTxt(), OpenLevel))
    print("LogicChat:SendChatMsg22", Msg, Id, ChannelId)
  elseif ChannelId == UE.EChatChannel.Team and not DataMgr.IsInTeam() then
    ChatDataMgr.AddErroMsgToChannel(ChannelId, NoTeamTxt())
    print("LogicChat:SendChatMsg33", Msg, Id, ChannelId)
  else
    if LogicChat:CheckIsLongMsg(Msg, ChannelId) then
      local ResultChatContent, RowChatContent = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBChatContent, 2)
      if ResultChatContent then
        ChatDataMgr.AddErroMsgToChannel(ChannelId, RowChatContent.Content)
      end
      return
    end
    if LogicChat:CheckSendMsgCD(ChannelId, true) then
      return
    end
    ChatDataMgr.SendChatMsg(Id, ChannelId, Msg)
  end
end
function LogicChat:CheckSendMsgCD(ChannelId, bAddErrorMsg)
  if not LogicChat.CDData then
    LogicChat.CDData = {}
  end
  if not LogicChat.CDData[ChannelId] then
    return false
  end
  local CDData = LogicChat.CDData[ChannelId]
  local CurDiff = os.time() - CDData.TimeStamp
  if CurDiff < CDData.Period then
    if bAddErrorMsg then
      local LeftTime = CDData.Period - CurDiff
      print("LogicChat:CheckSendMsgCD", ChannelId, CDData.Period, LeftTime)
      ChatDataMgr.AddErroMsgToChannel(LogicChat.CurSelectChannel, UE.FTextFormat(ChatCDTxt(), LeftTime))
    end
    return true
  end
  return false
end
function LogicChat:CheckIsLongMsg(Msg, ChannelId)
  if not Msg then
    print("LogicChat:CheckIsLongMsg Msg Is Null")
    return false
  end
  if not ChannelId then
    print("LogicChat:CheckIsLongMsg ChannelId Is Null")
    return false
  end
  local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBChat, ChannelId)
  if Result and Row.TextLimit > 0 then
    local Len = #Msg
    print("LogicChat:CheckIsLongMsg", Len, Row.TextLimit, ChannelId)
    return Len > Row.TextLimit
  end
  return false
end
function LogicChat:SendPersonChatMsg(UserId, Msg)
  HttpCommunication.Request("chatservice/personalmessage", {
    receiver = UserId,
    msg = Msg,
    channelUID = DataMgr.ChannelUserIdWithPrefix
  }, {}, {})
end
function LogicChat:CheckChannelUnLock(ChannelId)
  local ChatTb = LuaTableMgr.GetLuaTableByName(TableNames.TBChat)
  if not ChatTb then
    print("LogicChat:CheckChannelUnLock ChatTb Is Null", ChannelId)
    return true, 0
  end
  if not ChatTb[ChannelId] then
    print("LogicChat:CheckChannelUnLock ChatTb[ChannelId] Is Null", ChannelId)
    return true, 0
  end
  print("LogicChat:CheckChannelUnLock", ChatTb[ChannelId].OpenLevel, DataMgr.GetRoleLevel())
  return ChatTb[ChannelId].OpenLevel > DataMgr.GetRoleLevel(), ChatTb[ChannelId].OpenLevel
end
function LogicChat:SheildPlayerMsg(UserId, bIsSheild, NickName)
  ChatDataMgr.SheildPlayerMsg(UserId, LogicChat.CurSelectChannel, bIsSheild, NickName)
end
function LogicChat:GetChannelRow(Channel)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return nil
  end
  local Result, ChatChannelRow = DTSubsystem:GetChatChannelTableRow(Channel, nil)
  if Result then
    return ChatChannelRow
  end
  return nil
end
function LogicChat:UnBindWidget(Widget)
  if not LogicChat.Widgets then
    return
  end
  if UE.RGUtil.IsUObjectValid(Widget) then
    table.RemoveItem(LogicChat.Widgets, Widget)
  end
  if 0 == #LogicChat.Widgets then
    LogicChat:Clear()
  end
end
function LogicChat:Clear()
  LogicChat.Widgets = nil
  self.bIsInited = false
  LogicChat.CurSelectChannel = UE.EChatChannel.Composite
  EventSystem.RemoveListener(EventDef.Chat.ReciveNewMsg, LogicChat.OnReciveNewMsg)
  EventSystem.RemoveListener(EventDef.Chat.SendChatMsgFailed, LogicChat.OnSendChatMsgFailed)
end
