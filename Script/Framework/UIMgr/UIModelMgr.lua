local ERGTimerType = UE.ERGTimerType
local UnLua = _G.UnLua
local GlobalTimer = _G.GlobalTimer
local UIModelDef = require("UI.UIModelDef")
local InstantiateViewModel = _G.InstantiateViewModel
local UIModelMgr = {
  allViewModels = {}
}
local ErrorFunc = function(err)
  UnLua.LogError("UIModelMgr ErrorFunc:", err)
end

function UIModelMgr:Init()
  if self.bInited then
    return
  end
  self.bInited = true
  self.allViewModels = {}
  self.pendingBatchNotifications = {}
  self.allTickViewModels = {}
  if self.timerKey then
    GlobalTimer.DeleteTickTimer(self.timerKey)
  end
  self.timerKey = GlobalTimer.AddTickTimer(function(deltaTime)
    self:Tick(deltaTime)
    return true
  end, 0)
  self:RegisterAllViewModels()
end

function UIModelMgr:Shutdown()
  self:Tick()
  GlobalTimer.DeleteTickTimer(self.timerKey)
  self:UnRegisterAllViewModels()
end

function UIModelMgr:ClearDirtyViewModel()
  UIMgr:ClearAllViews()
  if nil ~= UIModelDef then
    for k, v in ipairs(UIModelDef) do
      local targetViewModel = self.allViewModels[v.name]
      if nil ~= targetViewModel then
        xpcall(function()
          targetViewModel:OnShutdown()
        end, ErrorFunc)
        self.allViewModels[v.name] = nil
        if targetViewModel.Tick then
          self.allTickViewModels[v.name] = nil
        end
      end
      local newViewModel
      xpcall(function()
        newViewModel = InstantiateViewModel(require(v.Path))
        newViewModel:OnInit()
      end, ErrorFunc)
      self.allViewModels[v.name] = newViewModel
      if newViewModel and newViewModel.Tick then
        self.allTickViewModels[v.name] = newViewModel
      end
    end
  end
end

function UIModelMgr:OnClear()
  for _, v in pairs(self.allViewModels) do
    v:OnClear()
  end
end

function UIModelMgr:Tick(deltaTime)
  for k, v in pairs(self.allTickViewModels) do
    if v then
      v:Tick(deltaTime)
    end
  end
  for viewModel, v in pairs(self.pendingBatchNotifications) do
    viewModel:BatchNotify()
    self.pendingBatchNotifications[viewModel] = nil
  end
end

function UIModelMgr:AddBatchNotifications(viewModel)
  self.pendingBatchNotifications[viewModel] = true
end

function UIModelMgr:RemoveBatchNotifications(viewModel)
  self.pendingBatchNotifications[viewModel] = nil
end

function UIModelMgr:RegisterAllViewModels()
  self.allTickViewModels = {}
  if nil ~= UIModelDef then
    for k, v in pairs(UIModelDef) do
      local newViewModel
      xpcall(function()
        newViewModel = InstantiateViewModel(require(v.Path))
        newViewModel:OnInit()
      end, ErrorFunc)
      self.allViewModels[v.name] = newViewModel
      if newViewModel and newViewModel.Tick then
        self.allTickViewModels[v.name] = newViewModel
      end
    end
  end
end

function UIModelMgr:UnRegisterAllViewModels()
  for k, v in pairs(self.allViewModels) do
    v:OnShutdown()
  end
  self.allViewModels = {}
  self.allTickViewModels = {}
end

function UIModelMgr:Get(viewname)
  if self.allViewModels == nil then
    return nil
  end
  return self.allViewModels[viewname]
end

function UIModelMgr:UnRegisterAllPropertyChanged()
  for k, v in pairs(self.allViewModels) do
    v:UnRegisterAllPropertyChanged()
  end
end

_G.UIModelMgr = _G.UIModelMgr or UIModelMgr
