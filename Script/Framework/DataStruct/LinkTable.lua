local LinkTable = {}
function LinkTable:New()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self
  instance:Clear()
  return instance
end
function LinkTable:Clear()
  self._table = {}
  self._head = nil
  self._end = nil
  self._count = 0
end
function LinkTable:_RemoveLink(key)
  local item = self._table[key]
  if item then
    if item.prev then
      item.prev.next = item.next
    end
    if item.next then
      item.next.prev = item.prev
    end
    if item == self._head then
      self._head = item.next
    end
    if item == self._end then
      self._end = item.prev
    end
  end
end
function LinkTable:Push(key, value)
  local item
  if self._table[key] then
    self:_RemoveLink(key)
    item = self._table[key]
    item.data = value
    item.prev = self._end
    if self._end then
      self._end.next = item
    end
    item.next = nil
  else
    item = {}
    item.data = value
    item.prev = self._end
    if self._end then
      self._end.next = item
    end
    item.next = nil
    item.key = key
    self._table[key] = item
    self._count = self._count + 1
    self._end = item
    if not self._head then
      self._head = item
    end
  end
end
function LinkTable:Get(key)
  if self._table[key] then
    return self._table[key].data
  end
  return nil
end
function LinkTable:IsEnd(key)
  if self._end and self._end.key == key then
    return true
  end
  return false
end
function LinkTable:HeadNode()
  return self._head
end
function LinkTable:Head()
  if self._head then
    return self._head.data
  end
  return nil
end
function LinkTable:End()
  if self._end then
    return self._end.data
  end
  return nil
end
function LinkTable:PopHead()
  local item = self._head
  self:RemoveHead()
  if item then
    return item.data, item.key
  end
  return nil
end
function LinkTable:PopEnd()
  local item = self._end
  self:RemoveEnd()
  if item then
    return item.data
  end
  return nil
end
function LinkTable:Contains(key)
  if self._table[key] then
    return true
  end
  return false
end
function LinkTable:Remove(key)
  self:_RemoveLink(key)
  self._table[key] = nil
end
function LinkTable:RemoveHead()
  local item = self._head
  if item then
    self._head = item.next
    self:Remove(item.key)
  end
end
function LinkTable:RemoveEnd()
  local item = self._end
  if item then
    self._end = item.prev
    self:Remove(item.key)
  end
end
function LinkTable:Count()
  return self._count
end
return LinkTable
