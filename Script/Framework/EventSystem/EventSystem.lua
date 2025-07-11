local EventSystem = {}
function EventSystem.AddListenerNew(EventName, Target, func)
  EventSystem.AddListener(Target, EventName, func)
end
function EventSystem.RemoveListenerNew(EventName, Target, func)
  EventSystem.RemoveListener(EventName, func, Target)
end
function EventSystem.AddListener(Target, EventName, func)
  if nil == EventName or nil == func then
    print("\229\156\168EventSystem.AddListener\228\184\173EventName\230\136\150func\228\184\186\231\169\186", EventName, func)
    return
  end
  if nil == EventSystem[EventName] then
    local TempTable = {Target = nil, Func = nil}
    TempTable.Target = Target
    TempTable.Func = func
    local EventList = {}
    table.insert(EventList, TempTable)
    EventSystem[EventName] = EventList
  else
    local TempTable = {Target = nil, Func = nil}
    TempTable.Target = Target
    TempTable.Func = func
    if not EventSystem.IsListeningForEvent(EventName, func, Target) then
      table.insert(EventSystem[EventName], TempTable)
    else
      UnLua.LogWarn("EventSystem.AddListener \228\186\139\228\187\182\229\183\178\231\187\143\229\173\152\229\156\168\228\186\134", EventName, func, Target)
    end
  end
end
function EventSystem.IsListeningForEvent(EventName, func, Target)
  if nil == EventName or nil == func then
    print("\229\156\168EventSystem.CheckIsListener\228\184\173EventName\230\136\150func\228\184\186\231\169\186", EventName, func)
    return false
  end
  local a = EventSystem[EventName]
  if nil ~= a then
    for k, v in pairs(a) do
      if Target then
        if v.Target == Target and v.Func == func then
          return true
        end
      elseif v.Func == func then
        return true
      end
    end
  end
  return false
end
function EventSystem.RemoveListener(EventName, func, Target)
  if nil == EventName or nil == func then
    print("\229\156\168EventSystem.RemoveListener\228\184\173EventName\230\136\150func\228\184\186\231\169\186", EventName, func)
    return
  end
  local a = EventSystem[EventName]
  if nil ~= a then
    for k, v in pairs(a) do
      if Target then
        if v.Target == Target and v.Func == func then
          a[k] = nil
          break
        end
      elseif v.Func == func then
        a[k] = nil
        break
      end
    end
  end
end
function EventSystem.RemoveEventAllListener(EventName)
  if nil == EventName then
    print("\229\156\168EventSystem.RemoveEventAllListener\228\184\173EventName\228\184\186\231\169\186")
    return
  end
  if EventSystem[EventName] then
    EventSystem[EventName] = nil
  end
end
function EventSystem.Invoke(EventName, ...)
  if nil ~= EventName then
    local a = EventSystem[EventName]
    if nil ~= a then
      for k, v in pairs(a) do
        if v.Target then
          if v.Target.IsValid then
            if v.Target:IsValid() then
              v.Func(v.Target, ...)
            else
              a[k] = nil
              print("not valid Target", EventName)
            end
          else
            v.Func(v.Target, ...)
          end
        else
          v.Func(...)
        end
      end
    end
  end
end
_G.EventSystem = _G.EventSystem or EventSystem
return EventSystem
