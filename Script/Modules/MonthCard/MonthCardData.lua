local MonthCardData = {
  MonthCardRoleInfo = {},
  MaxMonthCardNum = 6,
  MonthCardResourceInfo = {},
  MonthCardProductIdList = {},
  MonthCardPackId = 0
}
local TopupData = require("Modules.Topup.TopupData")
function MonthCardData:DealWithTable(...)
  local MonthCardResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBMonthCard)
  for ResourceId, RowInfo in pairs(MonthCardResourceTable) do
    MonthCardData.MonthCardResourceInfo[RowInfo.MonthCardID] = RowInfo
  end
  MonthCardData.MonthCardPackId = 0
  MonthCardData.MonthCardProductIdList = {}
  local AllProductIds = TopupData:GetProductIdListByShelfId(101)
  local Num = 0
  for i, SingleProductId in ipairs(AllProductIds) do
    local Result, PaymentRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPaymentMall, SingleProductId)
    if Result then
      local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, tonumber(PaymentRowInfo.MidasGoodsID))
      if Result then
        if ResourceRowInfo.Type == TableEnums.ENUMResourceType.Gift then
          MonthCardData.MonthCardPackId = PaymentRowInfo.ID
        elseif ResourceRowInfo.Type == TableEnums.ENUMResourceType.MonthCard then
          Num = Num + 1
          table.insert(MonthCardData.MonthCardProductIdList, SingleProductId)
        end
      end
    end
  end
  MonthCardData.MaxMonthCardNum = Num
end
function MonthCardData:GetMonthCardProductIdList()
  return MonthCardData.MonthCardProductIdList
end
function MonthCardData:GetMonthCardPackId()
  return MonthCardData.MonthCardPackId
end
function MonthCardData:GetMaxMonthCardNum()
  return MonthCardData.MaxMonthCardNum
end
function MonthCardData:SetRoleMonthCardInfo(RoleId, InMonthCardInfo)
  MonthCardData.MonthCardRoleInfo[RoleId] = {
    MonthCardInfo = InMonthCardInfo,
    SetTime = GetCurrentUTCTimestamp()
  }
end
function MonthCardData:GetMonthCardInfoByRoleId(InRoleId)
  return MonthCardData.MonthCardRoleInfo[InRoleId] and MonthCardData.MonthCardRoleInfo[InRoleId].MonthCardInfo
end
function MonthCardData:HasValidMonthCardInfo(InRoleId)
  local TargetMonthCardRoleInfo = MonthCardData.MonthCardRoleInfo[InRoleId]
  if TargetMonthCardRoleInfo and GetCurrentUTCTimestamp() - TargetMonthCardRoleInfo.SetTime <= 300 then
    return true
  end
  return false
end
function MonthCardData:IsMonthCardExpired(InRoleId, MonthCardID)
  local MonthCardInfo = MonthCardData:GetMonthCardInfoByRoleId(InRoleId)
  if MonthCardInfo then
    local EndTime = MonthCardInfo[tostring(MonthCardID)] and tonumber(MonthCardInfo[tostring(MonthCardID)])
    if EndTime then
      local CurTime = GetLocalTimestampByServerTimeZone()
      return EndTime < CurTime
    end
  end
  return true
end
function MonthCardData:GetMonthCardResourceId(MonthCardID)
  return MonthCardData.MonthCardResourceInfo[tonumber(MonthCardID)] and MonthCardData.MonthCardResourceInfo[tonumber(MonthCardID)].ID or 0
end
return MonthCardData
