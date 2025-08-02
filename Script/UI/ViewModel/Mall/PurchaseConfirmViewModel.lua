local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local PurchaseConfirmViewModel = CreateDefaultViewModel()

function PurchaseConfirmViewModel:OnInit()
  self.Super.OnInit(self)
end

function PurchaseConfirmViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

return PurchaseConfirmViewModel
