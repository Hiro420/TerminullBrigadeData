local WBP_BattleModeContent_C = UnLua.Class()

function WBP_BattleModeContent_C:Construct()
  self:BindToAnimationFinished(self.Ani_CanvasPanelFailed, function()
    self:ChangeGameStage(UE.EBattleModeStage.Node)
  end)
  self:BindToAnimationFinished(self.Ani_CanvasPanelSuccess, function()
    self:ChangeGameStage(UE.EBattleModeStage.Node)
  end)
  self:BindToAnimationFinished(self.Ani_CanvasPanelTitle_1, function()
    self:ChangeGameStage(UE.EBattleModeStage.Node)
  end)
  self:BindToAnimationFinished(self.Ani_CanvasPanelGameStart_start, function()
    self:ChangeGameStage(UE.EBattleModeStage.Node)
  end)
  self:BindToAnimationFinished(self.Ani_CanvasPanelGameStart_end, function()
    self:ChangeGameStage(UE.EBattleModeStage.Node)
  end)
  UpdateVisibility(self.CanvasPanel_Progress, false)
end

function WBP_BattleModeContent_C:ChangeGameStage(NewStage)
  print("LJS ChangeGameStage", NewStage)
  if NewStage == self.CurGameStage then
    return
  end
  if NewStage ~= UE.EBattleModeStage.Node then
    UpdateVisibility(self.CanvasPanel_Progress, false)
  end
  if NewStage == UE.EBattleModeStage.BeginAssemblyStage then
    self:BeginAssembly()
  elseif NewStage == UE.EBattleModeStage.EndAssemblyStage then
    self:EndAssembly()
  elseif NewStage == UE.EBattleModeStage.BeginChallengeStage then
    self:BeginChanllenge()
    if self.bNeedProgressBar then
      UpdateVisibility(self.CanvasPanel_Progress, true)
    end
  elseif NewStage == UE.EBattleModeStage.EndChallengeStage then
    self:EndChallenge()
  elseif NewStage == UE.EBattleModeStage.SuccessStage then
    self:ShowSuccess()
  elseif NewStage == UE.EBattleModeStage.FailedStage then
    self:ShowFailed()
  elseif NewStage == UE.EBattleModeStage.CustStage1 then
    self:CustStage1()
  elseif self.ShowPanel then
    UpdateVisibility(self.ShowPanel, false)
    self.ShowPanel = nil
  end
end

function WBP_BattleModeContent_C:BeginAssembly()
  if self.RGText:GetText() == "" then
    return
  end
  if self.ShowPanel then
    UpdateVisibility(self.ShowPanel, false)
  end
  self.ShowPanel = self.CanvasPanelTitle_1
  UpdateVisibility(self.ShowPanel, true)
  self.CurGameStage = UE.EBattleModeStage.BeginAssemblyStage
  self:PlayAnimation(self.Ani_CanvasPanelTitle_1)
  print("LJS : BeginAssembly")
end

function WBP_BattleModeContent_C:EndAssembly()
  self.CurGameStage = UE.EBattleModeStage.EndAssemblyStage
end

function WBP_BattleModeContent_C:BeginChanllenge()
  if self.RGTextGameStart:GetText() == "" then
    return
  end
  if self.ShowPanel then
    UpdateVisibility(self.ShowPanel, false)
  end
  self.ShowPanel = self.CanvasPanelGameStart
  UpdateVisibility(self.ShowPanel, true)
  self.CurGameStage = UE.EBattleModeStage.BeginChallengeStage
  self:PlayAnimation(self.Ani_CanvasPanelGameStart_start)
  print("LJS : BeginChanllenge")
end

function WBP_BattleModeContent_C:EndChallenge()
end

function WBP_BattleModeContent_C:ShowSuccess()
  if self.TextSuccess:GetText() == "" then
    return
  end
  if self.ShowPanel then
    UpdateVisibility(self.ShowPanel, false)
  end
  self.ShowPanel = self.CanvasPanelSuccess
  UpdateVisibility(self.ShowPanel, true)
  self.CurGameStage = UE.EBattleModeStage.SuccessStage
  self:PlayAnimation(self.Ani_CanvasPanelSuccess)
end

function WBP_BattleModeContent_C:ShowFailed()
  if self.RGTextFailed:GetText() == "" then
    return
  end
  if self.ShowPanel then
    UpdateVisibility(self.ShowPanel, false)
  end
  self.ShowPanel = self.CanvasPanelFailed
  UpdateVisibility(self.ShowPanel, true)
  self.CurGameStage = UE.EBattleModeStage.FailedStage
  self:PlayAnimation(self.Ani_CanvasPanelFailed)
end

function WBP_BattleModeContent_C:CustStage1()
  if self.ShowPanel then
    UpdateVisibility(self.ShowPanel, false)
  end
  self.ShowPanel = self.CanvasPanelMoneyStart
  UpdateVisibility(self.ShowPanel, true)
  self.CurGameStage = UE.EBattleModeStage.CustStage1
  self:PlayAnimation(self.Ani_CanvasPanelMoneyStart)
end

function WBP_BattleModeContent_C:CustStage2()
end

function WBP_BattleModeContent_C:CustStage3()
end

function WBP_BattleModeContent_C:RefreshCountdown()
  if self.CurGameStage == UE.EBattleModeStage.BeginChallengeStage then
    self.Progress:SetPercent(1 - LogicBattleMode:GetDurationProgress(LogicBattleMode.BattleModeStage.Challenge))
    self.Timer:SetText(Format(LogicBattleMode:GetDuration(LogicBattleMode.BattleModeStage.Challenge), "mm:ss"))
    if self.LastDuration ~= LogicBattleMode:GetDuration(LogicBattleMode.BattleModeStage.Challenge) then
      PlaySound2DEffect(10108)
    end
    self.LastDuration = LogicBattleMode:GetDuration(LogicBattleMode.BattleModeStage.Challenge)
  end
end

function WBP_BattleModeContent_C:LuaTick(InDeltaTime)
  if self.bNeedProgressBar then
    self:RefreshCountdown()
  end
end

return WBP_BattleModeContent_C
