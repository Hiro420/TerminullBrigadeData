local SystemTravelMgr = {
  recIdx = 0,
  records = {},
  datas = {},
  active = nil,
  fade = false,
  fadeState = nil,
  fadeClass = nil,
  fadeParam = nil,
  rollBackStateClass = nil
}
local PushStateRecord = function(stateClass, ...)
  if stateClass then
    SystemTravelMgr.recIdx = SystemTravelMgr.recIdx + 1
    SystemTravelMgr.records[SystemTravelMgr.recIdx] = stateClass
    local data = (...)
    if data then
      SystemTravelMgr.datas[SystemTravelMgr.recIdx] = table.pack(...)
    end
  end
end
local PopStateRecord = function()
  local stateClass = SystemTravelMgr.records[SystemTravelMgr.recIdx]
  if stateClass then
    SystemTravelMgr.datas[SystemTravelMgr.recIdx] = nil
  else
    UnLua.LogError("PopStateRecord error(no state), recIdx: ", SystemTravelMgr.recIdx)
  end
  SystemTravelMgr.records[SystemTravelMgr.recIdx] = nil
  SystemTravelMgr.recIdx = SystemTravelMgr.recIdx - 1
end
local ReplaceState = function(state, stateClass, ...)
  if not state then
    error("state is nil.")
  end
  if SystemTravelMgr.active then
    local curActive = SystemTravelMgr.active
    SystemTravelMgr.active = nil
    if nil ~= curActive.CacheDataOnExit then
      local saveTemp = curActive:CacheDataOnExit()
      SystemTravelMgr.datas[SystemTravelMgr.recIdx] = saveTemp
    end
    local ok, errors = pcall(curActive.OnExit, curActive)
    if not ok then
      UnLua.LogError("Exit state{", curActive.name, "} error, errors:", errors)
    else
      print("Exit state:", SystemTravelMgr.active.name, " success.")
    end
  end
  PushStateRecord(stateClass, ...)
  SystemTravelMgr.active = state
  state:OnEnter(...)
  print("Enter exit:", state, " success.")
end
local OnStateFadeEndCall = function()
  if not SystemTravelMgr.fade then
    return
  end
  SystemTravelMgr.fade = false
  if SystemTravelMgr.fadeState then
    local state = SystemTravelMgr.fadeState
    local param = SystemTravelMgr.fadeParam
    local class = SystemTravelMgr.fadeClass
    ReplaceState(state, class, param)
  elseif SystemTravelMgr.rollBackStateClass then
    SystemTravelMgr.RollBackState(SystemTravelMgr.rollBackStateClass)
  else
    SystemTravelMgr.ExitState()
  end
  SystemTravelMgr.rollBackStateClass = nil
  SystemTravelMgr.fadeState = nil
  SystemTravelMgr.fadeParam = nil
  SystemTravelMgr.fadeClass = nil
end
local CheckIsCurrentState = function(stateClass)
  if SystemTravelMgr.active ~= nil and SystemTravelMgr.active.name == stateClass.name then
    return true
  end
  return false
end
local NewState = function(Cls)
  if Cls then
    local instance = {}
    setmetatable(instance, Cls)
    Cls._index = Cls
    return instance
  end
  return nil
end

function SystemTravelMgr.GotoState(stateClass, ...)
  if SystemTravelMgr.fade then
    print("SystemTravelMgr.GotoState - \229\189\147\229\137\141\229\164\132\228\186\142\229\187\182\232\191\159\232\183\179\232\189\172\228\184\173\239\188\140\231\155\180\230\142\165return")
    return
  end
  if not stateClass then
    UnLua.LogError("GotoState: stateClass is nil.")
    return
  end
  if stateClass.CanTravel and not stateClass.CanTravel() then
    return
  end
  if CheckIsCurrentState(stateClass) then
    return
  end
  local stateNew = NewState(stateClass)
  print("SystemTravelMgr.Goto:", stateClass.name)
  ReplaceState(stateNew, stateClass, ...)
end

function SystemTravelMgr.ExitState(stateClass)
  if stateClass and not CheckIsCurrentState(stateClass) then
    if SystemTravelMgr.active then
      print("ExitState error, stateClassName:", stateClass.name, ", activeName:", SystemTravelMgr.active.name)
    else
      print("ExitState error, stateClassName:", stateClass.name, ", active is nil.")
    end
  end
  if SystemTravelMgr.active then
    local curActive = SystemTravelMgr.active
    SystemTravelMgr.active = nil
    local ok, errors = pcall(curActive.OnExit, curActive)
    if not ok then
      UnLua.LogError("Exit state{", curActive.name, "} error, errors:", errors)
    end
  end
  if SystemTravelMgr.recIdx > 0 then
    PopStateRecord()
  end
  while SystemTravelMgr.recIdx > 0 do
    local stateClass = SystemTravelMgr.records[SystemTravelMgr.recIdx]
    if stateClass and stateClass.NotRecover and stateClass.NotRecover == true then
      PopStateRecord()
    else
      break
    end
  end
  local stateClass = SystemTravelMgr.records[SystemTravelMgr.recIdx]
  if stateClass then
    SystemTravelMgr.active = NewState(stateClass)
    if SystemTravelMgr.active then
      SystemTravelMgr.active:OnEnter()
      local stateName = SystemTravelMgr.active.name
      local lastData = SystemTravelMgr.datas[SystemTravelMgr.recIdx] or {}
      local data = SystemTravelMgr.datas
      if SystemTravelMgr.active.OnRecover then
        print("uiview active OnRecover\239\188\154", stateName)
        SystemTravelMgr.active:OnRecover(table.unpack(lastData))
      else
        SystemTravelMgr.active:OnEnter(table.unpack(lastData))
      end
    else
      UnLua.LogError("uiview ExitState enter new state error", stateClass.name)
    end
  else
    UnLua.LogError("uiview ExitState stateClass is nil , recIdx:", SystemTravelMgr.recIdx)
  end
  if not SystemTravelMgr.active then
    SystemTravelMgr.ClearAllState()
    ReplaceState(MainPanelState)
  end
end

function SystemTravelMgr.FastExitState()
  SystemTravelMgr.ExitState()
end

function SystemTravelMgr.RemoveStateRecord(stateClass)
  for index, class in ipairs(SystemTravelMgr.records) do
    if class == stateClass then
      table.remove(SystemTravelMgr.records, index)
      SystemTravelMgr.datas[index] = nil
      SystemTravelMgr.recIdx = SystemTravelMgr.recIdx - 1
      break
    end
  end
end

function SystemTravelMgr.FadeGoto(stateClass, fadeTime, ...)
  if SystemTravelMgr.fade then
    return
  end
  local state = NewState(stateClass)
  if state and state.OnPreEnter then
    SystemTravelMgr.fade = true
    SystemTravelMgr.fadeState = state
    SystemTravelMgr.fadeClass = stateClass
    SystemTravelMgr.fadeParam = {
      ...
    }
    state:OnPreEnter()
    GlobalTimer.DelayCallback(fadeTime, OnStateFadeEndCall)
  end
end

function SystemTravelMgr.FadeExitState()
  if SystemTravelMgr.fade then
    return
  end
  local state = SystemTravelMgr.active
  if state and state.OnPreExit then
    SystemTravelMgr.fade = true
    SystemTravelMgr.fadeState = nil
    SystemTravelMgr.rollBackStateClass = nil
    state:OnPreExit()
  end
end

function SystemTravelMgr.FadeRollBackState(stateClass)
  if SystemTravelMgr.fade then
    return
  end
  local state = SystemTravelMgr.active
  if state and state.OnPreExit then
    SystemTravelMgr.fade = true
    SystemTravelMgr.fadeState = nil
    SystemTravelMgr.rollBackStateClass = stateClass
    state:OnPreExit()
  end
end

function SystemTravelMgr.RollBackState(stateClass)
  if SystemTravelMgr.active then
    SystemTravelMgr.active:OnExit()
    SystemTravelMgr.active = nil
  end
  local maxIndex = SystemTravelMgr.recIdx
  for i = 1, maxIndex do
    if SystemTravelMgr.records[SystemTravelMgr.recIdx] == stateClass then
      local state = NewState(stateClass)
      if state then
        SystemTravelMgr.active = state
        state:OnEnter()
      end
      break
    end
    SystemTravelMgr.records[SystemTravelMgr.recIdx] = nil
    SystemTravelMgr.datas[SystemTravelMgr.recIdx] = nil
    SystemTravelMgr.recIdx = SystemTravelMgr.recIdx - 1
  end
  if not SystemTravelMgr.active then
    ReplaceState(MainPanelState)
  end
end

function SystemTravelMgr.CheckIsStateExist(stateClass)
  for i = 1, SystemTravelMgr.recIdx do
    if SystemTravelMgr.records[i] == stateClass then
      return true
    end
  end
  return false
end

function SystemTravelMgr.GetCurrentStateClass()
  return SystemTravelMgr.records[SystemTravelMgr.recIdx]
end

function SystemTravelMgr.ClearAllState()
  if SystemTravelMgr.active ~= nil then
    print("SystemTravelMgr.ClearAllState:", SystemTravelMgr.active.name)
    SystemTravelMgr.active:OnExit()
  else
    print("SystemTravelMgr.ClearAllState: no active")
  end
  SystemTravelMgr.recIdx = 0
  SystemTravelMgr.records = {}
  SystemTravelMgr.datas = {}
  SystemTravelMgr.active = nil
  SystemTravelMgr.fade = false
  SystemTravelMgr.fadeState = nil
  SystemTravelMgr.fadeClass = nil
  SystemTravelMgr.fadeParam = nil
  SystemTravelMgr.rollBackStateClass = nil
end

return SystemTravelMgr
