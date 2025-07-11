local M = {}
local GetBooleanArg = function(Args, Name, DefaultValue)
  if nil == Args[Name] then
    return DefaultValue
  end
  return not not Args[Name]
end
local MakeBinding = function(BindingClass, Args)
  local Ret = BindingClass()
  Ret.bConsumeInput = GetBooleanArg(Args, "ConsumeInput", true)
  Ret.bExecuteWhenPaused = GetBooleanArg(Args, "ExecuteWhenPaused", false)
  Ret.bOverrideParentBinding = GetBooleanArg(Args, "OverrideParentBinding", true)
  return Ret
end
local function MakeLuaFunction(Module, Prefix, Handler, No)
  local Name = string.format("%s_%d", Prefix, No)
  if not Module[Name] then
    Module[Name] = Handler
    return Name
  end
  return MakeLuaFunction(Module, Prefix, Handler, No + 1)
end
local Modifiers = {
  "Ctrl",
  "Alt",
  "Shift",
  "Cmd"
}
local GetModifierSuffix = function(Args)
  local Array = {""}
  for _, Modifier in ipairs(Modifiers) do
    if Args[Modifier] then
      table.insert(Array, Modifier)
    end
  end
  return table.concat(Array, "_")
end
function M.BindKey(Module, KeyName, KeyEvent, Handler, Args)
  Args = Args or {}
  Module.__UnLuaInputBindings = Module.__UnLuaInputBindings or {}
  local ModifierSuffix = GetModifierSuffix(Args)
  local FunctionName = MakeLuaFunction(Module, string.format("UnLuaInput_%s_%s%s", KeyName, KeyEvent, ModifierSuffix), Handler, 0)
  local Bindings = Module.__UnLuaInputBindings
  table.insert(Bindings, function(Manager, Class)
    local BindingObject = Manager:GetOrAddBindingObject(Class, UE.UInputKeyDelegateBinding)
    for _, OldBinding in pairs(BindingObject.InputKeyDelegateBindings) do
      if OldBinding.FunctionNameToBind == FunctionName then
        Manager:Override(Class, "InputAction", FunctionName)
        return
      end
    end
    local InputChord = UE.FInputChord()
    InputChord.Key = UE.EKeys[KeyName]
    InputChord.bShift = not not Args.Shift
    InputChord.bCtrl = not not Args.Ctrl
    InputChord.bAlt = not not Args.Alt
    InputChord.bCmd = not not Args.Cmd
    local Binding = MakeBinding(UE.FBlueprintInputKeyDelegateBinding, Args)
    Binding.InputChord = InputChord
    Binding.InputKeyEvent = UE.EInputEvent["IE_" .. KeyEvent]
    Binding.FunctionNameToBind = FunctionName
    BindingObject.InputKeyDelegateBindings:Add(Binding)
    Manager:Override(Class, "InputAction", FunctionName)
  end)
end
function M.BindAction(Module, ActionName, KeyEvent, Handler, Args)
  Args = Args or {}
  Module.__UnLuaInputBindings = Module.__UnLuaInputBindings or {}
  local FunctionName = MakeLuaFunction(Module, string.format("UnLuaInput_%s_%s", ActionName, KeyEvent), Handler, 0)
  local Bindings = Module.__UnLuaInputBindings
  table.insert(Bindings, function(Manager, Class)
    local BindingObject = Manager:GetOrAddBindingObject(Class, UE.UInputActionDelegateBinding)
    for _, OldBinding in pairs(BindingObject.InputActionDelegateBindings) do
      if OldBinding.FunctionNameToBind == FunctionName then
        Manager:Override(Class, "InputAction", FunctionName)
        return
      end
    end
    local Binding = MakeBinding(UE.FBlueprintInputActionDelegateBinding, Args)
    Binding.InputActionName = ActionName
    Binding.InputKeyEvent = UE.EInputEvent["IE_" .. KeyEvent]
    Binding.FunctionNameToBind = FunctionName
    BindingObject.InputActionDelegateBindings:Add(Binding)
    Manager:Override(Class, "InputAction", FunctionName)
  end)
end
function M.BindAxis(Module, AxisName, Handler, Args)
  Args = Args or {}
  Module.__UnLuaInputBindings = Module.__UnLuaInputBindings or {}
  local FunctionName = MakeLuaFunction(Module, string.format("UnLuaInput_%s", AxisName), Handler, 0)
  local Bindings = Module.__UnLuaInputBindings
  table.insert(Bindings, function(Manager, Class)
    local BindingObject = Manager:GetOrAddBindingObject(Class, UE.UInputAxisDelegateBinding)
    for _, OldBinding in pairs(BindingObject.InputAxisDelegateBindings) do
      if OldBinding.FunctionNameToBind == FunctionName then
        Manager:Override(Class, "InputAxis", FunctionName)
        return
      end
    end
    local Binding = MakeBinding(UE.FBlueprintInputAxisDelegateBinding, Args)
    Binding.InputAxisName = AxisName
    Binding.FunctionNameToBind = FunctionName
    BindingObject.InputAxisDelegateBindings:Add(Binding)
    Manager:Override(Class, "InputAxis", FunctionName)
  end)
end
function M.PerformBindings(Module, Manager, Class)
  local Bindings = Module.__UnLuaInputBindings
  if not Bindings then
    return
  end
  for _, Binding in ipairs(Bindings) do
    xpcall(Binding, function(Error)
      UnLua.LogError(Error .. "\n" .. debug.traceback())
    end, Manager, Class)
  end
end
return M
