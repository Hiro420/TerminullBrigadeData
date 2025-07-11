local rawget = rawget
local rawset = rawset
local pairs = pairs
local setmetatable = setmetatable
local getmetatable = getmetatable
local type = type
local require = require
local string = string
local str_find = string.find
local str_gsub = string.gsub
local str_len = string.len
local table_insert = table.insert
local defaultViewModel = {}
defaultViewModel._bindings = {}
defaultViewModel._isDefaultViewModelType = true
defaultViewModel._CallbackKeyMap = {}
_G.bindingTargetMap = _G.bindingTargetMap or {}
local targetMap = _G.bindingTargetMap
function defaultViewModel:OnInit()
  if self.subViewModels then
    for name, path in pairs(self.subViewModels) do
      rawset(self, name, {_count = 0})
    end
  end
end
function defaultViewModel:OnShutdown()
  if self.subViewModels then
    for name, path in pairs(self.subViewModels) do
      for i, svm in pairs(self[name]) do
        svm:OnShutdown()
      end
    end
  end
end
function defaultViewModel:OnClear()
  if self.subViewModels then
    for name, path in pairs(self.subViewModels) do
      if self[name] then
        for i, svm in pairs(self[name]) do
          svm:OnClear()
        end
      end
    end
  end
end
function defaultViewModel:RegisterPropertyChanged(tab, view)
  local bindings = self._bindings
  for v, _ in pairs(bindings) do
    if v.Object == nil then
      bindings[v] = nil
      UnLua.LogError("\232\191\153\228\184\170viewmodel\231\154\132\231\187\145\229\174\154\230\178\161\230\156\137\232\167\163\231\187\145\239\188\154\232\132\154\230\156\172\230\138\165\233\148\153\230\136\150\232\128\133\230\188\143\228\186\134\232\167\163\231\187\145")
    end
  end
  tab = tab or {}
  local viewBinding = bindings[view]
  bindings[view] = tab
  self:NotifyAllPropertyToView(view)
  bindings[view]._CacheInit = true
end
function defaultViewModel:UnRegisterPropertyChanged(tab, view)
  local bindings = self._bindings
  if nil ~= bindings[view] then
    bindings[view] = nil
  end
end
function defaultViewModel:UnRegisterAllPropertyChanged()
  self._bindings = {}
end
function defaultViewModel:NotifyAllPropertyToView(view)
  local bindings = self._bindings
  local viewBindingList = bindings[view]
  if nil == viewBindingList then
    return
  end
  for i = 1, #viewBindingList do
    local bindProp = viewBindingList[i]
    if bindProp.Target and str_find(bindProp.Target, ".", 1, true) and not bindProp.multiLevelTarget then
      local retList = targetMap[bindProp.Target]
      if not retList then
        local tmp = {}
        str_gsub(bindProp.Target, "[^.]+", function(w)
          table_insert(tmp, w)
        end)
        targetMap[bindProp.Target] = tmp
      end
      bindProp.multiLevelTarget = true
    end
    if nil ~= bindProp.Callback then
      self._CallbackKeyMap[bindProp.Source] = true
    end
    defaultViewModel.PrivateProcessKey(bindProp.Source, bindProp, viewBindingList)
    self:InvokePropertyChangedHandler(view, bindProp, self[bindProp.Source])
  end
end
function defaultViewModel.PrivateProcessKey(key, bindProp, viewBindingList)
  if viewBindingList._CacheInit then
    return
  end
  if not viewBindingList[key] then
    viewBindingList[key] = bindProp
    bindProp.bSingleKey = true
  elseif viewBindingList[key].bSingleKey == true then
    viewBindingList[key].bSingleKey = nil
    local props = {}
    table_insert(props, viewBindingList[key])
    table_insert(props, bindProp)
    viewBindingList[key] = props
  else
    table_insert(viewBindingList[key], bindProp)
  end
end
function defaultViewModel:NotifyPropertyChanged(key, newValue)
  local bindings = self._bindings
  for view, bindList in pairs(bindings) do
    if view.Object then
      if bindList[key] then
        if bindList[key].bSingleKey then
          self:InvokePropertyChangedHandler(view, bindList[key], newValue)
        else
          for i = 1, #bindList[key] do
            local prop = bindList[key]
            self:InvokePropertyChangedHandler(view, prop[i], newValue)
          end
        end
      end
    else
      bindings[view] = nil
      UnLua.LogError("\232\191\153\228\184\170viewmodel\231\154\132\231\187\145\229\174\154\230\178\161\230\156\137\232\167\163\231\187\145\239\188\154\232\132\154\230\156\172\230\138\165\233\148\153\230\136\150\232\128\133\230\188\143\228\186\134\232\167\163\231\187\145")
    end
  end
end
function defaultViewModel:InvokePropertyChangedHandler(view, bindProp, newValue)
  local policy = bindProp.Policy
  local srcVal = newValue
  local convertedVal = srcVal
  if nil ~= policy then
    if nil ~= policy.Converter then
      convertedVal = policy.Converter(srcVal, policy.ConverterParam)
    end
    if nil ~= policy.OnSourceChanged then
      local target = view
      if bindProp.multiLevelTarget then
        local retList = targetMap[bindProp.Target]
        if retList then
          for i = 1, #retList do
            target = target[retList[i]]
          end
        end
      elseif bindProp.Target and str_len(bindProp.Target) > 0 then
        target = target[bindProp.Target]
      end
      if target then
        policy.OnSourceChanged(target, convertedVal, srcVal)
      end
    end
  end
  if nil ~= bindProp.Callback then
    bindProp.Callback(view, srcVal)
  end
end
function defaultViewModel:GetFirstView()
  local bindings = self._bindings
  for view, _ in pairs(bindings) do
    if view.Object then
      return view
    else
      UnLua.LogError("\232\191\153\228\184\170viewmodel\230\178\161\230\156\137\232\167\163\231\187\145\239\188\154\232\132\154\230\156\172\230\138\165\233\148\153\230\136\150\232\128\133\230\188\143\228\186\134\232\167\163\231\187\145")
    end
  end
end
local _meta_set = function(tab, key, val)
  local properties = rawget(tab, "propertyBindings")
  if nil ~= properties then
    local oldValue = rawget(properties, key)
    if nil ~= oldValue then
      properties[key] = val
      if not tab._CallbackKeyMap[key] then
        local valueType = type(val)
        local bCheck = "number" == valueType or "string" == valueType
        if not bCheck or bCheck and oldValue ~= val then
          tab:NotifyPropertyChanged(key, val)
        end
      else
        tab:NotifyPropertyChanged(key, val)
      end
      return
    end
  end
  rawset(tab, key, val)
end
local _meta_get = function(tab, key)
  local properties = rawget(tab, "propertyBindings")
  if nil ~= properties then
    local bindProperty = properties[key]
    if nil ~= bindProperty then
      return bindProperty
    end
  end
  return rawget(tab, key)
end
function defaultViewModel:SetupMetaTable()
  local meta = {__newindex = _meta_set, __index = _meta_get}
  setmetatable(self, meta)
end
local function DeepCopy(dst, src)
  for k, v in pairs(src) do
    if "table" == type(v) then
      dst[k] = {}
      local meta = getmetatable(v)
      if nil ~= meta and nil ~= meta.__index then
        setmetatable(dst[k], {
          __index = meta.__index
        })
      end
      DeepCopy(dst[k], v)
    else
      dst[k] = v
    end
  end
end
local CreateDefaultViewModel = function()
  local newViewModel = {}
  DeepCopy(newViewModel, defaultViewModel)
  newViewModel.Super = setmetatable({}, {__index = defaultViewModel})
  return newViewModel
end
local InstantiateViewModel = function(template)
  local newViewModel = {}
  DeepCopy(newViewModel, template)
  newViewModel.Super = setmetatable({}, {__index = defaultViewModel})
  newViewModel:SetupMetaTable()
  return newViewModel
end
function defaultViewModel:SetSubViewModel(name, count)
  local svms = self[name]
  if count > svms._count then
    local newSubViewModel
    local svmTemplate = require(self.subViewModels[name])
    for index = svms._count + 1, count do
      local newSvm = InstantiateViewModel(svmTemplate)
      newSvm:OnInit(index)
      svms[index] = newSvm
    end
  else
    for index = count + 1, svms._count do
      svms[index]:OnShutdown()
      svms[index] = nil
    end
  end
  svms._count = count
end
_G.CreateDefaultViewModel = CreateDefaultViewModel
_G.InstantiateViewModel = InstantiateViewModel
