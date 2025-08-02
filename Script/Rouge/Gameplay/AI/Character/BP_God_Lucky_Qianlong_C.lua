local BP_God_Lucky_Qianlong_C = UnLua.Class()

function BP_God_Lucky_Qianlong_C:BattleBeginLua()
  if self.BattleModeWidget then
    self.BattleModeWidget:BeginChanllenge()
    return
  end
end

function BP_God_Lucky_Qianlong_C:BattleFailLua()
  if self.BattleModeWidget then
    self.BattleModeWidget:ShowFailed()
  end
end

function BP_God_Lucky_Qianlong_C:BattleSuccessLua()
  if self.BattleModeWidget then
    self.BattleModeWidget:ShowSuccess()
  end
end

function BP_God_Lucky_Qianlong_C:OnRep_BeginTimestamp()
end

return BP_God_Lucky_Qianlong_C
