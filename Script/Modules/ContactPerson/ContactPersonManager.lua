local ContactPersonManager = LuaClass()
local RapidJson = require("rapidjson")
local ContactPersonHandler = require("Protocol.ContactPerson.ContactPersonHandler")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local MsgIntervalTime = 3600
function ContactPersonManager:Ctor()
  self.ContactPersonListSaveGameName = "ContactPersonListSaveGame"
  self.SaveGame = nil
  self.MaxRecentPlayerNum = 20
  self.SessionUpdateRegistered = false
  self.PendingTeamNeedJoin = false
end
function ContactPersonManager:OnInit()
  self:InitContactPersonListSaveGame()
  EventSystem.AddListener(self, EventDef.WSMessage.SocialAskAgree, ContactPersonManager.BindOnSocialAskAgreeFriend)
  EventSystem.AddListener(self, EventDef.WSMessage.SocialAskReject, ContactPersonManager.BindOnSocialAskRejectFriend)
  EventSystem.AddListener(self, EventDef.WSMessage.SocialAskAdd, ContactPersonManager.BindOnSocialAskAddFriend)
  EventSystem.AddListener(self, EventDef.WSMessage.SocialRemove, ContactPersonManager.BindOnSocialRemoveFriend)
  EventSystem.AddListener(self, EventDef.WSMessage.PersonalMsg, ContactPersonManager.BindOnPersonalChatMsg)
end
function ContactPersonManager:BindOnSocialAskAgreeFriend(Json)
  print("BindOnSocialAskAgreeFriend", Json)
  local JsonTable = RapidJson.decode(Json)
  ContactPersonHandler:RequestGetFriendListToServer()
  ContactPersonHandler:RequestGetApplyListToServer()
  ContactPersonHandler:RequestGetBlackListToServer()
end
function ContactPersonManager:BindOnSocialAskRejectFriend(Json)
  print("BindOnSocialAskRejectFriend", Json)
  local JsonTable = RapidJson.decode(Json)
end
function ContactPersonManager:BindOnSocialAskAddFriend(Json)
  print("BindOnSocialAskAddFriend", Json)
  local JsonTable = RapidJson.decode(Json)
  ContactPersonHandler:RequestGetApplyListToServer()
end
function ContactPersonManager:BindOnSocialRemoveFriend(Json)
  print("BindOnSocialRemoveFriend", Json)
  local JsonTable = RapidJson.decode(Json)
  ContactPersonHandler:RequestGetFriendListToServer()
end
function ContactPersonManager:BindOnPersonalChatMsg(MsgJson)
  print("ContactPersonManager:BindOnPersonalChatMsg", MsgJson)
  local Response = RapidJson.decode(MsgJson)
  if not Response then
    return
  end
  local ReceiverId = tostring(Response.receiver)
  if ReceiverId == DataMgr.GetUserId() then
    ReceiverId = tostring(Response.sender)
  end
  if ChatDataMgr.CheckPlayerIsBeSheilded(ReceiverId) then
    print("ContactPersonManager:BindOnPersonalChatMsg \232\175\165\231\142\169\229\174\182\229\183\178\232\162\171\229\177\143\232\148\189")
    return
  end
  ContactPersonData:AddPersonalChatInfo(tostring(ReceiverId), Response.msg, tostring(Response.sender) ~= DataMgr.GetUserId())
  EventSystem.Invoke(EventDef.ContactPerson.OnPersonalChatInfoUpdate, tostring(ReceiverId), tostring(Response.sender) == DataMgr.GetUserId())
end
function ContactPersonManager:OnShutdown()
  self:Clear()
  EventSystem.RemoveListener(EventDef.WSMessage.SocialAskAgree, ContactPersonManager.BindOnSocialAskAgreeFriend, self)
  EventSystem.RemoveListener(EventDef.WSMessage.SocialAskReject, ContactPersonManager.BindOnSocialAskRejectFriend, self)
  EventSystem.RemoveListener(EventDef.WSMessage.SocialAskAdd, ContactPersonManager.BindOnSocialAskAddFriend, self)
  EventSystem.RemoveListener(EventDef.WSMessage.SocialRemove, ContactPersonManager.BindOnSocialRemoveFriend, self)
  EventSystem.RemoveListener(EventDef.WSMessage.PersonalMsg, ContactPersonManager.BindOnPersonalChatMsg, self)
  if UE.URGPlayerSessionSubsystem and self.SessionUpdateRegistered then
    local RGPlayerSessionSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlayerSessionSubsystem:StaticClass())
    if RGPlayerSessionSubsystem then
      RGPlayerSessionSubsystem.OnSessionRoleUpdated:Remove(GameInstance, ContactPersonManager.OnSessionRoleUpdated)
    end
  end
end
function ContactPersonManager:OnSessionRoleUpdated(FromUserId, RoleId, TeamId)
  print("ContactPersonManager:OnSessionRoleUpdated", FromUserId, RoleId, TeamId)
  if LogicTeam.IsFullTeam() then
    ShowWaveWindow(15020)
    return
  end
  if LogicTeam.IsTeammate(RoleId) then
    ShowWaveWindow(15000)
    return
  end
  if DataMgr.IsInTeam() then
    LogicTeam.RequestQuitTeamToServer({
      self,
      function()
        LogicTeam.RequestJoinTeamToServer(TeamId, LogicTeam.JoinTeamWay.TeamCode, {
          self,
          function()
            LogicTeam.DoJoinSession()
          end
        })
      end
    })
  else
    LogicTeam.RequestJoinTeamToServer(TeamId, LogicTeam.JoinTeamWay.TeamCode, {
      self,
      function()
        LogicTeam.DoJoinSession()
      end
    })
  end
end
function ContactPersonManager:CheckSessionUpdateDelegate()
  if not UE.URGPlayerSessionSubsystem then
    return
  end
  if not self.SessionUpdateRegistered then
    local RGPlayerSessionSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlayerSessionSubsystem:StaticClass())
    if RGPlayerSessionSubsystem then
      print("ContactPersonManager:SendInviteOrApplyTeamRequestPlatformConsole Register OnSessionRoleUpdated")
      RGPlayerSessionSubsystem.OnSessionRoleUpdated:Add(GameInstance, ContactPersonManager.OnSessionRoleUpdated)
      self.SessionUpdateRegistered = true
    end
  end
end
function ContactPersonManager:SendInviteOrApplyTeamRequestPlatformConsole(TargetPlayerInfo, InviteTeamWay)
  print("SendInviteOrApplyTeamRequestPlatformConsole: ", TargetPlayerInfo)
  local BasicInfo = DataMgr.GetBasicInfo()
  if BasicInfo.onlineStatus == OnlineStatus.OnlineStatusMatch then
    print("\232\135\170\229\183\177\230\173\163\229\156\168\229\140\185\233\133\141\228\184\173")
    return
  end
  if TargetPlayerInfo.roleid ~= nil and LogicTeam.IsTeammate(TargetPlayerInfo.roleid) then
    ShowWaveWindow(15000)
    return
  end
  if LogicTeam.IsFullTeam() then
    ShowWaveWindow(15020)
    return
  end
  if not UE.URGPlayerSessionSubsystem then
    return
  end
  local RGPlayerSessionSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlayerSessionSubsystem:StaticClass())
  if RGPlayerSessionSubsystem then
    if DataMgr.IsInTeam() then
      local TeamInfo = DataMgr.GetTeamInfo()
      RGPlayerSessionSubsystem:InvitePlayerToTeam(TargetPlayerInfo.userId, TeamInfo.teamid)
    else
      LogicTeam.RequestCreateTeamToServer({
        self,
        function()
          local TeamInfo = DataMgr.GetTeamInfo()
          RGPlayerSessionSubsystem:InvitePlayerToTeam(TargetPlayerInfo.userId, TeamInfo.teamid)
        end
      })
    end
  end
end
function ContactPersonManager:SendInviteOrApplyTeamRequest(TargetPlayerInfo, InviteTeamWay)
  local BasicInfo = DataMgr.GetBasicInfo()
  if BasicInfo.onlineStatus == OnlineStatus.OnlineStatusMatch then
    print("\232\135\170\229\183\177\230\173\163\229\156\168\229\140\185\233\133\141\228\184\173")
    return
  end
  if LogicTeam.IsTeammate(TargetPlayerInfo.roleid) then
    ShowWaveWindow(15000)
    return
  end
  if TargetPlayerInfo.onlineStatus == OnlineStatus.OnlineStatusOffline or TargetPlayerInfo.onlineStatus == OnlineStatus.OnlineStatusGame then
    return
  end
  if LogicTeam.IsFullTeam() then
    ShowWaveWindow(15020)
    return
  end
  if TargetPlayerInfo.onlineStatus == OnlineStatus.OnlineStatusFree then
    if DataMgr.IsInTeam() then
      LogicTeam.RequestInviteJoinTeamToServer(TargetPlayerInfo.roleid, InviteTeamWay)
    else
      LogicTeam.RequestCreateTeamToServer({
        self,
        function()
          LogicTeam.RequestInviteJoinTeamToServer(TargetPlayerInfo.roleid, InviteTeamWay)
        end
      })
    end
  elseif TargetPlayerInfo.onlineStatus == OnlineStatus.OnlineStatusTeam then
    local TeamInfo = DataMgr.GetTeamInfo()
    if DataMgr.IsInTeam() and TeamInfo.players and table.count(TeamInfo.players) > 1 then
      if DataMgr.IsInTeam() then
        LogicTeam.RequestInviteJoinTeamToServer(TargetPlayerInfo.roleid, InviteTeamWay)
      else
        LogicTeam.RequestCreateTeamToServer({
          self,
          function()
            LogicTeam.RequestInviteJoinTeamToServer(TargetPlayerInfo.roleid, InviteTeamWay)
          end
        })
      end
    else
      LogicTeam.RequestGetTeamMemberCountToServer(TargetPlayerInfo.roleid, {
        TargetPlayerInfo,
        function(TargetPlayerInfo, Count)
          if 3 == Count then
            ShowWaveWindow(15021)
            return
          end
          if 2 == Count then
            LogicTeam.RequestApplyJoinTeamToServer(TargetPlayerInfo.roleid, InviteTeamWay)
          elseif DataMgr.IsInTeam() then
            LogicTeam.RequestInviteJoinTeamToServer(TargetPlayerInfo.roleid, InviteTeamWay)
          else
            LogicTeam.RequestCreateTeamToServer({
              self,
              function()
                LogicTeam.RequestInviteJoinTeamToServer(TargetPlayerInfo.roleid, InviteTeamWay)
              end
            })
          end
        end
      })
    end
  end
end
function ContactPersonManager:InitContactPersonListSaveGame()
  if not UE.UGameplayStatics.DoesSaveGameExist(self.ContactPersonListSaveGameName, 0) then
    local SaveGameObject = UE.UGameplayStatics.CreateSaveGameObject(UE.UContactPersonListSaveGame:StaticClass())
    if SaveGameObject then
      UE.UGameplayStatics.SaveGameToSlot(SaveGameObject, self.ContactPersonListSaveGameName, 0)
    end
  end
  self.SaveGame = UE.UGameplayStatics.LoadGameFromSlot(self.ContactPersonListSaveGameName, 0)
  self.SaveGameRef = UnLua.Ref(self.SaveGame)
end
function ContactPersonManager:GetContactPersonSaveGame()
  local SaveGame = UE.UGameplayStatics.LoadGameFromSlot(self.ContactPersonListSaveGameName, 0)
  return SaveGame
end
function ContactPersonManager:GetRecentPlayerList(RoleId)
  local SaveGame = self:GetContactPersonSaveGame()
  local TargetRecentListStruct = SaveGame.AllPlayerRecentPlayerList:Find(RoleId)
  return TargetRecentListStruct and TargetRecentListStruct.RecentPlayerList:ToTable() or {}
end
function ContactPersonManager:SaveRecentPlayerList(RoleId, TeamIdList)
  local SaveGame = self:GetContactPersonSaveGame()
  if not SaveGame then
    print("ContactPersonManager:SaveRecentPlayerList not found SaveGameObject")
    return
  end
  local TargetRecentListStruct = SaveGame.AllPlayerRecentPlayerList:Find(RoleId)
  if not TargetRecentListStruct then
    local RecentPlayerListStruct = UE.FRecentPlayerList()
    RecentPlayerListStruct.RecentPlayerList = TeamIdList
    SaveGame.AllPlayerRecentPlayerList:Add(RoleId, RecentPlayerListStruct)
  else
    local CurTeamCount = table.count(TeamIdList)
    local CurRecentPlayerList = TargetRecentListStruct.RecentPlayerList
    local RecentPlayerListLength = CurRecentPlayerList:Length()
    local ExceedListNum = RecentPlayerListLength + CurTeamCount - self.MaxRecentPlayerNum
    if ExceedListNum > 0 then
      for i = 1, ExceedListNum do
        CurRecentPlayerList:Remove(1)
      end
    end
    for index, SinglePlayerId in ipairs(TeamIdList) do
      CurRecentPlayerList:AddUnique(SinglePlayerId)
    end
    SaveGame.AllPlayerRecentPlayerList:Add(RoleId, TargetRecentListStruct)
  end
  UE.UGameplayStatics.SaveGameToSlot(SaveGame, self.ContactPersonListSaveGameName, 0)
end
function ContactPersonManager:InitPersonalHistoryChatInfo(RoleId)
  local SaveGame = self:GetContactPersonSaveGame()
  if not SaveGame then
    print("ContactPersonManager:InitPersonalHistoryChatInfo not found SaveGameObject")
    return
  end
  local TargetPlayerChatInfo = SaveGame.AllPlayerChatInfoList:Find(RoleId)
  if not TargetPlayerChatInfo then
    print("ContactPersonManager:InitPersonalHistoryChatInfo not found History Chat Info, RoleId:", RoleId)
    return
  end
  local LastReceiveTime = 0
  local TargetChatInfo
  for ChatRoleId, ChatInfoList in pairs(TargetPlayerChatInfo.ChatInfoList) do
    LastReceiveTime = GetCurrentTimestamp(false)
    TargetChatInfo = ContactPersonData:GetPersonalChatInfoById(ChatRoleId)
    if not TargetChatInfo then
      TargetChatInfo = {}
      ContactPersonData.PersonalChatInfo[ChatRoleId] = TargetChatInfo
    end
    for index, SingleChatInfo in pairs(ChatInfoList.ChatInfoList) do
      if math.abs(SingleChatInfo.ReceiveTime - LastReceiveTime) >= MsgIntervalTime and not SingleChatInfo.IsTimeInfo then
        local TempTable = {
          ReceiveTime = SingleChatInfo.ReceiveTime,
          IsTime = true
        }
        table.insert(TargetChatInfo, TempTable)
      end
      local TempTable = {
        Msg = SingleChatInfo.Msg,
        ReceiveTime = SingleChatInfo.ReceiveTime,
        IsTime = SingleChatInfo.IsTimeInfo,
        IsReceive = SingleChatInfo.IsReceiveMsg
      }
      table.insert(TargetChatInfo, TempTable)
      LastReceiveTime = SingleChatInfo.ReceiveTime
    end
  end
end
function ContactPersonManager:AddPlayerHistoryChatInfo(RoleId, InChatInfo)
  local SaveGame = self:GetContactPersonSaveGame()
  if not SaveGame then
    print("ContactPersonManager:AddPlayerHistoryChatInfo not found SaveGameObject")
    return
  end
  SaveGame:AddPlayerChatInfo(DataMgr.GetUserId(), RoleId, InChatInfo)
  UE.UGameplayStatics.SaveGameToSlot(SaveGame, self.ContactPersonListSaveGameName, 0)
end
function ContactPersonManager:RemovePlayerHistoryChatInfo(RoleId)
  local SaveGame = self:GetContactPersonSaveGame()
  if not SaveGame then
    print("ContactPersonManager:RemovePlayerHistoryChatInfo not found SaveGameObject")
    return
  end
  SaveGame:RemovePlayerChatInfo(DataMgr.GetUserId(), RoleId)
  UE.UGameplayStatics.SaveGameToSlot(SaveGame, self.ContactPersonListSaveGameName, 0)
end
function ContactPersonManager:Clear()
  if self.SaveGame and self.SaveGame:IsValid() then
    UnLua.Unref(self.SaveGame)
    self.SaveGame = nil
    self.SaveGameRef = nil
  end
end
return ContactPersonManager
