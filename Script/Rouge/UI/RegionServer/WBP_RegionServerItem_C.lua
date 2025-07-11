local WBP_RegionServerItem_C = UnLua.Class()
function WBP_RegionServerItem_C:Construct()
  if not self.bComboBox then
    self:InitRegionServerItem(LogicTeam.GetRegion())
    EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  end
  EventSystem.AddListener(self, EventDef.Lobby.UpdateRegionPing, self.UpdateRegionPing)
end
function WBP_RegionServerItem_C:UpdateRegionPing()
  if not self.bComboBox then
    self:InitRegionServerItem(LogicTeam.GetRegion())
  end
  self:SetPingValue(LogicTeam.GetRegionPingValue(self.Region))
end
function WBP_RegionServerItem_C:BindOnUpdateMyTeamInfo()
  self:InitRegionServerItem(LogicTeam.GetRegion())
end
function WBP_RegionServerItem_C:InitRegionServerItem(Region)
  if nil == Region then
    return
  end
  local result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattleServerList, Region)
  if not result then
    return
  end
  self.Region = Region
  self.Txt_ServerName:SetText(RowInfo.costType)
  local PingValue = LogicTeam.GetRegionPingValue(self.Region)
  self:SetPingValue(PingValue)
end
function WBP_RegionServerItem_C:SetPingValue(Value)
  if Value then
    self.Txt_ServerPing:SetText(Value .. "ms")
  end
  if nil == Value or Value < 0 or Value > self.Error then
    self.Txt_ServerPing:SetText(self.ErrorText)
    self.RGStateController_Ping:ChangeStatus("Error")
  elseif Value > self.Warning then
    self.RGStateController_Ping:ChangeStatus("Warning")
  else
    self.RGStateController_Ping:ChangeStatus("Normal")
  end
end
return WBP_RegionServerItem_C
