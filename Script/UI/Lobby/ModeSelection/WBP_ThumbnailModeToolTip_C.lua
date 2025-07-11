local WBP_ThumbnailModeToolTip_C = UnLua.Class()
function WBP_ThumbnailModeToolTip_C:RefreshInfo(GameModeIndex, LevelFloorInfo)
  local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(GameModeIndex))
  if not Result then
    print("WBP_ThumbnailModeToolTip_C:RefreshInfo not found gamemode row info, ", GameModeIndex)
    return
  end
  self.Txt_ModeName:SetText(RowInfo.Name)
  self.Txt_Desc:SetText(RowInfo.Desc)
  SetImageBrushBySoftObject(self.Img_WorldIcon, RowInfo.WorldSmallIcon)
  SetImageBrushBySoftObject(self.Img_ThumbnailIcon, RowInfo.TipThumbnailIcon)
  local UnLockFloor = DataMgr.GetFloorByGameModeIndex(GameModeIndex)
  if UnLockFloor > 0 then
    self.Txt_LockStatus:SetText(self.UnLockText)
    self.SelectPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.LockTipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Txt_LockStatus:SetText(self.LockText)
    self.SelectPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.LockTipPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local MinFloorLevelId = 0
    local MinFloor = 999
    for Floor, LevelId in pairs(LevelFloorInfo) do
      if Floor < MinFloor then
        MinFloorLevelId = LevelId
        MinFloor = Floor
      end
    end
    local TBGameFloorUnlock = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
    if not TBGameFloorUnlock then
      return
    end
    local MinFloorLevelInfo = TBGameFloorUnlock[MinFloorLevelId]
    if not MinFloorLevelInfo then
      print("\230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\231\154\132\229\133\179\229\141\161\228\191\161\230\129\175\239\188\140\229\156\168TBGameFloorUnlock\232\161\168, ", MinFloorLevelId)
      return
    end
    local PrefixLevelId = MinFloorLevelInfo.dependIDs[1] and MinFloorLevelInfo.dependIDs[1] or 0
    if 0 == PrefixLevelId then
      self.Txt_LockTip:SetText("\230\156\170\233\133\141\231\189\174\229\137\141\231\189\174\232\167\163\233\148\129\229\133\179\229\141\161")
      return
    end
    local PrefixLevelInfo = TBGameFloorUnlock[PrefixLevelId]
    if not PrefixLevelInfo then
      print("\230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\231\154\132\229\133\179\229\141\161\228\191\161\230\129\175\239\188\140\229\156\168TBGameFloorUnlock\232\161\168, ", PrefixLevelInfo)
      return
    end
    local BResult, BRowInfo = GetRowData(DT.DT_GameMode, tostring(PrefixLevelInfo.gameWorldID))
    if not BResult then
      return
    end
    local Text = string.format("\233\128\154\229\133\179%s\194\183\233\154\190\229\186\166%d\232\167\163\233\148\129", BRowInfo.Name, PrefixLevelInfo.floor)
    self.Txt_LockTip:SetText(Text)
  end
end
return WBP_ThumbnailModeToolTip_C
