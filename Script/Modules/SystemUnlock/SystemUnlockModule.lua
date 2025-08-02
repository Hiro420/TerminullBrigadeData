local SystemUnlockModule = LuaClass()
local rapidjson = require("rapidjson")
local SystemUnlockData = require("Modules.SystemUnlock.SystemUnlockData")

function SystemUnlockModule:Ctor()
end

function SystemUnlockModule:OnInit()
  print("SystemUnlockModule:OnInit...........")
  SystemUnlockData:DealWithTable()
  EventSystem.AddListenerNew(EventDef.WSMessage.systemUnlock, self, self.BindOnSystemUnlock)
end

function SystemUnlockModule:OnShutdown()
  print("SystemUnlockModule:OnShutdown...........")
  EventSystem.RemoveListenerNew(EventDef.WSMessage.systemUnlock, self, self.BindOnSystemUnlock)
end

function SystemUnlockModule:BindOnSystemUnlock(JsonStr)
  local JsonTable = rapidjson.decode(JsonStr)
  for i, v in ipairs(JsonTable.unlockSystemIDs) do
    SystemUnlockData.SystemUnlockInfo[v] = ESystemState.UnLock
    EventSystem.Invoke(EventDef.SystemUnlock.SystemUnlockUpdate, v)
  end
end

function SystemUnlockModule:CheckIsViewUnlock(ViewName)
  local sysId = SystemUnlockData:GetSysIdByViewName(ViewName)
  if sysId >= 0 then
    return self:CheckIsSystemUnlock(sysId)
  else
    return true
  end
end

function SystemUnlockModule:CheckIsSystemUnlock(SystemId)
  if not SystemUnlockData.SystemUnlockInfo[SystemId] then
    return true
  end
  if SystemUnlockData.SystemUnlockInfo[SystemId] == ESystemState.UnLock then
    return true
  else
    return false
  end
end

return SystemUnlockModule
