local RedDotData = {
  RedDotRawList = {},
  RedDotList = {},
  bIsNeedSaveToFile = false
}

function RedDotData:Init()
  self.RedDotList = {}
  self.RedDotRawList = LuaTableMgr.GetLuaTableByName("reddot_tbreddot")
  for k, v in pairs(self.RedDotRawList) do
    self:InitRedDotState(v.Class, v.Class)
  end
  self.bIsNeedSaveToFile = false
end

function RedDotData:CreateRedDotState(RedDotId, RedDotClass)
  if self.RedDotList[RedDotId] then
    return false
  else
    self:InitRedDotState(RedDotId, RedDotClass)
    self.bIsNeedSaveToFile = true
    return true
  end
end

function RedDotData:InitRedDotState(RedDotId, RedDotClass)
  if not self.RedDotRawList[RedDotClass] then
    UnLua.LogError("RedDotData:InitRedDotState, RedDotClass not exist, RedDotClass:" .. tostring(RedDotClass))
    return
  end
  self.RedDotList[RedDotId] = DeepCopy(self.RedDotRawList[RedDotClass]) or {}
  self.RedDotList[RedDotId].Num = 0
  self.RedDotList[RedDotId].StubbornChildList = {}
  self.RedDotList[RedDotId].IsLeaf = true
  self.RedDotList[RedDotId].IsActive = false
  self.RedDotList[RedDotId].RedDotTypePriorityList = {}
  local RedDotTypePriorityClass = "Root"
  if self.RedDotRawList[RedDotClass] and self.RedDotRawList[RedDotClass].RedDotTypePriorityList == {} then
    RedDotTypePriorityClass = RedDotClass
  end
  for _, RedDotType in pairs(self.RedDotRawList[RedDotTypePriorityClass].RedDotTypePriorityList) do
    self.RedDotList[RedDotId].RedDotTypePriorityList[RedDotType] = _
  end
end

function RedDotData:GetRedDotState(RedDotId)
  if not self.RedDotList[RedDotId] then
    print("RedDotData:GetRedDotState, RedDotId not exist, RedDotId:" .. RedDotId)
    return
  end
  return self.RedDotList[RedDotId]
end

function RedDotData:UpdateRedDotState(RedDotId, NewState, ChildRedDotId, IsChildRedDotShowToHide)
  local OldState = {
    ParentIdList = self.RedDotList[RedDotId].ParentIdList,
    IsActive = self.RedDotList[RedDotId].IsActive,
    Num = self.RedDotList[RedDotId].Num
  }
  local NowRedDotState = self.RedDotList[RedDotId]
  if not NowRedDotState then
    print("RedDotData:UpdateRedDotState, RedDotId not exist, RedDotId:" .. RedDotId)
    return
  end
  if NewState.Num == nil then
    NewState.Num = NowRedDotState.Num
  end
  local NumChange = NewState.Num - NowRedDotState.Num
  for k, v in pairs(NewState) do
    NowRedDotState[k] = v
  end
  if ChildRedDotId then
    local ChildRedDot = self.RedDotList[ChildRedDotId]
    if ChildRedDot.IsActive then
      if ChildRedDot.IsStubborn and not table.Contain(NowRedDotState.StubbornChildList, ChildRedDotId) then
        table.insert(NowRedDotState.StubbornChildList, ChildRedDotId)
      end
    elseif not ChildRedDot.IsActive and ChildRedDot.IsStubborn then
      table.RemoveItem(NowRedDotState.StubbornChildList, ChildRedDotId)
    end
    if table.Contain(NowRedDotState.StubbornChildList, ChildRedDotId) and not table.Contain(ChildRedDot.ParentIdList, RedDotId) then
      table.RemoveItem(NowRedDotState.StubbornChildList, ChildRedDotId)
    end
  end
  if NumChange > 0 then
    NowRedDotState.IsActive = true
  elseif 0 == NowRedDotState.Num then
    NowRedDotState.IsActive = false
  elseif not NowRedDotState.IsLeaf and (NumChange < 0 or IsChildRedDotShowToHide) and 0 == #NowRedDotState.StubbornChildList then
    NowRedDotState.IsActive = false
  end
  local IsShowToHide = OldState.IsActive and not NowRedDotState.IsActive
  if self:GetRedDotRawDef(NowRedDotState.Class).RedDotType == "" then
    local ChildRedDotIdList = self:GetRedDotIdListByParentId(RedDotId)
    local HighestPriorityRedDotType = ""
    for k, v in pairs(ChildRedDotIdList) do
      local ChildRedDot = self.RedDotList[v]
      if ChildRedDot and ChildRedDot.IsActive then
        if "" == HighestPriorityRedDotType then
          HighestPriorityRedDotType = ChildRedDot.RedDotType
        elseif ChildRedDot.RedDotType ~= "" and NowRedDotState.RedDotTypePriorityList[ChildRedDot.RedDotType] < NowRedDotState.RedDotTypePriorityList[HighestPriorityRedDotType] then
          HighestPriorityRedDotType = ChildRedDot.RedDotType
        end
      end
    end
    NowRedDotState.RedDotType = HighestPriorityRedDotType
  end
  EventSystem.Invoke(EventDef.RedDot.OnRedDotStateChanged, RedDotId)
  local ParentIdList = self.RedDotList[RedDotId].ParentIdList
  for _, ParentId in pairs(ParentIdList) do
    if "" ~= ParentId and self.RedDotList[ParentId] then
      local NewParentState = {}
      if self.RedDotList[ParentId].IsLeaf then
        NewParentState.IsLeaf = false
      end
      if table.Contain(OldState.ParentIdList, ParentId) then
        if 0 ~= NumChange then
          NewParentState.Num = self.RedDotList[ParentId].Num + NumChange
        end
      else
        NewParentState.Num = self.RedDotList[ParentId].Num + NowRedDotState.Num
      end
      if table.count(NewParentState) > 0 or IsShowToHide then
        self:UpdateRedDotState(ParentId, NewParentState, RedDotId, IsShowToHide)
        self.bIsNeedSaveToFile = true
      end
    end
  end
  for _, ParentId in pairs(OldState.ParentIdList) do
    if "" ~= ParentId and not table.Contain(ParentIdList, ParentId) then
      local NewParentState = {}
      NewParentState.Num = self.RedDotList[ParentId].Num - OldState.Num
      self:UpdateRedDotState(ParentId, NewParentState, RedDotId)
    end
  end
end

function RedDotData:ChangeRedDotNum(RedDotId, delta)
  if not self.RedDotList[RedDotId] then
    UnLua.LogWarn("RedDotData:ChangeRedDotNum, RedDotId not exist, RedDotId:" .. RedDotId)
    return
  end
  self:SetRedDotNum(RedDotId, math.max(0, self.RedDotList[RedDotId].Num + delta))
end

function RedDotData:SetRedDotNum(RedDotId, Num)
  if not self.RedDotList[RedDotId] then
    UnLua.LogWarn("RedDotData:SetRedDotNum, RedDotId not exist, RedDotId:" .. RedDotId)
    return
  end
  if self.RedDotList[RedDotId].Num == Num then
    return
  end
  self:UpdateRedDotState(RedDotId, {Num = Num})
end

function RedDotData:GetRedDotIdListByClass(RedDotClass)
  local RedDotIdList = {}
  for k, v in pairs(self.RedDotList) do
    if v.Class == RedDotClass then
      table.insert(RedDotIdList, k)
    end
  end
  return RedDotIdList
end

function RedDotData:GetRedDotIdListByParentId(ParentId)
  local RedDotIdList = {}
  for k, v in pairs(self.RedDotList) do
    if table.Contain(v.ParentIdList, ParentId) then
      table.insert(RedDotIdList, k)
    end
  end
  return RedDotIdList
end

function RedDotData:GetRedDotRawDef(Class)
  if not self.RedDotRawList[Class] then
    print("RedDotData:GetRedDotRawDef, RedDotId not exist, RedDotId:" .. Class)
    return
  end
  return self.RedDotRawList[Class]
end

function RedDotData:SetRedDotActive(RedDotId, IsActive)
  if not self.RedDotList[RedDotId] then
    UnLua.LogWarn("RedDotData:SetRedDotNum, RedDotId not exist, RedDotId:" .. RedDotId)
    return
  end
  if self.RedDotList[RedDotId].IsActive == IsActive then
    return
  end
  self:UpdateRedDotState(RedDotId, {IsActive = IsActive})
end

function RedDotData:DeleteRedDotState(RedDotId)
  if not self.RedDotList[RedDotId] then
    print("RedDotData:DeleteRedDotState fail! RedDotId not exist, RedDotId:" .. RedDotId)
    return
  end
  local ChildRedDotIdList = self:GetRedDotIdListByParentId(RedDotId)
  if #ChildRedDotIdList > 0 then
    print("RedDotData:DeleteRedDotState fail! ChildRedDotIdList exist, RedDotId:" .. RedDotId)
    return
  end
  for _, ParentId in pairs(self.RedDotList[RedDotId].ParentIdList) do
    if "" ~= ParentId then
      local NewParentState = {}
      NewParentState.Num = self.RedDotList[ParentId].Num - self.RedDotList[RedDotId].Num
      self:UpdateRedDotState(ParentId, NewParentState, RedDotId)
    end
  end
  table.RemoveItem(self.RedDotList, RedDotId)
end

return RedDotData
