require("Utils.LuaCommon")
require("Utils.LuaTableMgr")
require("Utils.MessageTags")
require("Rouge.Gameplay.DataMgr")
require("Rouge.Gameplay.CmdLineMgr")
require("Rouge.Gameplay.Audio.LogicAudio")
require("Rouge.UI.Chat.Logic_Chat")
require("Rouge.UI.Lobby.Logic.Logic_OutsideWeapon")
require("Utils.DataTablaName")
require("BootstrapRequire")
require("UI.Common.CommonPopupTypes")
require("Rouge.UI.Battle.Logic.Logic_Scroll")
require("Rouge.UI.Lobby.Logic.Logic_Team")
require("Rouge.UI.Lobby.Logic.Logic_Role")
require("UI.Common.Countdown.CountdownHandler")
local ControllerConnectionLostTitle = NSLOCTEXT("BP_RGGameInstance_C", "ControllerConnectionLostTitle", "\230\142\167\229\136\182\229\153\168\233\147\190\230\142\165\229\188\130\229\184\184")
local ControllerConnectionLostContent = NSLOCTEXT("BP_RGGameInstance_C", "ControllerConnectionLostContent", "\232\175\183\233\135\141\230\150\176\233\147\190\230\142\165\230\142\167\229\136\182\229\153\168\230\136\150\233\135\141\229\144\175\230\184\184\230\136\143\233\128\128\229\135\186\230\142\167\229\136\182\229\153\168\230\142\167\229\136\182")
local BP_RGGameInstance_C = UnLua.Class()

function BP_RGGameInstance_C:Initialize(Initializer)
  print("GameInstance Initialize")
  _G.GameInstance = self
  ListenObjectMessage(nil, GMP.MSG_Lobby_Travel_DisconnectError, self, self.BindOnTravelNetworkFailure)
  print("by chj GameInstance Initialize End")
end

function BP_RGGameInstance_C:ReceiveStart()
  if UE.UKismetSystemLibrary.IsDedicatedServer(self) == false then
    _G.ModuleManager:Start()
  end
  local UserOnlineSubsystem = UE.URGGameplayStatics.GetUserOnlineSubsystem(self)
  if UserOnlineSubsystem then
    UserOnlineSubsystem.OnControllerConnectionChangeDelegate:Add(self, self.HandleControllerConnectionChange)
  end
end

function BP_RGGameInstance_C:HandleControllerConnectionChange(IsConnected)
  print("HandleControllerConnectionChange", IsConnected)
  if IsConnected then
    UIMgr:Hide(ViewID.UI_CommonSmallPopups)
  else
    UIMgr:ShowLink(ViewID.UI_CommonSmallPopups, nil, ECommonSmallPopupTypes.ControllerConnectionLost, ControllerConnectionLostTitle, ControllerConnectionLostContent)
  end
end

function BP_RGGameInstance_C:HandleNetworkError(FailureType, IsServer)
  if IsServer then
    return
  end
  local ErrorStr = UE.ENetworkFailure:GetNameByValue(FailureType)
  print("BP_RGGameInstance_C:HandleNetworkError", ErrorStr)
  self.NetErrorType = FailureType
  self.IsNetWorkError = true
end

function BP_RGGameInstance_C:BindOnTravelNetworkFailure()
  LogicLobby.GiveUpBattle()
end

function BP_RGGameInstance_C:GetNetworkErrorTipId()
  return self.NetWorkErrorTipIdList:Find(self.NetErrorType) and self.NetWorkErrorTipIdList:Find(self.NetErrorType) or self.DefaultNetWorkErrorTipId
end

function BP_RGGameInstance_C:ReceiveShutdown()
  _G.ModuleManager:Shutdown()
  print("BP_RGGameInstance_C:Shutdown")
  self.Overridden.ReceiveShutdown(self)
end

return BP_RGGameInstance_C
