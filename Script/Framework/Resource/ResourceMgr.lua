local ResourceMgr = {}
function ResourceMgr.GetPreloadedResByPath(res_path)
  if not res_path then
    error("res_path is nil")
  end
  return UE.URGAssetManager.GetAssetByString(res_path)
end
function ResourceMgr.PreloadBattleRes()
  print("=====ResourceMgr.PreloadBattleRes() begin.")
  local BattleResPreloadConfig = require("GameConfig.Preload.BattleResPreloadConfig")
  if BattleResPreloadConfig then
    local preloadArr = UE.TArray("")
    for _, path in pairs(BattleResPreloadConfig) do
      preloadArr:Add(path)
    end
    UE.URGAssetManager.PreloadAssets("ResourceMgr_PreloadBattleRes", preloadArr)
  else
    printError("require BattleResPreloadConfig failed.")
  end
end
function ResourceMgr.ReleaseBattleRes()
  print("=====ResourceMgr.ReleaseBattleRes() end.")
end
return ResourceMgr
