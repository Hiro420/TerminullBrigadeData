local BP_MS_BattleGuide_FirstGenericModify = UnLua.Class()
local BattleModule = require("Modules.Beginner.BeginnerGuideModule")
function BP_MS_BattleGuide_FirstGenericModify:MissionStarted(...)
  if not UE.RGUtil.IsDedicatedServer() then
    EventSystem.AddListener(self, EventDef.GenericModify.OnChoosePanelHideByFinishInteract, self.BindOnFinishInteract)
    ListenObjectMessage(nil, GMP.MSG_Level_Guide_OnGenericModifyPanelShow, self, self.BindOnGenericModifyPanelShow)
    if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
      self:TriggerUIGuide()
    end
  end
end
function BP_MS_BattleGuide_FirstGenericModify:TriggerUIGuide(...)
  if 0 == self.UIGuideId then
    return
  end
  BattleModule:InitByGuideId(self.UIGuideId)
end
function BP_MS_BattleGuide_FirstGenericModify:BindOnGenericModifyPanelShow(...)
  self:TriggerUIGuide()
end
function BP_MS_BattleGuide_FirstGenericModify:BindOnFinishInteract(IsFinishInteract)
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
return BP_MS_BattleGuide_FirstGenericModify
