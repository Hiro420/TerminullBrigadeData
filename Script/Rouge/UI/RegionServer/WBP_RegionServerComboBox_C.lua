local LoginData = require("Modules.Login.LoginData")
local WBP_RegionServerComboBox_C = UnLua.Class()

function WBP_RegionServerComboBox_C:Construct()
  local TBBattleServerList = LuaTableMgr.GetLuaTableByName(TableNames.TBBattleServerList)
  local ServerId = LoginData:GetLobbyServerId()
  self.ServerList:ClearOptions()
  for key, RowInfo in pairs(TBBattleServerList) do
    for i, v in ipairs(RowInfo.serverlist) do
      if tonumber(v) == tonumber(ServerId) then
        self.ServerList:AddOption(key)
        break
      end
    end
  end
  if LogicTeam.GetRegion() ~= nil and LogicTeam.GetRegion() ~= "" then
    self.ServerList:SetSelectedOption(LogicTeam.GetRegion())
  else
    self.ServerList:SetSelectedIndex(0)
  end
  self.ServerList.OnSelectionChanged:Add(self, WBP_RegionServerComboBox_C.OnSelectionChanged)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  self.ServerList:SetIsEnabled(true)
  UpdateVisibility(self, self.ServerList:GetOptionCount() > 0)
  self.Btn_Refresh.OnClicked:Add(self, function()
    LogicTeam.RegionPingRefresh()
  end)
end

function WBP_RegionServerComboBox_C:Destruct()
  self.ServerList:ClearOptions()
  self.ServerList.OnSelectionChanged:Remove(self, WBP_RegionServerComboBox_C.OnSelectionChanged)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
end

function WBP_RegionServerComboBox_C:BindOnUpdateMyTeamInfo()
  if LogicTeam.GetRegion() ~= nil and LogicTeam.GetRegion() ~= "" then
    self.ServerList:SetSelectedOption(LogicTeam.GetRegion())
  end
  if DataMgr.IsInTeam() then
    self.ServerList:SetIsEnabled(LogicTeam.IsCaptain())
  else
    self.ServerList:SetIsEnabled(true)
  end
end

function WBP_RegionServerComboBox_C:On_ServerList_GenerateWidget(Item)
  local result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattleServerList, Item)
  if not result then
    return
  end
  local Widget = UE.UWidgetBlueprintLibrary.Create(self, self.ItemClass)
  if nil == Widget then
    return
  end
  if nil == Widget.InitRegionServerItem then
    return
  end
  Widget:InitRegionServerItem(Item)
  return Widget
end

function WBP_RegionServerComboBox_C:OnSelectionChanged(Item, Type)
  if nil == Item or "" == Item then
    print("Selection nil")
    return
  end
  LogicTeam.SetRegion(Item)
end

return WBP_RegionServerComboBox_C
