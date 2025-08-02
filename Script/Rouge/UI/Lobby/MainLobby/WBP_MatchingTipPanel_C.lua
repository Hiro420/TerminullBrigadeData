local WBP_MatchingTipPanel_C = UnLua.Class()
local ChangeStartTipId = 100005

function WBP_MatchingTipPanel_C:Construct()
  self.Btn_CancelMatch.OnClicked:Add(self, self.BindOnCancelMatchButtonClicked)
end

function WBP_MatchingTipPanel_C:BindOnCancelMatchButtonClicked()
  if DataMgr.IsInTeam() then
    local TeamInfo = DataMgr.GetTeamInfo()
    if TeamInfo.state == LogicTeam.TeamState.Matching then
      LogicTeam.RequestStopMatchToServer()
    end
  end
end

function WBP_MatchingTipPanel_C:Play_Ani_Out()
  self:PlayAnimation(self.Anim_OUT)
end

function WBP_MatchingTipPanel_C:UpdateMatchingTimeText()
  local fmt = "mm:ss"
  if LogicTeam.GetCurMatchingTime() >= 60 then
    fmt = "hh:mm:ss"
  end
  local TeamInfo = DataMgr.GetTeamInfo()
  if LogicTeam.IsCaptain() and TeamInfo.state == LogicTeam.TeamState.Matching and not self.IsShowChangeStartTip and LogicTeam.GetCurMatchingTime() > self.ShowChangeStartTipTime then
    self.ChangeStartWaveWindow = ShowWaveWindowWithDelegate(ChangeStartTipId, {}, {
      self,
      function()
        LogicTeam.SetIsDefaultNeedMatchTeammate(false)
        LogicTeam.RequestStopMatchToServer({
          self,
          function()
            LogicTeam.RequestStartGameToServer()
          end
        })
      end
    }, {
      self,
      function()
      end
    })
    self.IsShowChangeStartTip = true
  end
  local TimeText = Format(LogicTeam.GetCurMatchingTime(), fmt, false)
  self.Txt_MatchingTime:SetText(tostring(self.MatchingTimeText) .. TimeText)
end

function WBP_MatchingTipPanel_C:OnShow()
  self.IsInitiativeStop = true
  self:StopAllAnimations()
  self:PlayAnimationForward(self.Ani_in)
  self.IsShowChangeStartTip = false
  self:UpdateMatchingTimeText()
  self:UpdateGameModeInfo()
  self.MatchLoading:PlayLoopAnimation()
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
  if not IsListeningForInputAction(self, self.CancelKeyName, UE.EInputEvent.IE_Pressed) then
    ListenForInputAction(self.CancelKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnListenCancelKeyPressed
    })
  end
end

function WBP_MatchingTipPanel_C:BindOnUpdateMyTeamInfo()
  self:UpdateGameModeInfo()
  local TeamInfo = DataMgr.GetTeamInfo()
  if TeamInfo.state ~= LogicTeam.TeamState.Matching and self.ChangeStartWaveWindow and self.ChangeStartWaveWindow:IsValid() then
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    RGWaveWindowManager:CloseWaveWindow(self.ChangeStartWaveWindow)
    self.ChangeStartWaveWindow = nil
  end
end

function WBP_MatchingTipPanel_C:BindOnListenCancelKeyPressed()
  self:BindOnCancelMatchButtonClicked()
end

function WBP_MatchingTipPanel_C:UpdateGameModeInfo()
  local BResult, WorldRowInfo = GetRowData(DT.DT_GameMode, LogicTeam.GetWorldId())
  if BResult then
    self.Txt_ModeName:SetText(WorldRowInfo.Name)
  end
  self.Txt_DifficultyLevel:SetText(LogicTeam.GetFloor())
end

function WBP_MatchingTipPanel_C:OnHide()
  self:RemoveEvent()
  self:Play_Ani_Out()
  self.IsShowChangeStartTip = false
end

function WBP_MatchingTipPanel_C:RemoveEvent()
  self.MatchLoading:StopLoopAnimation()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.MatchingTimeTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.MatchingTimeTimer)
  end
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  if IsListeningForInputAction(self, self.CancelKeyName) then
    StopListeningForInputAction(self, self.CancelKeyName, UE.EInputEvent.IE_Pressed)
  end
end

function WBP_MatchingTipPanel_C:Destruct()
  self:RemoveEvent()
end

return WBP_MatchingTipPanel_C
