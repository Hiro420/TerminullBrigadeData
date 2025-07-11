local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local ViewID = {BattlePassSubView = 0, BattlePassTaskView = 1}
local BattlePassMainViewModel = CreateDefaultViewModel()
function BattlePassMainViewModel:OnInit()
  self.Super.OnInit(self)
  self.SubView = nil
  self:PullBattlePassTaskInfo()
end
function BattlePassMainViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
function BattlePassMainViewModel:Switch(SelectID)
  if SelectID == ViewID.BattlePassSubView then
    self:GetFirstView().WBP_BattlePassSubView:ReOpenSubView()
  end
end
function BattlePassMainViewModel:InitSubView(BattlePassID)
end
function BattlePassMainViewModel:PullBattlePassTaskInfo()
  local JsonTable = {}
  local TBBattlePassTask = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassTask)
  if not TBBattlePassTask then
    return
  end
  for index, value in ipairs(TBBattlePassTask) do
    table.insert(JsonTable, value.TaskGroupID)
  end
  Logic_MainTask.PullTask(JsonTable, false)
end
return BattlePassMainViewModel
