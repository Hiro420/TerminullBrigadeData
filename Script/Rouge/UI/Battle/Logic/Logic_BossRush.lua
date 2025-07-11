local M = {IsInit = false}
_G.LogicBossRush = _G.LogicBossRush or M
function LogicBossRush.Init()
  if not LogicBossRush.IsInit then
    ListenObjectMessage(nil, GMP.MSG_Global_BossRush_MechanicsStart, GameInstance, LogicBossRush.ShowBossRushTip)
    LogicBossRush.IsInit = true
  end
end
function LogicBossRush.Clear()
  UnListenObjectMessage(GMP.MSG_Global_BossRush_MechanicsStart)
end
function LogicBossRush.ShowBossRushTip(Stage)
  if not RGUIMgr:IsShown(UIConfig.WBP_BossRushTip_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_BossRushTip_C.UIName)
  end
  local BossRushTip = RGUIMgr:GetUI(UIConfig.WBP_BossRushTip_C.UIName)
  BossRushTip:InitBossRushTip(Stage)
end
