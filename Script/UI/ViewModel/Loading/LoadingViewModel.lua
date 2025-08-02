local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local AppearanceData = require("Modules.Appearance.AppearanceData")
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local LoadingViewModel = CreateDefaultViewModel()
LoadingViewModel.propertyBindings = {}
LoadingViewModel.subViewModels = {}

function LoadingViewModel:OnInit()
  self.Super.OnInit(self)
  local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
  if RGHttpClientMgr then
    RGHttpClientMgr.OnHttpShowLoadingDelegate:Bind(GameInstance, self.OnShowLoading)
    RGHttpClientMgr.OnHttpHideLoadingDelegate:Bind(GameInstance, self.OnHideLoading)
  end
end

function LoadingViewModel:OnShutdown()
  local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
  if RGHttpClientMgr then
    RGHttpClientMgr.OnHttpShowLoadingDelegate:Unbind(GameInstance, self.OnShowLoading)
    RGHttpClientMgr.OnHttpHideLoadingDelegate:Unbind(GameInstance, self.OnHideLoading)
  end
  self.Super.OnShutdown(self)
end

function LoadingViewModel:RegisterPropertyChanged(BindingTable, View)
  self.Super.RegisterPropertyChanged(self, BindingTable, View)
end

function LoadingViewModel:OnShowLoading(HttpRequestId)
  local loadingVM = UIModelMgr:Get("LoadingViewModel")
  if not loadingVM then
    return
  end
  if not loadingVM.RequestIdDic then
    loadingVM.RequestIdDic = {}
  end
  loadingVM.RequestIdDic[HttpRequestId] = true
  if loadingVM:GetFirstView() then
    loadingVM:GetFirstView():Refresh()
  else
    UIMgr:Show(ViewID.UI_HttpRequestLoadingView)
  end
end

function LoadingViewModel:OnHideLoading(HttpRequestId)
  local loadingVM = UIModelMgr:Get("LoadingViewModel")
  if not loadingVM then
    return
  end
  if not loadingVM.RequestIdDic then
    loadingVM.RequestIdDic = {}
  end
  loadingVM.RequestIdDic[HttpRequestId] = nil
  if loadingVM:GetFirstView() and loadingVM:CheckNeedHideLoading() then
    UIMgr:Hide(ViewID.UI_HttpRequestLoadingView)
  end
end

function LoadingViewModel:CheckNeedHideLoading()
  for i, v in pairs(self.RequestIdDic) do
    if v then
      return false
    end
  end
  return true
end

function LoadingViewModel:ClearRequestIdDic()
  self.RequestIdDic = {}
end

return LoadingViewModel
