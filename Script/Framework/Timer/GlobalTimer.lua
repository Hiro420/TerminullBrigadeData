local type = type
local getmetatable = getmetatable
local UnLua = _G.UnLua
local GlobalTimer = {}
function GlobalTimer.AddTickTimer(callback, delayTime)
  if "function" ~= type(callback) then
    UnLua.LogError("GlobalTimer.luaAddTickTimer - ", callback, " isn't a function")
    return
  end
  return UE.URGGlobalTimer.LuaAddCallback(callback, delayTime, UE.ERGTimerType.Tick)
end
function GlobalTimer.DeleteTickTimer(id)
  if not id or "number" ~= type(id) then
    UnLua.LogError("GlobalTimer.luaDeleteTickTimer - id isn't a number key\239\188\154", id)
    return
  end
  UE.URGGlobalTimer.LuaDeleteCallback(id)
end
function GlobalTimer.DelayCallback(delayTime, callback)
  if delayTime < 0 or nil == callback then
    return false
  end
  if "function" ~= type(callback) then
    UnLua.LogError("GlobalTimer.DelayCallback - ", callback, "isn't a function")
    return
  end
  local timeHandler
  timeHandler = UE.URGGlobalTimer.LuaAddCallback(function()
    GlobalTimer.DeleteDelayCallback(timeHandler)
    callback()
  end, delayTime, UE.ERGTimerType.Timeout)
  return timeHandler
end
function GlobalTimer.DeleteDelayCallback(timeHandler)
  if not timeHandler or "number" ~= type(timeHandler) then
    UnLua.LogError("GlobalTimer.DeleteDelayCallback - timeHandler isn't a number key\239\188\154", timeHandler)
    return
  end
  UE.URGGlobalTimer.LuaDeleteCallback(timeHandler)
end
_G.GlobalTimer = _G.GlobalTimer or GlobalTimer
