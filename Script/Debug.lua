require("UnLua")
local M = {
  GI = nil,
  World = nil,
  PC = nil,
  Hero = nil
}
function M.dir(obj)
  for k, v in pairs(obj) do
    print(k, v)
  end
end
function M.Update()
  M.GI = GameInstance
  M.World = M.GetWorld()
  M.PC = M.GetPC()
  M.Hero = M.GetPlayer()
  M.HeroASC = M.GetPlayerASC()
end
function M.GetWorld()
  return GameInstance:GetWorld()
end
function M.GetPC()
  local world = GameInstance:GetWorld()
  local PC = UE.UGameplayStatics.GetPlayerController(world, 0)
  return PC
end
function M.GetPlayer()
  local world = GameInstance:GetWorld()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  return Character
end
function M.GetPlayerASC()
  local char = M.GetPlayer()
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(char)
  return ASC
end
function M.GetActorsOfClass(cls)
  local world = GameInstance:GetWorld()
  local actors = UE.UGameplayStatics.GetAllActorsOfClass(world, cls)
  return actors
end
return M
