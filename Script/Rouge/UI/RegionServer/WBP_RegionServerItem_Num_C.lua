local LoginData = require("Modules.Login.LoginData")
local WBP_RegionServerItem_Num_C = UnLua.Class()
function WBP_RegionServerItem_Num_C:Construct()
  if not self.bComboBox then
    self:InitRegionServerItem(LogicTeam.GetRegion())
    EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  end
  EventSystem.AddListener(self, EventDef.Lobby.UpdateRegionPing, self.UpdateRegionPing)
end
function WBP_RegionServerItem_Num_C:UpdateRegionPing()
  self:SetPingValue(LogicTeam.GetRegionPingValue(LogicTeam.Region))
end
function WBP_RegionServerItem_Num_C:BindOnUpdateMyTeamInfo()
  self:InitRegionServerItem(LogicTeam.GetRegion())
end
function WBP_RegionServerItem_Num_C:InitRegionServerItem(Region)
  if nil == Region then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self, true)
  local result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattleServerList, Region)
  if not result then
    UpdateVisibility(self, false)
    return
  end
  local ServerId = LoginData:GetLobbyServerId()
  for i, v in ipairs(RowInfo.serverlist) do
    if tonumber(v) == tonumber(ServerId) then
      self.Region = Region
      self:SetPingValue(LogicTeam.GetRegionPingValue(self.Region))
      return
    end
  end
  UpdateVisibility(self, false)
end
function WBP_RegionServerItem_Num_C:SetPingValue(Value)
  if Value then
    self.Txt_ServerPing:SetText(Value .. "ms")
  else
    self.Txt_ServerPing:SetText("Error")
    self.RGStateController_Ping:ChangeStatus("Error")
    return
  end
  if nil == Value or Value < 0 or Value > self.Error then
    self.RGStateController_Ping:ChangeStatus("Error")
    self.Txt_ServerPing:SetText(self.ErrorText)
  elseif Value > self.Warning then
    self.RGStateController_Ping:ChangeStatus("Warning")
  else
    self.RGStateController_Ping:ChangeStatus("Normal")
  end
end
return WBP_RegionServerItem_Num_C
