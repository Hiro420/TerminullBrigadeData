local URGHttpHelper = UE.URGHttpHelper
local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local SystemUnlockData = require("Modules.SystemUnlock.SystemUnlockData")
local SystemUnlockHandler = {}

function SystemUnlockHandler:RequestGetSystemUnlockInfo()
  local path = "playergrowth/systemunlock/info"
  HttpCommunication.RequestByGet(path, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetSystemUnlockInfo Succ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(tostring(JsonResponse.Content))
      for k, v in pairs(JsonTable.systemUnlockInfo) do
        local sysId = tonumber(k)
        SystemUnlockData.SystemUnlockInfo[sysId] = v
      end
      EventSystem.Invoke(EventDef.SystemUnlock.SystemUnlockInit, SystemUnlockData.SystemUnlockInfo)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

function SystemUnlockHandler:RequestUnlockSystem(SystemId)
  local path = "dbg/playergrowth/systemunlock/unlock"
  HttpCommunication.Request(path, {
    systemIDs = {
      tonumber(SystemId)
    }
  }, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestUnlockSystem Succ", JsonResponse.Content)
      local JsonTable = rapidjson.decode(tostring(JsonResponse.Content))
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

return SystemUnlockHandler
