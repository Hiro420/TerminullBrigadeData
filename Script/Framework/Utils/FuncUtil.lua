local type = type
local pairs = pairs
local str_format = string.format
local UnLua = _G.UnLua
local FuncUtil = {}

function __TRACEBACK__()
  local traceback = debug.traceback()
  return traceback
end

function FuncUtil.ErrPrint(err)
  err = str_format([[
%s
%s]], err, __TRACEBACK__())
  UnLua.LogError(err)
end

function FuncUtil.IsEqualTable(tbLeft, tbRight, depth)
  for Key, Value in pairs(tbLeft) do
    if nil == tbRight[Key] or not FuncUtil.IsEqualVar(Value, tbRight[Key], depth - 1) then
      return false
    end
  end
  for Key, _ in pairs(tbRight) do
    if nil == tbLeft[Key] then
      return false
    end
  end
  return true
end

local Max_Table_Depth = 4

function FuncUtil.IsEqualVar(varLeft, varRight, depth)
  depth = depth or Max_Table_Depth
  local type_left = type(varLeft)
  local type_right = type(varRight)
  if type_left ~= type_right then
    return false
  end
  local bRawEqual = varLeft == varRight
  if bRawEqual or depth <= 0 then
    return bRawEqual
  end
  return "table" == type_left and FuncUtil.IsEqualTable(varLeft, varRight, depth)
end

function FuncUtil.PrintTable(t, name)
  if UE_BUILD_DEVELOPMENT or UE_BUILD_DEBUG then
    local serialize_table = function(t, name)
      local cart, autoref
      local isemptytable = function(t)
        return next(t) == nil
      end
      local basicSerialize = function(o)
        local so = tostring(o)
        if "function" == type(o) then
          local info = debug.getinfo(o, "S")
          if info.what == "C" then
            return string.format("%q", so .. ", C function")
          else
            return string.format("%q", so .. ", defined in (" .. info.linedefined .. "-" .. info.lastlinedefined .. ")" .. info.source)
          end
        elseif "number" == type(o) or "boolean" == type(o) then
          return so
        else
          return string.format("%q", so)
        end
      end
      
      local function addtocart(value, name, indent, saved, field)
        indent = indent or ""
        saved = saved or {}
        field = field or name
        cart = cart .. indent .. field
        if "table" ~= type(value) then
          cart = cart .. " = " .. basicSerialize(value) .. ";\n"
        elseif saved[value] then
          cart = cart .. " = {}; -- " .. saved[value] .. " (self reference)\n"
          autoref = autoref .. name .. " = " .. saved[value] .. ";\n"
        else
          saved[value] = name
          if isemptytable(value) then
            cart = cart .. " = {};\n"
          else
            cart = cart .. " = {\n"
            for k, v in pairs(value) do
              k = basicSerialize(k)
              local fname = string.format("%s[%s]", name, k)
              field = string.format("[%s]", k)
              addtocart(v, fname, indent .. "   ", saved, field)
            end
            cart = cart .. indent .. "};\n"
          end
        end
      end
      
      name = name or "PRINT_Table"
      if "table" ~= type(t) then
        return name .. " = " .. basicSerialize(t)
      end
      cart, autoref = "", ""
      addtocart(t, name, indent)
      return cart .. autoref
    end
    local str = serialize_table(t, name)
    print(str)
  end
end

function FuncUtil.AddClickStatistics(statistic_key)
  if not statistic_key then
    error("statistic_key is nil.")
    return
  end
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics(statistic_key)
  end
end

_G.FuncUtil = _G.FuncUtil or FuncUtil
return FuncUtil
