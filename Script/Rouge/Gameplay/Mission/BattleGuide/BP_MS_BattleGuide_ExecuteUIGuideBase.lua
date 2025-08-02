local BP_MS_BattleGuide_ExecuteUIGuideBase = UnLua.Class()
local BattleModule = require("Modules.Beginner.BeginnerGuideModule")

function BP_MS_BattleGuide_ExecuteUIGuideBase:TriggerUIGuide(...)
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  if 0 == self.UIGuideId then
    return
  end
  BattleModule:InitByGuideId(self.UIGuideId)
end

return BP_MS_BattleGuide_ExecuteUIGuideBase
