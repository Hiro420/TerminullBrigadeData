local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local MallGoodsViewModel = CreateDefaultViewModel()

function MallGoodsViewModel:OnInit()
  self.Super.OnInit(self)
end

function MallGoodsViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

function MallGoodsViewModel:GetPosterData()
end
