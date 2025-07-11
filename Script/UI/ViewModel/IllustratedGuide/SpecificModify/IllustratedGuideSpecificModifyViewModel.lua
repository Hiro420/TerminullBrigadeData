local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local IllustratedGuideSpecificModifyViewModel = CreateDefaultViewModel()
IllustratedGuideSpecificModifyViewModel.propertyBindings = {}
IllustratedGuideSpecificModifyViewModel.subViewModels = {}
local OwnedSpecificModifyList = {}
function IllustratedGuideSpecificModifyViewModel:OnInit()
  self.Super.OnInit(self)
end
function IllustratedGuideSpecificModifyViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
function IllustratedGuideSpecificModifyViewModel:GetOwnedSpecificModifyList()
  return OwnedSpecificModifyList
end
function IllustratedGuideSpecificModifyViewModel:CheckOwnedSpecificModify(SpecificModifyId)
  return table.Contain(OwnedSpecificModifyList, tostring(SpecificModifyId))
end
function IllustratedGuideSpecificModifyViewModel:SetOwnedSpecificModifyList(_OwnedSpecificModifyList)
  OwnedSpecificModifyList = _OwnedSpecificModifyList
end
return IllustratedGuideSpecificModifyViewModel
