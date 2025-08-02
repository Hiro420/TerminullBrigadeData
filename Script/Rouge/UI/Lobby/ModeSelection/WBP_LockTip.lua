local WBP_LockTip = UnLua.Class()
local LockFloorText = NSLOCTEXT("WBP_LockTip", "LockFloorText", "\228\187\165\228\184\139\233\152\159\229\145\152\230\156\170\232\167\163\233\148\129\232\175\165\233\154\190\229\186\166")
local LockModeText = NSLOCTEXT("WBP_LockTip", "LockFloorText", "\228\187\165\228\184\139\233\152\159\229\145\152\230\156\170\232\167\163\233\148\129\232\175\165\230\168\161\229\188\143")

function WBP_LockTip:Show(RoleId, IsMode)
  self.RoleId = RoleId
  UpdateVisibility(self, true)
  UpdateVisibility(self.Overlay_LockGroup, false)
  self:RefreshRessourcenInfo(false)
  self:RefreshTeamUnlockInfo()
  EventSystem.AddListenerNew(EventDef.Lobby.GetRolesGameFloorData, self, self.BindOnGetRolesGameFloorData)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateMyTeamInfo, self, self.BindOnUpdateMyTeamInfo)
  self.Txt_Reason:SetText(IsMode and LockModeText or LockFloorText)
end

function WBP_LockTip:BindOnGetRolesGameFloorData(RolesGameFloorInfo)
  if not RolesGameFloorInfo[self.RoleId] then
    return
  end
  self:RefreshTeamUnlockInfo()
end

function WBP_LockTip:BindOnUpdateMyTeamInfo(...)
  self:RefreshTeamUnlockInfo()
end

function WBP_LockTip:RefreshTeamUnlockInfo(...)
  local Floor = DataMgr.GetTeamMemberGameFloorByModeAndWorld(self.RoleId, LogicTeam.GetModeId(), LogicTeam.GetWorldId())
  if self.RoleId == DataMgr.GetUserId() then
    Floor = DataMgr.GetFloorByGameModeIndex(LogicTeam.GetWorldId(), LogicTeam.GetModeId())
  end
  if Floor >= LogicTeam.GetFloor() then
    UpdateVisibility(self.Overlay_LockGroup, false)
  else
    UpdateVisibility(self.Overlay_LockGroup, true)
    if 0 == Floor then
      self.Txt_Reason:SetText(self.WorldReasonText)
    else
      self.Txt_Reason:SetText(UE.FTextFormat(self.FloorReasonText, Floor))
    end
  end
end

function WBP_LockTip:RefreshRessourcenInfo(NotResource)
  if self.RoleId == DataMgr.GetUserId() then
    UpdateVisibility(self.Overlay_NotRessourcen, NotResource)
  else
    UpdateVisibility(self.Overlay_NotRessourcen, false)
  end
end

function WBP_LockTip:Hide()
  EventSystem.RemoveListenerNew(EventDef.Lobby.GetRolesGameFloorData, self, self.BindOnGetRolesGameFloorData)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateMyTeamInfo, self, self.BindOnUpdateMyTeamInfo)
  UpdateVisibility(self.Overlay_LockGroup, false)
end

function WBP_LockTip:Destruct(...)
  self:Hide()
end

return WBP_LockTip
