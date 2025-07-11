local WBP_SingleDifficultLevelItem_C = UnLua.Class()
function WBP_SingleDifficultLevelItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtOnHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtOnUnhovered)
end
function WBP_SingleDifficultLevelItem_C:Show(Floor, GameLevelId, Parent)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Floor = Floor
  self.GameLevelId = GameLevelId
  self.Parent = Parent
  self.TeamUnLock = true
  local GameLevelTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  if not GameLevelTable then
    print("WBP_SingleDifficultLevelItem_C:Show not found TBGameFloorUnlock")
    return
  end
  local GameLevelInfo = GameLevelTable[self.GameLevelId]
  if not GameLevelInfo then
    print("WBP_SingleDifficultLevelItem_C:Show not found GameLevelInfo, GameLevelId:", self.GameLevelId)
    return
  end
  EventSystem.AddListener(self, EventDef.ModeSelection.OnChangeModeDifficultLevelItem, self.BindOnChangeModeDifficultLevelItem)
  self.GameModeIndex = GameLevelInfo.gameWorldID
  self.GameModeId = GameLevelInfo.gameMode
  self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(self.GameModeIndex) .. "_" .. tostring(Floor))
  self.Txt_Level:SetText(self.Floor)
  local MaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(self.GameModeIndex)
  if MaxUnLockFloor >= self.Floor then
    self.UnLockPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.LockPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_Level:SetColorAndOpacity(self.UnLockTextColor)
  else
    self.UnLockPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.LockPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_Level:SetColorAndOpacity(self.LockTextColor)
  end
  local MaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(self.GameModeIndex)
  if MaxUnLockFloor >= self.Floor and #DataMgr.MyTeamInfo.players > 1 then
    local result = LogicTeam.GetTeamUnLockModeFloor(self.GameModeId, self.GameModeIndex, self.Floor)
    self.TeamUnLock = result
  end
end
function WBP_SingleDifficultLevelItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeDifficultLevelItem, self.GameModeIndex, self.Floor, self.GameModeId)
end
function WBP_SingleDifficultLevelItem_C:BindOnMainButtOnHovered()
  if not self.TeamUnLock then
    self.Parent:DifficultLevel_OnHover(true, self.Floor)
  end
end
function WBP_SingleDifficultLevelItem_C:BindOnMainButtOnUnhovered()
  if not self.TeamUnLock then
    self.Parent:DifficultLevel_OnHover(false)
  end
end
function WBP_SingleDifficultLevelItem_C:BindOnChangeModeDifficultLevelItem(GameModeIndex, Floor)
  if Floor == self.Floor then
    self.Txt_Level:SetColorAndOpacity(self.SelectTextColor)
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WBP_RedDotView:SetNum(0)
  else
    local MaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(self.GameModeIndex)
    if MaxUnLockFloor >= self.Floor then
      if #DataMgr.MyTeamInfo.players > 1 and not LogicTeam.GetTeamUnLockModeFloor(self.GameModeId, self.GameModeIndex, self.Floor) then
        self.Txt_Level:SetColorAndOpacity(self.TeamLockTextColor)
        UpdateVisibility(self.Img_Prohibit, true)
      else
        UpdateVisibility(self.Img_Prohibit, false)
        self.Txt_Level:SetColorAndOpacity(self.UnSelectTextColor)
      end
    else
      self.Txt_Level:SetColorAndOpacity(self.LockTextColor)
    end
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_SingleDifficultLevelItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Floor = -1
  self.GameLevelId = -1
  self.GameModeIndex = -1
  EventSystem.RemoveListener(EventDef.ModeSelection.OnChangeModeDifficultLevelItem, self.BindOnChangeModeDifficultLevelItem, self)
end
function WBP_SingleDifficultLevelItem_C:Destruct()
  self:Hide()
end
return WBP_SingleDifficultLevelItem_C
