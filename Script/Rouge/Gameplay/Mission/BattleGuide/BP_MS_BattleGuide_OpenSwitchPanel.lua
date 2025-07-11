local BeginnerGuideHandler = require("Protocol.BeginnerGuide.BeginnerGuideHandler")
local BP_MS_BattleGuide_OpenSwitchPanel = UnLua.Class()
local StartGuideId = 301
function BP_MS_BattleGuide_OpenSwitchPanel:ExecuteClientLogic(...)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
  TutorialLevelSubSystem:SetIsExecuteBeginGuideLogic(true)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  local MiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if MiscComp then
    MiscComp:ServerSetIsExecuteBeginGuideLogic(true)
  else
    print("BP_MS_BattleGuide_OpenSwitchPanel:ExecuteClientLogic not MiscComp")
  end
end
return BP_MS_BattleGuide_OpenSwitchPanel
