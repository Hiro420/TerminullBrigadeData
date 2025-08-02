local WBP_LoadingPanel = UnLua.Class()
local MAXSCREENSIZE = 2.388888888888889
local MINSCREENSIZE = 1.3333333333333333

function WBP_LoadingPanel:Construct()
  self:ResizeCanvasPanel()
  local CurLoadingScreenType = self:GetLoadingScreenType()
  local Result, RowInfo = GetRowData(DT.DT_LoadingScreen, CurLoadingScreenType)
  if not Result then
    print("WBP_LoadingPanel:Construct DT_LoadingScreen RowInfo is nil! Please check rowName:", CurLoadingScreenType)
    return
  end
  self.LevelList = {}
  UpdateVisibility(self.CanvasPanel_Progress, RowInfo.IsNeedLevelProgress)
  if RowInfo.IsNeedLevelProgress then
    local GameLevelSystem = UE.URGGameLevelSystem.GetInstance(self)
    local WorldConfigs = GameLevelSystem.WorldConfigs
    for k, SingleWorldConfig in pairs(WorldConfigs.Worlds) do
      local Index = 1
      for i, SingleLevelConfig in pairs(SingleWorldConfig.Levels) do
        if SingleLevelConfig.LevelType ~= UE.ERGLevelType.ReadyRoom then
          table.insert(self.LevelList, SingleLevelConfig.LevelId)
        end
        Index = Index + 1
      end
    end
    self:InitLevelProgress()
  end
  if not RowInfo.IsNeedBG then
    self.Img_BG:SetBrush(self.EmptyBGBrush)
  else
    self:InitBG()
  end
  UpdateVisibility(self.CanvasPanel_Icon, RowInfo.IsNeedIcon)
  UpdateVisibility(self.CanvasPanel_LoadingAnim, RowInfo.IsNeedLoadingAnim)
  self.IsNeedLoadingAnim = RowInfo.IsNeedLoadingAnim
  UpdateVisibility(self.CanvasPanel_TipText, RowInfo.IsNeedTipText)
  if RowInfo.IsNeedTipText then
    self:InitTipText()
  end
  local IsReadyLevelToNextLevel = "ReadyLevelToNextLevel" == CurLoadingScreenType
  UpdateVisibility(self.Img_BG, not IsReadyLevelToNextLevel)
  UpdateVisibility(self.URGImage_76, not IsReadyLevelToNextLevel)
  UpdateVisibility(self.URGImage_80, not IsReadyLevelToNextLevel)
  UpdateVisibility(self.CanvasPanel_ReadyLevelToWorld, IsReadyLevelToNextLevel)
  if IsReadyLevelToNextLevel then
    self:InitReadyLevelToNextLevel()
  end
end

function WBP_LoadingPanel:ResizeCanvasPanel()
  local scale = UE.URGBlueprintLibrary.GetCurrentViewportScale(self)
  local screenSize = UE.URGBlueprintLibrary.GetCurrentViewportSize(self) / scale
  local ui = self.CanvasPanelRoot
  if screenSize.X / screenSize.Y > MAXSCREENSIZE then
    local newx = MAXSCREENSIZE * screenSize.Y
    if ui then
      local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ui)
      Slot:SetAnchors(UE.FAnchors(0.5, 0.5, 0.5, 0.5))
      Slot:SetAlignment(UE.FVector2D(0.5, 0.5))
      Slot:SetSize(UE.FVector2D(newx, screenSize.Y))
      Slot:SetPosition(UE.FVector2D(screenSize.X / 2, screenSize.Y / 2))
    end
    return
  end
  if screenSize.X / screenSize.Y < MINSCREENSIZE then
    local newy = screenSize.X / MINSCREENSIZE
    if ui then
      local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ui)
      Slot:SetAnchors(UE.FAnchors(0.5, 0.5, 0.5, 0.5))
      Slot:SetAlignment(UE.FVector2D(0.5, 0.5))
      Slot:SetSize(UE.FVector2D(screenSize.X, newy))
      Slot:SetPosition(UE.FVector2D(screenSize.X / 2, screenSize.Y / 2))
    end
    return
  end
  if ui then
    local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ui)
    Slot:SetAnchors(UE.FAnchors(0, 0, 1, 1))
    Slot:SetAlignment(UE.FVector2D(0, 0))
    Slot:SetSize(UE.FVector2D(screenSize.X, screenSize.Y))
    Slot:SetPosition(UE.FVector2D(0, 0))
  end
end

function WBP_LoadingPanel:InitReadyLevelToNextLevel()
  local WorldModeId = UE.URGLevelLibrary.GetWorldModeId()
  print("WBP_LoadingPanel:InitReadyLevelToNextLevel", WorldModeId)
  self:SetIsNeedReadyLevelToNextAnim(true)
  local AResult, WorldModeRowInfo = GetRowData(DT.DT_GameMode, WorldModeId)
  if AResult then
    local NumArray = UE.UKismetStringLibrary.GetCharacterArrayFromString(tostring(WorldModeRowInfo.Name))
    local NameNum = NumArray:Length()
    self:SetNameMaterial(NameNum)
    self.Txt_WorldName:SetText(WorldModeRowInfo.Name)
    SetImageBrushBySoftObjectPath(self.Img_WorldName, WorldModeRowInfo.ReadyLevelToNextLevelTextImg)
    self.Txt_WorldDesc:SetText(WorldModeRowInfo.ReadyLevelToNextLevelDesc)
  end
end

function WBP_LoadingPanel:IsBattleLoading(...)
  local CurLoadingScreenType = self:GetLoadingScreenType()
  return "InBattle" == CurLoadingScreenType
end

function WBP_LoadingPanel:IsLobbyToBattleLoading()
  local CurLoadingScreenType = self:GetLoadingScreenType()
  return "LobbyToBattle" == CurLoadingScreenType
end

function WBP_LoadingPanel:GetLoadingScreenType(...)
  local CurLoadingScreenType = UE.UAsyncLoadingScreenLibrary.GetLoadingScreenType()
  if "None" == CurLoadingScreenType then
    return "default"
  else
    return CurLoadingScreenType
  end
end

function WBP_LoadingPanel:InitBG(...)
  local CurLoadingScreenType = self:GetLoadingScreenType()
  local LoadingScreenSettings = UE.UAsyncLoadingScreenLibrary.GetLoadingScreenSettingsByScreenType(CurLoadingScreenType)
  if not self:IsBattleLoading() then
    if self:IsLobbyToBattleLoading() then
      local CurWorldId = LogicTeam.GetWorldId()
      local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(CurWorldId))
      if Result and UE.URGBlueprintLibrary.IsValidSoftObjectPath(RowInfo.LobbyToBattleLoadingImg) then
        SetImageBrushBySoftObjectPath(self.Img_BG, RowInfo.LobbyToBattleLoadingImg)
        return
      end
    end
    local Length = LoadingScreenSettings.Background.Images:Length()
    if Length > 1 then
      local RandomIndex = math.random(1, Length)
      SetImageBrushBySoftObjectPath(self.Img_BG, LoadingScreenSettings.Background.Images:Get(RandomIndex))
    elseif 1 == Length then
      SetImageBrushBySoftObjectPath(self.Img_BG, LoadingScreenSettings.Background.Images:Get(1))
    else
      print("WBP_LoadingPanel:InitBG LoadingBG List is empty!", CurLoadingScreenType)
      self.Img_BG:SetBrush(self.EmptyBGBrush)
    end
  else
    local CurrentLevelIndex = UE.UAsyncLoadingScreenLibrary.GetDisplayProgressMarkIndex()
    local LevelId = self.LevelList[CurrentLevelIndex]
    print("WBP_LoadingPanel:InitBG", LevelId, CurrentLevelIndex)
    local Result, RowInfo = false
    if LevelId then
      Result, RowInfo = GetRowData(DT.DT_WorldLevelPool, LevelId)
    end
    if not Result then
      print("WBP_LoadingPanel:InitBG DT_LevelDetail row is nil!", LevelId)
      self.Img_BG:SetBrush(self.EmptyBGBrush)
    else
      local BGIndex = RowInfo.LoadingConfig.BackgroundIndex + 1
      if LoadingScreenSettings.Background.Images:IsValidIndex(BGIndex) then
        SetImageBrushBySoftObjectPath(self.Img_BG, LoadingScreenSettings.Background.Images:Get(BGIndex))
      else
        self.Img_BG:SetBrush(self.EmptyBGBrush)
      end
    end
  end
end

function WBP_LoadingPanel:InitTipText()
  local AllLoadingText = GetAllRowNames(DT.DT_LoadingText)
  local CommonTextList = {}
  for i, SingleLoadingTextRowName in ipairs(AllLoadingText) do
    local Result, RowInfo = GetRowData(DT.DT_LoadingText, SingleLoadingTextRowName)
    if RowInfo.IsCommonText then
      table.insert(CommonTextList, RowInfo.Text)
    end
  end
  if not self:IsBattleLoading() then
    if self:IsLobbyToBattleLoading() then
      local CurWorldId = LogicTeam.GetWorldId()
      local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(CurWorldId))
      if Result then
        local ModeCommonTextList = RowInfo.LobbyToBattleLoadingTips
        local Length = 0
        local RandomList = {}
        local RandomWeightList = {}
        for LoadingTextId, LoadingTextWeight in pairs(ModeCommonTextList) do
          table.insert(RandomList, LoadingTextId)
          table.insert(RandomWeightList, LoadingTextWeight)
          Length = Length + 1
        end
        if Length > 0 then
          local LoadingTextId = RandomListByWeight(RandomList, RandomWeightList)
          local Result, RowInfo = GetRowData(DT.DT_LoadingText, LoadingTextId)
          if Result then
            self.Txt_Text:SetText(RowInfo.Text)
            return
          end
        end
      end
    end
    local RandomIndex = math.random(1, #CommonTextList)
    self.Txt_Text:SetText(CommonTextList[RandomIndex])
  else
    local CurrentLevelIndex = UE.UAsyncLoadingScreenLibrary.GetDisplayProgressMarkIndex()
    local LevelId = self.LevelList[CurrentLevelIndex]
    local Result, RowInfo = false
    if LevelId then
      Result, RowInfo = GetRowData(DT.DT_LevelLoadingText, LevelId)
    end
    if not Result then
      print("WBP_LoadingPanel:InitTipText DT_LevelLoadingText row is nil!", LevelId)
      local RandomIndex = math.random(1, #CommonTextList)
      self.Txt_Text:SetText(CommonTextList[RandomIndex])
    else
      local RandomList = {1}
      local RandomWeightList = {
        self.CommonLoadingTextWeight
      }
      local LevelCommonTextList = RowInfo.CommonTextList.TextList
      if LevelCommonTextList:Length() > 0 then
        table.insert(RandomList, 2)
        table.insert(RandomWeightList, self.LevelCommonLoadingTextWeight)
      end
      local LevelModeTextList = RowInfo.ModeTextList:Find(LogicTeam.GetModeId())
      if LevelModeTextList and LevelModeTextList.TextList:Length() > 0 then
        table.insert(RandomList, 3)
        table.insert(RandomWeightList, self.LevelModeLoadingTextWeight)
      end
      local RandomListIndex = RandomListByWeight(RandomList, RandomWeightList)
      print("WBP_LoadingPanel:InitTipText Random List Index is", RandomListIndex)
      if 1 == RandomListIndex then
        local RandomIndex = math.random(1, #CommonTextList)
        self.Txt_Text:SetText(CommonTextList[RandomIndex])
      elseif 2 == RandomListIndex then
        local RandomIndex = math.random(1, LevelCommonTextList:Length())
        local TargetTextId = LevelCommonTextList:Get(RandomIndex)
        local Result, TextRowInfo = GetRowData(DT.DT_LoadingText, TargetTextId)
        self.Txt_Text:SetText(TextRowInfo.Text)
      elseif 3 == RandomListIndex then
        local RandomIndex = math.random(1, LevelModeTextList.TextList:Length())
        local TargetTextId = LevelModeTextList.TextList:Get(RandomIndex)
        local Result, TextRowInfo = GetRowData(DT.DT_LoadingText, TargetTextId)
        self.Txt_Text:SetText(TextRowInfo.Text)
      end
    end
  end
end

local EProgressStatus = {
  NoPass = 1,
  Current = 2,
  Pass = 3
}

function WBP_LoadingPanel:InitLevelProgress(...)
  local CurrentLevelIndex = UE.UAsyncLoadingScreenLibrary.GetDisplayProgressMarkIndex()
  local CurrentLevelId = self.LevelList[CurrentLevelIndex]
  print("WBP_LoadingPanel:InitLevelProgress", CurrentLevelId)
  local Index = 1
  for i, SingleLevelId in ipairs(self.LevelList) do
    local Item = GetOrCreateItem(self.HorizontalBox_Main, Index, self.WBP_LoadingPanelItem:StaticClass())
    local IconSoftObj
    local ProgressStatus = EProgressStatus.NoPass
    if i == #self.LevelList then
      if i == CurrentLevelIndex then
        IconSoftObj = self.LastLevelCurrentProgressIcon
        ProgressStatus = EProgressStatus.Current
      else
        IconSoftObj = self.LastLevelPassProgressIcon
      end
    else
      local Result, RowInfo = GetRowData(DT.DT_WorldLevelPool, SingleLevelId)
      if i < CurrentLevelIndex then
        if RowInfo.LevelType == UE.ERGLevelType.BossRoom then
          IconSoftObj = self.BossPassProgressIcon
        else
          IconSoftObj = self.NormalPassProgressIcon
        end
        ProgressStatus = EProgressStatus.Pass
      elseif i == CurrentLevelIndex then
        if RowInfo.LevelType == UE.ERGLevelType.BossRoom then
          IconSoftObj = self.BossCurrentProgressIcon
        else
          IconSoftObj = self.NormalCurrentProgressIcon
        end
        ProgressStatus = EProgressStatus.Current
      else
        if RowInfo.LevelType == UE.ERGLevelType.BossRoom then
          IconSoftObj = self.BossPassProgressIcon
        else
          IconSoftObj = self.NormalPassProgressIcon
        end
        ProgressStatus = EProgressStatus.NoPass
      end
    end
    Item:Show(ProgressStatus, IconSoftObj)
    Index = Index + 1
  end
  HideOtherItem(self.HorizontalBox_Main, Index, true)
end

function WBP_LoadingPanel:Destruct(...)
  self:StopAllAnimations()
end

return WBP_LoadingPanel
