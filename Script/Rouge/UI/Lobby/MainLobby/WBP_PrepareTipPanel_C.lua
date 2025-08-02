local WBP_PrepareTipPanel_C = UnLua.Class()

function WBP_PrepareTipPanel_C:Construct()
  self.Btn_CancelMatch.OnClicked:Add(self, self.BindOnCancelMatchButtonClicked)
end

function WBP_PrepareTipPanel_C:BindOnCancelMatchButtonClicked()
  LogicTeam.RequestCancelPrepareToServer()
end

function WBP_PrepareTipPanel_C:UpdateMatchingTimeText()
  local RemainTime = math.max(0, LogicTeam.GetEndPrepareTime() - GetTimeWithServerDelta())
  self.Txt_RemainTime:SetText(tostring(RemainTime))
  self:PlayAnimationForward(self.Ani_countdown)
end

function WBP_PrepareTipPanel_C:OnShow()
  self:PlayAnimationForward(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0.0, 0)
  self:UpdateMatchingTimeText()
  self:UpdateGameModeInfo()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.MatchingTimeTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.MatchingTimeTimer)
  end
  self.MatchingTimeTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self:UpdateMatchingTimeText()
    end
  }, 1.0, true, 0.0)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  ListenForInputAction(self.CancelKeyName, UE.EInputEvent.IE_Pressed, false, {
    self,
    self.BindOnListenCancelKeyPressed
  })
end

function WBP_PrepareTipPanel_C:BindOnUpdateMyTeamInfo()
  self:UpdateGameModeInfo()
end

function WBP_PrepareTipPanel_C:BindOnListenCancelKeyPressed()
  self:BindOnCancelMatchButtonClicked()
end

function WBP_PrepareTipPanel_C:UpdateGameModeInfo()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ModeId = LogicTeam.GetModeId()
  if CheckIsInNormal(ModeId) then
    local BResult, ModeRowInfo = DTSubsystem:GetGameModeRowInfoById(LogicTeam.GetWorldId(), nil)
    if BResult then
      self.Txt_ModeName:SetText(ModeRowInfo.Name)
    end
  else
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, ModeId)
    if Result then
      self.Txt_ModeName:SetText(RowInfo.Name)
    end
  end
  self.Txt_DifficultyLevel:SetText(LogicTeam.GetFloor())
end

function WBP_PrepareTipPanel_C:HideUI()
  self.IsInitiativeStop = true
  self:StopAllAnimations()
  self:PlayAnimationForward(self.Ani_out)
  self.IsInitiativeStop = false
end

function WBP_PrepareTipPanel_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out and not self.IsInitiativeStop then
    UIMgr:Hide(ViewID.UI_PrepareTipPanel)
  end
end

function WBP_PrepareTipPanel_C:OnShowByHideOther()
  if self:IsAnimationPlaying(self.Ani_out) then
    self.IsInitiativeStop = false
    self:StopAnimation(self.Ani_out)
  end
end

function WBP_PrepareTipPanel_C:OnHide()
  self:RemoveEvent()
end

function WBP_PrepareTipPanel_C:RemoveEvent()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.MatchingTimeTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.MatchingTimeTimer)
  end
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  if IsListeningForInputAction(self, self.CancelKeyName) then
    StopListeningForInputAction(self, self.CancelKeyName, UE.EInputEvent.IE_Pressed)
  end
end

function WBP_PrepareTipPanel_C:Destruct()
  self:RemoveEvent()
end

return WBP_PrepareTipPanel_C
