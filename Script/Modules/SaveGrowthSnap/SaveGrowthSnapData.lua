local SaveGrowthSnapData = {
  SaveGrowthSnapMap = {},
  CurSelectPos = 0,
  SnapshotStaging = {},
  SlotToSnapDataMap = {},
  CurSelectTogglePos = 0,
  SaveGrowthSnapTipNoUseTimes = {},
  bAutoSave = true
}
function SaveGrowthSnapData:DealWithTable()
end
function SaveGrowthSnapData:GetGenericModifyDataBySlot(Slot, Pos)
  if not self.SaveGrowthSnapMap[Pos] then
    return nil
  end
  if not self.SlotToSnapDataMap[Pos] then
    self.SlotToSnapDataMap[Pos] = {}
    for i = 1, i <= #self.SaveGrowthSnapMap[Pos], 2 do
      local genericId = self.SaveGrowthSnapMap[Pos][i]
      local result, genericRow = GetRowData(DT.DT_GenericModify, genericId)
      if result and genericRow.Slot ~= UE.ERGGenericModifySlot.None then
        local level = self.SaveGrowthSnapMap[Pos][i + 1]
        self.SlotToSnapDataMap[Pos][Slot] = {ModifyId = genericId, Level = level}
      end
    end
  end
  if self.SlotToSnapDataMap[Pos][Slot] then
    return self.SlotToSnapDataMap[Pos][Slot]
  end
  return nil
end
function SaveGrowthSnapData:CheckIsEmpty(Pos)
  if not self.SaveGrowthSnapMap[Pos] then
    return true
  end
  if self.SaveGrowthSnapMap[Pos].SnapshotStagingTime == "0" or not self.SaveGrowthSnapMap[Pos].SnapshotStagingTime then
    return true
  end
  return false
end
function SaveGrowthSnapData:CheckSnapMapIsEmpty()
  if not self.SaveGrowthSnapMap then
    return true
  end
  for k, v in pairs(self.SaveGrowthSnapMap) do
    if not self:CheckIsEmpty(k) then
      return false
    end
  end
  return true
end
function SaveGrowthSnapData:FindEmptyPos()
  if not self.SaveGrowthSnapMap or not self.SaveGrowthSnapMap[0] then
    return 0
  end
  for i = 0, #self.SaveGrowthSnapMap do
    if self:CheckIsEmpty(i) then
      return i
    end
  end
  return -1
end
function SaveGrowthSnapData:FindEarliestSave()
  local EarliestTimeStamp = math.huge
  local EarliestPos = -1
  for k, v in pairs(self.SaveGrowthSnapMap) do
    if not self:CheckIsEmpty(k) then
      local TimeStamp = tonumber(v.SnapshotStagingTime)
      if TimeStamp and EarliestTimeStamp > TimeStamp then
        EarliestTimeStamp = TimeStamp
        EarliestPos = k
      end
    end
  end
  return EarliestPos, EarliestTimeStamp
end
function SaveGrowthSnapData:GetGrowthSnapUseLimitNum()
  return GetLuaConstValueByKey("GrowthSnapshotUseLimitNum") or 0
end
function SaveGrowthSnapData:GetGrowthSnapUseLeftNum(UseTimesParam)
  local UseTimes = UseTimesParam or 0
  local limitNum = self:GetGrowthSnapUseLimitNum()
  if 0 == limitNum then
    return 0
  end
  if limitNum < 0 then
    return -1
  end
  local leftNum = limitNum - UseTimes
  if leftNum < 0 then
    leftNum = 0
  end
  return leftNum
end
function SaveGrowthSnapData:ResetSnapData(SnapData)
  if not SnapData then
    return
  end
  SnapData.SnapshotStagingTime = "0"
end
return SaveGrowthSnapData
