local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SaveGrowthSnapData = require("Modules.SaveGrowthSnap.SaveGrowthSnapData")
local WBP_BossRushSelectionPanel_C = Class(ViewBase)

function WBP_BossRushSelectionPanel_C:BindClickHandler()
  self.Button_StartMatch.OnClicked:Add(self, self.StartMatch)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  self.Btn_Difficulty:BindOnClicked(self, self.SetDifficulty_Easy)
  self.Btn_Difficulty_1:BindOnClicked(self, self.SetDifficulty_Difficulty)
  EventSystem.AddListener(self, EventDef.ModeSelection.OnChangeModeSelectionItem_BossRush, self.BindOnChangeModeSelectionItem)
  EventSystem.AddListener(self, EventDef.ModeSelection.OnChangeModeDifficultLevelItem_BossRush, self.BindOnChangeModeDifficultLevelItem)
end

function WBP_BossRushSelectionPanel_C:UnBindClickHandler()
  self.Button_StartMatch.OnClicked:Remove(self, self.StartMatch)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  EventSystem.RemoveListener(EventDef.ModeSelection.OnChangeModeSelectionItem_BossRush, self.BindOnChangeModeSelectionItem, self)
  EventSystem.RemoveListener(EventDef.ModeSelection.OnChangeModeDifficultLevelItem_BossRush, self.BindOnChangeModeDifficultLevelItem, self)
end

function WBP_BossRushSelectionPanel_C:OnInit()
  self.DataBindTable = {}
end

function WBP_BossRushSelectionPanel_C:OnDestroy()
end

function WBP_BossRushSelectionPanel_C:OnShowLink(...)
  print("WBP_BossRushSelectionPanel_C:OnShowLink", ...)
end

function WBP_BossRushSelectionPanel_C:OnShow(...)
  self:BindClickHandler()
  self.GameModeId = 3001
  self.CurSelectFloor = TableEnums.ENUMDifficultyType.Normal
  self:RefreshModeList()
  self:UpdateSaveGrowthSnapTxt()
  self.WBP_CommonButton_Snap.OnMainButtonClicked:Add(self, self.OnOpenSnap)
  self:PlayAnimation(self.Ani_in)
  EventSystem.AddListenerNew(EventDef.SaveGrowthSnap.OnRefreshSelect, self, self.UpdateSaveGrowthSnapTxt)
  self.Btn_Difficulty:SetSelect(true)
  self.Btn_Difficulty_1:SetSelect(false)
  self:SetEnhancedInputActionBlocking(true)
  UpdateVisibility(self.Button_StartMatch, not DataMgr.IsInTeam() or LogicTeam.IsCaptain(), true)
end

function WBP_BossRushSelectionPanel_C:OnHide()
  self:UnBindClickHandler()
  EventSystem.RemoveListenerNew(EventDef.SaveGrowthSnap.OnRefreshSelect, self, self.UpdateSaveGrowthSnapTxt)
  self.WBP_CommonButton_Snap.OnMainButtonClicked:Remove(self, self.OnOpenSnap)
  self:SetEnhancedInputActionBlocking(false)
end

function WBP_BossRushSelectionPanel_C:UpdateSaveGrowthSnapTxt()
  if not SaveGrowthSnapData:CheckIsEmpty(SaveGrowthSnapData.CurSelectPos) then
    local remark = SaveGrowthSnapData.SaveGrowthSnapMap[SaveGrowthSnapData.CurSelectPos].Remark
    local fmt = UE.URGBlueprintLibrary.TextFromStringTable("1360")
    local desc = UE.FTextFormat(fmt, remark)
    self.RichText_Snap:SetText(desc)
  else
    local desc = UE.URGBlueprintLibrary.TextFromStringTable("1361")
    self.RichText_Snap:SetText(desc)
  end
end

function WBP_BossRushSelectionPanel_C:OnOpenSnap()
  self.WBP_SaveGrowthSnap:ShowSnap(ESaveGrowthSnapFrom.ClimbTower)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnClickOpenSnap)
end

function WBP_BossRushSelectionPanel_C:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_BossRush, true)
end

function WBP_BossRushSelectionPanel_C:RefreshModeList()
  local TBBossRush = LuaTableMgr.GetLuaTableByName(TableNames.TBBossRush)
  local Index = 1
  local BossId = -1
  local DefWorldID = 0
  self.ModeList:ClearChildren()
  for Id, RowInfo in pairs(TBBossRush) do
    if RowInfo.DifficultyType == self.CurSelectFloor then
      local ModeItemClass = UE.UClass.Load(RowInfo.BossItemClass .. "_C")
      local Item = UE.UWidgetBlueprintLibrary.Create(self.ModeList, ModeItemClass)
      if Item then
        self.ModeList:AddChild(Item)
        if -1 == BossId then
          BossId = Id
          local Result, FloorUnlockRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, RowInfo.LevelId)
          DefWorldID = FloorUnlockRowInfo.gameWorldID
        end
        Item:Show(Id, self)
        UpdateVisibility(Item, true)
        local Padding = UE.FMargin()
        Padding.Bottom = 10.0
        Item.Slot:SetPadding(Padding)
        Index = Index + 1
      end
    end
  end
  HideOtherItem(self.ModeList, Index, true)
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeSelectionItem_BossRush, BossId, DefWorldID, TableEnums.ENUMGameMode.BOSSRUSH)
    end
  }, 0.25, false)
end

function WBP_BossRushSelectionPanel_C:StartMatch()
  if not self:IsUnlock() then
    print("\230\178\161\230\156\137\232\167\163\233\148\129")
    return
  end
  local TeamInfo = DataMgr.GetTeamInfo()
  local TBBossRush = LuaTableMgr.GetLuaTableByName(TableNames.TBBossRush)
  local Floor = 1
  if TBBossRush[self.CurBossId] then
    local Result, FloorUnlockRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, TBBossRush[self.CurBossId].LevelId)
    Floor = FloorUnlockRowInfo.floor
  end
  self.WBP_CombatPowerTip:RefreshTipText(self.CurSelectedWorldIndex, Floor)
  if TeamInfo and table.count(TeamInfo.players) <= 2 then
    ShowWaveWindowWithDelegate(1402, {}, {
      GameInstance,
      function()
        LogicTeam.RequestSetTeamDataToServer(self.CurSelectedWorldIndex, self.CurSelectMode, Floor)
        UIMgr:Hide(ViewID.UI_BossRush, true)
        UIMgr:Hide(ViewID.UI_MainModeSelection, true)
        local LobbyPanelTagName = LogicLobby.GetLabelTagNameByUIName("UI_LobbyMain")
        LogicLobby.ChangeLobbyPanelLabelSelected(LobbyPanelTagName)
      end
    })
  else
    LogicTeam.RequestSetTeamDataToServer(self.CurSelectedWorldIndex, self.CurSelectMode, Floor)
    UIMgr:Hide(ViewID.UI_BossRush, true)
    UIMgr:Hide(ViewID.UI_MainModeSelection, true)
    local LobbyPanelTagName = LogicLobby.GetLabelTagNameByUIName("UI_LobbyMain")
    LogicLobby.ChangeLobbyPanelLabelSelected(LobbyPanelTagName)
  end
end

function WBP_BossRushSelectionPanel_C:OnHoverItem(bHover, ModeItem, ModeId, WorldId)
  if not bHover then
    UpdateVisibility(self.WBP_LockWordTip, bHover)
    return
  end
  local ModeGeometry = ModeItem:GetCachedGeometry()
  local ModeListGeometry = self:GetCachedGeometry()
  local ItemPos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(ModeListGeometry, ModeGeometry)
  local ItemSize = UE.USlateBlueprintLibrary.GetLocalSize(ModeGeometry)
  print("fyltest posX = " .. ItemPos.X .. "   posY = " .. ItemPos.Y)
  print("fyltest sizeX = " .. ItemSize.X .. "   sizeY = " .. ItemSize.Y)
  local New_TipPos_X = ItemPos.X + ItemSize.X
  local New_TipPos_Y = ItemPos.Y
  local New_TipPos = UE.FVector2D(New_TipPos_X, New_TipPos_Y)
  self.WBP_LockWordTip.Slot:SetPosition(New_TipPos)
  local TeamUnLock, LockTeamMembers = LogicTeam.GetTeamUnLockModeAndMember(ModeId, WorldId)
  local TBGameFloor = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  if TBGameFloor then
    for LevelId, LevelInfo in pairs(TBGameFloor) do
      if LevelInfo.initUnlock and LevelInfo.gameWorldID == WorldId and LevelInfo.gameMode == ModeId then
        TeamUnLock = true
        break
      end
    end
  end
  if not TeamUnLock then
    self.WBP_LockWordTip:Show(LockTeamMembers)
    UpdateVisibility(self.WBP_LockWordTip, true)
  end
end

function WBP_BossRushSelectionPanel_C:BindOnChangeModeSelectionItem(BossId, ModeId, GameModeId)
  self.CurSelectedWorldIndex = ModeId
  self.CurSelectMode = GameModeId
  self.CurBossId = BossId
  self:RefreshGameFloorDesc(ModeId, self.CurSelectFloor)
  self:RefreshFloorDropPanel(ModeId, self.CurSelectFloor)
  self:RefreshBeginnerClearRewardPanel()
  if self:IsUnlock() then
    self.RGStateController_Lock:ChangeStatus("Unlock")
  else
    local TBBossRush = LuaTableMgr.GetLuaTableByName(TableNames.TBBossRush)
    if TBBossRush[self.CurBossId] then
      self.Txt_Lock:SetText(TBBossRush[self.CurBossId].UnLockDes)
    end
    self.RGStateController_Lock:ChangeStatus("Lock")
  end
  if self.CurSelectFloor == TableEnums.ENUMDifficultyType.Normal then
    self:PlayAnimation(self.Ani_Easy_click)
  else
    self:PlayAnimation(self.Ani_Difficulty_click)
  end
end

function WBP_BossRushSelectionPanel_C:BindOnChangeModeDifficultLevelItem(WorldIndex, Floor, GameModeId)
  self.CurSelectFloor = Floor
  self:RefreshModeList()
  self:RefreshGameFloorDesc(WorldIndex, Floor)
  self:RefreshFloorDropPanel(WorldIndex, Floor)
  self:RefreshBeginnerClearRewardPanel()
  if self:IsUnlock() then
    self.RGStateController_Lock:ChangeStatus("Unlock")
  else
    local TBBossRush = LuaTableMgr.GetLuaTableByName(TableNames.TBBossRush)
    if TBBossRush[self.CurBossId] then
      self.Txt_Lock:SetText(TBBossRush[self.CurBossId].UnLockDes)
    end
    self.RGStateController_Lock:ChangeStatus("Lock")
  end
end

function WBP_BossRushSelectionPanel_C:RefreshGameFloorDesc(GameModeIndex, Floor)
  local TBBossRush = LuaTableMgr.GetLuaTableByName(TableNames.TBBossRush)
  if TBBossRush[self.CurBossId] then
    self.Txt_BossName:SetText(TBBossRush[self.CurBossId].BossName)
    SetImageBrushByPath(self.Img_Name, TBBossRush[self.CurBossId].BossNameIcon)
    self.Txt_Difficulty:SetText(TBBossRush[self.CurBossId].DifficultyName)
    local Result, FloorUnlockRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, TBBossRush[self.CurBossId].LevelId)
    Floor = FloorUnlockRowInfo.floor
    self.WBP_CombatPowerTip:RefreshTipText(self.CurSelectedWorldIndex, Floor)
    local Result, FloorUnlockRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, TBBossRush[self.CurBossId].LevelId)
    if Result then
      local TBTicket = LuaTableMgr.GetLuaTableByName(TableNames.TBGameModeTicket)
      if TBTicket[FloorUnlockRowInfo.ticketID] then
        for key, value in pairs(TBTicket[FloorUnlockRowInfo.ticketID].costResources) do
          local RowInfo = LogicOutsidePackback.GetResourceInfoById(value.key)
          SetImageBrushByPath(self.Icon_Consumables, RowInfo.Icon)
          self.Txt_Num:SetText(value.value)
          self.TicketNum = value.value
          break
        end
      end
    end
    SetImageBrushByPath(self.Bg_Word, TBBossRush[self.CurBossId].BossBg)
  end
  local ModeRowId = TBBossRush[self.CurBossId].LevelId
  if ModeRowId then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, ModeRowId)
    if Result then
      UpdateVisibility(self.FloorDescPanel, true)
      local Index = 1
      local Item
      for index, SingleDescription in ipairs(RowInfo.FloorDescription) do
        Item = GetOrCreateItem(self.FloorDescPanel, Index, self.FloorDescItemTemplate:StaticClass())
        Item:Show(SingleDescription)
        Index = Index + 1
      end
      HideOtherItem(self.FloorDescPanel, Index)
      if not RowInfo.ExtraEffectsDesc or next(RowInfo.ExtraEffectsDesc) == nil then
        UpdateVisibility(self.FloorExtraDescPanel, false)
        UpdateVisibility(self.Additional_Effects, false)
      else
        UpdateVisibility(self.FloorExtraDescPanel, true)
        UpdateVisibility(self.Additional_Effects, true)
        local Index = 1
        local Item
        for index, SingleDescription in ipairs(RowInfo.ExtraEffectsDesc) do
          Item = GetOrCreateItem(self.FloorExtraDescPanel, Index, self.FloorExtraDescItemTemplate:StaticClass())
          Item:Show(SingleDescription)
          Index = Index + 1
        end
        HideOtherItem(self.FloorExtraDescPanel, Index)
      end
    else
      UpdateVisibility(self.FloorDescPanel, false)
      UpdateVisibility(self.FloorExtraDescPanel, false)
    end
  else
    UpdateVisibility(self.FloorDescPanel, false)
    UpdateVisibility(self.FloorExtraDescPanel, false)
  end
end

function WBP_BossRushSelectionPanel_C:RefreshFloorDropPanel(GameModeIndex, Floor)
  local TBBossRush = LuaTableMgr.GetLuaTableByName(TableNames.TBBossRush)
  if TBBossRush[self.CurBossId] then
    self.Txt_BossName:SetText(TBBossRush[self.CurBossId].BossName)
  end
  local ModeRowId = TBBossRush[self.CurBossId].LevelId
  if ModeRowId then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, ModeRowId)
    if Result then
      UpdateVisibility(self.FloorDropPanel, true)
      local Index = 1
      local Item, DropRatio
      local DropRatioList = {}
      for i, SingleDropRatioInfoKey in ipairs(RowInfo.DropResourcesRatioKey) do
        DropRatioList[SingleDropRatioInfoKey] = RowInfo.DropResourcesRatioValue[i]
      end
      for index, SingleResourceId in ipairs(RowInfo.DropResources) do
        Item = GetOrCreateItem(self.DropList, Index, self.SingleModeDropItemTemplate:StaticClass())
        DropRatio = DropRatioList[tostring(SingleResourceId)]
        Item:Show(SingleResourceId, DropRatio)
        Index = Index + 1
      end
      HideOtherItem(self.DropList, Index)
      if 1 == Index then
        UpdateVisibility(self.FloorDropPanel, false)
      end
    else
      UpdateVisibility(self.FloorDropPanel, false)
    end
  else
    UpdateVisibility(self.FloorDropPanel, false)
  end
end

function WBP_BossRushSelectionPanel_C:RefreshBeginnerClearRewardPanel()
end

function WBP_BossRushSelectionPanel_C:SetDifficulty_Easy()
  self.Btn_Difficulty:SetSelect(true)
  self.Btn_Difficulty_1:SetSelect(false)
  self:PlayAnimation(self.Ani_Easy_in)
  EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeDifficultLevelItem_BossRush, self.CurSelectedWorldIndex, TableEnums.ENUMDifficultyType.Normal, self.CurSelectMode)
end

function WBP_BossRushSelectionPanel_C:SetDifficulty_Difficulty()
  self.Btn_Difficulty:SetSelect(false)
  self.Btn_Difficulty_1:SetSelect(true)
  self:PlayAnimation(self.Ani_Difficulty_in)
  EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeDifficultLevelItem_BossRush, self.CurSelectedWorldIndex, TableEnums.ENUMDifficultyType.Hard, self.CurSelectMode)
end

function WBP_BossRushSelectionPanel_C:IsUnlock()
  local TBGameFloor = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  if TBGameFloor then
    for LevelId, LevelInfo in pairs(TBGameFloor) do
      if LevelInfo.initUnlock and LevelInfo.gameWorldID == self.CurSelectedWorldIndex and LevelInfo.gameMode == self.CurSelectMode then
        return true
      end
    end
  end
  for RoleId, ModeInfo in pairs(LogicTeam.RolesGameFloorInfo) do
    if not ModeInfo[tostring(self.CurSelectMode)] then
      return false
    elseif not ModeInfo[tostring(self.CurSelectMode)][tostring(self.CurSelectedWorldIndex)] then
      return false
    end
  end
  return true
end

return WBP_BossRushSelectionPanel_C
