local WBP_SingleModeItem_C = UnLua.Class()

function WBP_SingleModeItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end

function WBP_SingleModeItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeSelectionItem, self.WorldModeId, self.GameModeId)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnSingleModeItemClicked)
  if not self.UnLock then
    local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(self.WorldModeId))
    if Result then
      ShowWaveWindow(self.LockTipId, {
        RowInfo.LockTipText
      })
    end
  end
end

function WBP_SingleModeItem_C:BindOnMainButtonHovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if not self.TeamUnLock then
    self.ParentView:ModeItem_OnHover(true, self, self.GameModeId, self.WorldModeId)
  end
end

function WBP_SingleModeItem_C:BindOnMainButtonUnhovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  if not self.TeamUnLock then
    self.ParentView:ModeItem_OnHover(false)
  end
end

function WBP_SingleModeItem_C:Show(WorldModeId, ModeFloorInfo, ParentView)
  local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(WorldModeId))
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  if not Result then
    print("\230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\231\154\132\230\168\161\229\188\143\228\191\161\230\129\175", WorldModeId)
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self.UnLock = true
  self.TeamUnLock = true
  self.WorldModeId = WorldModeId
  self.ParentView = ParentView
  local Result, FloorUnlockRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, ModeFloorInfo[1])
  self.GameModeId = FloorUnlockRowInfo.gameMode
  self.ModeFloorInfo = ModeFloorInfo
  self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(WorldModeId))
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Name:SetText(RowInfo.Name)
  UpdateVisibility(self.Overlay_Difficult, CheckIsInNormal(self.GameModeId))
  UpdateVisibility(self.Txt_Difficult, self.GameModeId == TableEnums.ENUMGameMode.BEGINERGUIDANCE)
  if self.GameModeId == TableEnums.ENUMGameMode.BEGINERGUIDANCE then
    self.Txt_Difficult:SetText(LogicTeam.GetModeDifficultDisplayText(self.GameModeId, 1))
  else
    local Floor = DataMgr.GetFloorByGameModeIndex(WorldModeId)
    local MaxConfigFloor = 0
    for Floor, value in pairs(self.ModeFloorInfo) do
      if Floor > MaxConfigFloor then
        MaxConfigFloor = Floor
      end
    end
    if Floor > MaxConfigFloor then
      Floor = MaxConfigFloor
    end
    if Floor > 0 then
      self.DifficultPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Img_Lock:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Txt_DifficultyLevel:SetText(UE.FTextFormat(self.DifficultText, Floor))
      self.UnLock = true
      if #DataMgr.MyTeamInfo.players > 1 then
        local TeamUnLock = LogicTeam.GetTeamUnLockMode(self.GameModeId, WorldModeId)
        if TeamUnLock then
          self.TeamUnLock = true
          self:SetLock(false)
        else
          self:SetLock(true)
          self.TeamUnLock = false
        end
      end
    else
      self.DifficultPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Img_Lock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.UnLock = false
    end
  end
  EventSystem.AddListener(self, EventDef.ModeSelection.OnChangeModeSelectionItem, self.BindOnChangeModeSelectionItem)
end

function WBP_SingleModeItem_C:BindOnChangeModeSelectionItem(WorldModeId)
  if WorldModeId == self.WorldModeId then
    self.Img_Bottom:SetColorAndOpacity(self.SelectedBottomColor)
    self.Txt_Name:SetColorAndOpacity(self.SelectedNameTextColor)
    self.Txt_CurFloorTitle:SetColorAndOpacity(self.SelectedCurFloorTextColor)
    self.Txt_DifficultyLevel:SetColorAndOpacity(self.SelectedFloorTextColor)
    self.Txt_Difficult:SetColorAndOpacity(self.SelectedFloorTextColor)
    UpdateVisibility(self.SelectEffect_Panel, true)
  else
    local CurUnLockFloor = DataMgr.GetFloorByGameModeIndex(self.WorldModeId)
    if 0 == CurUnLockFloor then
      self.Img_Bottom:SetColorAndOpacity(self.LockBottomColor)
      self.Txt_Name:SetColorAndOpacity(self.LockNameTextColor)
      self.Txt_CurFloorTitle:SetColorAndOpacity(self.LockCurFloorTextColor)
      self.Txt_DifficultyLevel:SetColorAndOpacity(self.LockFloorTextColor)
      self.Txt_Difficult:SetColorAndOpacity(self.LockFloorTextColor)
    else
      self.Img_Bottom:SetColorAndOpacity(self.UnSelectedBottomColor)
      self.Txt_Name:SetColorAndOpacity(self.UnSelectedNameTextColor)
      self.Txt_CurFloorTitle:SetColorAndOpacity(self.UnSelectedCurFloorTextColor)
      self.Txt_DifficultyLevel:SetColorAndOpacity(self.UnSelectedFloorTextColor)
      self.Txt_Difficult:SetColorAndOpacity(self.UnSelectedFloorTextColor)
    end
    UpdateVisibility(self.SelectEffect_Panel, false)
  end
end

function WBP_SingleModeItem_C:SetLock(IsLock)
  UpdateVisibility(self.Icon_Mode, IsLock)
end

function WBP_SingleModeItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.WorldModeId = -1
  self.GameModeId = -1
  self.ModeFloorInfo = {}
  EventSystem.RemoveListener(EventDef.ModeSelection.OnChangeModeSelectionItem, self.BindOnChangeModeSelectionItem, self)
end

function WBP_SingleModeItem_C:Destruct()
  self:Hide()
end

return WBP_SingleModeItem_C
