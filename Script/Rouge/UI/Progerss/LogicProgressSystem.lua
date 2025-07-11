local rapidjson = require("rapidjson")
LogicProgressSystem = LogicProgressSystem or {ProgressWidget = nil}
function LogicProgressSystem.ShowProgress(Id)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:OpenUIByName("WBP_ProgressSystem_C", false, UE.EUILayer.EUILayer_Low)
    local ProgressWidget = UIManager:GetUIByName("WBP_ProgressSystem_C")
    if nil == ProgressWidget then
      return
    end
    ProgressWidget:Init(Id)
    LogicProgressSystem.ProgressWidget = ProgressWidget
    return ProgressWidget
  end
end
function LogicProgressSystem.PauseProgress(Id)
  if LogicProgressSystem.ProgressWidget == nil then
    return
  end
  LogicProgressSystem.ProgressWidget:DoPause()
  return LogicProgressSystem.ProgressWidget
end
function LogicProgressSystem.FinishProgress()
  if LogicProgressSystem.ProgressWidget then
    LogicProgressSystem.ProgressWidget:DoFinish()
    return LogicProgressSystem.ProgressWidget
  end
end
