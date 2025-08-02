local WBP_BattleModeCharging_C = UnLua.Class()

function WBP_BattleModeCharging_C:Tick(MyGeometry, InDeltaTime)
end

function WBP_BattleModeCharging_C:Construct()
  self.Overridden.Construct(self)
  ListenObjectMessage(nil, GMP.MSG_World_BattleStage_Charge_LevelChange, self, self.OnLevelChange)
  ListenObjectMessage(nil, GMP.MSG_World_BattleStage_Charge_UpdateProgress, self, self.UpdateProgress)
end

function WBP_BattleModeCharging_C:OnInit(Id)
  self:Reset()
  self.WBP_BattleModeContent.bNeedProgressBar = 1005 == Id
end

function WBP_BattleModeCharging_C:OnDeInit()
  self:Reset()
end

function WBP_BattleModeCharging_C:BeginAssembly()
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.BeginAssemblyStage)
end

function WBP_BattleModeCharging_C:EndAssembly()
  print("WBP_BattleModeCharging_C22222222222")
end

function WBP_BattleModeCharging_C:BeginChanllenge()
  print("WBP_BattleModeCharging_C  11111111111")
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.BeginChallengeStage)
    end
  }, self.DelayTime, false)
end

function WBP_BattleModeCharging_C:UpdateAwards(OverlayAward, AwardTempleteItem, HorizontalBoxAwardsRoot)
end

function WBP_BattleModeCharging_C:EndChallenge()
  print("WBP_BattleModeCharging_C EndChallenge")
  self:ChargingEnd()
  self:PlayAnimation(self.Ani_out)
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.EndChallengeStage)
end

function WBP_BattleModeCharging_C:ShowSuccess()
  print("WBP_BattleModeCharging_C ShowSuccess")
  self:PlayAnimation(self.Ani_succeed)
  self:ChargingEnd()
end

function WBP_BattleModeCharging_C:ShowFailed()
  print("WBP_BattleModeCharging_C ShowFailed")
  self.WBP_BattleModeContent:ChangeGameStage(UE.EBattleModeStage.FailedStage)
  self:ChargingEnd()
end

function WBP_BattleModeCharging_C:OccupancyShutdown()
end

function WBP_BattleModeCharging_C:Reset()
end

function WBP_BattleModeCharging_C:FocusInput()
  self.Overridden.UnfocusInput(self)
end

function WBP_BattleModeCharging_C:Destruct()
  self.Overridden.Destruct(self)
end

function WBP_BattleModeCharging_C:OnLevelChange(Level)
  UpdateVisibility(self.CanvasPanel_Progress, true)
  local OpenLevel = Level + 1
  if 1 == OpenLevel then
    self.Progress:SetFillColorAndOpacity(self.FirstColor)
    self:PlayAnimation(self.Ani_in)
  elseif 2 == OpenLevel then
    self.RGStateController_Progress:ChangeStatus("Second")
    self.Progress:SetFillColorAndOpacity(self.SecondColor)
    self:PlayAnimation(self.Ani_change)
    ShowWaveWindow(900001)
  elseif 3 == OpenLevel then
    self.RGStateController_Progress:ChangeStatus("Third")
    self.Progress:SetFillColorAndOpacity(self.ThirdColor)
    self:PlayAnimation(self.Ani_change)
    ShowWaveWindow(900002)
  else
    self.RGStateController_Progress:ChangeStatus("First")
    self:PlayAnimation(self.Ani_change)
    self:EndChallenge()
  end
end

function WBP_BattleModeCharging_C:ChargingEnd()
  UpdateVisibility(self.CanvasPanel_Progress, false)
end

function WBP_BattleModeCharging_C:UpdateProgress(Progress)
  self:PlayAnimation(self.Ani_tips)
  self.Progress:SetPercent(Progress)
  local LeftPadding = 392
  if self.CanvasPanel_75.Slot then
    local Padding = self.CanvasPanel_75.Slot.Padding
    Padding.Left = LeftPadding * Progress
    self.CanvasPanel_75.Slot:SetPadding(Padding)
  end
  self.Text_Stage:SetText(tostring(math.floor(Progress * 100)) .. "%")
end

return WBP_BattleModeCharging_C
