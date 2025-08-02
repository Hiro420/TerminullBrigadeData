local UIConsoleUtil = {}

function UIConsoleUtil.UpdateConsoleStoreUIVisible(bIsVisible)
  local PlatformName = UE.URGBlueprintLibrary.GetPlatformName()
  if "PS5" ~= PlatformName then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
  if UserOnlineSubsystem then
    if bIsVisible then
      UserOnlineSubsystem:ReportEnterInGameStoreUI()
    else
      UserOnlineSubsystem:ReportExitInGameStoreUI()
    end
  end
end

return UIConsoleUtil
