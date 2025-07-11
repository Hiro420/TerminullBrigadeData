local SystemOpenMgr = LuaClass()
function SystemOpenMgr:Ctor()
  self._SystemSwitches = {}
  self._bInit = false
end
function SystemOpenMgr:OnInit()
  EventSystem.AddListenerNew(EventDef.WSMessage.SystemSwitch, self, self.OnSystemSwitchUpdate)
  self._bInit = true
end
function SystemOpenMgr:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.WSMessage.SystemSwitch, self, self.OnSystemSwitchUpdate)
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
    error("SystemOpenMgr\230\156\170\229\136\157\229\167\139\229\140\150")
  end
  local DefaultSwitchs = require("GameConfig.SystemOpen.DefaultSwitchs")
  if DefaultSwitchs and false == DefaultSwitchs[systemID] then
    if false ~= showCloseTips then
      ShowWaveWindow(1168)
    end
    return false
  end
  if self:IsSystemIdValid(systemID) then
    local isunlock = true
    local isenable = self._SystemSwitches[systemID]
    if nil == isenable then
      print("SystemOpenMgr:IsSystemOpen _SystemSwitches don't contains systemID=", systemID)
      isenable = true
    end
    local IsOpen = isunlock and isenable
    if false == IsOpen and false ~= showCloseTips then
      ShowWaveWindow(1168)
    end
    return IsOpen
  end
  print("SystemOpenMgr:IsSystemOpen systemID=", systemID, "is not defined.")
  return true
end
function SystemOpenMgr:OnSystemSwitchUpdate(jsonStr)
  if not jsonStr then
    return
  end
  local rapidjson = require("rapidjson")
  local jsonTable = rapidjson.decode(jsonStr)
  if not jsonTable.data then
    UnLua.LogError("SystemOpenMgr:OnSystemSwitchUpdate decode json msg failed.")
    return
  end
  local data = rapidjson.decode(jsonTable.data)
  if data then
    self._SystemSwitches = data
  else
    UnLua.LogError("SystemOpenMgr:OnSystemSwitchUpdate decode jsonTable.data failed.")
  end
end
return SystemOpenMgr
