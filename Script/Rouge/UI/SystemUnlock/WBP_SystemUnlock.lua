local WBP_SystemUnlock = UnLua.Class()

function WBP_SystemUnlock:Construct()
  EventSystem.AddListenerNew(EventDef.SystemUnlock.SystemUnlockInit, self, self.OnSystemUnlockInit)
  EventSystem.AddListenerNew(EventDef.SystemUnlock.SystemUnlockUpdate, self, self.OnSystemUnlockUpdate)
  self.Btn_LockTips.OnClicked:Add(self, self.OnBtn_LockTipsClicked)
  self:UpdateSystemUnlock()
end

function WBP_SystemUnlock:InitSysId(SystemId)
  self.SystemId = SystemId or -1
  self:UpdateSystemUnlock()
end

function WBP_SystemUnlock:OnSystemUnlockInit(SystemUnlockInfo)
  if self.SystemId < 0 then
    return
  end
  self:UpdateSystemUnlock()
end

function WBP_SystemUnlock:OnSystemUnlockUpdate(SystemId)
  if SystemId == self.SystemId then
    self:UpdateSystemUnlock()
  end
end

function WBP_SystemUnlock:UpdateSystemUnlock()
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  local systemState = ESystemState.Lock
  if SystemUnlockModule and SystemUnlockModule:CheckIsSystemUnlock(self.SystemId) then
    systemState = ESystemState.UnLock
  elseif self.SystemId < 0 then
    systemState = ESystemState.UnLock
  end
  print("WBP_SystemUnlock:UpdateSystemUnlock", self.SystemId, systemState)
  self.StateCtrl_State:ChangeStatus(systemState)
  local bIsGrayTarget = true
  local rowName = self.DataTableRow.RowName
  local dataRow = UE.UDataTableFunctionLibrary.GetRowDataStructure(self.DataTableRow.DataTable, rowName)
  if dataRow then
    bIsGrayTarget = dataRow.bIsGrayTarget
  end
  if systemState == ESystemState.UnLock then
    self:UpdateTargetWidgetListEnable(true)
    UpdateVisibility(self, false)
  elseif systemState == ESystemState.Lock then
    if bIsGrayTarget then
      self:UpdateTargetWidgetListEnable(false)
    else
      self:UpdateTargetWidgetListEnable(true)
    end
    UpdateVisibility(self, true)
  end
end

function WBP_SystemUnlock:OnBtn_LockTipsClicked()
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSystemUnlock, self.SystemId)
  if not result then
    return
  end
  if CheckNSLocTbIsValid(row.UnlockTips) then
    ShowWaveWindow(1407, {
      row.UnlockTips
    })
  else
    ShowWaveWindow(1401)
  end
end

function WBP_SystemUnlock:Destruct()
  EventSystem.RemoveListenerNew(EventDef.SystemUnlock.SystemUnlockInit, self, self.OnSystemUnlockInit)
  EventSystem.RemoveListenerNew(EventDef.SystemUnlock.SystemUnlockUpdate, self, self.OnSystemUnlockUpdate)
  self.Btn_LockTips.OnClicked:Remove(self, self.OnBtn_LockTipsClicked)
end

return WBP_SystemUnlock
