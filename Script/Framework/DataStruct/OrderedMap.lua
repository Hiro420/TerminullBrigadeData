local DicPairs = function(tb)
  local k, v
  return function()
    repeat
      k, v = next(tb.keys, k)
    until v and tb.map[v] or not v and not tb.map[v]
    return v, tb.map[v]
  end
end
local OrderedMap = {
  __newindex = function(tb, k, v)
    if not tb.map then
      tb.map = {}
    end
    if not v then
      local idx = -1
      for i, v in ipairs(tb.keys) do
        if v == k then
          idx = i
          break
        end
      end
      if idx > 0 then
        table.remove(tb.keys, idx)
      end
    end
    if not tb.map[k] and v then
      table.insert(tb.keys, k)
    end
    tb.map[k] = v
  end,
  __pairs = DicPairs,
  __len = function(tb)
    return #tb.keys
  end,
  __ContainerName = "OrderedMap"
}

function OrderedMap.__index(tb, k)
  if tb.map and tb.map[k] then
    return tb.map[k]
  end
  return OrderedMap[k]
end

function OrderedMap.New(tb)
  local obj = {
    keys = {},
    map = {}
  }
  if tb then
    for k, v in pairs(tb) do
      table.insert(obj.keys, k)
      obj.map[k] = v
    end
  end
  setmetatable(obj, OrderedMap)
  return obj
end

function OrderedMap:Add(key, value, pos)
  if self.map[key] == nil then
    if pos then
      table.insert(self.keys, pos, key)
    else
      table.insert(self.keys, key)
    end
  end
  self.map[key] = value
end

function OrderedMap:Get(key)
  return self.map[key]
end

function OrderedMap:GetByIdx(Idx)
  local key = self.keys[Idx]
  if key then
    return self.map[key]
  end
  return nil
end

function OrderedMap:GetKeyByIdx(Idx)
  return self.keys[Idx]
end

function OrderedMap:Keys()
  return self.keys
end

function OrderedMap:Count()
  return #self.keys
end

function OrderedMap:IsEmpty()
  return table.IsEmpty(self.keys)
end

function OrderedMap:ContainsKey(Key)
  return self.map[Key] ~= nil
end

function OrderedMap:Values()
  local result = {}
  for _, key in ipairs(self.keys) do
    table.insert(result, self.map[key])
  end
  return result
end

function OrderedMap:Sort(SortFunc)
  local partition = function(arr, low, high)
    local pivot = arr[high]
    local i = low - 1
    for j = low, high - 1 do
      if SortFunc(self.map[arr[j]], self.map[pivot]) then
        i = i + 1
        arr[i], arr[j] = arr[j], arr[i]
      end
    end
    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return i + 1
  end
  
  local function quicksort_recursive(arr, low, high)
    if low < high then
      local pivot_index = partition(arr, low, high)
      quicksort_recursive(arr, low, pivot_index - 1)
      quicksort_recursive(arr, pivot_index + 1, high)
    end
  end
  
  quicksort_recursive(self.keys, 1, #self.keys)
end

function OrderedMap:Clear()
  self.map = {}
  self.keys = {}
end

return OrderedMap
