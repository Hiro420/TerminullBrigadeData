local rapidjson = require("rapidjson")
HttpCommunication = HttpCommunication or {IsInit = false}
function HttpCommunication.Init()
  if HttpCommunication.IsInit then
    return
  end
  HttpCommunication.IsInit = true
  HttpCommunication.Token = ""
  HttpCommunication.Version = ""
end
function HttpCommunication.Request(Path, JsonParams, SuccessDelegate, FailDelegate, IsServer, bIsShowLoading)
  local BPHttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, HttpCommunication.GetHttpServiceClass())
  if BPHttpService then
    BPHttpService:Request(Path, RapidJsonEncode(JsonParams), HttpCommunication.Token, SuccessDelegate, FailDelegate, false, false, bIsShowLoading)
  end
end
function HttpCommunication.RequestByJson(Path, Json, SuccessDelegate, FailDelegate, IsServer, bIsShowLoading)
  local BPHttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, HttpCommunication.GetHttpServiceClass())
  if BPHttpService then
    BPHttpService:Request(Path, Json, HttpCommunication.Token, SuccessDelegate, FailDelegate, false, false, bIsShowLoading)
  end
end
function HttpCommunication.RequestByGet(Path, SuccessDelegate, FailDelegate, IsServer, bIsShowLoading)
  local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, HttpCommunication.GetHttpServiceClass())
  if HttpService then
    HttpService:RequestByGet(Path, HttpCommunication.Token, SuccessDelegate, FailDelegate, false, bIsShowLoading)
  end
end
function HttpCommunication.RequestByGetWithFullPath(Path, SuccessDelegate, FailDelegate, IsServer, bIsShowLoading)
  local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, HttpCommunication.GetHttpServiceClass())
  if HttpService then
    HttpService:RequestByGetWithFullPath(Path, HttpCommunication.Token, SuccessDelegate, FailDelegate, false, bIsShowLoading)
  end
end
function HttpCommunication.RequestByGetWithCosCheck(Path, SuccessDelegate, FailDelegate)
  local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, HttpCommunication.GetHttpServiceClass())
  if HttpService then
    HttpService:RequestByGetWithFullPath(Path, "", SuccessDelegate, FailDelegate, false)
  end
end
function HttpCommunication.GetHttpServiceClass()
  return UE.UHttpService:StaticClass()
end
function HttpCommunication.SetToken(Token)
  HttpCommunication.Token = Token
  local MatchSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGMatchSubsystem:StaticClass())
  MatchSubsystem:SetToken(Token)
  local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UHttpService:StaticClass())
  HttpService:SetToken(Token)
end
function HttpCommunication.GetToken()
  return HttpCommunication.Token
end
function HttpCommunication.StartMatch(RoomId, SuccessDelegate, FailDelegate)
  local DebugDSName = CmdLineMgr.FindParam("DebugDSName")
  print("[kk]HttpCommunication.StartMatch, DebugDSName: ", DebugDSName)
  if DebugDSName then
    HttpCommunication.Request("dbg/roomservice/match", {roomId = RoomId, name = DebugDSName}, {
      nil,
      function()
        print("HttpCommunication.DbgStartMatch Succeeded.")
      end
    }, {
      nil,
      function()
        print("HttpCommunication.DbgStartMatch Failed.")
      end
    })
  else
    HttpCommunication.Request("roomservice/match", {roomId = RoomId}, SuccessDelegate, FailDelegate)
  end
end
