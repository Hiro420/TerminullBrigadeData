local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local ContactPersonManager = ModuleManager:Get("ContactPersonModule")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local RapidJson = require("rapidjson")
local RuleTaskViewModel = CreateDefaultViewModel()
RuleTaskViewModel.propertyBindings = {
  BasicInfo = {}
}
RuleTaskViewModel.subViewModels = {}

function RuleTaskViewModel:OnInit()
  self.Super.OnInit(self)
end

function RuleTaskViewModel:InitInfo(ActivityId)
  self.ActivityId = ActivityId
  self:DealWithTable()
end

function RuleTaskViewModel:DealWithTable(...)
  self.MainTaskGroupIdList = {}
  local Result, ActivityRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleTask, self.ActivityId)
  if Result then
    for i, SingleRuleInfoId in ipairs(ActivityRowInfo.ruleInfoList) do
      local BResult, RuleInfoRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleInfo, SingleRuleInfoId)
      if BResult then
        table.insert(self.MainTaskGroupIdList, RuleInfoRowInfo.MainTaskGroupId)
      end
    end
  end
end

function RuleTaskViewModel:GetMainTaskGroupList()
  return self.MainTaskGroupIdList
end

function RuleTaskViewModel:GetAllTaskGroupList()
  local Result, ActivityRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBActivityGeneral, self.ActivityId)
  if Result then
    return ActivityRowInfo.taskGroupList
  end
  return {}
end

function RuleTaskViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

return RuleTaskViewModel
