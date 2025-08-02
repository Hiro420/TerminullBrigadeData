local Global = {}

function Global.ApplicationCrashCallback()
  print("Call Global.ApplicationCrashCallback()")
  EventSystem.Invoke(EventDef.Global.OnApplicationCrash)
end

function Global.StartBattleCallback()
  print("call Global.StartBattleCallback()")
  local ResourceMgr = require("Framework.Resource.ResourceMgr")
  ResourceMgr.PreloadBattleRes()
end

function Global.EndBattleCallback()
  local ResourceMgr = require("Framework.Resource.ResourceMgr")
  ResourceMgr.ReleaseBattleRes()
  print("Global.EndBattleCallback()")
end

function Global.ReloadLuaModule(module)
  print("Global.ReloadLuaModule()", module)
  local hotreload = require("UnLua.HotReload")
  hotreload.reload({module})
end

function Global.RgtkCall(func, args)
  UnLua.LogVerbose("Global.RgtkCall()" .. "  " .. func .. "  " .. args)
  local rgtk = require("RougeTestKit")
  local rapidjson = require("rapidjson")
  if rgtk and rgtk[func] then
    return rgtk[func](rapidjson.decode(args))
  else
    print("Global.RgtkCall() failed, function '" .. func .. "' not found in RougeTestKit")
  end
end

_G.Global = _G.Global or Global
return Global
