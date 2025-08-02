local SystemOpenMgr = LuaClass()

function SystemOpenMgr:Ctor()
  self._SystemSwitches = {}
  self._bInit = false
  self._RequestSystemSwitchsInitDataCounter = 0
end

function SystemOpenMgr:OnInit()
  EventSystem.AddListenerNew(EventDef.WSMessage.SystemSwitch, self, self.OnSystemSwitchUpdate)
  self._bInit = true
end

function SystemOpenMgr:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.WSMessage.SystemSwitch, self, self.OnSystemSwitchUpdate)
end

function SystemOpenMgr:ExecuteRequestSystemSwitchsInitDataCallback()
  if not self._RequestSystemSwitchsInitDataCallback then
    printError("SystemOpenMgr:ExecuteRequestSystemSwitchsInitDataCallback - callback is nil")
    return
  end
  local ErrPrint = function(err)
    printError("SystemOpenMgr:ExecuteRequestSystemSwitchsInitDataCallback - error:", err)
  end
  xpcall(function()
    self._RequestSystemSwitchsInitDataCallback()
    self._RequestSystemSwitchsInitDataCounter = 0
    self._RequestSystemSwitchsInitDataCallback = nil
  end, ErrPrint)
end

function SystemOpenMgr:RequestSystemSwitchsInitData(SucceedCallback)
  self._RequestSystemSwitchsInitDataCounter = self._RequestSystemSwitchsInitDataCounter + 1
  print("SystemOpenMgr:RequestSystemSwitchsInitData begin, Counter:", self._RequestSystemSwitchsInitDataCounter)
  self._RequestSystemSwitchsInitDataCallback = SucceedCallback
  if self._RequestSystemSwitchsInitDataCounter > 5 then
    printShipping("SystemOpenMgr:RequestSystemSwitchsInitData - Counter > 5, execute callback directly.")
    self:ExecuteRequestSystemSwitchsInitDataCallback()
    return
  end
  local SystemSwitchHandler = require("Protocol.SystemSwitchHandler")
  if SystemSwitchHandler then
    SystemSwitchHandler.SendSystemSwitchReq()
  else
    printError("SystemOpenMgr:RequestSystemSwitchsInitData() - require SystemSwitchHandler is nil!!!")
  end
end

function SystemOpenMgr:OnRequestSystemSwitchsInitDataSucceed(SwitchesData)
  printShipping("SystemOpenMgr:OnRequestSystemSwitchsInitDataSucceed - SwitchesData:", SwitchesData)
  self:OnSystemSwitchUpdate(SwitchesData)
  self:ExecuteRequestSystemSwitchsInitDataCallback()
end

function SystemOpenMgr:IsSystemIdValid(systemID)
  if systemID then
    for _, v in pairs(SystemOpenID) do
      if systemID == v then
        return true
      end
    end
  end
  return false
end

function SystemOpenMgr:IsSystemOpen(systemID, showCloseTips)
  if self._bInit == false then
    printError("SystemOpenMgr\230\156\170\229\136\157\229\167\139\229\140\150")
  end
  local DefaultSwitchs = require("GameConfig.SystemOpen.DefaultSwitchs")
  if DefaultSwitchs and false == DefaultSwitchs[systemID] then
    print("SystemOpenMgr:IsSystemOpen systemID{", systemID, "} is set closed by DefaultSwitchs.")
    if false ~= showCloseTips then
      ShowWaveWindow(1168)
    end
    return false
  end
  if self:IsSystemIdValid(systemID) then
    local isenable = self._SystemSwitches[systemID]
    if nil == isenable then
      print("SystemOpenMgr:IsSystemOpen systemID{" .. systemID .. "} is not defined by server, set default open.")
      isenable = true
    end
    if false == isenable then
      print("SystemOpenMgr:IsSystemOpen systemID{", systemID, "} is set closed by server.")
      if false ~= showCloseTips then
        ShowWaveWindow(1168)
      end
    end
    return isenable
  end
  print("SystemOpenMgr:IsSystemOpen systemID{" .. systemID .. "}is both not set by DefaultSwitchs and server, so set default open.")
  return true
end

function SystemOpenMgr:OnSystemSwitchUpdate(jsonStr)
  if not jsonStr then
    printError("SystemOpenMgr:OnSystemSwitchUpdate jsonStr is nil")
    return
  end
  printShipping("SystemOpenMgr:OnSystemSwitchUpdate jsonStr: ", jsonStr)
  local rapidjson = require("rapidjson")
  local jsonTable = rapidjson.decode(jsonStr)
  if not jsonTable then
    printError("SystemOpenMgr:OnSystemSwitchUpdate decode jsonStr failed.")
    return
  end
  if not jsonTable.data then
    printError("SystemOpenMgr:OnSystemSwitchUpdate jsonTable.data is nil")
    return
  end
  local data = rapidjson.decode(jsonTable.data)
  if data then
    print("SystemOpenMgr:OnSystemSwitchUpdate Success decode jsonTable.data: ", jsonTable.data)
    printShipping("SystemOpenMgr:OnSystemSwitchUpdate Update switches data succeed.")
    self._SystemSwitches = data
  else
    printError("SystemOpenMgr:OnSystemSwitchUpdate decode jsonTable.data failed.")
  end
end

return SystemOpenMgr
