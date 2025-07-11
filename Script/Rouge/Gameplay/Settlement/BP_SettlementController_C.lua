require("Rouge.UI.Lobby.Logic.Logic_Talent")
local BP_SettlementController_C = UnLua.Class()
function BP_SettlementController_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  print("BP_SettlementController_C:ReceiveBeginPlay")
  if UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  UE.URGGameplayLibrary.TriggerOnClientBeginSettlement(GameInstance)
  LogicHUD.bHadShowBattleLagacy = false
  UIMgr:Init(10)
  UIMgr:Reset()
  UE.URGUIEffectMgr.Get(GameInstance):Reset()
  LogicTalent.Init()
  LogicSettlement.Init()
  LogicOutsidePackback.Init()
  print("BP_SettlementController_C:ReceiveBeginPlay CursorVirtualFocus 0")
  UE.URGBlueprintLibrary.CursorVirtualFocus(0)
  local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
  if RGHttpClientMgr then
    RGHttpClientMgr.OnHttpBusinessErrorTip:Add(self, BP_SettlementController_C.BindOnHttpBusinessErrorTip)
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if UIManager then
    print("BP_SettlementController_C:ReceiveBeginPlay Reset")
    UIManager:Reset()
    UIManager:UnloadPreloadWidget(UE.EPreLoadScene.Lobby)
  end
  RGUIMgr:OpenUI(UIConfig.WBP_SettlementView_C.UIName, false, UE.EUILayer.EUILayer_Low)
  RGUIMgr:OpenUI(UIConfig.WBP_Marquee.UIName)
  print("BP_SettlementController_C:ReceiveBeginPlay1")
end
function BP_SettlementController_C:BindOnHttpBusinessErrorTip(ErrorCode, ErrorMsg)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager or "" == ErrorMsg then
    return
  end
  local TargetId = tonumber(ErrorCode)
  local Params = {}
  local Result, PromptRowInfo = GetRowData(DT.DT_SystemPrompt, ErrorCode)
  if not Result then
    TargetId = 100001
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBErrorCode, tonumber(ErrorCode))
    if Result then
      table.insert(Params, RowInfo.Tips)
    end
  end
  ShowWaveWindowWithConsoleCheck(TargetId, Params, ErrorCode)
end
function BP_SettlementController_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  LogicTalent.Clear()
  LogicSettlement.Clear()
  LogicOutsidePackback.Clear()
  local RGHttpClientMgr = UE.URGHttpClientMgr.Get()
  if RGHttpClientMgr then
    RGHttpClientMgr.OnHttpBusinessErrorTip:Remove(self, BP_SettlementController_C.BindOnHttpBusinessErrorTip)
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if UIManager then
    print("BP_SettlementController_C:ReceiveEndPlay Reset")
    UIManager:Reset()
    UIManager:UnloadPreloadWidget(UE.EPreLoadScene.Lobby)
  end
  UE.URGUIEffectMgr.Get(GameInstance):Reset()
end
function BP_SettlementController_C:GetCurSceneStatus()
  return UE.ESceneStatus.ESettlement
end
return BP_SettlementController_C
