local BeginnerGuideData = {
  WBPMap = {__mode = "v"},
  WidgetMap = {__mode = "v"},
  FinishedGuideList = {},
  GuideList = {},
  GuideStepList = {},
  NowGuideId = nil,
  NowGuideStepId = nil,
  NowTargetWidgetName = "",
  FreshmanBDFinished = true
}
function BeginnerGuideData:ResetData()
  self.WBPMap = {__mode = "v"}
  self.WidgetMap = {__mode = "v"}
  self.FinishedGuideList = {}
  self.GuideList = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)
  self.GuideStepList = LuaTableMgr.GetLuaTableByName(TableNames.TBGuideStep)
  self.NowGuideId = nil
  self.NowGuideStepId = nil
  self.NowTargetWidgetName = ""
  self.FreshmanBDFinished = true
end
function BeginnerGuideData:FinishedGuide(GuideId)
  table.insert(BeginnerGuideData.FinishedGuideList, {guideID = GuideId, finishedTimes = 1})
end
function BeginnerGuideData:CheckGuideIsFinished(GuideId)
  for k, v in pairs(BeginnerGuideData.FinishedGuideList) do
    if v.guideID == GuideId and v.finishedTimes >= 1 then
      return true
    end
  end
  return false
end
function BeginnerGuideData:CheckFreshmanBDIsFinished()
  return BeginnerGuideData.FreshmanBDFinished
end
function BeginnerGuideData:UpdateWBP(WBPName, WBP)
  BeginnerGuideData.WBPMap[WBPName] = WBP
end
function BeginnerGuideData:GetWBP(WBPName)
  if BeginnerGuideData.WBPMap[WBPName] then
    return BeginnerGuideData.WBPMap[WBPName]
  else
    print(WBPName .. " don't find")
    return nil
  end
end
function BeginnerGuideData:UpdateWidget(WidgetName, Widget)
  BeginnerGuideData.WidgetMap[WidgetName] = Widget
end
function BeginnerGuideData:GetWidget(WBPName, WidgetName)
  if WBPName and BeginnerGuideData.WBPMap[WBPName] then
    if BeginnerGuideData.WBPMap[WBPName][WidgetName] then
      return BeginnerGuideData.WBPMap[WBPName][WidgetName]
    else
      print("WBP don't find" .. WidgetName)
    end
  end
  if BeginnerGuideData.WidgetMap[WidgetName] then
    return BeginnerGuideData.WidgetMap[WidgetName]
  else
    print(WidgetName .. " don't find")
    return nil
  end
end
function BeginnerGuideData:GetNowGuide()
  if BeginnerGuideData.NowGuideId == nil then
    print("ywtao,NowGuideId is nil")
    return nil
  end
  return BeginnerGuideData.GuideList[BeginnerGuideData.NowGuideId]
end
function BeginnerGuideData:GetNowGuideStep()
  if BeginnerGuideData.NowGuideStepId == nil then
    print("ywtao,NowGuideStepId is nil")
    return nil
  end
  return BeginnerGuideData.GuideStepList[BeginnerGuideData.NowGuideStepId]
end
function BeginnerGuideData:GetNextGuideStepId()
  if BeginnerGuideData.NowGuideId == nil or nil == BeginnerGuideData.NowGuideStepId then
    print("ywtao,NowGuideId or NowGuideStepId is nil")
    return nil
  end
  local NextGuideStepId
  for k, v in pairs(BeginnerGuideData.GuideList[BeginnerGuideData.NowGuideId].guidelist) do
    if v == BeginnerGuideData.NowGuideStepId then
      NextGuideStepId = BeginnerGuideData.GuideList[BeginnerGuideData.NowGuideId].guidelist[k + 1]
      break
    end
  end
  if nil == NextGuideStepId then
    print("ywtao,NextGuideStepId is nil")
    return nil
  end
  return NextGuideStepId
end
function BeginnerGuideData:GetGuideBookActiveItemList()
  local TotalGuideTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)
  local GuideBookActiveItemList = {}
  for k, GuideInfo in pairs(TotalGuideTable) do
    if 1 == GuideInfo.intohandbook and (self:CheckGuideIsFinished(GuideInfo.id) or 4 == GuideInfo.guidetype) then
      table.insert(GuideBookActiveItemList, GuideInfo)
    end
  end
  return GuideBookActiveItemList
end
return BeginnerGuideData
