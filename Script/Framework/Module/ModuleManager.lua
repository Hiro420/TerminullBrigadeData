local UnLua = _G.UnLua
local GlobalModuleDef = require("Modules.GlobalModuleDef")
local GlobalTimer = _G.GlobalTimer
local ModuleManager = LuaClass()
function ModuleManager:Ctor()
  self._bInited = false
  self._ModulesMap = {}
  self._TimerKey = nil
  self._TickModulesMap = {}
end
local ErrorFunc = function(err)
  UnLua.LogError("ModuleManager Error:", err)
end
function ModuleManager:Get(modulename)
  if not self._bInited then
    return nil
  end
  return self._ModulesMap[modulename]
end
function ModuleManager:Init()
  if self._bInited == true then
    UnLua.LogWarn("ModuleManager is already inited.")
    return
  end
  print("ModuleManager:Init() begin...")
  EventSystem.AddListenerNew(EventDef.Global.OnApplicationCrash, nil, ModuleManager.OnApplicationCrash)
  if GlobalModuleDef then
    for k, v in pairs(GlobalModuleDef) do
      local newModule
      xpcall(function()
        local newModuleCls = require(v.Path)
        newModule = newModuleCls.New()
        if newModule.OnInit then
          newModule:OnInit()
        end
      end, ErrorFunc)
      if newModule then
        self._ModulesMap[v.name] = newModule
        if newModule.OnTick then
          self._TickModulesMap[v.name] = newModule
        end
      else
        UnLua.LogError("ModuleManager:Init - Create logic module(", v.name, ") failed!")
      end
    end
  end
  if self._TickModulesMap and next(self._TickModulesMap) then
    self._TimerKey = GlobalTimer.AddTickTimer(function(deltaSeconds)
      self:Tick(deltaSeconds)
      return true
    end, 0)
  end
  self._bInited = true
end
function ModuleManager:Start()
  print("ModuleManager:Start() begin...")
  if GlobalModuleDef then
    for k, v in pairs(GlobalModuleDef) do
      local module = self._ModulesMap[v.name]
      if module and module.OnStart then
        module:OnStart()
      end
    end
  end
end
function ModuleManager:Shutdown()
  print("ModuleManager:Shutdown() begin...")
  if self._TimerKey then
    GlobalTimer.DeleteTickTimer(self._TimerKey)
    self._TimerKey = nil
  end
  for k, v in pairs(self._ModulesMap) do
    if v.OnShutdown then
      xpcall(function()
        v:OnShutdown()
      end, ErrorFunc)
    end
  end
  self._ModulesMap = {}
  self._TickModulesMap = {}
  self._bInited = false
end
function ModuleManager:Tick(deltaSeconds)
  if self._TickModulesMap and next(self._TickModulesMap) ~= nil then
    for k, v in pairs(self._TickModulesMap) do
      if v then
        v:OnTick(deltaSeconds)
      end
    end
  end
end
function ModuleManager.OnApplicationCrash()
  print("ModuleManager:OnApplicationCrash()")
  local M = _G.ModuleManager
  if M then
    M:Shutdown()
  end
end
_G.ModuleManager = _G.ModuleManager or ModuleManager.New()
