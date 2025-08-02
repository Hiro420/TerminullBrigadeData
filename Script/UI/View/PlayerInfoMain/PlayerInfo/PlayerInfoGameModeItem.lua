local PlayerInfoGameModeItem = Class()

function PlayerInfoGameModeItem:Construct()
  self.Overridden.Construct(self)
end

function PlayerInfoGameModeItem:InitPlayerInfoGameModeItem(ModeId, StatisticWorldInfo, LevelConfig, bIsOwnerInfo)
  UpdateVisibility(self, true, true)
  local result, row = GetRowData(DT.DT_GameMode, tostring(ModeId))
  if result then
    SetImageBrushBySoftObject(self.URGImageIcon, row.ThumbnailIcon)
    SetImageBrushBySoftObject(self.URGImageWorldSmallIcon, row.WorldSmallIcon)
    self.RGTextName:SetText(row.Name)
    self.RGTextNameDetails:SetText(row.Name)
  end
  local fmt = "hh:mm:ss"
  local floor = 0
  if StatisticWorldInfo and StatisticWorldInfo.worldMatchStatistics then
    local matchInfoAlone = StatisticWorldInfo.worldMatchStatistics[EPlayerInfoMatchType.Alone]
    local matchInfoTeam = StatisticWorldInfo.worldMatchStatistics[EPlayerInfoMatchType.Team]
    if matchInfoTeam then
      local TimeText = "--"
      if matchInfoTeam.leastWinDuration == "86400" then
      else
        TimeText = Format(tonumber(matchInfoTeam.leastWinDuration), fmt, false)
      end
      local windHradest = "--"
      if matchInfoTeam.winHardest > 0 then
        windHradest = matchInfoTeam.winHardest
      end
      if floor < matchInfoTeam.winHardest then
        floor = matchInfoTeam.winHardest
      end
      self.WBP_PlayerInfoGameModeDetailsInfoItem1:InitPlayerInfoGameModeDetailsInfoItem(windHradest, TimeText)
    else
      self.WBP_PlayerInfoGameModeDetailsInfoItem1:InitPlayerInfoGameModeDetailsInfoItem("--", "--")
    end
    if matchInfoAlone then
      local TimeText = "--"
      if matchInfoAlone.leastWinDuration == "86400" then
      else
        TimeText = Format(tonumber(matchInfoAlone.leastWinDuration), fmt, false)
      end
      local windHradest = "--"
      if matchInfoAlone.winHardest > 0 then
        windHradest = matchInfoAlone.winHardest
      end
      if floor < matchInfoAlone.winHardest then
        floor = matchInfoAlone.winHardest
      end
      self.WBP_PlayerInfoGameModeDetailsInfoItem2:InitPlayerInfoGameModeDetailsInfoItem(windHradest, TimeText)
    else
      self.WBP_PlayerInfoGameModeDetailsInfoItem2:InitPlayerInfoGameModeDetailsInfoItem("--", "--")
    end
  else
    self.WBP_PlayerInfoGameModeDetailsInfoItem2:InitPlayerInfoGameModeDetailsInfoItem("--", "--")
    self.WBP_PlayerInfoGameModeDetailsInfoItem1:InitPlayerInfoGameModeDetailsInfoItem("--", "--")
  end
  HideOtherItem(self.HorizontalBoxBadges, floor + 1)
  if floor > 0 then
    self.RGStateControllerLock:ChangeStatus(ELock.UnLock)
    self.WBP_PlayerInfoGameModeBadgeItem:InitPlayerInfoGameModeBadgeItem(LevelConfig[floor], floor)
    self.WBP_PlayerInfoGameModeBadgeItemDetails:InitPlayerInfoGameModeBadgeItem(LevelConfig[floor], floor)
  else
    if bIsOwnerInfo then
      local maxUnlockFloor = DataMgr.GetFloorByGameModeIndex(ModeId)
      if maxUnlockFloor <= 0 then
        self.RGStateControllerLock:ChangeStatus(ELock.Lock)
      else
        self.RGStateControllerLock:ChangeStatus(ELock.UnLock)
      end
    else
      self.RGStateControllerLock:ChangeStatus(ELock.UnLock)
    end
    self.WBP_PlayerInfoGameModeBadgeItem:Hide()
    self.WBP_PlayerInfoGameModeBadgeItemDetails:Hide()
  end
end

function PlayerInfoGameModeItem:Hide()
  UpdateVisibility(self, false)
end

function PlayerInfoGameModeItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end

function PlayerInfoGameModeItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end

return PlayerInfoGameModeItem
