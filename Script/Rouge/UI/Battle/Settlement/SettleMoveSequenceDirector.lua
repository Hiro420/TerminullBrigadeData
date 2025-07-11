local SettleMoveSequenceDirector = UnLua.Class()
function SettleMoveSequenceDirector:HideSettlement()
  EventSystem.Invoke(EventDef.Settlement.HideSettleTxt)
end
return SettleMoveSequenceDirector
