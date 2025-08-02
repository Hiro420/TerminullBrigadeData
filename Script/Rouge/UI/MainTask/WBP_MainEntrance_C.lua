local WBP_MainEntrance_C = UnLua.Class()

function WBP_MainEntrance_C:Construct()
  self.Btn_Activity.OnClicked:Add(self, self.OnBtnActivityClicked)
  self.Btn_Main.OnClicked:Add(self, self.OnBtnMainTaskClicked)
  EventSystem.AddListener(self, EventDef.MainTask.OnMainTaskRefres, WBP_MainEntrance_C.OnMainTaskRefres)
  self:OnMainTaskRefres()
end

function WBP_MainEntrance_C:Destruct()
  self.Btn_Activity.OnClicked:Remove(self, self.OnBtnActivityClicked)
  self.Btn_Main.OnClicked:Remove(self, self.OnBtnMainTaskClicked)
  EventSystem.RemoveListener(EventDef.MainTask.OnMainTaskRefres, WBP_MainEntrance_C.OnMainTaskRefres, self)
end

function WBP_MainEntrance_C:OnBtnMainTaskClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.TASK) then
    return
  end
  local ActiveGroups = Logic_MainTask.GetAllMainTaskGroupIds()
  if nil ~= ActiveGroups and #ActiveGroups > 0 then
    UIMgr:Show(ViewID.UI_MainTaskDetail, true, ActiveGroups[1])
  end
end

function WBP_MainEntrance_C:OnBtnActivityClicked()
  UIMgr:Show(ViewID.UI_ActivityPanel, true)
end

function WBP_MainEntrance_C:OnMainTaskRefres()
  local ActiveGroups = Logic_MainTask.GetActiveGroups()
  local bHaveReceiveAward = false
  local TaskGroupData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  local TaskData = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  for index, GroupsId in ipairs(ActiveGroups) do
    local ActiveTask = Logic_MainTask.GetGroupActiveTask(GroupsId)
    local TsakId = ActiveTask.taskID
    if 2 == ActiveTask.state and Logic_MainTask.HaveReceiveAward(tonumber(ActiveTask.taskID)) then
      bHaveReceiveAward = true
    end
  end
  UpdateVisibility(self.RedDot_Overlay, bHaveReceiveAward)
end

return WBP_MainEntrance_C
