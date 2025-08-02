local BP_MS_BattleGuide_FirstGenericModifyHUD = UnLua.Class()
local BeginnerGuideModule = require("Modules.Beginner.BeginnerGuideModule")

function BP_MS_BattleGuide_FirstGenericModifyHUD:MissionStarted(...)
  self:TriggerUIGuide()
  self.HideTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      if not UE.RGUtil.IsDedicatedServer() and 0 ~= self.UIGuideId then
        local ViewModel = UIModelMgr:Get("BeginnerGuidanceSystemTipsViewModel")
        ViewModel:FinishNowGuide()
        UIMgr:Hide(ViewID.UI_BeginnerGuidanceSystemTips)
      end
      self:MakeMissionFinished()
    end
  }, self.Duration, false)
end

function BP_MS_BattleGuide_FirstGenericModifyHUD:TriggerUIGuide(...)
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  if 0 == self.UIGuideId then
    return
  end
  BeginnerGuideModule:InitByGuideId(self.UIGuideId)
end

return BP_MS_BattleGuide_FirstGenericModifyHUD
