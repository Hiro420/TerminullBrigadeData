local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local BeginnerGuideHandler = require("Protocol.BeginnerGuide.BeginnerGuideHandler")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local BeginnerGuidanceSystemTipsViewModel = CreateDefaultViewModel()
BeginnerGuidanceSystemTipsViewModel.propertyBindings = {}
local NowNextTriggerEvent = ""
function BeginnerGuidanceSystemTipsViewModel:OnInit()
  self.Super.OnInit(self)
end
function BeginnerGuidanceSystemTipsViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
function BeginnerGuidanceSystemTipsViewModel:SetTargetWidget(Widget)
  local NowGuideStep = BeginnerGuideData:GetNowGuideStep()
  if nil == NowGuideStep then
    print("ywtao,NowGuideStep is nil")
    return
  end
  UIMgr:Show(ViewID.UI_BeginnerGuidanceSystemTips, nil, NowGuideStep, nil)
end
function BeginnerGuidanceSystemTipsViewModel:ChangeNextTriggerEvent(NextTriggerEvent)
  if "" ~= NowNextTriggerEvent then
    EventSystem.RemoveListenerNew(NowNextTriggerEvent, self, self.NextGuideStep)
    NowNextTriggerEvent = ""
  end
  if "" ~= NextTriggerEvent then
    NowNextTriggerEvent = NextTriggerEvent
    EventSystem.AddListenerNew(NowNextTriggerEvent, self, self.NextGuideStep)
  end
end
function BeginnerGuidanceSystemTipsViewModel:NextGuideStep()
  BeginnerGuideData.NowGuideStepId = BeginnerGuideData:GetNextGuideStepId()
  self:ShowNowGuide()
  if BeginnerGuideData.NowGuideId == nil then
    UIMgr:Hide(ViewID.UI_BeginnerGuidanceSystemTips)
    return false
  else
    return true
  end
end
function BeginnerGuidanceSystemTipsViewModel:ShowNowGuide()
  if self:GetFirstView() then
    self:GetFirstView():ResetTargetUI()
  end
  if BeginnerGuideData.NowGuideId == nil then
    print("ywtao,NowGuideId is nil")
  end
  if BeginnerGuideData.NowGuideId ~= nil and nil == BeginnerGuideData.NowGuideStepId then
    self:FinishNowGuide()
    return
  end
  local NowGuideStep = BeginnerGuideData:GetNowGuideStep()
  if nil == NowGuideStep then
    print("ywtao,NowGuideStep is nil")
    return
  end
  if NowGuideStep.uiname == "" then
    print("ywtao,NowGuideStep.uiname is nil")
  end
  BeginnerGuideData.NowTargetWidgetName = NowGuideStep.uiname
  self:ChangeNextTriggerEvent(NowGuideStep.nexttriggerevent)
  self:SetTargetWidget()
end
function BeginnerGuidanceSystemTipsViewModel:ClearNowGuideInfo()
  self:ChangeNextTriggerEvent("")
  BeginnerGuideData.NowGuideId = nil
  BeginnerGuideData.NowGuideStepId = nil
  BeginnerGuideData.NowTargetWidgetName = nil
end
function BeginnerGuidanceSystemTipsViewModel:FinishNowGuide(bIsSkip)
  if not BeginnerGuideData.NowGuideId then
    return
  end
  print("ywtao,NowGuideId" .. BeginnerGuideData.NowGuideId .. " is over")
  ModuleManager:Get("BeginnerGuideModule"):FinishGuide(BeginnerGuideData.NowGuideId, bIsSkip)
  self:ClearNowGuideInfo()
end
return BeginnerGuidanceSystemTipsViewModel
