local pairs = pairs
local table_insert = table.insert
local table_remove = table.remove
local type = type
local rawget = rawget
local rawset = rawset
local next = next
local UIUtil = require("Framework.UIMgr.UIUtil")
local UnLua = _G.UnLua
local SubViewHelper = LuaClass()

function SubViewHelper:Ctor()
  self._subViewList = {}
  self._onInitList = {}
  self._onShowList = {}
  self._onHideList = {}
  self._onPreHideList = {}
  self._luaTickList = {}
  self._onDestroyList = {}
  self.parentView = nil
end

function SubViewHelper:OnInit()
  for k, subView in pairs(self._onInitList) do
    subView:OnInit()
  end
end

function SubViewHelper:OnShow(...)
  for k, subView in pairs(self._onShowList) do
    subView:OnShow(...)
  end
end

function SubViewHelper:OnPreHide()
  for k, subView in pairs(self._onPreHideList) do
    subView:OnPreHide()
  end
end

function SubViewHelper:OnHide()
  for k, subView in pairs(self._onHideList) do
    subView:OnHide()
  end
end

function SubViewHelper:OnTick(deltaSeconds)
  for k, subView in pairs(self._luaTickList) do
    subView:OnTick(deltaSeconds)
  end
end

function SubViewHelper:OnDestroy()
  local ClearWhenDestroy = UIUtil.ClearWhenDestroy
  for k, subView in pairs(self._onDestroyList) do
    subView:OnDestroy()
    ClearWhenDestroy(subView)
  end
end

function SubViewHelper:SetSubViewTickEnabled(InSubView, bEnable)
  if nil == InSubView then
    return
  end
  local bNeedTickBefore = self:IsNeedTick()
  if false == bEnable then
    if InSubView.LuaTick then
      for k, subView in pairs(self._luaTickList) do
        if subView == InSubView then
          table_remove(self._luaTickList, k)
          break
        end
      end
    end
  elseif true == bEnable and InSubView.LuaTick then
    for k, subView in pairs(self._luaTickList) do
      if subView == InSubView then
        return
      end
    end
    table_insert(self._luaTickList, InSubView)
  end
  local bNeedTick = self:IsNeedTick()
  if bNeedTick ~= bNeedTickBefore and self.SetTickEnabled then
    self.SetTickEnabled(bNeedTick)
  end
end

function SubViewHelper:IsNeedTick()
  return next(self._luaTickList)
end

function SubViewHelper:AddSubView(subView)
  if nil == subView then
    return
  end
  table_insert(self._subViewList, subView)
  if subView.OnInit then
    table_insert(self._onInitList, subView)
  end
  if subView.OnShow then
    table_insert(self._onShowList, subView)
  end
  if subView.OnPreHide then
    table_insert(self._onPreHideList, subView)
  end
  if subView.OnHide then
    table_insert(self._onHideList, subView)
  end
  if subView.LuaTick then
    table_insert(self._luaTickList, subView)
  end
  if subView.OnDestroy then
    table_insert(self._onDestroyList, subView)
  end
  if "table" == type(subView) then
    rawset(subView, "SetTickEnabled", function(bEnable)
      self:SetSubViewTickEnabled(subView, bEnable)
    end)
  end
end

function SubViewHelper:RemoveSubView(value)
  if nil == value then
    return
  end
  for k, subView in pairs(self._subViewList) do
    if subView == value then
      table_remove(self._subViewList, k)
      break
    end
  end
  for k, subView in pairs(self._onInitList) do
    if subView == value then
      table_remove(self._onInitList, k)
      break
    end
  end
  for k, subView in pairs(self._onShowList) do
    if subView == value then
      table_remove(self._onShowList, k)
      break
    end
  end
  for k, subView in pairs(self._onHideList) do
    if subView == value then
      table_remove(self._onHideList, k)
      break
    end
  end
  for k, subView in pairs(self._onPreHideList) do
    if subView == value then
      table_remove(self._onPreHideList, k)
      break
    end
  end
  for k, subView in pairs(self._luaTickList) do
    if subView == value then
      table_remove(self._luaTickList, k)
      break
    end
  end
  for k, subView in pairs(self._onDestroyList) do
    if subView == value then
      table_remove(self._onDestroyList, k)
      break
    end
  end
  if "table" == type(value) then
    rawset(value, "SetTickEnabled", nil)
  end
end

function SubViewHelper:AddAsyncSubView(targetName, parentView)
  if nil == parentView or nil == parentView.Object then
    return
  end
  if self.parentView and self.parentView ~= parentView then
    UnLua.LogError("AddAsyncSubView Error: parentView is not same")
    return
  end
  self.parentView = parentView
  local subView = parentView[targetName]
  if subView then
    self:AddSubView(subView)
  end
end

function SubViewHelper:RemoveAsyncSubView(targetName, parentView)
  local subView = parentView[targetName]
  if subView then
    parentView[targetName] = nil
    self:RemoveSubView(subView)
  end
end

function SubViewHelper:ClearSubView()
  for k, subView in pairs(self._subViewList) do
    table_remove(self._subViewList, k)
    subView = nil
  end
  self._subViewList = {}
end

function SubViewHelper:CallCustomFunc(funcName, ...)
  for k, subView in pairs(self._subViewList) do
    if subView[funcName] then
      subView[funcName](subView, ...)
    end
  end
end

return SubViewHelper
