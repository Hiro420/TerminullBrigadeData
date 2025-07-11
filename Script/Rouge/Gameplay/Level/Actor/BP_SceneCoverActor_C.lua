require("Rouge.UI.Progerss.LogicProgressSystem")
local BP_SceneCoverActor_C = UnLua.Class()
function BP_SceneCoverActor_C:CreateProgressUI()
  self.ProgressUI = LogicProgressSystem.ShowProgress(1000)
end
function BP_SceneCoverActor_C:EventRemoveProgressUI(bFinish)
  if bFinish then
    self.ProgressUI = LogicProgressSystem.FinishProgress()
  else
    self.ProgressUI = LogicProgressSystem.PauseProgress()
  end
  self.bIsStartProgressUI = false
end
function BP_SceneCoverActor_C:UpdateProgress(Percent)
  if self.ProgressUI then
    self.ProgressUI:SetPercent(Percent)
  end
end
return BP_SceneCoverActor_C
