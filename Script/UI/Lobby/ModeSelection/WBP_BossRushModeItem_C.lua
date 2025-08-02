local WBP_BossRushModeItem_C = UnLua.Class()

function WBP_BossRushModeItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  EventSystem.AddListener(self, EventDef.ModeSelection.OnChangeModeSelectionItem_BossRush, self.BindOnChangeModeSelectionItem)
end

function WBP_BossRushModeItem_C:BindOnChangeModeSelectionItem(BossId, WorldModeId, GameModeId)
  if self.Id == nil then
    return
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBossRush, self.Id)
  if not Result then
    return
  end
  self.bSel = BossId == self.Id
  if BossId == self.Id then
    UpdateVisibility(self.Img_Hovered, false)
    SetImageBrushByPath(self.Img_Icon, RowInfo.BossIconSel)
    self:PlayAnimation(self.Ani_select)
    self.RGStateController_Select:ChangeStatus("Select")
  else
    SetImageBrushByPath(self.Img_Icon, RowInfo.BossIcon)
    self.RGStateController_Select:ChangeStatus("Normal")
  end
end

function WBP_BossRushModeItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeSelectionItem_BossRush, self.Id, self.WorldModeId, self.GameModeId)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnSingleModeItemClicked)
  if not self:IsUnlock() then
    ShowWaveWindow(304010)
  end
end

function WBP_BossRushModeItem_C:BindOnMainButtonHovered()
  if not self.bSel then
    UpdateVisibility(self.Img_Hovered, true)
  end
  if self.ParentView and self.ParentView.OnHoverItem then
    self.ParentView:OnHoverItem(true, self, self.GameModeId, self.WorldModeId)
  end
end

function WBP_BossRushModeItem_C:BindOnMainButtonUnhovered()
  UpdateVisibility(self.Img_Hovered, false)
  if self.ParentView and self.ParentView.OnHoverItem then
    self.ParentView:OnHoverItem(false, self, self.GameModeId, self.WorldModeId)
  end
end

function WBP_BossRushModeItem_C:Show(Id, ParentView)
  self.bSel = false
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBossRush, Id)
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  if not Result then
    print("Boss\232\174\168\228\188\144\232\161\168\230\178\161\230\137\190\229\136\176", Id)
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local Result, FloorUnlockRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, RowInfo.LevelId)
  self.Id = Id
  self.WorldModeId = FloorUnlockRowInfo.gameWorldID
  self.GameModeId = FloorUnlockRowInfo.gameMode
  self.ParentView = ParentView
  self.Txt_Name:SetText(RowInfo.BossName)
  SetImageBrushByPath(self.Img_Icon, RowInfo.BossIcon)
  local IsUnlock = self:IsUnlock()
  UpdateVisibility(self.Overlay_LockPanel, not IsUnlock)
end

function WBP_BossRushModeItem_C:IsUnlock(...)
  local TBGameFloor = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  if TBGameFloor then
    for LevelId, LevelInfo in pairs(TBGameFloor) do
      if LevelInfo.initUnlock and LevelInfo.gameWorldID == self.WorldModeId and LevelInfo.gameMode == self.GameModeId then
        return true
      end
    end
  end
  for RoleId, ModeInfo in pairs(LogicTeam.RolesGameFloorInfo) do
    if not ModeInfo[tostring(self.GameModeId)] then
      return false
    elseif not ModeInfo[tostring(self.GameModeId)][tostring(self.WorldModeId)] then
      return false
    end
  end
  return true
end

return WBP_BossRushModeItem_C
