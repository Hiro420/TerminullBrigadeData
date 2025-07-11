local WBP_GameplaySelectionItem_C = UnLua.Class()
function WBP_GameplaySelectionItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, WBP_GameplaySelectionItem_C.BindOnMainButtonClicked)
  self.Btn_Left.OnClicked:Add(self, WBP_GameplaySelectionItem_C.BindOnLeftButtonClicked)
  self.Btn_Left.OnHovered:Add(self, WBP_GameplaySelectionItem_C.BindOnLeftButtonHovered)
  self.Btn_Left.OnUnhovered:Add(self, WBP_GameplaySelectionItem_C.BindOnLeftButtonUnhovered)
  self.Btn_Right.OnClicked:Add(self, WBP_GameplaySelectionItem_C.BindOnRightButtonClicked)
  self.Btn_Right.OnHovered:Add(self, WBP_GameplaySelectionItem_C.BindOnRightButtonHovered)
  self.Btn_Right.OnUnhovered:Add(self, WBP_GameplaySelectionItem_C.BindOnRightButtonUnhovered)
  self.Btn_Difficult.OnClicked:Add(self, WBP_GameplaySelectionItem_C.BindOnDifficultButtonClicked)
  EventSystem.AddListener(self, EventDef.Lobby.OnModeInfoItemClicked, WBP_GameplaySelectionItem_C.BindOnModeInfoItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.OnGameplaySelectionBGClicked, WBP_GameplaySelectionItem_C.BindOnGameplaySelectionBGClicked)
end
function WBP_GameplaySelectionItem_C:BindOnMainButtonClicked()
  if not self.IsSelected then
    EventSystem.Invoke(EventDef.Lobby.OnModeInfoItemClicked, self.ModeId, self.CurSelectFloor)
  end
end
function WBP_GameplaySelectionItem_C:BindOnLeftButtonClicked()
  local LeftLevelInfo = self.ModeLevels[self.CurSelectFloor - 1]
  if not LeftLevelInfo then
    print("\230\178\161\230\156\137\230\155\180\228\189\142\233\154\190\229\186\166")
    return
  end
  EventSystem.Invoke(EventDef.Lobby.OnModeInfoItemClicked, self.ModeId, self.CurSelectFloor - 1)
end
function WBP_GameplaySelectionItem_C:BindOnLeftButtonHovered()
  self.Img_LeftHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_GameplaySelectionItem_C:BindOnLeftButtonUnhovered()
  self.Img_LeftHover:SetVisibility(UE.ESlateVisibility.Hidden)
end
function WBP_GameplaySelectionItem_C:BindOnRightButtonClicked()
  local LeftLevelInfo = self.ModeLevels[self.CurSelectFloor + 1]
  if not LeftLevelInfo then
    print("\230\178\161\230\156\137\230\155\180\233\171\152\233\154\190\229\186\166")
    return
  end
  EventSystem.Invoke(EventDef.Lobby.OnModeInfoItemClicked, self.ModeId, self.CurSelectFloor + 1)
end
function WBP_GameplaySelectionItem_C:BindOnRightButtonHovered()
  self.Img_RightHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_GameplaySelectionItem_C:BindOnRightButtonUnhovered()
  self.Img_RightHover:SetVisibility(UE.ESlateVisibility.Hidden)
end
function WBP_GameplaySelectionItem_C:BindOnDifficultButtonClicked()
  if self.IsOpenDifficultPanel then
    self:ChangeDifficultPanelVis(false)
  else
    self:ChangeDifficultPanelVis(true)
    self:RefreshDifficultList()
  end
end
function WBP_GameplaySelectionItem_C:BindOnModeInfoItemClicked(ModeId, Floor)
  if self.ModeId == ModeId then
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if table.count(self.ModeLevels) > 1 then
      self.CurrentDifficultPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      if not self.IsSelected then
        self:PlayAnimationForward(self.ani_selected)
      end
    else
      self.CurrentDifficultPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    local MaxConfigFloor = table.count(self.ModeLevels)
    if Floor > MaxConfigFloor then
      Floor = MaxConfigFloor
    end
    local TargetFloorInfo = self.ModeLevels[Floor]
    self.Txt_CurDifficult:SetText(TargetFloorInfo.LevelName)
    local CurUnLockMaxFloor = DataMgr.GetGameFloorByGameMode(self.ModeId)
    if Floor > CurUnLockMaxFloor then
      self.Img_LevelLock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      local PreFloorInfo = self.ModeLevels[Floor - 1]
      if PreFloorInfo then
        self.Txt_UnLockDesc:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.Txt_UnLockDesc:SetText(string.format(self.UnLockConditionText, PreFloorInfo.LevelName))
      end
    else
      self.Txt_UnLockDesc:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Img_LevelLock:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    self.CurSelectFloor = Floor
    self.IsSelected = true
    local LeftLevelInfo = self.ModeLevels[self.CurSelectFloor - 1]
    local RightLevelInfo = self.ModeLevels[self.CurSelectFloor + 1]
    if not LeftLevelInfo then
      self.Img_Left:SetColorAndOpacity(self.CanNotChangeDifficultColor)
    else
      self.Img_Left:SetColorAndOpacity(self.CanChangeDifficultColor)
    end
    if not RightLevelInfo then
      self.Img_Right:SetColorAndOpacity(self.CanNotChangeDifficultColor)
    else
      self.Img_Right:SetColorAndOpacity(self.CanChangeDifficultColor)
    end
  else
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CurrentDifficultPanel:SetVisibility(UE.ESlateVisibility.Hidden)
    self.IsSelected = false
    local MaxConfigFloor = table.count(self.ModeLevels)
    local UnLockFloor = DataMgr.GetGameFloorByGameMode(self.ModeId)
    if MaxConfigFloor < UnLockFloor then
      UnLockFloor = MaxConfigFloor
    end
    self.CurSelectFloor = UnLockFloor
  end
  if self.IsOpenDifficultPanel then
    self:ChangeDifficultPanelVis(false)
  end
end
function WBP_GameplaySelectionItem_C:BindOnGameplaySelectionBGClicked()
  if self.IsOpenDifficultPanel then
    self:ChangeDifficultPanelVis(false)
  end
end
function WBP_GameplaySelectionItem_C:ChangeDifficultPanelVis(IsShow)
  self.IsOpenDifficultPanel = IsShow
  if self.IsOpenDifficultPanel then
    self.DifficultPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimationForward(self.ani_DifficultPanel_in)
    local ParentWidget = self:GetParent()
    if ParentWidget then
      ParentWidget:SetConsumeMouseWheel(UE.EConsumeMouseWheel.Never)
    end
  else
    self.DifficultPanel:SetVisibility(UE.ESlateVisibility.Hidden)
    local ParentWidget = self:GetParent()
    if ParentWidget then
      ParentWidget:SetConsumeMouseWheel(UE.EConsumeMouseWheel.WhenScrollingPossible)
    end
  end
end
function WBP_GameplaySelectionItem_C:RefreshDifficultList()
  local AllItem = self.DifficultList:GetAllChildren()
  for i, SingleItem in pairs(AllItem) do
    SingleItem:Hide()
  end
  for i, SingleModeLevelInfo in ipairs(self.ModeLevels) do
    local Item = self.DifficultList:GetChildAt(i - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.DifficultItemTemplate:StaticClass())
      self.DifficultList:AddChild(Item)
    end
    Item:Show(i, SingleModeLevelInfo, self.ModeId)
  end
end
function WBP_GameplaySelectionItem_C:Show(ModeId)
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.ModeId = ModeId
  self.CurSelectFloor = DataMgr.GetGameFloorByGameMode(self.ModeId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowInfo = DTSubsystem:GetGameModeRowInfoById(self.ModeId, nil)
  if not Result then
    print("\230\137\190\228\184\141\229\136\176\232\175\165\230\168\161\229\188\143\228\191\161\230\129\175\239\188\140\230\168\161\229\188\143ID:", self.ModeId)
  end
  self.Txt_ModeName:SetText(RowInfo.Name)
  SetImageBrushBySoftObject(self.Img_ModeIcon, RowInfo.Icon)
  self.ModeLevels = RowInfo.ModeLevels:ToTable()
  self:ChangeDifficultPanelVis(false)
  if RowInfo.bUnLock then
    self.LockPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.LockPanel:SetVisibility(UE.ESlateVisibility.Visible)
  end
  self.Img_LeftHover:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Img_RightHover:SetVisibility(UE.ESlateVisibility.Hidden)
end
function WBP_GameplaySelectionItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_GameplaySelectionItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.OnModeInfoItemClicked, WBP_GameplaySelectionItem_C.BindOnModeInfoItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnGameplaySelectionBGClicked, WBP_GameplaySelectionItem_C.BindOnGameplaySelectionBGClicked, self)
end
return WBP_GameplaySelectionItem_C
