local M = {IsInit = false, DisPlayTimer = nil}
_G.Logic_SurvivalTips = _G.Logic_SurvivalTips or M
function Logic_SurvivalTips.Init()
  if Logic_SurvivalTips.IsInit then
    return
  end
  ListenObjectMessage(nil, GMP.MSG_UI_SurvivalTips, GameInstance, Logic_SurvivalTips.BindOnSurvivalTips)
end
function Logic_SurvivalTips.Clear()
  UnListenObjectMessage(GMP.MSG_UI_SurvivalTips)
end
function Logic_SurvivalTips.BindOnSurvivalTips(TitleId)
  if not RGUIMgr:IsShown(UIConfig.WBP_Survival_Tips_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_Survival_Tips_C.UIName)
  end
  local SurvivalTips = RGUIMgr:GetUI(UIConfig.WBP_Survival_Tips_C.UIName)
  if SurvivalTips then
    SurvivalTips:InitTitle(TitleId)
  end
end
