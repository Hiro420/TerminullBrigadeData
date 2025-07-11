local BP_MS_BattleGuide_FirstUpgradeModify = UnLua.Class()
local BattleModule = require("Modules.Beginner.BeginnerGuideModule")
function BP_MS_BattleGuide_FirstUpgradeModify:MissionStarted(...)
  if not UE.RGUtil.IsDedicatedServer() then
    EventSystem.AddListener(self, EventDef.GenericModify.OnChoosePanelHideByFinishInteract, self.BindOnFinishInteract)
    ListenObjectMessage(nil, GMP.MSG_Level_Guide_OnUpgradeModifyPanelShow, self, self.BindOnUpgradeModifyPanelShow)
    if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
      self:TriggerUIGuide()
    end
  end
end
function BP_MS_BattleGuide_FirstUpgradeModify:TriggerUIGuide(...)
  if 0 == self.UIGuideId then
    return
  end
  BattleModule:InitByGuideId(self.UIGuideId)
end
function BP_MS_BattleGuide_FirstUpgradeModify:BindOnUpgradeModifyPanelShow(...)
  self:TriggerUIGuide()
end
function BP_MS_BattleGuide_FirstUpgradeModify:BindOnFinishInteract(IsFinishInteract)
  if IsFinishInteract then
    self:MakeMissionFinished()
    EventSystem.RemoveListener(EventDef.GenericModify.OnChoosePanelHideByFinishInteract, self.BindOnFinishInteract, self)
    UnListenObjectMessage(GMP.MSG_Level_Guide_OnGenericModifyPanelShow, self)
  elseif 0 ~= self.UIGuideId then
    local ViewModel = UIModelMgr:Get("BeginnerGuidanceSystemTipsViewModel")
    ViewModel:FinishNowGuide()
    UIMgr:Hide(ViewID.UI_BeginnerGuidanceSystemTips)
  end
end
return BP_MS_BattleGuide_FirstUpgradeModify
