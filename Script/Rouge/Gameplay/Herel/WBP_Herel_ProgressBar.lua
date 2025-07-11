local WBP_Herel_ProgressBar = UnLua.Class()
local SkillStatus = {
  Normal = 0,
  CoolDown = 1,
  NoCount = 2
}
function WBP_Herel_ProgressBar:Construct()
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnEnterState, self, self.BindOnCharacterEnterState)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnExitState, self, self.BindOnCharacterExitState)
end
function WBP_Herel_ProgressBar:OnDisplay()
  print("WBP_Herel_ProgressBar:OnDisplay")
  self.Overridden.OnDisplay(self)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnEnterState, self, self.BindOnCharacterEnterState)
  ListenObjectMessage(nil, GMP.MSG_World_Character_OnExitState, self, self.BindOnCharacterExitState)
  self:InitState()
end
function WBP_Herel_ProgressBar:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  UnListenObjectMessage(GMP.MSG_World_Character_OnEnterState, self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnExitState, self)
end
function WBP_Herel_ProgressBar:Destruct()
  UnListenObjectMessage(GMP.MSG_World_Character_OnEnterState, self)
  UnListenObjectMessage(GMP.MSG_World_Character_OnExitState, self)
end
function WBP_Herel_ProgressBar:BindOnCharacterEnterState(TargetActor, Tag)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  print("WBP_Herel_ProgressBar:BindOnCharacterEnterState", TargetActor, Character, Tag)
  if TargetActor ~= Character then
    return
  end
  if not UE.UBlueprintGameplayTagLibrary.HasTag(self.ForbiddenSkillTagContainer, Tag, true) then
    return
  end
  self:InitState()
end
function WBP_Herel_ProgressBar:InitState()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local logicStateComp = Character:GetLogicStateComponent()
  if not logicStateComp then
    return
  end
  local hasTag = false
  for i, v in pairs(self.ForbiddenSkillTagContainer.GameplayTags) do
    if logicStateComp:HasStateTag(v) then
      hasTag = true
      break
    end
  end
  if hasTag then
    self.RGStateController_Disable:ChangeStatus("Disable")
  else
    self.RGStateController_Disable:ChangeStatus("Able")
  end
end
function WBP_Herel_ProgressBar:BindOnCharacterExitState(TargetActor, Tag, IsBlocked)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  print("WBP_Herel_ProgressBar:BindOnCharacterExitState", TargetActor, Character, Tag)
  if TargetActor ~= Character then
    return
  end
  if not UE.UBlueprintGameplayTagLibrary.HasTag(self.ForbiddenSkillTagContainer, Tag, true) then
    return
  end
  self:InitState()
end
return WBP_Herel_ProgressBar
