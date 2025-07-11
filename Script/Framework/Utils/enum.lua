local ipairs = ipairs
local enum = function(tbl, index)
  local enumtbl = {}
  local enumindex = index or 0
  for i, v in ipairs(tbl) do
    enumtbl[v] = enumindex + i - 1
  end
  return enumtbl
end
_G.enum = _G.enum or enum
