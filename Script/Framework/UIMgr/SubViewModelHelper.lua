local pairs = pairs
local table = table
local SubViewModelHelper = LuaClass()

function SubViewModelHelper:Ctor()
  self._subViewModelList = {}
end

function SubViewModelHelper:OnInit()
  for k, subViewModel in pairs(self._subViewModelList) do
    subViewModel:OnInit()
  end
end

function SubViewModelHelper:OnShutdown()
  for k, subViewModel in pairs(self._subViewModelList) do
    subViewModel:OnShutdown()
  end
end

function SubViewModelHelper:AddSubViewModel(subViewModel)
  table.insert(self._subViewModelList, subViewModel)
end

function SubViewModelHelper:RemoveSubViewModel(value)
  for k, subViewModel in pairs(self._subViewModelList) do
    if subViewModel == value then
      table.remove(self._subViewModelList, k)
      break
    end
  end
end

function SubViewModelHelper:ClearSubViewModel()
  for k, subViewModel in pairs(self._subViewModelList) do
    table.remove(self._subViewModelList, k)
    subViewModel = nil
  end
  self._subViewModelList = {}
end

return SubViewModelHelper
