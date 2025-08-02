local OnlineAntiAddictionModule = ModuleManager:Get("OnlineAntiAddictionModule") or LuaClass()
local TipId = 1800002

function OnlineAntiAddictionModule:Ctor()
end

function OnlineAntiAddictionModule:OnInit()
  print("OnlineAntiAddictionModule:OnInit...........")
end

function OnlineAntiAddictionModule:InitBindEvent()
  if not UE.UOnlineAntiAddictionSystem then
    return
  end
  local OnlineAntiAddictionSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlineAntiAddictionSystem:StaticClass())
  if OnlineAntiAddictionSystem then
    OnlineAntiAddictionSystem.Delegate_OnShowTips:Add(GameInstance, OnlineAntiAddictionModule.BindOnShowTips)
    OnlineAntiAddictionSystem.Delegate_OnHalt:Add(GameInstance, OnlineAntiAddictionModule.BindOnHalt)
  end
end

function OnlineAntiAddictionModule:BindOnShowTips(Title, Content, Duration)
  print("OnlineAntiAddictionModule:BindOnShowTips", Title, Content, Duration)
  local Result, PromptRowInfo = GetRowData(DT.DT_SystemPrompt, TipId)
  if not Result then
    print("OnlineAntiAddictionModule:BindOnShowTips Invalid Tip Id:", TipId)
    return
  end
  local RGWaveWindowManagr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not RGWaveWindowManagr then
    return
  end
  local WaveWindow
  local OnlineAntiAddictionSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlineAntiAddictionSystem:StaticClass())
  if OnlineAntiAddictionSystem and OnlineAntiAddictionSystem:HasHaltActionInProgress() then
    WaveWindow = RGWaveWindowManagr:ShowWaveWindowWithDelegate(TipId, {Content}, nil, {
      GameInstance,
      function()
        UE.UKismetSystemLibrary.QuitGame(GameInstance, UE.UGameplayStatics.GetPlayerController(self, 0), UE.EQuitPreference.Quit, false)
      end
    })
  else
    WaveWindow = RGWaveWindowManagr:ShowWaveWindow(TipId, {Content}, nil)
  end
  PromptRowInfo.Info = Content
  PromptRowInfo.Title = Title
  PromptRowInfo.Duration = Duration
  WaveWindow:UpdateCommonMsgWindow(PromptRowInfo)
end

function OnlineAntiAddictionModule:BindOnHalt()
  print("OnlineAntiAddictionModule:BindOnHalt")
  UE.UKismetSystemLibrary.QuitGame(GameInstance, UE.UGameplayStatics.GetPlayerController(self, 0), UE.EQuitPreference.Quit, false)
end

function OnlineAntiAddictionModule:OnShutdown()
  if not UE.UOnlineAntiAddictionSystem then
    return
  end
  local OnlineAntiAddictionSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlineAntiAddictionSystem:StaticClass())
  if OnlineAntiAddictionSystem then
    OnlineAntiAddictionSystem.Delegate_OnShowTips:Remove(GameInstance, OnlineAntiAddictionModule.BindOnShowTips)
    OnlineAntiAddictionSystem.Delegate_OnHalt:Remove(GameInstance, OnlineAntiAddictionModule.BindOnHalt)
  end
end

return OnlineAntiAddictionModule
