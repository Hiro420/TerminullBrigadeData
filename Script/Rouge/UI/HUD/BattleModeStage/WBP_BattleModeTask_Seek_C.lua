local WBP_BattleModeTask_Seek_C = UnLua.Class()
function WBP_BattleModeTask_Seek_C:Construct()
end
function WBP_BattleModeTask_Seek_C:OnDisplay()
  self.Overridden.OnDisplay(self)
  self:PlayAnimation(self.TaskShowAni)
  ListenObjectMessage(nil, GMP.MSG_UI_HUD_BattleMode_OnSeekCaveDestoryCountChange, self, self.BindOnUpdateTaskProgress)
end
function WBP_BattleModeTask_Seek_C:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  UnListenObjectMessage(GMP.MSG_UI_HUD_BattleMode_OnSeekCaveDestoryCountChange, self)
end
function WBP_BattleModeTask_Seek_C:OnAnimationFinished(Animation)
  if Animation == self.TaskFadeoutAni then
    UpdateVisibility(self.Canvas_TaskItem, false)
  end
end
function WBP_BattleModeTask_Seek_C:BindOnUpdateTaskProgress(Instigator, CurrentValue, TargetValue)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character ~= Instigator then
    return
  end
  self:RefreshTaskProgress(CurrentValue, TargetValue)
end
function WBP_BattleModeTask_Seek_C:RefreshTaskProgress(CurrentValue, TargetValue)
  self.Txt_CurrentValue:SetText(CurrentValue)
  self.Txt_TargetValue:SetText(TargetValue)
  UpdateVisibility(self.Canvas_Finished, true)
  if CurrentValue == TargetValue then
    self:PlayAnimation(self.TaskFinishedAni)
  elseif CurrentValue < TargetValue then
    UpdateVisibility(self.Canvas_Finished, false)
  end
end
return WBP_BattleModeTask_Seek_C
