local SettleShakeSequenceDirector = UnLua.Class()

function SettleShakeSequenceDirector:ShowSettlementTxtEvent()
  EventSystem.Invoke(EventDef.Settlement.ShowSettleTxt)
end

return SettleShakeSequenceDirector
