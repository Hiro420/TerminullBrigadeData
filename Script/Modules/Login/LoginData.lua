local ELoginStep = {
  Empty = -1,
  NotLogin = 0,
  NotLoginAndNotShowAccountNameInputPanel = 1,
  LoggedInWaitClick = 2,
  SetNickName = 3,
  AfterSetNickName = 4
}
_G.ELoginStep = ELoginStep
local RegionCode = {
  America = "840",
  Korea = "410",
  Japan = "392"
}
_G.RegionCode = RegionCode
local LoginData = {
  LobbyServerId = -1,
  IsServerListInited = false,
  IsLoginByDistributionChannel = false,
  UserIdStr = "0",
  GetServerListCount = 0,
  ServerListLabel = nil,
  IsRequestServerList = false
}
function LoginData:SetUserIdStr(UserIdStr)
  LoginData.UserIdStr = UserIdStr
end
function LoginData:GetUserIdStr()
  return LoginData.UserIdStr
end
function LoginData:AddGetServerListCount()
  LoginData.GetServerListCount = LoginData.GetServerListCount + 1
end
function LoginData:IsOverGetServerListMaxCount()
  return LoginData.GetServerListCount >= 10
end
function LoginData:SetIsServerListInited(IsInit)
  LoginData.IsServerListInited = IsInit
end
function LoginData:GetIsServerListInited()
  return LoginData.IsServerListInited
end
function LoginData:SetServerListLabel(InServerListLabel)
  LoginData.ServerListLabel = InServerListLabel
end
function LoginData:GetServerListLabel()
  return LoginData.ServerListLabel
end
function LoginData:SetLobbyServerId(InLobbyServerId)
  LoginData.LobbyServerId = InLobbyServerId
  local RGAccountSubsystem = UE.URGAccountSubsystem.Get()
  if RGAccountSubsystem then
    RGAccountSubsystem:SetLobbyServerId(InLobbyServerId)
  end
end
function LoginData:GetLobbyServerId()
  return LoginData.LobbyServerId
end
function LoginData:SetIsLoginByDistributionChannel(IsLogin)
  LoginData.IsLoginByDistributionChannel = IsLogin
end
function LoginData:GetIsLoginByDistributionChannel()
  return LoginData.IsLoginByDistributionChannel
end
function LoginData:GetLoginSavedGameName()
  return "LoginSavedGame"
end
function LoginData:SaveLastSelectServeName(InServerName)
  local LoginSaveGameName = LoginData:GetLoginSavedGameName()
  local SaveGameObject
  if not UE.UGameplayStatics.DoesSaveGameExist(LoginSaveGameName, 0) then
    return
  end
  SaveGameObject = UE.UGameplayStatics.LoadGameFromSlot(LoginSaveGameName, 0)
  if not SaveGameObject then
    return
  end
  SaveGameObject:SetLastSelectedServerName(InServerName)
  local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, HttpCommunication.GetHttpServiceClass())
  if HttpService then
    HttpService:SetLastSelectedServerName(InServerName)
  end
end
function LoginData:SetIsRequestServerList(IsRequestServerList)
  LoginData.IsRequestServerList = IsRequestServerList
end
function LoginData:GetIsRequestServerList(...)
  return LoginData.IsRequestServerList
end
function LoginData:ClearData()
  LoginData.IsServerListInited = false
  LoginData.UserIdStr = "0"
  LoginData.GetServerListCount = 0
end
return LoginData
