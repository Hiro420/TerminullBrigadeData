local LoginModule = LuaClass()
local rapidjson = require("rapidjson")
local LoginData = require("Modules.Login.LoginData")
local RGUtil = UE.RGUtil

function LoginModule:Ctor()
end

function LoginModule:OnInit()
  self:InitLoginSaveGame()
end

function LoginModule:OnStart()
  self:InitLastSelectServerName()
end

function LoginModule:InitLoginSaveGame()
  local SaveGameName = LoginData:GetLoginSavedGameName()
  if not UE.UGameplayStatics.DoesSaveGameExist(SaveGameName, 0) then
    local SaveGameObject = UE.UGameplayStatics.CreateSaveGameObject(UE.ULoginSaveGame:StaticClass())
    if SaveGameObject then
      UE.UGameplayStatics.SaveGameToSlot(SaveGameObject, SaveGameName, 0)
    end
  end
end

function LoginModule:InitLastSelectServerName(...)
  local SaveGameName = LoginData:GetLoginSavedGameName()
  if not UE.UGameplayStatics.DoesSaveGameExist(SaveGameName, 0) then
    return
  end
  local LoginSaveGame = UE.UGameplayStatics.LoadGameFromSlot(SaveGameName, 0)
  if not LoginSaveGame then
    return
  end
  local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
  if not HttpService then
    return
  end
  print("LoginModule:InitLastSelectServerName", LoginSaveGame:GetLastSelectedServerName())
  HttpService:SetLastSelectedServerName(LoginSaveGame:GetLastSelectedServerName())
end

function LoginModule:OnShutdown()
end

return LoginModule
