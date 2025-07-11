local EBattleLagacyLobbyItemActive = {Active = "Active", NotActive = "NotActive"}
local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local WBP_BattleLagacyLobbyItem_C = UnLua.Class()
function WBP_BattleLagacyLobbyItem_C:Construct()
  self.Overridden.Construct(self)
  self:OnGetCurrBattleLagacyLogin()
  self:OnUpdateMyTeamInfo()
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateMyTeamInfo, self, self.OnUpdateMyTeamInfo)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnGetCurrBattleLagacyLogin, self, self.OnGetCurrBattleLagacyLogin)
  self.BP_ButtonWithSoundHover.OnHovered:Add(self, self.OnHovered)
  self.BP_ButtonWithSoundHover.OnUnhovered:Add(self, self.OnUnhovered)
end
function WBP_BattleLagacyLobbyItem_C:InitBattleLagacyLobbyItem(ParentView)
  self.ParentView = ParentView
end
function WBP_BattleLagacyLobbyItem_C:OnUpdateMyTeamInfo()
  local bIsActive = BattleLagacyModule:CheckBattleLagacyIsActive()
  self.bIsActive = bIsActive
  if bIsActive then
    self.RGStateControllerActive:ChangeStatus(EBattleLagacyLobbyItemActive.Active)
  else
    self.RGStateControllerActive:ChangeStatus(EBattleLagacyLobbyItemActive.NotActive)
  end
end
function WBP_BattleLagacyLobbyItem_C:OnGetCurrBattleLagacyLogin()
  if BattleLagacyData.CurBattleLagacyData ~= nil and BattleLagacyData.CurBattleLagacyData.BattleLagacyId ~= "0" then
    UpdateVisibility(self, true)
  else
    UpdateVisibility(self, false)
  end
end
function WBP_BattleLagacyLobbyItem_C:OnHovered()
  if not self.ParentView then
    return
  end
  self.ParentView:ShowBattleLagacyTips(true, BattleLagacyData.CurBattleLagacyData, self.bIsActive)
end
function WBP_BattleLagacyLobbyItem_C:OnUnhovered()
  if not self.ParentView then
    return
  end
  self.ParentView:ShowBattleLagacyTips(false)
end
function WBP_BattleLagacyLobbyItem_C:Destruct()
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateMyTeamInfo, self, self.OnUpdateMyTeamInfo)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnGetCurrBattleLagacyLogin, self, self.OnGetCurrBattleLagacyLogin)
  self.BP_ButtonWithSoundHover.OnHovered:Remove(self, self.OnHovered)
  self.BP_ButtonWithSoundHover.OnUnhovered:Remove(self, self.OnUnhovered)
  self.Overridden.Destruct(self)
end
return WBP_BattleLagacyLobbyItem_C
