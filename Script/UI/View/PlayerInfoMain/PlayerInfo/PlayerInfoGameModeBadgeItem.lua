local PlayerInfoGameModeBadgeItem = Class()
function PlayerInfoGameModeBadgeItem:Construct()
  self.Overridden.Construct(self)
end
function PlayerInfoGameModeBadgeItem:InitPlayerInfoGameModeBadgeItem(LevelId, Floor)
  UpdateVisibility(self, true)
  local allLevels = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  if allLevels and allLevels[LevelId] and allLevels[LevelId].Icon then
    SetImageBrushByPath(self.URGImageBg, allLevels[LevelId].Icon)
  end
  self.RGTextLv:SetText(Floor)
end
function PlayerInfoGameModeBadgeItem:Hide()
  UpdateVisibility(self, false)
end
return PlayerInfoGameModeBadgeItem
