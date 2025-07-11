local RechargeData = {
  LocalSaveData = {MonthRechargeTimestamp = nil, CurRechargeTimestamp = 0}
}
function RechargeData.GetMonthRechargeTimestamp()
  return RechargeData.LocalSaveData.MonthRechargeTimestamp
end
function RechargeData.SetMonthRechargeTimestamp(Timestamp)
  RechargeData.LocalSaveData.MonthRechargeTimestamp = Timestamp
end
function RechargeData.GetCurRechargeTimestamp()
  return RechargeData.LocalSaveData.CurRechargeTimestamp + os.time()
end
function RechargeData.SetCurRechargeTimestamp(Timestamp)
  RechargeData.LocalSaveData.CurRechargeTimestamp = Timestamp
end
return RechargeData
