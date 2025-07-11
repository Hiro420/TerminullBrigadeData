local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_PuzzleDevelopView = Class(ViewBase)
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleHandler = require("Protocol.Puzzle.PuzzleHandler")
local EToggleView = {Upgrade = 1, Reset = 2}
function WBP_PuzzleDevelopView:BindClickHandler()
  self.CheckBox_DetailInfo.OnCheckStateChanged:Add(self, self.BindOnDetailListCheckStateChanged)
  self.Btn_Filter.OnClicked:Add(self, self.BindOnFilterButtonClicked)
  self.MenuToggleGroup.OnCheckStateChanged:Add(self, self.BindOnMenuCheckStateChanged)
  self.Btn_Upgrade.OnMainButtonClicked:Add(self, self.BindOnUpgradeButtonClicked)
  self.Btn_Reset.OnMainButtonClicked:Add(self, self.BindOnResetButtonClicked)
  self.Btn_Level.OnClicked:Add(self, self.BindOnExpandLevelButtonClicked)
end
function WBP_PuzzleDevelopView:UnBindClickHandler()
  self.CheckBox_DetailInfo.OnCheckStateChanged:Remove(self, self.BindOnDetailListCheckStateChanged)
  self.Btn_Filter.OnClicked:Remove(self, self.BindOnFilterButtonClicked)
  self.MenuToggleGroup.OnCheckStateChanged:Remove(self, self.BindOnMenuCheckStateChanged)
  self.Btn_Upgrade.OnMainButtonClicked:Remove(self, self.BindOnUpgradeButtonClicked)
  self.Btn_Reset.OnMainButtonClicked:Remove(self, self.BindOnResetButtonClicked)
  self.Btn_Level.OnClicked:Remove(self, self.BindOnExpandLevelButtonClicked)
end
function WBP_PuzzleDevelopView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("PuzzleDevelopViewModel")
  self:BindClickHandler()
end
function WBP_PuzzleDevelopView:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_PuzzleDevelopView:OnShow(CurSelectedPuzzleId)
  self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  self.ViewModel:SetCurSelectPuzzleId(CurSelectedPuzzleId)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleItemSelected, self, self.BindOnPuzzleItemSelected)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, self, self.BindOnChangePuzzleUpgradeLevelSelected)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateResourceInfo, self, self.BindOnUpdateResourceInfo)
  self.MenuToggleGroup:SelectId(EToggleView.Upgrade)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self:InitSortRuleComboBox()
  self:BindOnDetailListCheckStateChanged(false)
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  UpdateVisibility(self.CanvasPanel_Empty, next(AllPackageInfo) == nil)
  UpdateVisibility(self.CanvasPanel_HasPuzzle, next(AllPackageInfo) ~= nil)
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  for i, SingleResourceInfo in ipairs(ConstTable.MartrixPuzzleResetCost) do
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, SingleResourceInfo.key)
    self.Btn_Reset:SetIconBrush(MakeStringToSoftObjectReference(RowInfo.Icon), self.ResetResourceIconSize)
    self.Btn_Reset:SetContentText(SingleResourceInfo.value)
    break
  end
  UpdateVisibility(self.WBP_PuzzleFilterView, false)
end
function WBP_PuzzleDevelopView:InitNum(...)
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  self.Txt_CurHaveNum:SetText(table.count(AllPackageInfo))
end
function WBP_PuzzleDevelopView:InitSortRuleComboBox(...)
  self.WBP_PuzzleSortRuleComboBox:Show(self)
end
function WBP_PuzzleDevelopView:RefreshPuzzleItemList()
  self.RGTileViewPuzzleList:RecyleAllData()
  local DataObjList = {}
  local PuzzlePackageIdList = {}
  local FilterSelectStatus = self.ViewModel:GetPuzzleFilterSelectStatus()
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  for PuzzleId, SinglePackageInfo in pairs(AllPackageInfo) do
    local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(PuzzleId)
    local Result, PuzzleResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
    if next(FilterSelectStatus[EPuzzleFilterType.World]) == nil or table.Contain(FilterSelectStatus[EPuzzleFilterType.World], PuzzleResourceRowInfo.worldID) then
      local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
      if nil == next(FilterSelectStatus[EPuzzleFilterType.Quality]) or table.Contain(FilterSelectStatus[EPuzzleFilterType.Quality], ResourceRowInfo.Rare) then
        local DetailInfo = PuzzleData:GetPuzzleDetailInfo(PuzzleId)
        local IsContainSubAttr = false
        if nil == next(FilterSelectStatus[EPuzzleFilterType.SubAttr]) then
          IsContainSubAttr = true
        else
          IsContainSubAttr = true
          local SubAttrIdList = {}
          for i, AttrInfo in ipairs(DetailInfo.SubAttrInitV2) do
            SubAttrIdList[AttrInfo.attrID] = true
          end
          for index, SubAttrId in ipairs(FilterSelectStatus[EPuzzleFilterType.SubAttr]) do
            if not SubAttrIdList[SubAttrId] and not DetailInfo.SubAttrGrowth[tostring(SubAttrId)] then
              IsContainSubAttr = false
              break
            end
          end
        end
        if IsContainSubAttr then
          table.insert(PuzzlePackageIdList, PuzzleId)
        end
      end
    end
  end
  UpdateVisibility(self.RGTileViewPuzzleList, next(PuzzlePackageIdList) ~= nil)
  if next(PuzzlePackageIdList) ~= nil then
    local SortFunction = self.ViewModel:GetSortRuleFunction()
    table.sort(PuzzlePackageIdList, SortFunction)
    local IsNeedChangeSelectPuzzleId = not self.ViewModel:GetCurSelectPuzzleId() or not table.Contain(PuzzlePackageIdList, self.ViewModel:GetCurSelectPuzzleId())
    local FocusObj
    for i, PuzzleId in ipairs(PuzzlePackageIdList) do
      local DataObj = self.RGTileViewPuzzleList:GetOrCreateDataObj()
      DataObj.PuzzleId = PuzzleId
      DataObj.CanDrag = false
      DataObj.CanShowToolTipWidget = false
      DataObj.ViewModel = self.ViewModel
      table.insert(DataObjList, DataObj)
      if IsNeedChangeSelectPuzzleId then
        self.ViewModel:SetCurSelectPuzzleId(PuzzleId)
        IsNeedChangeSelectPuzzleId = false
      end
      if PuzzleId == self.ViewModel:GetCurSelectPuzzleId() then
        FocusObj = DataObj
      end
    end
    self.RGTileViewPuzzleList:SetRGListItems(DataObjList, false, true)
    if FocusObj then
      self.RGTileViewPuzzleList:BP_ScrollItemIntoView(FocusObj)
    end
    EventSystem.Invoke(EventDef.Puzzle.OnPuzzleItemSelected, self.ViewModel:GetCurSelectPuzzleId())
  end
  self:InitNum()
end
function WBP_PuzzleDevelopView:RefreshFilterIconStatus(...)
  local FilterSelectList = self.ViewModel:GetPuzzleFilterSelectStatus()
  local IsSelect = false
  for k, SelectList in pairs(FilterSelectList) do
    if next(SelectList) ~= nil then
      IsSelect = true
      break
    end
  end
  if IsSelect then
    self.RGStateController_Filter:ChangeStatus("HasFilter")
  else
    self.RGStateController_Filter:ChangeStatus("NoFilter")
  end
end
function WBP_PuzzleDevelopView:BindOnDetailListCheckStateChanged(IsChecked)
  self.ViewModel:SetIsShowPuzzleDetailList(IsChecked)
  local TargetEntrySize
  if IsChecked then
    TargetEntrySize = self.DetailEntrySize
  else
    TargetEntrySize = self.SimpleEntrySize
  end
  self.RGTileViewPuzzleList:SetEntryWidth(TargetEntrySize.X)
  self.RGTileViewPuzzleList:SetEntryHeight(TargetEntrySize.Y)
  self.RGTileViewPuzzleList:RequestRefresh()
  EventSystem.Invoke(EventDef.Puzzle.UpdatePuzzleListStyle)
end
function WBP_PuzzleDevelopView:BindOnFilterButtonClicked()
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  else
    UpdateVisibility(self.WBP_PuzzleFilterView, true)
    self.WBP_PuzzleFilterView:Show(self.ViewModel)
  end
end
function WBP_PuzzleDevelopView:BindOnMenuCheckStateChanged(ToggleId)
  local LastToggleId = self.CurToggleId
  self.CurToggleId = ToggleId
  UpdateVisibility(self.CanvasPanel_Strengthen, ToggleId == EToggleView.Upgrade)
  UpdateVisibility(self.CanvasPanel_Reset, ToggleId == EToggleView.Reset)
  UpdateVisibility(self.CanvasPanel_UpgradeBg, ToggleId == EToggleView.Upgrade)
  UpdateVisibility(self.CanvasPanel_ResetBg, ToggleId == EToggleView.Reset)
  UpdateVisibility(self.Txt_EmptyUpgrade, ToggleId == EToggleView.Upgrade)
  UpdateVisibility(self.Txt_EmptyReset, ToggleId == EToggleView.Reset)
  self:RefreshOperateInfo()
  if LastToggleId and LastToggleId ~= self.CurToggleId then
    self:PlayAnimation(self.Ani_switch)
    self.WBP_PuzzleDevelopInfoItem:PlaySwitchAnim()
  end
end
function WBP_PuzzleDevelopView:RefreshOperateInfo(...)
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  if next(AllPackageInfo) == nil then
    return
  end
  if self.CurToggleId == EToggleView.Upgrade then
    self:RefreshUpgradeInfo()
  elseif self.CurToggleId == EToggleView.Reset then
    self:RefreshResetInfo()
  end
end
function WBP_PuzzleDevelopView:RefreshUpgradeInfo(...)
  local CurSelectedPuzzleId = self.ViewModel:GetCurSelectPuzzleId()
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.ViewModel:GetCurSelectPuzzleId())
  if not PackageInfo then
    return
  end
  if not self.CurSelectedLevel then
    return
  elseif self.CurSelectedLevel == math.min(PackageInfo.level + 1, self.CurSelectedMaxLevel) then
    self:BindOnChangePuzzleUpgradeLevelSelected(self.CurSelectedLevel)
    return
  end
  local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(CurSelectedPuzzleId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  local LevelInfo = self.ViewModel:GetLevelInfoByQuality(RowInfo.Rare)
  local LevelList = {}
  for Level, LevelInfo in pairs(LevelInfo) do
    if 0 ~= Level then
      table.insert(LevelList, Level)
    end
  end
  table.sort(LevelList, function(A, B)
    return A < B
  end)
  local Index = 1
  for i, Level in ipairs(LevelList) do
    local Item = GetOrCreateItem(self.ScrollList_Level, Index, self.WBP_LevelItem:StaticClass())
    Item:Show(self.ViewModel:GetCurSelectPuzzleId(), Level)
    Index = Index + 1
  end
  HideOtherItem(self.ScrollList_Level, Index, true)
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.ViewModel:GetCurSelectPuzzleId())
  local Level = PackageInfo.level
  EventSystem.Invoke(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, math.min(Level + 1, self.CurSelectedMaxLevel))
end
function WBP_PuzzleDevelopView:RefreshResetInfo(...)
  local PuzzleId = self.ViewModel:GetCurSelectPuzzleId()
  self.WBP_PuzzleDevelopInfoItem:Show(PuzzleId, 0)
  self:UpdateResetButtonStatus()
end
function WBP_PuzzleDevelopView:UpdateResetButtonStatus(...)
  local PuzzleId = self.ViewModel:GetCurSelectPuzzleId()
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
  if 0 == PackageInfo.level then
    print("\229\183\178\228\184\186\229\136\157\229\167\139\231\138\182\230\128\129")
    self.Btn_Reset:SetContentText(self.OriginResetText)
    self.Btn_Reset:SetStyleByBottomStyleRowName(self.OriginResetStyle)
    self.Btn_Reset:SetContentTextColorAndOpacity(self.EnoughResourceColor)
  else
    local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
    local ResourceId = 0
    local NeedResourceNum = 0
    for i, SingleResourceInfo in ipairs(ConstTable.MartrixPuzzleResetCost) do
      self.Btn_Reset:SetContentText(SingleResourceInfo.value)
      ResourceId = SingleResourceInfo.key
      NeedResourceNum = SingleResourceInfo.value
      break
    end
    if PackageInfo.state == EPuzzleStatus.Lock then
      print("\233\148\129\229\174\154\231\138\182\230\128\129")
      self.Btn_Reset:SetInfoText(self.LockResetText)
      self.Btn_Reset:SetStyleByBottomStyleRowName(self.LockResetStyle)
    else
      self.Btn_Reset:SetInfoText(self.NormalResetText)
      self.Btn_Reset:SetStyleByBottomStyleRowName(self.NormalResetStyle)
      local CurResourceNum = LogicOutsidePackback.GetResourceNumById(ResourceId)
      if NeedResourceNum <= CurResourceNum then
        self.Btn_Reset:SetContentTextColorAndOpacity(self.EnoughResourceColor)
      else
        self.Btn_Reset:SetContentTextColorAndOpacity(self.NotEnoughResourceColor)
        self.Btn_Reset:SetContentTextFont(self.ResetBtnNotResourceFont)
      end
    end
  end
end
function WBP_PuzzleDevelopView:BindOnUpgradeButtonClicked(...)
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.ViewModel:GetCurSelectPuzzleId())
  if PackageInfo.level >= self.CurSelectedMaxLevel then
    print("\229\183\178\231\187\143\229\136\176\230\187\161\231\186\167\228\186\134")
    return
  end
  if not self.HasEnoughResource then
    print("\232\181\132\230\186\144\228\184\141\229\164\159")
    ShowWaveWindow(300005)
    return
  end
  PuzzleHandler:RequestUpgradePuzzleToServer(self.ViewModel:GetCurSelectPuzzleId(), self.CurSelectedLevel)
end
function WBP_PuzzleDevelopView:BindOnResetButtonClicked(...)
  local PuzzleId = self.ViewModel:GetCurSelectPuzzleId()
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
  if 0 == PackageInfo.level then
    print("\229\183\178\228\184\186\229\136\157\229\167\139\231\138\182\230\128\129")
    return
  elseif PackageInfo.state == EPuzzleStatus.Lock then
    print("\233\148\129\229\174\154\231\138\182\230\128\129")
    return
  else
    local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
    local ResourceId = 0
    local NeedResourceNum = 0
    for i, SingleResourceInfo in ipairs(ConstTable.MartrixPuzzleResetCost) do
      ResourceId = SingleResourceInfo.key
      NeedResourceNum = SingleResourceInfo.value
      break
    end
    local CurHaveResourceNum = LogicOutsidePackback.GetResourceNumById(ResourceId)
    if NeedResourceNum <= CurHaveResourceNum then
      local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
      local WaveWindow = RGWaveWindowManager:ShowWaveWindowWithDelegate(300003, {}, nil, {
        self,
        function()
          PuzzleHandler:RequestResetPuzzleToServer(PuzzleId)
        end
      })
      WaveWindow:Show({PuzzleId})
    else
      print("\232\181\132\230\186\144\228\184\141\232\182\179")
    end
  end
end
function WBP_PuzzleDevelopView:BindOnExpandLevelButtonClicked(...)
  UpdateVisibility(self.SizeBox_ExpandList, not self.SizeBox_ExpandList:IsVisible())
end
function WBP_PuzzleDevelopView:BindOnSortRuleSelectionChanged(CurSelectedIndex)
  self.ViewModel:SetPuzzleSortRule(CurSelectedIndex)
  self:RefreshPuzzleItemList()
end
function WBP_PuzzleDevelopView:BindOnUpdatePuzzleItemHoverStatus(IsHover, PuzzleId, IsPuzzleBoard)
  if IsHover then
    self.HoveredPuzzleId = PuzzleId
  else
    self.HoveredPuzzleId = nil
  end
  if not IsPuzzleBoard then
    UpdateVisibility(self.PuzzleItemTipSlot, IsHover)
    if IsHover then
      local HoverTip = self.ViewModel:GetPuzzleHoverWidget(PuzzleId)
      HoverTip:ListenInputEvent(false)
      self.PuzzleItemTipSlot:AddChild(HoverTip)
    else
      local HoverTip = self.PuzzleItemTipSlot:GetChildAt(0)
      if HoverTip then
        self.PuzzleItemTipSlot:ClearChildren()
      end
    end
  end
end
function WBP_PuzzleDevelopView:BindOnPuzzleItemSelected(PuzzleId)
  local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(PuzzleId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  local Size = self.BoardItemSize
  local Result, PuzzleRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
  local TemplateSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_SingleHexItem)
  local Index = 1
  local Result, ShapeRowInfo = PuzzleData:GetPuzzleShapeRowInfo(PuzzleId)
  for k, SingleCoordinate in pairs(ShapeRowInfo.initPositions) do
    local Item = GetOrCreateItem(self.CanvasPanel_Puzzle, Index, self.WBP_SingleHexItem:StaticClass())
    local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
    if Slot then
      Slot:SetAnchors(TemplateSlot:GetAnchors())
      Slot:SetAlignment(TemplateSlot:GetAlignment())
      local PosX = 1.5 * Size.X * SingleCoordinate.key
      local PosY = Size.Y * (0 - (-SingleCoordinate.key - SingleCoordinate.value) + SingleCoordinate.value)
      Slot:SetPosition(UE.FVector2D(PosX, PosY))
      Slot:SetAutoSize(true)
    end
    Item:Show(PuzzleId, SingleCoordinate, ShapeRowInfo.initPositions, nil, Index - 1)
    UpdateVisibility(Item, true)
    Index = Index + 1
  end
  HideOtherItem(self.CanvasPanel_Puzzle, Index, true)
  if PuzzleRowInfo.DevelopViewOffsetAndScale[1] then
    local OffsetAndScale = PuzzleRowInfo.DevelopViewOffsetAndScale[1]
    self.CanvasPanel_Puzzle:SetRenderTranslation(UE.FVector2D(OffsetAndScale.x, OffsetAndScale.y))
    self.CanvasPanel_Puzzle:SetRenderScale(UE.FVector2D(OffsetAndScale.z, OffsetAndScale.z))
  else
    self.CanvasPanel_Puzzle:SetRenderTranslation(UE.FVector2D(0.0, 0.0))
    self.CanvasPanel_Puzzle:SetRenderScale(UE.FVector2D(1.0, 1.0))
  end
  self.CurSelectedLevel = 0
  self.CurSelectedPuzzleRare = RowInfo.Rare
  self.CurSelectedMaxLevel = self.ViewModel:GetMaxLevelByQuality(RowInfo.Rare)
  self:RefreshOperateInfo()
end
function WBP_PuzzleDevelopView:BindOnChangePuzzleUpgradeLevelSelected(TargetLevel)
  UpdateVisibility(self.SizeBox_ExpandList, false)
  self.WBP_PuzzleDevelopInfoItem:Show(self.ViewModel:GetCurSelectPuzzleId(), TargetLevel)
  TargetLevel = math.min(TargetLevel, self.CurSelectedMaxLevel)
  if self.CurSelectedLevel == TargetLevel then
    self:RefreshUpgradeButtonStatus()
    return
  end
  self.CurSelectedLevel = TargetLevel
  self:RefreshUpgradeResouceStatus()
  local LevelFmt = NSLOCTEXT("PuzzleDevelopView", "CurSelectLevel", "{0}\231\186\167")
  local LevelTxt = UE.FTextFormat(LevelFmt(), TargetLevel)
  self.Txt_CurSelectLevel:SetText(LevelTxt)
  self:RefreshUpgradeButtonStatus()
end
function WBP_PuzzleDevelopView:RefreshUpgradeResouceStatus(...)
  local CurPuzzleId = self.ViewModel:GetCurSelectPuzzleId()
  local LevelInfo = self.ViewModel:GetLevelInfoByQuality(self.CurSelectedPuzzleRare)
  local CostResourceInfo = {}
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(CurPuzzleId)
  for i = PackageInfo.level, self.CurSelectedLevel do
    if i > PackageInfo.level then
      local CostUpgradeResourceList = LevelInfo[i].UpgradeCostResource
      for i, ResourceInfo in ipairs(CostUpgradeResourceList) do
        if not CostResourceInfo[ResourceInfo.key] then
          CostResourceInfo[ResourceInfo.key] = 0
        end
        CostResourceInfo[ResourceInfo.key] = CostResourceInfo[ResourceInfo.key] + ResourceInfo.value
      end
    end
  end
  local Index = 1
  self.HasEnoughResource = true
  local ResourceList = {}
  for ResourceId, Num in pairs(CostResourceInfo) do
    table.insert(ResourceList, ResourceId)
  end
  table.sort(ResourceList, function(A, B)
    return A < B
  end)
  for i, ResourceId in ipairs(ResourceList) do
    local Item = GetOrCreateItem(self.Horizontal_ResourceList, Index, self.WBP_ResourceItem:StaticClass())
    Item:Show(ResourceId, CostResourceInfo[ResourceId])
    Item:UpdateNumTextStatus(CostResourceInfo[ResourceId])
    Index = Index + 1
    local ResourceNum = LogicOutsidePackback.GetResourceNumById(ResourceId)
    if ResourceNum < CostResourceInfo[ResourceId] then
      self.HasEnoughResource = false
    end
  end
  HideOtherItem(self.Horizontal_ResourceList, Index, true)
end
function WBP_PuzzleDevelopView:RefreshUpgradeButtonStatus(...)
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.ViewModel:GetCurSelectPuzzleId())
  if PackageInfo.level >= self.CurSelectedMaxLevel then
    self.Btn_Upgrade:SetStyleByBottomStyleRowName(self.UpgradeMaxStyle)
    self.Btn_Upgrade:SetContentText(self.MaxUpgradeText)
  else
    self.Btn_Upgrade:SetContentText(self.NormalText)
    if self.HasEnoughResource then
      self.Btn_Upgrade:SetStyleByBottomStyleRowName(self.NormalUpgradeStyle)
    else
      self.Btn_Upgrade:SetStyleByBottomStyleRowName(self.NotEnoughResourceUpgradeStyle)
    end
  end
end
function WBP_PuzzleDevelopView:BindOnUpdatePuzzlePackageInfo(PuzzleIdList)
  if not PuzzleIdList or table.Contain(PuzzleIdList, self.HoveredPuzzleId) then
    local HoverWidget = self.ViewModel:GetPuzzleHoverWidget(self.HoveredPuzzleId)
    HoverWidget:RefreshOperateVis()
  end
  if PuzzleIdList and table.Contain(PuzzleIdList, self.ViewModel:GetCurSelectPuzzleId()) then
    if self.CurToggleId == EToggleView.Upgrade then
      local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.ViewModel:GetCurSelectPuzzleId())
      if PackageInfo.level >= self.CurSelectedLevel then
        EventSystem.Invoke(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, math.min(self.CurSelectedLevel + 1, self.CurSelectedMaxLevel))
      end
      self.WBP_PuzzleDevelopInfoItem:Show(self.ViewModel:GetCurSelectPuzzleId(), self.CurSelectedLevel)
    elseif self.CurToggleId == EToggleView.Reset then
      self:RefreshResetInfo()
    end
  end
end
function WBP_PuzzleDevelopView:BindOnUpdateResourceInfo(...)
  if self.CurToggleId == EToggleView.Upgrade then
    self:RefreshUpgradeResouceStatus()
    self:RefreshUpgradeButtonStatus()
  end
end
function WBP_PuzzleDevelopView:PlayUpgradeSuccessAnim(...)
  self.WBP_PuzzleDevelopInfoItem:PlayUpgradeSuccessAnim()
end
function WBP_PuzzleDevelopView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  end
  UpdateVisibility(self.SizeBox_ExpandList, false)
  self.WBP_PuzzleSortRuleComboBox:HideExpandList()
  return UE.UWidgetBlueprintLibrary.Unhandled()
end
function WBP_PuzzleDevelopView:OnHide()
  self.ViewModel:OnViewClose()
  self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  local AllChildren = self.ScrollList_Level:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  self:StopAllAnimations()
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleItemSelected, self, self.BindOnPuzzleItemSelected)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, self, self.BindOnChangePuzzleUpgradeLevelSelected)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateResourceInfo, self, self.BindOnUpdateResourceInfo)
end
return WBP_PuzzleDevelopView
