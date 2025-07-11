local BP_LobbyCameraState_C = UnLua.Class()
function BP_LobbyCameraState_C:OnStateMachineStart()
  self.Overridden.OnStateMachineStart(self)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  self:BindOnUpdateMyTeamInfo()
end
function BP_LobbyCameraState_C:BindOnUpdateMyTeamInfo()
  local TeamInfo = DataMgr.GetTeamInfo()
  if DataMgr.IsInTeam() then
    local CurTeamMemberCount = table.count(TeamInfo.players)
    if CurTeamMemberCount == self.LastTeamMemberCount then
      return
    end
    self.LastTeamMemberCount = CurTeamMemberCount
  else
    self.LastTeamMemberCount = 1
  end
  self.IsSingleStateByMemberCount = false
end
function BP_LobbyCameraState_C:CanEnterLobbySingleState()
  local Result = LogicTeam.CurTeamState <= LogicTeam.TeamState.Preparing and self.IsSingleStateByMemberCount
  return not LogicLobby.IsShowModeSelection and Result
end
function BP_LobbyCameraState_C:CanEnterLobbyTeamState()
  local TeamInfo = DataMgr.GetTeamInfo()
  local TeamMemberResult = DataMgr.IsInTeam() and TeamInfo.state ~= LogicTeam.TeamState.HeroPicking and not self.IsSingleStateByMemberCount
  local IsNotInHeroPicking = TeamInfo.state == LogicTeam.TeamState.HeroPicking and not LogicHeroSelect.IsInHeroSelection
  return (TeamMemberResult or IsNotInHeroPicking) and not LogicLobby.IsShowModeSelection
end
function BP_LobbyCameraState_C:CanEnterHeroSelectionChangeHeroState()
  local TeamInfo = DataMgr.GetTeamInfo()
  local Result = TeamInfo.state == LogicTeam.TeamState.HeroPicking and LogicHeroSelect.IsInHeroSelection
  return Result
end
function BP_LobbyCameraState_C:CanEnterModeSelectionState()
  return LogicLobby.IsShowModeSelection
end
function BP_LobbyCameraState_C:UpdateLobbyMiddleModelRotation(IsSingle)
  if not self.OwnModel or not self.OwnModel:IsValid() then
    local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "LobbyMain1", nil)
    for key, SingleActor in pairs(AllActors) do
      self.OwnModel = SingleActor
      break
    end
  end
  if not self.OwnModel or not self.OwnModel:IsValid() then
    print("BP_LobbyCameraState_C:UpdateLobbyMiddleModelRotation not found OwnModel")
    return
  end
  local TargetRotation = UE.FRotator()
  if IsSingle then
    TargetRotation = self.LobbyMiddleModelSingleRotation
  else
    TargetRotation = self.LobbyMiddleModelTeamRotation
  end
  if self.OwnModel then
    self.OwnModel:K2_SetActorRotation(TargetRotation, false)
  end
end
function BP_LobbyCameraState_C:ResetLobbyScreenMaterialParam()
  LogicLobby.InitModeSelectionMaterialParamValue()
end
function BP_LobbyCameraState_C:OnStateMachineStop()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
end
return BP_LobbyCameraState_C
