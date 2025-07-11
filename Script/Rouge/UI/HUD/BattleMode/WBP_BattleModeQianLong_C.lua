local WBP_BattleModeQianLong_C = UnLua.Class()
function WBP_BattleModeQianLong_C:BeginChanllenge()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.CustStage1)
end
function WBP_BattleModeQianLong_C:ShowSuccess()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.SuccessStage)
end
function WBP_BattleModeQianLong_C:ShowFailed()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.FailedStage)
end
return WBP_BattleModeQianLong_C
