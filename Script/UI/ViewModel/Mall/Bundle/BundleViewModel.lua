local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local BundleViewModel = CreateDefaultViewModel()

function BundleViewModel:OnInit()
  self.Super.OnInit(self)
end

function BundleViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

function BundleViewModel:GetMallInfo()
end

return BundleViewModel
