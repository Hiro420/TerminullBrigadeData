local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local rapidjson = require("rapidjson")
local WBP_Pause_C = UnLua.Class()
local ExitGameTipId = 303018
local EscKeyName = "PauseGame"

function WBP_Pause_C:Construct()
  self.Btn_Continue.OnClicked:Add(self, self.BindOnContinueButtonClicked)
  self.Btn_BackToLobby.OnClicked:Add(self, WBP_Pause_C.BindOnBackToLobbyClicked)
  self.Btn_Exit.OnClicked:Add(self, WBP_Pause_C.BindOnExitClicked)
  self.Btn_GameSetting.OnClicked:Add(self, WBP_Pause_C.BindOnGameSettingButtonClicked)
  self.Btn_PreventFreeze.OnClicked:Add(self, WBP_Pause_C.BindOnPreventFreezeButtonClicked)
  self.Btn_CustomerService.OnClicked:Add(self, self.BindOnCustomerServiceClicked)
end

function WBP_Pause_C:FocusInput()
  self.Overridden.FocusInput(self)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  SetInputIgnore(Character, true)
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    self.Btn_BackToLobby:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Btn_PreventFreeze:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Btn_BackToLobby:SetVisibility(UE.ESlateVisibility.Visible)
    self.Btn_GameSetting:SetVisibility(UE.ESlateVisibility.Visible)
    self.Btn_PreventFreeze:SetVisibility(UE.ESlateVisibility.Visible)
  end
  if not IsListeningForInputAction(self, EscKeyName) then
    ListenForInputAction(EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscKeyPressed
    })
  end
  self:PushInputAction()
  local BtnList = {
    self.Btn_Continue,
    self.Btn_PreventFreeze_1,
    self.Btn_GameSetting,
    self.Btn_PreventFreeze,
    self.Btn_CustomerService,
    self.Btn_BackToLobby,
    self.Btn_Exit
  }
  self.VisibleBtnList = {}
  for Index, Btn in ipairs(BtnList) do
    if Btn:IsVisible() and Btn:GetParent():GetParent():IsVisible() then
      table.insert(self.VisibleBtnList, Btn)
    end
  end
  self.CurrentNavigationIndex = 1
end

function WBP_Pause_C:ListenForEscKeyPressed(...)
  RGUIMgr:HideUI(UIConfig.WBP_Pause_C.UIName)
end

function WBP_Pause_C:UnfocusInput(...)
  self.Overridden.UnfocusInput(self)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  SetInputIgnore(Character, false)
  if IsListeningForInputAction(self, EscKeyName) then
    StopListeningForInputAction(self, EscKeyName, UE.EInputEvent.IE_Pressed)
  end
end

function WBP_Pause_C:BindOnContinueButtonClicked()
  RGUIMgr:HideUI(UIConfig.WBP_Pause_C.UIName)
end

function WBP_Pause_C:BindOnBackToLobbyClicked()
  if LogicSettlement.IsShown() then
    return
  end
  local Function = function(...)
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager)
    if UIManager then
      UIManager:K2_CloseUI(UE.UGameplayStatics.GetObjectClass(self))
    end
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      LogicSettlement.SetClearanceStatus(SettlementStatus.Exit)
      LogicSettlement.InitSettlementData()
      PC:LeaveFromMatch()
    end
  end
  if BattleLagacyData.CurBattleLagacyData and BattleLagacyData.CurBattleLagacyData.BattleLagacyId ~= "0" and BattleLagacyModule:CheckBattleLagacyIsActive() then
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if not WaveWindowManager then
      return
    end
    WaveWindowManager:ShowWaveWindowWithDelegate(1156, {}, nil, {
      GameInstance,
      function()
        local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager)
        if UIManager then
          UIManager:K2_CloseUI(UE.UGameplayStatics.GetObjectClass(self))
        end
        local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
        if PC then
          LogicSettlement.SetClearanceStatus(SettlementStatus.Exit)
          LogicSettlement.InitSettlementData()
          PC:LeaveFromMatch()
        end
      end
    }, {
      GameInstance,
      function()
      end
    })
    return
  end
  if LogicTeam.GetModeId() == TableEnums.ENUMGameMode.BEGINERGUIDANCE then
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if not WaveWindowManager then
      return
    end
    WaveWindowManager:ShowWaveWindowWithDelegate(305005, {}, nil, {
      self,
      function()
        Function()
      end
    }, {
      GameInstance,
      function()
      end
    })
    return
  end
  Function()
end

function WBP_Pause_C:BindOnExitClicked()
  ShowWaveWindowWithDelegate(ExitGameTipId, {}, {
    self,
    function()
      local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager)
      if UIManager then
        UIManager:K2_CloseUI(UE.UGameplayStatics.GetObjectClass(self))
      end
      local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
      if PC then
        PC:LeaveFromMatch()
      end
      UE.UKismetSystemLibrary.QuitGame(self, UE.UGameplayStatics.GetPlayerController(self, 0), UE.EQuitPreference.Quit, false)
    end
  })
end

function WBP_Pause_C:BindOnGameSettingButtonClicked()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager)
  if UIManager then
    UIManager:Switch(UE.UGameplayStatics.GetObjectClass(self))
  end
  LogicGameSetting.ShowGameSettingPanel()
end

function WBP_Pause_C:BindOnPreventFreezeButtonClicked()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if UE.RGUtil.IsUObjectValid(PC) then
    local timeStamp = UE.URGStatisticsLibrary.GetTimestamp()
    if timeStamp - DataMgr.PreventFreezeTimestamp <= PC.TeleportStartCD then
      print("WBP_Pause_C:BindOnPreventFreezeButtonClicked Is CD", timeStamp, DataMgr.PreventFreezeTimestamp, PC.TeleportStartCD, timeStamp - DataMgr.PreventFreezeTimestamp)
      local WaveManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if WaveManager then
        WaveManager:ShowWaveWindow(1145)
      end
      return
    end
    DataMgr.SetPreventFreezeTimestamp(UE.URGStatisticsLibrary.GetTimestamp())
    PC:ServerTeleportStuck()
    RGUIMgr:HideUI(UIConfig.WBP_Pause_C.UIName)
  end
end

function WBP_Pause_C:BindOnCustomerServiceClicked()
end

function WBP_Pause_C:DoCustomNavigation_Up()
  self.CurrentNavigationIndex = self.CurrentNavigationIndex - 1
  if self.CurrentNavigationIndex <= 0 then
    self.CurrentNavigationIndex = #self.VisibleBtnList
  end
  return self.VisibleBtnList[self.CurrentNavigationIndex]
end

function WBP_Pause_C:DoCustomNavigation_Down()
  self.CurrentNavigationIndex = self.CurrentNavigationIndex + 1
  if self.CurrentNavigationIndex > #self.VisibleBtnList then
    self.CurrentNavigationIndex = 1
  end
  return self.VisibleBtnList[self.CurrentNavigationIndex]
end

return WBP_Pause_C
