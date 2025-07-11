local PrivilegeData = {
  PrivilegeRoleInfo = {}
}
local TopupData = require("Modules.Topup.TopupData")
function PrivilegeData:SetRolePrivilegeInfo(PrivilegeInfo)
  for RoleId, Privileges in pairs(PrivilegeInfo) do
    local PrivilegeInfoList = {}
    for PrivilegeId, PrivilegeInfo in pairs(Privileges.privileges) do
      PrivilegeInfoList[PrivilegeId] = PrivilegeInfo
    end
    PrivilegeData.PrivilegeRoleInfo[RoleId] = PrivilegeInfoList
  end
end
function PrivilegeData:GetRolePrivilegeInfo(RoleId)
  for PrivilegeRoleId, PrivilegeInfo in pairs(PrivilegeData.PrivilegeRoleInfo) do
    if PrivilegeRoleId == RoleId then
      return PrivilegeInfo
    end
  end
end
function PrivilegeData:GetResIdByPrivilegeId(PrivilegeId)
  local PrivilegeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBResPrivilege)
  if PrivilegeTable then
    for ResId, PrivilegeInfo in pairs(PrivilegeTable) do
      if PrivilegeInfo.PrivilegeID == tonumber(PrivilegeId) then
        return ResId
      end
    end
  end
  return 0
end
function PrivilegeData:GetPrivilegeIsShow(PrivilegeId)
  local PrivilegeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBResPrivilege)
  if PrivilegeTable then
    for ResId, PrivilegeInfo in pairs(PrivilegeTable) do
      if PrivilegeInfo.PrivilegeID == tonumber(PrivilegeId) then
        return PrivilegeInfo.isShow
      end
    end
  end
  return false
end
function PrivilegeData:GetMaxPrivilegeQuality()
  local MonthCardTable = LuaTableMgr.GetLuaTableByName(TableNames.TBMonthCardRights)
  local CurTime = GetLocalTimestampByServerTimeZone()
  local MaxQuality = 0
  if MonthCardTable then
    for PrivilegeId, PrivilegeInfo in pairs(PrivilegeData.PrivilegeRoleInfo[DataMgr.GetUserId()]) do
      local PrivilegeRowInfo = MonthCardTable[tonumber(PrivilegeId)]
      if PrivilegeRowInfo.Type == TableEnums.ENUNPrivilegeType.NORMALPRIVILEGE and CurTime < tonumber(PrivilegeInfo.expireTime) and MaxQuality < PrivilegeRowInfo.Quality then
        MaxQuality = PrivilegeRowInfo.Quality
      end
    end
  end
  return MaxQuality
end
return PrivilegeData
