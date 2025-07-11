local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local LoginRewardActivityViewModel = CreateDefaultViewModel()
LoginRewardActivityViewModel.propertyBindings = {
  LoginTaskIdList = {}
}
function LoginRewardActivityViewModel:OnInit()
  self.Super.OnInit(self)
end
function LoginRewardActivityViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
function LoginRewardActivityViewModel:UpdateActivityId(ActivityId)
  local tbActivity = LuaTableMgr.GetLuaTableByName(TableNames.TBActivityGeneral)
  if not ActivityId or not tbActivity[ActivityId] then
    return
  end
  local activityRowInfo = tbActivity[ActivityId]
  local taskgroupId = activityRowInfo.taskGroupList[1]
  local tbTaskGroupData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  if not taskgroupId or not tbTaskGroupData[taskgroupId] then
    return
  end
  self.TaskGroupId = taskgroupId
  local taskGroupData = tbTaskGroupData[taskgroupId]
  self.LoginTaskIdList = taskGroupData.tasklist
end
return LoginRewardActivityViewModel
