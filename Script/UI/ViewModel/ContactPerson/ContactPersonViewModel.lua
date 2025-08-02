local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local ContactPersonManager = ModuleManager:Get("ContactPersonModule")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local RapidJson = require("rapidjson")
local ContactPersonViewModel = CreateDefaultViewModel()
ContactPersonViewModel.propertyBindings = {
  BasicInfo = {}
}
ContactPersonViewModel.subViewModels = {}

function ContactPersonViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListener(self, EventDef.ContactPerson.OnContactPersonItemClicked, self.OnContactPersonItemClicked)
  EventSystem.AddListener(self, EventDef.ContactPerson.OnRecentListPlayerInfoUpdate, self.OnRecentListPlayerInfoChanged)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateBasicInfo, self.OnUpdateBasicInfo)
  EventSystem.AddListener(self, EventDef.ContactPerson.OnFriendListUpdate, self.OnFriendListUpdate)
  EventSystem.AddListener(self, EventDef.ContactPerson.OnFriendApplyListUpdate, self.OnFriendApplyListUpdate)
  EventSystem.AddListener(self, EventDef.ContactPerson.OnBlackListUpdate, self.OnBlackListUpdate)
  EventSystem.AddListener(self, EventDef.PlayerInfo.QueryPlayerInfoSucc, self.BindOnQueryPlayerInfoSuccess)
  EventSystem.AddListener(self, EventDef.ContactPerson.OnPlatformFriendInfoListUpdate, self.BindOnPlatformFriendInfoListUpdate)
  if UE.UOnlineFriendSystem ~= nil then
    local OnlineFriendSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlineFriendSystem:StaticClass())
    if OnlineFriendSystem then
      OnlineFriendSystem.OnReadFriendsInfoListComplete:Add(GameInstance, self.BindOnReadFriendsInfoListComplete)
    end
  end
end

function ContactPersonViewModel:RefreshPlayerInfoList()
  local IdList = {}
  local ContactPersonViewModel = UIModelMgr:Get("ContactPersonViewModel")
  local CurSelectTabId = ContactPersonViewModel.CurViewSelectTabIndex
  if CurSelectTabId == EContactListType.Friend then
    IdList = ContactPersonData:GetFriendIdList()
  elseif CurSelectTabId == EContactListType.FriendRequest then
    IdList = ContactPersonData:GetFriendApplyIdList()
  elseif CurSelectTabId == EContactListType.RecentPlayer then
    IdList = ContactPersonManager:GetRecentPlayerList(DataMgr.GetUserId())
  elseif CurSelectTabId == EContactListType.PlatformFriend then
    IdList = ContactPersonData:GetPlatformFriendsRoleIdList()
  end
  ContactPersonViewModel:PullPlayerInfoList(IdList, CurSelectTabId)
end

function ContactPersonViewModel:PullPlayerInfoList(IdList, ContactListType)
  local FirstView = self:GetFirstView()
  if not FirstView or FirstView:GetCurSelectTabId() ~= ContactListType then
    return
  end
  if IdList and next(IdList) ~= nil then
    table.insert(IdList, DataMgr.GetUserId())
    LogicLobby.RequestGetRoleListInfoToServer(IdList, {
      self,
      function(self, PlayerInfoList)
        table.sort(PlayerInfoList, function(a, b)
          a.onlineStatus = 1 == a.invisible and OnlineStatus.OnlineStatusOffline or a.onlineStatus
          b.onlineStatus = 1 == b.invisible and OnlineStatus.OnlineStatusOffline or b.onlineStatus
          if a.onlineStatus == OnlineStatus.OnlineStatusOffline and b.onlineStatus == OnlineStatus.OnlineStatusOffline then
            return tonumber(a.lastlogouttime) > tonumber(b.lastlogouttime)
          end
          if a.onlineStatus == b.onlineStatus then
            return tonumber(a.roleid) < tonumber(b.roleid)
          end
          return EOnlineStatusPriority[a.onlineStatus] > EOnlineStatusPriority[b.onlineStatus]
        end)
        local TargetPlayerInfoList = {}
        for index, SinglePlayerInfo in ipairs(PlayerInfoList) do
          if SinglePlayerInfo.roleid == DataMgr.GetUserId() then
            DataMgr.SetBasicInfo(SinglePlayerInfo)
          else
            ContactPersonData:SetContactListPlayerInfo(SinglePlayerInfo)
            table.insert(TargetPlayerInfoList, SinglePlayerInfo)
          end
        end
        EventSystem.Invoke(EventDef.ContactPerson.OnRecentListPlayerInfoUpdate, TargetPlayerInfoList, ContactListType)
      end
    })
  else
    LogicLobby.RequestGetRoleListInfoToServer({
      DataMgr.GetUserId()
    }, {
      self,
      function(self, PlayerInfoList)
        DataMgr.SetBasicInfo(PlayerInfoList[1])
      end
    })
    if ContactListType ~= EContactListType.PlatformFriend then
      FirstView:HideAllPlayerInfoItem()
    else
      local PlatformFriendsHasNotRoleIdList = ContactPersonData:GetPlatformFriendsHasNotRoleIdInfo()
      if next(PlatformFriendsHasNotRoleIdList) == nil then
        FirstView:HideAllPlayerInfoItem()
      else
        EventSystem.Invoke(EventDef.ContactPerson.OnRecentListPlayerInfoUpdate, {}, ContactListType)
      end
    end
  end
end

function ContactPersonViewModel:StartOrEndRefreshPlayerInfoList(IsStart)
  if not IsStart then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PlayerInfoPullTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.PlayerInfoPullTimer)
    end
  else
    self.PlayerInfoPullTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      self.RefreshPlayerInfoList
    }, 5.0, true)
  end
end

function ContactPersonViewModel:OnContactPersonItemClicked(MousePosition, PlayerInfo, SourceFrom, ...)
  UIMgr:Show(ViewID.UI_ContactPersonOperateButtonPanel, nil, MousePosition, PlayerInfo, SourceFrom, ...)
end

function ContactPersonViewModel:OnRecentListPlayerInfoChanged(PlayerInfoList, ContactListType)
  local FirstView = self:GetFirstView()
  if FirstView and FirstView.OnPlayerListChanged then
    FirstView:OnPlayerListChanged(PlayerInfoList, ContactListType)
  end
end

function ContactPersonViewModel:OnUpdateBasicInfo()
  local BasicInfo = DataMgr.GetBasicInfo()
  local FirstView = self:GetFirstView()
  if FirstView and FirstView.InitInfo then
    FirstView:InitInfo(BasicInfo)
  end
end

function ContactPersonViewModel:OnFriendListUpdate()
  local IdList = ContactPersonData:GetFriendIdList()
  self:PullPlayerInfoList(IdList, EContactListType.Friend)
end

function ContactPersonViewModel:OnFriendApplyListUpdate()
  local IdList = ContactPersonData:GetFriendApplyIdList()
  self:PullPlayerInfoList(IdList, EContactListType.FriendRequest)
end

function ContactPersonViewModel:OnBlackListUpdate()
  local IdList = ContactPersonData:GetBlackListIdList()
  if next(IdList) == nil then
    local FirstView = self:GetFirstView()
    if FirstView then
      FirstView:HideAllBlackListItem()
    end
  else
    DataMgr.GetOrQueryPlayerInfo(IdList, true, nil, nil, nil, nil, EContactListType.BlackList)
  end
end

function ContactPersonViewModel:BindOnQueryPlayerInfoSuccess(Params)
  if not Params[1] or Params[1] ~= EContactListType.BlackList then
    return
  end
  local IdList = ContactPersonData:GetBlackListIdList()
  local Result, PlayerInfo = DataMgr.GetOrQueryPlayerInfo(IdList)
  if Result then
    local FirstView = self:GetFirstView()
    if FirstView and FirstView.RefreshBlackList then
      FirstView:RefreshBlackList(PlayerInfo)
    end
  end
end

function ContactPersonViewModel:BindOnPlatformFriendInfoListUpdate()
  local RoleIdList = ContactPersonData:GetPlatformFriendsRoleIdList()
  self:PullPlayerInfoList(RoleIdList, EContactListType.PlatformFriend)
end

function ContactPersonViewModel:BindOnReadFriendsInfoListComplete(Result)
  if not Result then
    print("ContactPersonViewModel:BindOnReadFriendsInfoListComplete Result is false")
    return
  end
  print("ContactPersonViewModel:BindOnReadFriendsInfoListComplete", Result)
  local OnlineFriendSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlineFriendSystem:StaticClass())
  local FriendInfoList = OnlineFriendSystem:GetFriendsInfoList(nil)
  local FriendUserIdList = {}
  local FriendInfoListTable = {}
  for key, SingleFriendInfo in pairs(FriendInfoList) do
    table.insert(FriendUserIdList, SingleFriendInfo.UserId)
    local TempTable = {}
    TempTable.UserId = SingleFriendInfo.UserId
    TempTable.NickName = SingleFriendInfo.NickName
    TempTable.IsPlaying = SingleFriendInfo.IsPlaying
    TempTable.IsOnline = SingleFriendInfo.IsOnline
    FriendInfoListTable[SingleFriendInfo.UserId] = TempTable
    print(SingleFriendInfo.UserId, SingleFriendInfo.NickName)
  end
  if next(FriendUserIdList) == nil then
    ContactPersonData:ClearPlatformFriendsHasRoleIdInfo()
    ContactPersonData:ClearPlatformFriendsHasNotRoleIdInfo()
    EventSystem.Invoke(EventDef.ContactPerson.OnPlatformFriendInfoListUpdate)
    return
  end
  if UE.URGBlueprintLibrary.IsPlatformConsole() then
    ContactPersonData:SetPlatformFriendsHasNotRoleIdInfo(FriendInfoListTable)
    EventSystem.Invoke(EventDef.ContactPerson.OnPlatformFriendInfoListUpdate)
  else
    HttpCommunication.Request("login/users", {userID = FriendUserIdList}, {
      GameInstance,
      function(Target, JsonResponse)
        print("GetRoleIdByUserId", JsonResponse.Content)
        local JsonTable = RapidJson.decode(JsonResponse.Content)
        local HasRoleIdFriendInfoList = {}
        for index, SingleInfo in ipairs(JsonTable.users) do
          local SingleFriendInfo = FriendInfoListTable[SingleInfo.userID]
          HasRoleIdFriendInfoList[SingleInfo.roleID] = SingleFriendInfo
          FriendInfoListTable[SingleInfo.userID] = nil
        end
        ContactPersonData:SetPlatformFriendsHasRoleIdInfo(HasRoleIdFriendInfoList)
        ContactPersonData:SetPlatformFriendsHasNotRoleIdInfo(FriendInfoListTable)
        EventSystem.Invoke(EventDef.ContactPerson.OnPlatformFriendInfoListUpdate)
      end
    })
  end
end

function ContactPersonViewModel:OnViewTabChanged(CurSelectIndex)
  self.CurViewSelectTabIndex = CurSelectIndex
  self:RefreshPlayerInfoList()
end

function ContactPersonViewModel:OnShutdown()
  EventSystem.RemoveListener(EventDef.ContactPerson.OnContactPersonItemClicked, self.OnContactPersonItemClicked, self)
  EventSystem.RemoveListener(EventDef.ContactPerson.OnRecentListPlayerInfoUpdate, self.OnRecentListPlayerInfoChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateBasicInfo, self.OnUpdateBasicInfo, self)
  EventSystem.RemoveListener(EventDef.ContactPerson.OnFriendListUpdate, self.OnFriendListUpdate, self)
  EventSystem.RemoveListener(EventDef.ContactPerson.OnFriendApplyListUpdate, self.OnFriendApplyListUpdate, self)
  EventSystem.RemoveListener(EventDef.ContactPerson.OnBlackListUpdate, self.OnBlackListUpdate, self)
  EventSystem.RemoveListener(EventDef.PlayerInfo.QueryPlayerInfoSucc, self.BindOnQueryPlayerInfoSuccess, self)
  EventSystem.RemoveListener(EventDef.ContactPerson.OnPlatformFriendInfoListUpdate, self.BindOnPlatformFriendInfoListUpdate, self)
  self:StartOrEndRefreshPlayerInfoList(false)
  if UE.UOnlineFriendSystem ~= nil then
    local OnlineFriendSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlineFriendSystem:StaticClass())
    if OnlineFriendSystem then
      OnlineFriendSystem.OnReadFriendsInfoListComplete:Remove(GameInstance, self.BindOnReadFriendsInfoListComplete)
    end
  end
  self.Super.OnShutdown(self)
end

return ContactPersonViewModel
