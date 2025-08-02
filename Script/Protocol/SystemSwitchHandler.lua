local SystemSwitchHandler = {}

function SystemSwitchHandler.SendSystemSwitchReq()
  printShipping("SystemSwitchHandler.SendSystemSwitchReq...")
  HttpCommunication.RequestByGet("hotfix/getsysswitch", {
    GameInstance,
    SystemSwitchHandler.OnSystemSwitchReqSucceed
  }, {
    GameInstance,
    SystemSwitchHandler.OnSystemSwitchReqFailed
  })
end

function SystemSwitchHandler.OnSystemSwitchReqSucceed(target, msg)
  local rapidjson = require("rapidjson")
  local response = rapidjson.decode(msg.Content)
  if not response then
    printError("SystemSwitchHandler.OnSystemSwitchReqSucceed - decode failed!!!")
    return
  end
  printShipping("SystemSwitchHandler.OnSystemSwitchReqSucceed response=", response.switchs)
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr then
    SystemOpenMgr:OnRequestSystemSwitchsInitDataSucceed(response.switchs)
  else
    printError("SystemSwitchHandler.OnSystemSwitchReqSucceed - require SystemOpenMgr is nil!!!")
  end
end

function SystemSwitchHandler.OnSystemSwitchReqFailed()
  printError("SystemSwitchHandler.OnSystemSwitchReqFailed")
  ShowWaveWindow(1553)
end

return SystemSwitchHandler
