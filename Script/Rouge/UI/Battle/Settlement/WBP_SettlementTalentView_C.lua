local ESettlementViewStatus = {
  FirstView = 1,
  RewardView = 2,
  TeamView = 3
}
local EscName = "PauseGame"
local WBP_SettlementTalentView_C = UnLua.Class()
local FinisCountDown = 9
local WorldPath = "/Game/Rouge/UI/Battle/Settlement/WBP_SettlementWorldItem.WBP_SettlementWorldItem_C"
local SettleRewardItemPath = "/Game/Rouge/UI/Battle/Settlement/WBP_SettlementRewardItem.WBP_SettlementRewardItem_C"
function WBP_SettlementTalentView_C:InitSettlementTalentView()
  self.WBP_TalentPanel:BindOnCommonTalentButtonClicked()
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.EscView)
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.EscView
    })
  end
end
function WBP_SettlementTalentView_C:EscView()
  if self.WBP_TalentPanel.CommonTalent:CanDirectExit() then
    LogicSettlement:HideSettlement()
  end
end
return WBP_SettlementTalentView_C
