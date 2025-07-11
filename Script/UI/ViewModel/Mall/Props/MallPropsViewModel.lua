local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local MallPropsViewModel = CreateDefaultViewModel()
function MallPropsViewModel:OnInit()
  self.Super.OnInit(self)
end
function MallPropsViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
function MallPropsViewModel:GetMallInfo()
  if self:GetFirstView() and self:GetFirstView().ShelfIndex and 0 ~= self:GetFirstView().ShelfIndex then
    Logic_Mall.PushPropsInfo(true, self:GetFirstView().ShelfIndex)
  end
end
return MallPropsViewModel
