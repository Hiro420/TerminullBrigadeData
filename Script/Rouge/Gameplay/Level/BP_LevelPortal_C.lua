local BP_LevelPortal_C = UnLua.Class()

function BP_LevelPortal_C:EventOnBeginInteract(InPlayer)
  self.Overridden.EventOnBeginInteract(self, InPlayer)
  if UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  local levelId = self:GetLevelId()
  local Result, Row = GetRowData("WorldLevelPool", tostring(levelId))
  if not Result then
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if not WaveWindowManager then
      return
    end
    local Param = {}
    table.insert(Param, tostring(levelId))
    WaveWindowManager:ShowWaveWindow(1119, Param)
  elseif tostring(Row.LevelName) == "None" or tostring(Row.LevelName) == "" then
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if not WaveWindowManager then
      return
    end
    local Param = {}
    table.insert(Param, tostring(levelId))
    WaveWindowManager:ShowWaveWindow(1120, Param)
  end
end

return BP_LevelPortal_C
