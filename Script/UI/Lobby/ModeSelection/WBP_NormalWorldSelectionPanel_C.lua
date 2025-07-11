local ViewBase = require("Framework.UIMgr.ViewBase")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local WBP_NormalWorldSelectionPanel_C = UnLua.Class()
function WBP_NormalWorldSelectionPanel_C:OnBindUIInput()
end
function WBP_NormalWorldSelectionPanel_C:OnUnBindUIInput()
end
function WBP_NormalWorldSelectionPanel_C:BindClickHandler()
  self.Btn_ChangeMode.OnClicked:Add(self, self.BindOnChangeModeButtonClicked)
  self.Btn_LeftChangeMode.OnClicked:Add(self, self.BindOnLeftChangeModeButtonClicked)
  self.Btn_RightChangeMode.OnClicked:Add(self, self.BindOnRightChangeModeButtonClicked)
  self.Btn_Tips.OnHovered:Add(self, self.BindOnBtnTipsHovered)
  self.Btn_Tips.OnUnhovered:Add(self, self.BindOnBtnTipsUnhovered)
  self.Btn_ModifyPack.OnHovered:Add(self, self.BindOnBtnModifyPackHovered)
  self.Btn_ModifyPack.OnUnhovered:Add(self, self.BindOnBtnModifyPackUnhovered)
  self.Button_StartMatch.OnClicked:Add(self, self.BindOnStartMatchButtonClicked)
end
function WBP_NormalWorldSelectionPanel_C:UnBindClickHandler()
  self.Btn_ChangeMode.OnClicked:Remove(self, self.BindOnChangeModeButtonClicked)
  self.Btn_LeftChangeMode.OnClicked:Remove(self, self.BindOnLeftChangeModeButtonClicked)
  self.Btn_RightChangeMode.OnClicked:Remove(self, self.BindOnRightChangeModeButtonClicked)
  self.Btn_Tips.OnHovered:Remove(self, self.BindOnBtnTipsHovered)
  self.Btn_Tips.OnUnhovered:Remove(self, self.BindOnBtnTipsUnhovered)
  self.Btn_ModifyPack.OnHovered:Remove(self, self.BindOnBtnModifyPackHovered)
  self.Btn_ModifyPack.OnUnhovered:Remove(self, self.BindOnBtnModifyPackUnhovered)
  self.Button_StartMatch.OnClicked:Remove(self, self.BindOnStartMatchButtonClicked)
end
function WBP_NormalWorldSelectionPanel_C:Construct()
  self:BindClickHandler()
end
function WBP_NormalWorldSelectionPanel_C:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_NormalWorldSelectionPanel_C:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self:InitModeDifficultLevelConfig()
  local Params = {
    ...
  }
  self.CurSelectMode = Params[1] and Params[1] or GetCurNormalMode()
  EventSystem.AddListener(self, EventDef.ModeSelection.OnChangeModeSelectionItem, self.BindOnChangeModeSelectionItem)
  EventSystem.AddListener(self, EventDef.ModeSelection.OnChangeModeDifficultLevelItem, self.BindOnChangeModeDifficultLevelItem)
  EventSystem.AddListener(self, EventDef.Lobby.OnUpdateGameFloorInfo, self.BindOnUpdateGameFloorInfo)
  EventSystem.AddListener(self, EventDef.Lobby.OnChangeDefaultNeedMatchTeammate, self.RefreshUnderGroup)
  ChangeToLobbyAnimCamera()
  self:PlayAnimationForward(self.Ani_in)
  LogicLobby.ChangeLobbyMainModelVis(false)
  LogicLobby.ChangeModeSelectionVideoState(true)
  self.DifficultLevelPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  UpdateVisibility(self.DifficultLevelBottomPanel, false)
  self:RefreshModeList()
  self.WBP_CombatPowerTip:Show()
end
function WBP_NormalWorldSelectionPanel_C:OnRollback(...)
  ChangeToLobbyAnimCamera()
end
function WBP_NormalWorldSelectionPanel_C:InitModeDifficultLevelConfig()
  local AllLevels = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  self.AllLevelConfigList = {}
  local SeasonModule = ModuleManager:Get("SeasonModule")
  for LevelID, LevelFloorInfo in pairs(AllLevels) do
    if SeasonModule:CheckIsInSeasonMode() and SeasonModule:CheckIsInFirstSeason() == false and LevelFloorInfo.gameMode == TableEnums.ENUMGameMode.SEASONNORMAL or SeasonModule:CheckIsInSeasonMode() == false and LevelFloorInfo.gameMode == TableEnums.ENUMGameMode.NORMAL or LevelFloorInfo.gameMode == TableEnums.ENUMGameMode.BEGINERGUIDANCE or SeasonModule:CheckIsInSeasonMode() and LevelFloorInfo.gameMode == TableEnums.ENUMGameMode.NORMAL and SeasonModule:CheckIsInFirstSeason() then
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
end
function WBP_NormalWorldSelectionPanel_C:RefreshModeList()
  local AllChildren = self.ModeList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local AllLevelModeIdList = {}
  for ModeIndex, LevelFloorInfo in pairs(self.AllLevelConfigList) do
    local AResult, ARowInfo = GetRowData(DT.DT_GameMode, tostring(ModeIndex))
    local Result, TargetLevelInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, LevelFloorInfo[1])
    if AResult and ARowInfo.bCanSelected and Result then
      if CheckIsInNormal(TargetLevelInfo.gameMode) then
        table.insert(AllLevelModeIdList, ModeIndex)
      elseif TargetLevelInfo.gameMode == TableEnums.ENUMGameMode.BEGINERGUIDANCE and not BeginnerGuideData:CheckFreshmanBDIsFinished() then
        table.insert(AllLevelModeIdList, ModeIndex)
      end
    end
  end
  table.sort(AllLevelModeIdList, function(A, B)
    local AResult, ARowInfo = GetRowData(DT.DT_GameMode, tostring(A))
    local BResult, BRowInfo = GetRowData(DT.DT_GameMode, tostring(B))
    local AMaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(A)
    local BMaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(B)
    if AMaxUnLockFloor > 0 and BMaxUnLockFloor > 0 then
      return ARowInfo.Priority > BRowInfo.Priority
    else
      return AMaxUnLockFloor > 0 and BMaxUnLockFloor <= 0
    end
  end)
  local Index = 0
  local Padding = UE.FMargin()
  Padding.Bottom = 10.0
  for index, SingleModeId in ipairs(AllLevelModeIdList) do
    local ModeFloorInfo = self.AllLevelConfigList[SingleModeId]
    local Item = self.ModeList:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.ModeItemTemplate:StaticClass())
      local Slot = self.ModeList:AddChild(Item)
      Slot:SetPadding(Padding)
    end
    Item:Show(SingleModeId, ModeFloorInfo, self)
    Index = Index + 1
    if 24 == SingleModeId then
      BeginnerGuideData:UpdateWidget("BanditModeItemButton", Item)
    end
  end
  local WorldId = LogicTeam.GetWorldId()
  local ModeId = LogicTeam.GetModeId()
  local IsNeedChangeWorldId = not table.Contain(AllLevelModeIdList, WorldId)
  if IsNeedChangeWorldId then
    WorldId = LogicTeam.GetCurSeasonModeDefaultWorldId()
    ModeId = GetCurNormalMode()
  end
  EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeSelectionItem, WorldId, ModeId)
end
function WBP_NormalWorldSelectionPanel_C:MediaPlayerFinish()
  local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(self.CurSelectedWorldIndex))
  if not Result then
    print("WBP_NormalWorldSelectionPanel_C:MediaPlayerFinish not found row info for modeid", self.CurSelectedWorldIndex)
    return
  end
  local MovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
  local MediaObj = MovieSubsystem:GetMediaSource(RowInfo.MediaId)
  if MediaObj then
    self.MediaPlayer.OnMediaReachedEnd:Remove(self, self.MediaPlayerFinish)
    self.MediaPlayer:OpenSource(MediaObj)
    self.MediaPlayer:SetLooping(true)
    UpdateVisibility(self.Img_Movie, true)
    self.MediaPlayer:Rewind()
  else
    UpdateVisibility(self.Img_Movie, false)
  end
end
function WBP_NormalWorldSelectionPanel_C:BindOnChangeModeSelectionItem(ModeId, GameModeId)
  local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(ModeId))
  if not Result then
    print("WBP_NormalWorldSelectionPanel_C:BindOnChangeModeSelectionItem not found row info for modeid", ModeId)
    return
  end
  if 0 ~= RowInfo.FirstMediaId then
    local MovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
    local MediaObj = MovieSubsystem:GetMediaSource(RowInfo.FirstMediaId)
    if MediaObj then
      self.MediaPlayer.OnMediaReachedEnd:Add(self, self.MediaPlayerFinish)
      self.MediaPlayer:OpenSource(MediaObj)
      self.MediaPlayer:SetLooping(false)
      self.MediaPlayer:Rewind()
      UpdateVisibility(self.Img_Movie, true)
    else
      UpdateVisibility(self.Img_Movie, false)
    end
  elseif 0 ~= RowInfo.MediaId then
    local MovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
    local MediaObj = MovieSubsystem:GetMediaSource(RowInfo.MediaId)
    if MediaObj then
      self.MediaPlayer:OpenSource(MediaObj)
      self.MediaPlayer:SetLooping(true)
      self.MediaPlayer:Rewind()
      UpdateVisibility(self.Img_Movie, true)
    else
      UpdateVisibility(self.Img_Movie, false)
    end
  else
    print("WBP_NormalWorldSelectionPanel_C:BindOnChangeModeSelectionItem MediaId and FirstMediaId is 0!")
    UpdateVisibility(self.Img_Movie, false)
  end
  local ModeFloorInfo = self.AllLevelConfigList[ModeId]
  ModeFloorInfo = ModeFloorInfo or self.AllLevelConfigList[LogicTeam.GetCurSeasonModeDefaultWorldId()]
  self.Txt_Name:SetText(RowInfo.Name)
  self.Txt_Desc:SetText(RowInfo.Desc)
  self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(ModeId))
  local AllChildren = self.DifficultLevelList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local Index = 0
  local MaxConfigFloor = 0
  local FloorList = {}
  for Floor, LevelId in pairs(ModeFloorInfo) do
    table.insert(FloorList, Floor)
  end
  table.sort(FloorList, function(A, B)
    return A < B
  end)
  for i, Floor in ipairs(FloorList) do
    local Item = self.DifficultLevelList:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.DifficultLevelItemTemplate:StaticClass())
      self.DifficultLevelList:AddChild(Item)
    end
    Item:Show(Floor, ModeFloorInfo[Floor], self)
    Index = Index + 1
    if Floor > MaxConfigFloor then
      MaxConfigFloor = Floor
    end
  end
  local CurModeId = LogicTeam.GetWorldId()
  local Floor = -1
  if CurModeId == ModeId then
    Floor = LogicTeam.GetFloor()
  else
    Floor = DataMgr.GetFloorByGameModeIndex(ModeId)
    if MaxConfigFloor < Floor then
      Floor = MaxConfigFloor
    end
  end
  Floor = Floor > 0 and Floor or 1
  EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeDifficultLevelItem, ModeId, Floor, GameModeId)
end
function WBP_NormalWorldSelectionPanel_C:RefreshGameFloorDesc(GameModeIndex, Floor)
  local ModeFloorInfo = self.AllLevelConfigList[GameModeIndex]
  local ModeRowId = ModeFloorInfo[Floor]
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
function WBP_NormalWorldSelectionPanel_C:RefreshUnderGroup()
  UpdateVisibility(self.CanvasPanel_UnderGroup, false)
  if LogicTeam.IsDefaultNeedMatchTeammate then
    local TeamMemberCount = 0
    for i, v in pairs(DataMgr.MyTeamInfo.players) do
      TeamMemberCount = TeamMemberCount + 1
    end
    if TeamMemberCount < 3 then
      UpdateVisibility(self.CanvasPanel_UnderGroup, true)
    end
  end
end
function WBP_NormalWorldSelectionPanel_C:BindOnChangeModeDifficultLevelItem(WorldIndex, Floor, GameModeId)
  UpdateVisibility(self.DifficultLevelBottomPanel, false)
  self.DifficultLevelPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CurSelectedFloor = Floor
  self.CurSelectedWorldIndex = WorldIndex
  self.CurSelectMode = GameModeId
  self:RefreshCurSelectDifficultLevelInfo(WorldIndex, Floor)
  self:RefreshGameFloorDesc(WorldIndex, Floor)
  self:RefreshFloorDropPanel(WorldIndex, Floor)
  self:RefreshModifyPack()
  self:RefreshBeginnerClearRewardPanel()
  self:RefreshStartMatchStatus()
  self.WBP_CombatPowerTip:RefreshTipText(self.CurSelectedWorldIndex, self.CurSelectedFloor)
  print(WorldIndex, LogicTeam.GetWorldId())
  if WorldIndex == LogicTeam.GetWorldId() and Floor == LogicTeam.GetFloor() then
    print("\233\133\141\231\189\174\228\184\128\230\160\183\239\188\140\230\151\160\233\156\128\228\191\174\230\148\185")
    return
  end
  if LogicTeam.IsCaptain() then
    local TeamInfo = DataMgr.GetTeamInfo()
    local TeamCount = table.count(TeamInfo.players)
    if TeamCount > 1 and self.CurSelectMode == TableEnums.ENUMGameMode.BEGINERGUIDANCE then
      ShowWaveWindow(305004, {})
    else
      local MaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(WorldIndex)
      if Floor <= MaxUnLockFloor then
        local modeId = GetCurNormalMode()
        if self.CurSelectMode == TableEnums.ENUMGameMode.BEGINERGUIDANCE then
          modeId = self.CurSelectMode
        end
        LogicTeam.RequestSetTeamDataToServer(WorldIndex, modeId, Floor)
      else
        print("\232\175\165\233\154\190\229\186\166\230\156\170\232\167\163\233\148\129")
      end
    end
  end
end
function WBP_NormalWorldSelectionPanel_C:RefreshStartMatchStatus()
  local MaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(self.CurSelectedWorldIndex)
  if MaxUnLockFloor < self.CurSelectedFloor then
    self.RGStateController_Lock:ChangeStatus(ELock.Lock)
  else
    self.RGStateController_Lock:ChangeStatus(ELock.UnLock)
  end
end
function WBP_NormalWorldSelectionPanel_C:RefreshCurSelectDifficultLevelInfo(WorldIndex, Floor)
  UpdateVisibility(self.Btn_LeftChangeMode, CheckIsInNormal(self.CurSelectMode))
  UpdateVisibility(self.Btn_ChangeMode, CheckIsInNormal(self.CurSelectMode))
  UpdateVisibility(self.Btn_RightChangeMode, CheckIsInNormal(self.CurSelectMode))
  UpdateVisibility(self.Txt_Difficult, self.CurSelectMode == TableEnums.ENUMGameMode.BEGINERGUIDANCE)
  if CheckIsInNormal(self.CurSelectMode) then
    self.Txt_CurSelectDifficultLevel:SetText(tostring(Floor))
  elseif self.CurSelectMode == TableEnums.ENUMGameMode.BEGINERGUIDANCE then
    self.Txt_Difficult:SetText(LogicTeam.GetModeDifficultDisplayText(self.CurSelectMode, 1))
  end
  local ModeFloorInfo = self.AllLevelConfigList[WorldIndex]
  local ModeRowId = ModeFloorInfo[Floor]
  if ModeRowId then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, ModeRowId)
    if Result then
      self.Txt_MapName:SetText(RowInfo.Name)
    end
  end
  local MaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(WorldIndex)
  UpdateVisibility(self.Img_CurSelectLevelLockIcon, Floor > MaxUnLockFloor)
  local UnlockTipText = ""
  local IsShowUnlockTip = false
  if Floor > MaxUnLockFloor then
    self.Img_CurSelectBottom:SetColorAndOpacity(self.LockCurSelectBottomColor)
    self.Txt_CurSelectDifficultLevel:SetColorAndOpacity(self.LockDifficultLevelColor)
    ShowWaveWindow(self.UnlockPreLevelTipId)
    IsShowUnlockTip = true
    local ModeFloorInfo = self.AllLevelConfigList[WorldIndex]
    local ModeRowId = ModeFloorInfo[Floor]
    if ModeRowId then
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, ModeRowId)
      if Result then
        if RowInfo.IsUseUnlockTip then
          local Format = NSLOCTEXT("WBP_NormalWorldSelectionPanel_C", "UnlockTipFormat", "{0}{1}")
          UnlockTipText = UE.FTextFormat(Format, RowInfo.UnlockTip, self.UnlockTipCurLevelText)
        else
          for i, SingleLevelId in ipairs(RowInfo.dependIDs) do
            local Result, PreLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, SingleLevelId)
            if Result then
              local Result, ModeRowInfo = GetRowData(DT.DT_GameMode, tostring(PreLevelRowInfo.gameWorldID))
              local Name = Floor > self.UnlockAllWorldFloor and self.AllWorldName or Result and ModeRowInfo.Name or ""
              local Result, GamePassRowInfo = GetRowData(DT.DT_GamePassConfigTable, tostring(PreLevelRowInfo.floor))
              local PassTime = Result and math.floor(GamePassRowInfo.PerfectTime / 60) or 0
              UnlockTipText = UE.FTextFormat(self.UnlockTipText, PassTime, Name, PreLevelRowInfo.floor, self.UnlockTipCurLevelText)
            end
            break
          end
        end
      end
    end
  else
    local ModeFloorInfo = self.AllLevelConfigList[WorldIndex]
    local MaxFloor = 0
    for Floor, value in pairs(ModeFloorInfo) do
      if Floor > MaxFloor then
        MaxFloor = Floor
      end
    end
    if Floor < MaxFloor then
      IsShowUnlockTip = true
      local ModeRowId = ModeFloorInfo[Floor + 1]
      if ModeRowId then
        local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, ModeRowId)
        if Result then
          if RowInfo.IsUseUnlockTip then
            local Format = NSLOCTEXT("WBP_NormalWorldSelectionPanel_C", "UnlockTipFormat", "{0}{1}")
            UnlockTipText = UE.FTextFormat(Format, RowInfo.UnlockTip, self.UnlockTipNextLevelText)
          else
            for i, SingleLevelId in ipairs(RowInfo.dependIDs) do
              local Result, PreLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, SingleLevelId)
              if Result then
                local Result, ModeRowInfo = GetRowData(DT.DT_GameMode, tostring(PreLevelRowInfo.gameWorldID))
                local Name = Floor + 1 > self.UnlockAllWorldFloor and self.AllWorldName or Result and ModeRowInfo.Name or ""
                local Result, GamePassRowInfo = GetRowData(DT.DT_GamePassConfigTable, tostring(PreLevelRowInfo.floor))
                local PassTime = Result and math.floor(GamePassRowInfo.PerfectTime / 60) or 0
                UnlockTipText = UE.FTextFormat(self.UnlockTipText, PassTime, Name, PreLevelRowInfo.floor, self.UnlockTipNextLevelText)
              end
              break
            end
          end
        end
      end
    end
    self.Img_CurSelectBottom:SetColorAndOpacity(self.UnLockCurSelectBottomColor)
    self.Txt_CurSelectDifficultLevel:SetColorAndOpacity(self.UnLockDifficultLevelColor)
  end
  UpdateVisibility(self.UnlockTipPanel, IsShowUnlockTip)
  if IsShowUnlockTip then
    self.RichTxt_UnlockTip:SetText(UnlockTipText)
  end
end
function WBP_NormalWorldSelectionPanel_C:RefreshFloorDropPanel(GameModeIndex, Floor)
  local ModeFloorInfo = self.AllLevelConfigList[GameModeIndex]
  local ModeRowId = ModeFloorInfo[Floor]
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
function WBP_NormalWorldSelectionPanel_C:RefreshBeginnerClearRewardPanel()
  UpdateVisibility(self.SizeBox_BeginnerClearReward, self.CurSelectMode == TableEnums.ENUMGameMode.BEGINERGUIDANCE)
  if self.CurSelectMode ~= TableEnums.ENUMGameMode.BEGINERGUIDANCE then
    return
  end
  local ModeFloorInfo = self.AllLevelConfigList[self.CurSelectedWorldIndex]
  local ModeRowId = ModeFloorInfo[self.CurSelectedFloor]
  if ModeRowId then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, ModeRowId)
    if Result then
      UpdateVisibility(self.SizeBox_BeginnerClearReward, true)
      local Index = 1
      local Item
      for index, SingleResourceInfo in ipairs(RowInfo.FirstPassReward) do
        Item = GetOrCreateItem(self.BeinnerClearRewardList, Index, self.ClearRewardTemplate:StaticClass())
        Item:Show(SingleResourceInfo.key, self.FirstClearText, SingleResourceInfo.value)
        Index = Index + 1
      end
      HideOtherItem(self.BeinnerClearRewardList, Index, true)
    else
      UpdateVisibility(self.SizeBox_BeginnerClearReward, false)
    end
  else
    UpdateVisibility(self.SizeBox_BeginnerClearReward, false)
  end
end
function WBP_NormalWorldSelectionPanel_C:RefreshUnlockContentPanel(GameModeIndex, Floor)
end
function WBP_NormalWorldSelectionPanel_C:RefreshModifyPack()
  UpdateVisibility(self.Canvas_ModifyPack, false)
  local ModeFloorInfo = self.AllLevelConfigList[self.CurSelectedWorldIndex]
  local ModeRowId = ModeFloorInfo[self.CurSelectedFloor]
  if ModeRowId then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, ModeRowId)
    if Result and RowInfo.isModifyPack then
      UpdateVisibility(self.Canvas_ModifyPack, true)
      self.Text_Name:SetText(RowInfo.ModifyPackTitle)
      self.Text_doc:SetText(RowInfo.ModifyPackDesc)
    end
  end
end
function WBP_NormalWorldSelectionPanel_C:BindOnUpdateGameFloorInfo()
  self:RefreshModeList(LogicTeam.GetWorldId())
end
function WBP_NormalWorldSelectionPanel_C:BindOnChangeModeButtonClicked()
  UpdateVisibility(self.DifficultLevelPanel, not self.DifficultLevelPanel:IsVisible())
  UpdateVisibility(self.DifficultLevelBottomPanel, not self.DifficultLevelBottomPanel:IsVisible())
  if self.DifficultLevelBottomPanel:IsVisible() then
    self:PlayAnimation(self.Ani_DifficultLevelBottomPanel_in)
  end
  EventSystem.Invoke(EventDef.BeginnerGuide.OnDifficultLevelPanelShow)
end
function WBP_NormalWorldSelectionPanel_C:BindOnLeftChangeModeButtonClicked()
  local AllWorldConfigInfo = self.AllLevelConfigList[self.CurSelectedWorldIndex]
  local TargetFloor = self.CurSelectedFloor - 1
  local MaxFloor = 1
  for Floor, value in pairs(AllWorldConfigInfo) do
    if Floor > MaxFloor then
      MaxFloor = Floor
    end
  end
  if TargetFloor < 1 then
    TargetFloor = MaxFloor
  end
  EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeDifficultLevelItem, self.CurSelectedWorldIndex, TargetFloor, self.CurSelectMode)
end
function WBP_NormalWorldSelectionPanel_C:BindOnRightChangeModeButtonClicked()
  local AllWorldConfigInfo = self.AllLevelConfigList[self.CurSelectedWorldIndex]
  local TargetFloor = self.CurSelectedFloor + 1
  local MaxFloor = 1
  for Floor, value in pairs(AllWorldConfigInfo) do
    if Floor > MaxFloor then
      MaxFloor = Floor
    end
  end
  if TargetFloor > MaxFloor then
    TargetFloor = 1
  end
  EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeDifficultLevelItem, self.CurSelectedWorldIndex, TargetFloor, self.CurSelectMode)
end
function WBP_NormalWorldSelectionPanel_C:BindOnBtnTipsHovered()
  UpdateVisibility(self.WBP_RuleDescription, true)
end
function WBP_NormalWorldSelectionPanel_C:BindOnBtnTipsUnhovered()
  UpdateVisibility(self.WBP_RuleDescription, false)
end
function WBP_NormalWorldSelectionPanel_C:BindOnBtnModifyPackHovered()
  UpdateVisibility(self.SizeBox_ModifyPackTips, true)
end
function WBP_NormalWorldSelectionPanel_C:BindOnBtnModifyPackUnhovered()
  UpdateVisibility(self.SizeBox_ModifyPackTips, false)
end
function WBP_NormalWorldSelectionPanel_C:BindOnStartMatchButtonClicked()
  local MaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(self.CurSelectedWorldIndex)
  if MaxUnLockFloor < self.CurSelectedFloor then
    return
  end
  UIMgr:Hide(ViewID.UI_MainModeSelection, true)
  local LobbyPanelTagName = LogicLobby.GetLabelTagNameByUIName("UI_LobbyMain")
  LogicLobby.ChangeLobbyPanelLabelSelected(LobbyPanelTagName)
end
function WBP_NormalWorldSelectionPanel_C:ModeItem_OnHover(IsShow, ModeItem, ModeId, WorldId)
  if not IsShow then
    self.WBP_LockWordTip:SetRenderOpacity(0.0)
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
  if not TeamUnLock then
    self.WBP_LockWordTip:Show(LockTeamMembers)
    self.WBP_LockWordTip:SetRenderOpacity(1)
  end
end
function WBP_NormalWorldSelectionPanel_C:DifficultLevel_OnHover(IsShow, Floor)
  if not IsShow then
    self.WBP_LockWordTip:SetRenderOpacity(0.0)
    return
  end
  local ModeGeometry = self.DifficultLevelPanel:GetCachedGeometry()
  local ModeListGeometry = self:GetCachedGeometry()
  local ItemPos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(ModeListGeometry, ModeGeometry)
  local ItemSize = UE.USlateBlueprintLibrary.GetLocalSize(ModeGeometry)
  local New_TipPos_X = ItemPos.X
  local New_TipPos_Y = ItemPos.Y + ItemSize.Y
  local New_TipPos = UE.FVector2D(New_TipPos_X, New_TipPos_Y)
  self.WBP_LockWordTip.Slot:SetPosition(New_TipPos)
  local TeamUnLock, LockTeamMembers = LogicTeam.GetTeamUnLockModeFloorAndMember(self.CurSelectMode, self.CurSelectedWorldIndex, Floor)
  if not TeamUnLock then
    self.WBP_LockWordTip:Show(LockTeamMembers)
    self.WBP_LockWordTip:SetRenderOpacity(1)
  end
end
function WBP_NormalWorldSelectionPanel_C:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if self.MediaPlayer:IsPlaying() then
    self.MediaPlayer:Close()
  end
  EventSystem.RemoveListener(EventDef.ModeSelection.OnChangeModeSelectionItem, self.BindOnChangeModeSelectionItem, self)
  EventSystem.RemoveListener(EventDef.ModeSelection.OnChangeModeDifficultLevelItem, self.BindOnChangeModeDifficultLevelItem, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnUpdateGameFloorInfo, self.BindOnUpdateGameFloorInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnChangeDefaultNeedMatchTeammate, self.RefreshUnderGroup, self)
  LogicLobby.ChangeLobbyMainModelVis(true)
  LogicLobby.ChangeModeSelectionVideoState(false)
  self.WBP_CombatPowerTip:Hide()
  self:StopAllAnimations()
end
function WBP_NormalWorldSelectionPanel_C:Destruct()
  self:OnHide()
  self:UnBindClickHandler()
end
return WBP_NormalWorldSelectionPanel_C
