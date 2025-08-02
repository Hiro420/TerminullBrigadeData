local PuzzleData = require("Modules.Puzzle.PuzzleData")
local WBP_CombatPowerTip = UnLua.Class()

function WBP_CombatPowerTip:Construct()
  local AllLevels = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  self.AllLevelConfigList = {}
  for LevelID, LevelFloorInfo in pairs(AllLevels) do
    local TargetLevelList = self.AllLevelConfigList[LevelFloorInfo.gameWorldID]
    if TargetLevelList then
      TargetLevelList[LevelFloorInfo.floor] = LevelID
    else
      local Table = {}
      Table[LevelFloorInfo.floor] = LevelID
      self.AllLevelConfigList[LevelFloorInfo.gameWorldID] = Table
    end
  end
end

function WBP_CombatPowerTip:Show(...)
  self:RefreshTipText()
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateMyTeamInfo, self, self.BindOnUpdateMyTeamInfo)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateCommonTalentInfo, self, self.BindOnUpdateCommonTalentInfo)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.BindOnUpdateMyHeroInfo)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
end

function WBP_CombatPowerTip:BindOnUpdateMyTeamInfo(...)
  self:RefreshTipText()
end

function WBP_CombatPowerTip:BindOnUpdateCommonTalentInfo(...)
  self:RefreshTipText()
end

function WBP_CombatPowerTip:BindOnUpdateMyHeroInfo(...)
  self:RefreshTipText()
end

function WBP_CombatPowerTip:BindOnUpdatePuzzlePackageInfo(...)
  self:RefreshTipText()
end

function WBP_CombatPowerTip:RefreshTipText(WorldId, Floor)
  local Coefficient = LogicLobby.GetCombatPowerCoefficcent(WorldId, Floor)
  local TargetText
  if -1 == Coefficient then
    TargetText = self.DefaultText
  else
    for k, SingleConditionInfo in pairs(self.CombatPowerCondition) do
      if Coefficient >= SingleConditionInfo.MinValue and Coefficient < SingleConditionInfo.MaxValue then
        TargetText = SingleConditionInfo.TipText
        break
      end
    end
    TargetText = TargetText or self.DefaultText
  end
  self.Txt_TipText:SetText(TargetText)
end

function WBP_CombatPowerTip:Hide(...)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateMyTeamInfo, self, self.BindOnUpdateMyTeamInfo)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateCommonTalentInfo, self, self.BindOnUpdateCommonTalentInfo)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.BindOnUpdateMyHeroInfo)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
end

return WBP_CombatPowerTip
