local EOperateButtonPanelSourceFromType = {
  Search = 1,
  RecentList = 2,
  Chat = 3,
  Rank = 4,
  PrivateChat = 5
}
_G.EOperateButtonPanelSourceFromType = _G.EOperateButtonPanelSourceFromType or EOperateButtonPanelSourceFromType
local OnlineStatus = {
  OnlineStatusFree = 1,
  OnlineStatusOffline = 2,
  OnlineStatusMatch = 4,
  OnlineStatusTeam = 5,
  OnlineStatusGame = 6
}
_G.OnlineStatus = _G.OnlineStatus or OnlineStatus
local EOnlineStatusPriority = {
  [OnlineStatus.OnlineStatusOffline] = 1,
  [OnlineStatus.OnlineStatusFree] = 2,
  [OnlineStatus.OnlineStatusTeam] = 3,
  [OnlineStatus.OnlineStatusMatch] = 4,
  [OnlineStatus.OnlineStatusGame] = 5
}
_G.EOnlineStatusPriority = _G.EOnlineStatusPriority or EOnlineStatusPriority
local EContactListType = {
  RecentPlayer = 1,
  Friend = 2,
  FriendRequest = 3,
  BlackList = 4,
  PlatformFriend = 5
}
_G.EContactListType = _G.EContactListType or EContactListType
local ContactPersonData = {
  FriendApplyList = {},
  FriendInfoList = {},
  FriendIdList = {},
  FriendApplyIdList = {},
  PersonalChatInfo = {},
  ContactListPlayerInfo = {},
  BlackList = {},
  PlatformFriendsHasRoleIdInfoList = {},
  PlatformFriendsHasNotRoleIdInfoList = {},
  PersonalChatListSendInfo = {}
}
local MsgIntervalTime = 3600

function ContactPersonData:SetFriendApplyList(InFriendApplyList)
  ContactPersonData.FriendApplyList = {}
  ContactPersonData.FriendApplyIdList = {}
  for index, SingleFriendApplyInfo in ipairs(InFriendApplyList) do
    ContactPersonData.FriendApplyList[SingleFriendApplyInfo.roleID] = SingleFriendApplyInfo
    table.insert(ContactPersonData.FriendApplyIdList, SingleFriendApplyInfo.roleID)
  end
end

function ContactPersonData:GetFriendApplyList()
  return ContactPersonData.FriendApplyList
end

function ContactPersonData:GetFriendApplyInfoById(InId)
  return ContactPersonData.FriendApplyList[InId]
end

function ContactPersonData:SetFriendInfoList(InFriendInfoList)
  ContactPersonData.FriendInfoList = {}
  ContactPersonData.FriendIdList = {}
  for index, SingleFriendInfo in ipairs(InFriendInfoList) do
    ContactPersonData.FriendInfoList[SingleFriendInfo.roleID] = SingleFriendInfo
    table.insert(ContactPersonData.FriendIdList, SingleFriendInfo.roleID)
  end
end

function ContactPersonData:GetFriendInfoList()
  return ContactPersonData.FriendInfoList
end

function ContactPersonData:GetFriendInfoById(InId)
  return ContactPersonData.FriendInfoList[InId]
end

function ContactPersonData:GetFriendApplyIdList()
  return ContactPersonData.FriendApplyIdList
end

function ContactPersonData:GetFriendIdList()
  return ContactPersonData.FriendIdList
end

function ContactPersonData:IsFriend(RoleId)
  return ContactPersonData.FriendInfoList[RoleId] ~= nil
end

function ContactPersonData:IsInFriendRequestList(RoleId)
  return ContactPersonData.FriendApplyList[RoleId] ~= nil
end

function ContactPersonData:AddPersonalChatInfo(RoleId, InMsg, InIsReceive)
  local TargetChatInfo = ContactPersonData.PersonalChatInfo[RoleId]
  local LastChatInfo
  if not TargetChatInfo then
    TargetChatInfo = {}
    ContactPersonData.PersonalChatInfo[RoleId] = TargetChatInfo
  else
    for index, SingleChatInfo in ipairs(TargetChatInfo) do
      LastChatInfo = SingleChatInfo
    end
  end
  if nil == InMsg then
    return
  end
  local ContactPersonManager = ModuleManager:Get("ContactPersonModule")
  if LastChatInfo and UE.URGStatisticsLibrary.GetTimestamp(false) - LastChatInfo.ReceiveTime > MsgIntervalTime then
    local TempTable = {
      ReceiveTime = UE.URGStatisticsLibrary.GetTimestamp(false),
      IsTime = true
    }
    table.insert(TargetChatInfo, TempTable)
    if ContactPersonManager then
      local ChatInfo = UE.FChatInfo()
      ChatInfo.ReceiveTime = TempTable.ReceiveTime
      ChatInfo.IsTimeInfo = TempTable.IsTime
      ContactPersonManager:AddPlayerHistoryChatInfo(RoleId, ChatInfo)
    end
  end
  local TempTable = {
    Msg = InMsg,
    ReceiveTime = UE.URGStatisticsLibrary.GetTimestamp(false),
    IsTime = false,
    IsReceive = InIsReceive
  }
  table.insert(TargetChatInfo, TempTable)
  if ContactPersonManager then
    local ChatInfo = UE.FChatInfo()
    ChatInfo.Msg = TempTable.Msg
    ChatInfo.ReceiveTime = TempTable.ReceiveTime
    ChatInfo.IsTimeInfo = TempTable.IsTime
    ChatInfo.IsReceiveMsg = TempTable.IsReceive
    ContactPersonManager:AddPlayerHistoryChatInfo(RoleId, ChatInfo)
  end
end

function ContactPersonData:RemovePersonalChatInfo(RoleId)
  ContactPersonData.PersonalChatInfo[RoleId] = nil
end

function ContactPersonData:GetPersonalChatInfo()
  return ContactPersonData.PersonalChatInfo
end

function ContactPersonData:GetPersonalChatInfoById(RoleId)
  return ContactPersonData.PersonalChatInfo[RoleId]
end

function ContactPersonData:SetContactListPlayerInfo(PlayerInfo)
  if not PlayerInfo then
    return
  end
  ContactPersonData.ContactListPlayerInfo[PlayerInfo.roleid] = PlayerInfo
end

function ContactPersonData:GetPlayerInfoByRoleId(RoleId)
  return ContactPersonData.ContactListPlayerInfo[RoleId]
end

function ContactPersonData:SetBlackList(InBlackList)
  ContactPersonData.BlackList = {}
  for index, SingleBlackInfo in ipairs(InBlackList) do
    ContactPersonData.BlackList[SingleBlackInfo.roleID] = SingleBlackInfo
  end
end

function ContactPersonData:GetBlackList()
  return ContactPersonData.BlackList
end

function ContactPersonData:GetBlackListIdList()
  local IdList = {}
  for RoleId, SingleBlackInfo in pairs(ContactPersonData.BlackList) do
    table.insert(IdList, RoleId)
  end
  return IdList
end

function ContactPersonData:IsInBlackList(RoleId)
  return ContactPersonData.BlackList[RoleId] ~= nil
end

function ContactPersonData:SetPlatformFriendsHasRoleIdInfo(InFriendsInfoList)
  ContactPersonData.PlatformFriendsHasRoleIdInfoList = InFriendsInfoList
end

function ContactPersonData:SetPlatformFriendsHasNotRoleIdInfo(InFriendInfoList)
  ContactPersonData.PlatformFriendsHasNotRoleIdInfoList = InFriendInfoList
end

function ContactPersonData:ClearPlatformFriendsHasRoleIdInfo()
  ContactPersonData.PlatformFriendsHasRoleIdInfoList = {}
end

function ContactPersonData:ClearPlatformFriendsHasNotRoleIdInfo()
  ContactPersonData.PlatformFriendsHasNotRoleIdInfoList = {}
end

function ContactPersonData:GetPlatformFriendsRoleIdList()
  local RoleIdList = {}
  for RoleId, value in pairs(ContactPersonData:GetPlatformFriendsHasRoleIdInfo()) do
    table.insert(RoleIdList, RoleId)
  end
  return RoleIdList
end

function ContactPersonData:GetPlatformFriendsHasRoleIdInfo()
  return ContactPersonData.PlatformFriendsHasRoleIdInfoList
end

function ContactPersonData:GetPlatformFriendsHasNotRoleIdInfo()
  return ContactPersonData.PlatformFriendsHasNotRoleIdInfoList
end

function ContactPersonData:GetPlatformFriendInfoByRoleId(RoleId)
  local PlatformFriendsHasRoleIdInfoList = ContactPersonData:GetPlatformFriendsHasRoleIdInfo()
  return PlatformFriendsHasRoleIdInfoList[RoleId]
end

function ContactPersonData:IsPlatformFriend(RoleId)
  local PlatformFriendsHasRoleIdInfoList = ContactPersonData:GetPlatformFriendsHasRoleIdInfo()
  return nil ~= PlatformFriendsHasRoleIdInfoList[RoleId]
end

function ContactPersonData:SetPersonalChatListSendInfo(ReceiveId, OnlineStatus)
  local TempTable = {
    SendTime = GetCurrentUTCTimestamp(),
    ReceiverOnlineStatus = OnlineStatus
  }
  ContactPersonData.PersonalChatListSendInfo[ReceiveId] = TempTable
end

function ContactPersonData:GetPersonalChatListSendInfo(RoleId)
  return ContactPersonData.PersonalChatListSendInfo[RoleId]
end

function ContactPersonData:ClearData()
  ContactPersonData.FriendApplyList = {}
  ContactPersonData.FriendInfoList = {}
  ContactPersonData.FriendIdList = {}
  ContactPersonData.FriendApplyIdList = {}
  ContactPersonData.PersonalChatInfo = {}
  ContactPersonData.BlackList = {}
  ContactPersonData.PlatformFriendsHasRoleIdInfoList = {}
  ContactPersonData.PlatformFriendsHasNotRoleIdInfoList = {}
  ContactPersonData.PersonalChatListSendInfo = {}
end

return ContactPersonData
