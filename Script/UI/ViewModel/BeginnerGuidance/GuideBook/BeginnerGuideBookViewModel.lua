local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local BeginnerGuideBookViewModel = CreateDefaultViewModel()
BeginnerGuideBookViewModel.propertyBindings = {
  FinishedGuideList = {}
}

function BeginnerGuideBookViewModel:OnInit()
  self.Super.OnInit(self)
end

function BeginnerGuideBookViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

function BeginnerGuideBookViewModel:CheckGuideFinished(GuideId)
  return BeginnerGuideData:CheckGuideIsFinished(GuideId)
end

return BeginnerGuideBookViewModel
