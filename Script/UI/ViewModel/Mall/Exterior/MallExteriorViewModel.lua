local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local MallExteriorViewModel = CreateDefaultViewModel()
function MallExteriorViewModel:OnInit()
  self.Super.OnInit(self)
end
function MallExteriorViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
function MallExteriorViewModel:GetMallInfo()
end
return MallExteriorViewModel
