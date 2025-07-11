local ESystemState = {Lock = 0, UnLock = 1}
_G.ESystemState = _G.ESystemState or ESystemState
local SystemUnlockData = {
  SystemUnlockInfo = {},
  ViewNameToSysId = {}
}
function SystemUnlockData:DealWithTable()
  local tbSystemUnlock = LuaTableMgr.GetLuaTableByName(TableNames.TBSystemUnlock)
  if tbSystemUnlock then
    for k, v in pairs(tbSystemUnlock) do
      for i, vViewName in ipairs(v.ViewNameList) do
        self.ViewNameToSysId[vViewName] = v.SystemID
      end
      if not self.SystemUnlockInfo[v.SystemID] then
        self.SystemUnlockInfo[v.SystemID] = ESystemState.Lock
      end
    end
  end
end
function SystemUnlockData:ResetWhenLogin()
  self.SystemUnlockInfo = {}
end
function SystemUnlockData:GetViewNameListBySysId(SysId)
  local tbSystemUnlock = LuaTableMgr.GetLuaTableByName(TableNames.TBSystemUnlock)
  if tbSystemUnlock then
    for k, v in pairs(tbSystemUnlock) do
      if v.SystemID == SysId then
        return v.ViewNameList
      end
    end
  end
  return {}
end
function SystemUnlockData:GetSysIdByViewName(ViewName)
  if table.IsEmpty(self.ViewNameToSysId) then
    self:DealWithTable()
  end
  if ViewName and self.ViewNameToSysId[ViewName] then
    return self.ViewNameToSysId[ViewName]
  end
  return -1
end
return SystemUnlockData
