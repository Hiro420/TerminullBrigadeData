local rapidjson = require("rapidjson")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local NickNameSensitiveWaveId = 1128
local MsgSensitiveWaveId = 302000
local OfflinePlayerTipId = 302002
local OfflinePlayerTipInterval = 1800
local ContactPersonHandler = {}

function ContactPersonHandler:RequestGetRolesByNameToServer(NameList, SuccessFuncCallback)
  HttpCommunication.Request("playerservice/rolesbyname", {nameList = NameList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("GetRolesByName Succ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if SuccessFuncCallback then
        SuccessFuncCallback[2](SuccessFuncCallback[1], JsonTable.players)
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function ContactPersonHandler:RequestAddFriendToServer(RoleId, AddSource, Callback)
  local Params = {addSource = AddSource, roleID = RoleId}
  HttpCommunication.Request("social/askaddplayer", Params, {
    GameInstance,
    function()
      print("RequestAddFriend Success!")
      if Callback then
        Callback()
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function ContactPersonHandler:RequestAgreeAddFriendToServer(RoleId)
  HttpCommunication.Request("social/askaddplayer/agree", {roleID = RoleId}, {
    GameInstance,
    function()
      print("RequestAgreeAddFriend Success!")
      ContactPersonHandler:RequestGetFriendListToServer()
      ContactPersonHandler:RequestGetApplyListToServer()
      if ContactPersonData:IsInBlackList(RoleId) then
        ContactPersonHandler:RequestGetBlackListToServer()
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function ContactPersonHandler:RequestRejectAddFriendToServer(RoleId)
  HttpCommunication.Request("social/askaddplayer/reject", {roleID = RoleId}, {
    GameInstance,
    function()
      print("RequestRejectAddFriend Success!")
      ContactPersonHandler:RequestGetApplyListToServer()
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function ContactPersonHandler:RequestDeleteFriendToServer(RoleId)
  HttpCommunication.Request("social/delplayer", {roleID = RoleId}, {
    GameInstance,
    function()
      print("RequestDeleteFriend Success!")
      ContactPersonHandler:RequestGetFriendListToServer()
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function ContactPersonHandler:RequestGetApplyListToServer()
  HttpCommunication.RequestByGet("social/pull/applylist", {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetApplyList Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      ContactPersonData:SetFriendApplyList(JsonTable.applyList)
      EventSystem.Invoke(EventDef.ContactPerson.OnFriendApplyListUpdate)
    end
  }, {
    GameInstance,
    function()
      print("RequestGetApplyList Fail!")
    end
  })
end

function ContactPersonHandler:RequestGetFriendListToServer()
  HttpCommunication.RequestByGet("social/pull/friendlist", {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetFriendList Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      ContactPersonData:SetFriendInfoList(JsonTable.friendDataList)
      EventSystem.Invoke(EventDef.ContactPerson.OnFriendListUpdate)
    end
  }, {
    GameInstance,
    function()
      print("RequestGetFriendList Fail!")
    end
  })
end

function ContactPersonHandler:RequestSendPersonalMessageToServer(Msg, PlayerInfo)
  local ReceiverId = PlayerInfo.roleid
  local Params = {
    msg = Msg,
    receiver = ReceiverId,
    channelUID = DataMgr.ChannelUserIdWithPrefix
  }
  HttpCommunication.Request("chatservice/personalmessage", Params, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestSendgeToServer Success!")
      local Response = rapidjson.decode(JsonResponse.Content)
      if PlayerInfo.onlineStatus == OnlineStatus.OnlineStatusOffline then
        local LastSendMsgInfo = ContactPersonData:GetPersonalChatListSendInfo(PlayerInfo.roleid)
        if not LastSendMsgInfo or LastSendMsgInfo.ReceiverOnlineStatus ~= OnlineStatus.OnlineStatusOffline or GetCurrentUTCTimestamp() - LastSendMsgInfo.SendTime > OfflinePlayerTipInterval then
          ShowWaveWindow(OfflinePlayerTipId)
        end
      end
    end
  }, {
    GameInstance,
    function()
      print("RequestSendPersonalMessageToServer Fail!")
    end
  })
end

function ContactPersonHandler:RequestGetBlackListToServer()
  HttpCommunication.RequestByGet("social/pull/blacklist", {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetBlackList Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      ContactPersonData:SetBlackList(JsonTable.blackList)
      EventSystem.Invoke(EventDef.ContactPerson.OnBlackListUpdate)
    end
  }, {
    GameInstance,
    function()
      print("RequestGetBlackList fail!")
    end
  })
end

function ContactPersonHandler:RequestBlackListPlayerToServer(RoleId)
  HttpCommunication.Request("social/blacklistplayer", {roleID = RoleId}, {
    GameInstance,
    function()
      print("RequestBlackListPlayerToServer Success!")
      ContactPersonHandler:RequestGetBlackListToServer()
      ContactPersonHandler:RequestGetFriendListToServer()
    end
  }, {
    GameInstance,
    function()
      print("RequestBlackListPlayerToServer Fail!")
    end
  })
end

function ContactPersonHandler:RequestCancelBlackListPlayerToServer(RoleId)
  HttpCommunication.Request("social/blacklistplayer/cancel", {roleID = RoleId}, {
    GameInstance,
    function()
      print("RequestCancelBlackListPlayerToServer Success!")
      ContactPersonHandler:RequestGetBlackListToServer()
    end
  }, {
    GameInstance,
    function()
      print("RequestCancelBlackListPlayerToServer Fail!")
    end
  })
end

function ContactPersonHandler:RequestRemarkNameToServer(RoleId, RemarkName)
  local Param = {remarkName = RemarkName, roleID = RoleId}
  HttpCommunication.Request("social/remarkname", Param, {
    GameInstance,
    function(Target, JsonResponse)
      local Response = rapidjson.decode(JsonResponse.Content)
      ContactPersonHandler:RequestGetFriendListToServer()
      EventSystem.Invoke(EventDef.ContactPerson.OnRemarkNameSuccess)
    end
  }, {
    GameInstance,
    function()
      print("RequestRemarkNameToServer Fail!")
    end
  })
end

function ContactPersonHandler:RequestChangeInvisibleToServer(IsInvisible)
  HttpCommunication.Request("playerservice/invisible", {invisible = IsInvisible, type = 0}, {
    GameInstance,
    function()
      print("RequestChangeInvisibleToServer Success!")
      DataMgr.SetInvisible(IsInvisible)
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function ContactPersonHandler:RequestOfflineMessagesToServer()
  HttpCommunication.RequestByGet("chatservice/offlinemessages", {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestOfflineMessages Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for i, SingleOfflineMessageInfo in ipairs(JsonTable.offlineMessage) do
        for index, SingleMessageInfo in ipairs(SingleOfflineMessageInfo.offlineMessages) do
          ContactPersonData:AddPersonalChatInfo(SingleOfflineMessageInfo.senderID, SingleMessageInfo.message, true)
        end
        EventSystem.Invoke(EventDef.ContactPerson.OnPersonalChatInfoUpdate, SingleOfflineMessageInfo.senderID)
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
end

return ContactPersonHandler
