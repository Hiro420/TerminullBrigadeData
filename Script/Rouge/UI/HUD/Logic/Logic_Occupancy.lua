LogicOccupancy = LogicOccupancy or {}
function LogicOccupancy:Init()
  LogicOccupancy.UIWidget = nil
end
function LogicOccupancy:InitWidgetBindEvent()
  if not self.UIWidget then
    return
  end
end
function LogicOccupancy.Clear()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    local OccupancyClass = UE.UClass.Load("/Game/Rouge/UI/HUD/Occupation/WBP_Occupancy.WBP_Occupancy_C")
    local Occupancy = UIManager:K2_GetUI(OccupancyClass)
    if Occupancy then
      Occupancy:OnDeInit()
    end
    UIManager:K2_CloseUI(OccupancyClass)
  end
end
function LogicOccupancy:CreateWidget()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    local OccupancyClass = UE.UClass.Load("/Game/Rouge/UI/HUD/Occupation/WBP_Occupancy.WBP_Occupancy_C")
    local Occupancy = UIManager:K2_GetUI(OccupancyClass)
    if not Occupancy then
      UIManager:Switch(OccupancyClass)
      LogicOccupancy.UIWidget = UIManager:K2_GetUI(OccupancyClass)
      LogicOccupancy.UIWidget:OnInit()
      LogicOccupancy:InitWidgetBindEvent()
    end
  end
end
function LogicOccupancy.GetUIWidget()
  return LogicOccupancy.UIWidget
end
function LogicOccupancy:BindOnEnterArea(LevelGameplay, Actor)
end
function LogicOccupancy:BindOnExitArea(LevelGameplay, Actor)
end
function LogicOccupancy:BindOnStartUp(LevelGameplay)
  if self.UIWidget then
    self.UIWidget:ShowStart()
  end
end
function LogicOccupancy:BindOnFinished(LevelGameplay)
  if LogicOccupancy.UIWidget then
    LogicOccupancy.UIWidget:ShowSuccess()
  end
end
function LogicOccupancy:BindOnFailed(LevelGameplay)
  if LogicOccupancy.UIWidget then
    LogicOccupancy.UIWidget:ShowFailed()
  end
end
function LogicOccupancy:BindOnShutdown(LevelGameplay)
  if LogicOccupancy.UIWidget then
    LogicOccupancy.UIWidget:OccupancyShutdown()
  end
end
