local WBP_ThumbnailModeItem_C = UnLua.Class()
WBP_ThumbnailModeItem_C.GameModes = {
  [1001] = "game_mode_1001",
  [1002] = "game_mode_1002",
  [1003] = "game_mode_1003",
  [2001] = "game_mode_2001",
  [3000] = "game_mode_3000",
  [3001] = "game_mode_3001",
  [3002] = "game_mode_3002"
}
local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")

function WBP_ThumbnailModeItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
end

function WBP_ThumbnailModeItem_C:RefreshInfo()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, self.GameModeId)
  if not Result then
    UpdateVisibility(self, false)
    print(string.format("WBP_ThumbnailModeItem_C:RefreshInfo not found RowInfo, ModeId:%s, please check the config !", self.GameModeId))
    return
  end
  SetImageBrushByPath(self.Img_Icon, RowInfo.Icon)
  self.Txt_Name:SetText(RowInfo.Name)
  UpdateVisibility(self.Overlay_SeasonPanel, RowInfo.Season)
  UpdateVisibility(self.Horizontal_Progress, self.GameModeId == TableEnums.ENUMGameMode.TOWERClIMBING)
  UpdateVisibility(self.TowerClimbingPanel, self.GameModeId == TableEnums.ENUMGameMode.TOWERClIMBING)
  UpdateVisibility(self.ScaleBox_0, not CheckIsInNormal(self.GameModeId))
  if self.GameModeId == TableEnums.ENUMGameMode.TOWERClIMBING then
    local Floor = DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, self.GameModeId)
    if self:IsUnlock() then
      self.Txt_Progress:SetText(LogicTeam.GetModeDifficultDisplayText(self.GameModeId, Floor))
    end
  end
  self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(self.GameModeId))
  self:RefreshLockStatus()
end

function WBP_ThumbnailModeItem_C:RefreshLockStatus(...)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, self.GameModeId)
  if Result and RowInfo.Season and not ModuleManager:Get("SeasonModule"):CheckIsInSeasonMode() then
    self.RGStateController_Lock:ChangeStatus("Season_Lock", true)
    return
  end
  local IsUnlock = self:IsUnlock()
  if IsUnlock then
    self.RGStateController_Lock:ChangeStatus("UnLock", true)
  else
    local bSelf, TeamMember = LogicTeam.GetTeamUnLockModeAndMember(self.GameModeId, self.DefaultWorldId)
    if bSelf then
      self.RGStateController_Lock:ChangeStatus("Lock", true)
      if self.GameModeId == TableEnums.ENUMGameMode.BOSSRUSH then
        local TBBossRush = LuaTableMgr.GetLuaTableByName(TableNames.TBBossRush)
        for index, value in ipairs(TBBossRush) do
          self.Txt_Progress:SetText(value.UnLockDes)
          return
        end
      else
        local TBGameMode = LuaTableMgr.GetLuaTableByName(TableNames.TBGameMode)
        if TBGameMode[self.GameModeId] then
          self.Txt_Progress:SetText(TBGameMode[self.GameModeId].UnLockText)
        end
      end
    else
      self.RGStateController_Lock:ChangeStatus("Team_Lock", true)
      self.WBP_LockWordTip:Show(TeamMember, true)
    end
  end
end

function WBP_ThumbnailModeItem_C:IsUnlock()
  local TBGameFloor = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  if TBGameFloor then
    for LevelId, LevelInfo in pairs(TBGameFloor) do
      if LevelInfo.initUnlock and LevelInfo.gameWorldID == self.DefaultWorldId and LevelInfo.gameMode == self.GameModeId then
        return true
      end
    end
  end
  for RoleId, ModeInfo in pairs(LogicTeam.RolesGameFloorInfo) do
    if not ModeInfo[tostring(self.GameModeId)] then
      return false
    elseif not ModeInfo[tostring(self.GameModeId)][tostring(self.DefaultWorldId)] then
      return false
    end
  end
  return true
end

function WBP_ThumbnailModeItem_C:BindOnMainButtonClicked()
  local SystemID = WBP_ThumbnailModeItem_C.GameModes[self.GameModeId]
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if nil ~= SystemID and nil ~= SystemOpenMgr and SystemOpenMgr:IsSystemOpen(SystemID) == false then
    return
  end
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, self.GameModeId)
  local SeasonModule = ModuleManager:Get("SeasonModule")
  if not SeasonModule:CheckIsInSeasonMode() and result and row.Season then
    ShowWaveWindow(1454)
    return
  end
  local IsUnlock = self:IsUnlock()
  if IsUnlock then
    EventSystem.Invoke(EventDef.ModeSelection.OnChangeThumbnailModeItem, self.GameModeId, self.DefaultWorldId)
  else
    print("\232\175\165\230\168\161\229\188\143\230\156\170\232\167\163\233\148\129", self.GameModeId)
    ShowWaveWindow(self.LockTipId)
  end
end

return WBP_ThumbnailModeItem_C
