local ProrityQueuePairs = function(tb)
  local k, v
  return function()
    repeat
      k, v = next(tb.elements, k)
    until v or not v
    return k, v
  end
end
local ProrityQueue = {
  __newindex = function(tb, k, v)
    if not tb.elements then
      tb.elements = {}
    end
    tb.elements[k] = v
  end,
  __pairs = ProrityQueuePairs,
  PairsFunc = ProrityQueuePairs,
  __len = function(tb)
    return #tb.elements
  end,
  __ContainerName = "ProrityQueue"
}
function ProrityQueue.__index(tb, k)
  if tb.elements and tb.elements[k] then
    return tb.elements[k]
  end
  return ProrityQueue[k]
end
function ProrityQueue.New(tb, SortFunc)
  local obj = {
    elements = {}
  }
  if tb then
    for i, v in ipairs(tb) do
      obj.elements[i] = v
    end
  end
  obj.SortFunc = SortFunc
  if SortFunc then
    table.sort(obj.elements, SortFunc)
  end
  setmetatable(obj, ProrityQueue)
  return obj
end
function ProrityQueue:Enqueue(value, SortFunc)
  table.insert(self.elements, value)
  if SortFunc then
    self.SortFunc = SortFunc
  end
  if self.SortFunc then
    table.sort(self.elements, self.SortFunc)
  end
end
function ProrityQueue:Dequeue()
  if #self.elements > 0 then
    return table.remove(self.elements, 1)
  end
  return nil
end
function ProrityQueue:Peek()
  return self.elements[1]
end
function ProrityQueue:RemoveByIdx(Idx)
  if Idx then
    if self.elements[Idx] then
      table.remove(self.elements, Idx)
    end
  else
    table.remove(self.elements, 1)
  end
end
function ProrityQueue:GetByIdx(Idx)
  local value = self.elements[Idx]
  return value
end
function ProrityQueue:Count()
  return #self.elements
end
function ProrityQueue:IsEmpty()
  return table.IsEmpty(self.elements)
end
function ProrityQueue:Sort(SortFunc)
  if SortFunc then
    self.SortFunc = SortFunc
  end
  if self.SortFunc then
    return
  end
end
function ProrityQueue:Clear()
  self.elements = {}
end
return ProrityQueue
