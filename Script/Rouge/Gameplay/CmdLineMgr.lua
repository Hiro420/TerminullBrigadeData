CmdLineMgr = CmdLineMgr or {}
local CmdLine = UE.UKismetSystemLibrary.GetCommandLine()
local CmdTokens, CmdSwitches, CmdParams = UE.UKismetSystemLibrary.ParseCommandLine(CmdLine, nil, nil, nil)
print("-----CmdTokens----------")
for i = 1, CmdTokens:Length() do
  print(i, CmdTokens:Get(i))
end
print("------CmdSwitches---------")
for i = 1, CmdSwitches:Length() do
  print(i, CmdSwitches:Get(i))
end
print("------CmdParams------------")
local keys = CmdParams:Keys()
for i = 1, keys:Length() do
  local key = keys:Get(i)
  local value = CmdParams:Find(key)
  print(i, key .. ":" .. tostring(value))
end

function CmdLineMgr.FindParam(paramName)
  local ParamFound = CmdParams:Find(paramName)
  return ParamFound
end

function CmdLineMgr.FindSwitch(switchName)
  local index = CmdSwitches:Find(switchName)
  return index > 0
end
