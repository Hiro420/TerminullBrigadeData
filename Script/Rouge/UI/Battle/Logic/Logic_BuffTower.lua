local M = {IsInit = false, DisPlayTimer = nil}
_G.Logic_BuffTower = _G.Logic_BuffTower or M
function Logic_BuffTower.Init()
  if Logic_BuffTower.IsInit then
    return
  end
  ListenObjectMessage(nil, GMP.MSG_BuffTower_BeginPlay, GameInstance, Logic_BuffTower.BindOnBuffTowerBeginPlay)
end
function Logic_BuffTower.Clear()
  UnListenObjectMessage(GMP.MSG_BuffTower_BeginPlay)
end
function Logic_BuffTower.BindOnBuffTowerBeginPlay()
  if not RGUIMgr:IsShown(UIConfig.WBP_Survival_Tips_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_Survival_Tips_C.UIName)
  end
  local SurvivalTips = RGUIMgr:GetUI(UIConfig.WBP_Survival_Tips_C.UIName)
  if SurvivalTips then
    SurvivalTips:InitTitle(1601)
  end
end
