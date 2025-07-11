local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_GemUpgradeView = Class(ViewBase)
local GemData = require("Modules.Gem.GemData")
local GemHandler = require("Protocol.Gem.GemHandler")
local EGemDevelopType = {Upgrade = 1, Mutation = 2}
local RefactorResourceVarList = {
  [EPuzzleRefactorType.Mutation] = "MutationCost",
  [EPuzzleRefactorType.SeniorMutation] = "SeniorMutationCost"
}
function WBP_GemUpgradeView:BindClickHandler()
  self.Btn_Filter.OnClicked:Add(self, self.BindOnFilterButtonClicked)
  self.Btn_Upgrade.OnMainButtonClicked:Add(self, self.BindOnUpgradeButtonClicked)
  self.Btn_Level.OnClicked:Add(self, self.BindOnExpandLevelButtonClicked)
  self.MenuToggleGroup.OnCheckStateChanged:Add(self, self.BindOnMenuCheckStateChanged)
  self.Btn_Refactor.OnMainButtonClicked:Add(self, self.BindOnMutationButtonClicked)
  self.Btn_JumpToModeSelection.OnMainButtonClicked:Add(self, self.BindOnJumpToModeSelectionButtonClicked)
  self.Btn_SelectMat.OnClicked:Add(self, self.BindOnSelectMatButtonClicked)
end
function WBP_GemUpgradeView:UnBindClickHandler()
  self.Btn_Filter.OnClicked:Remove(self, self.BindOnFilterButtonClicked)
  self.Btn_Upgrade.OnMainButtonClicked:Remove(self, self.BindOnUpgradeButtonClicked)
  self.Btn_Level.OnClicked:Remove(self, self.BindOnExpandLevelButtonClicked)
  self.MenuToggleGroup.OnCheckStateChanged:Remove(self, self.BindOnMenuCheckStateChanged)
  self.Btn_Refactor.OnMainButtonClicked:Remove(self, self.BindOnMutationButtonClicked)
  self.Btn_JumpToModeSelection.OnMainButtonClicked:Remove(self, self.BindOnJumpToModeSelectionButtonClicked)
  self.Btn_SelectMat.OnClicked:Remove(self, self.BindOnSelectMatButtonClicked)
end
function WBP_GemUpgradeView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("GemUpgradeViewModel")
  self:BindClickHandler()
end
function WBP_GemUpgradeView:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_GemUpgradeView:OnShow(CurSelectedGemId)
  self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  self.ViewModel:SetCurSelectGemId(CurSelectedGemId)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemItemSelected, self, self.BindOnGemItemSelected)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, self, self.BindOnChangePuzzleUpgradeLevelSelected)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateResourceInfo, self, self.BindOnUpdateResourceInfo)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemUpgradeSuccess, self, self.BindOnGemUpgradeSuccess)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleRefactorMaterialSelected, self, self.BindOnPuzzleRefactorMaterialSelected)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self.MenuToggleGroup:SelectId(EGemDevelopType.Upgrade)
  self.CurSelectMutationResourceId = nil
  self:InitSortRuleComboBox()
  self:InitMutationMatList()
  self:RefreshFilterIconStatus()
  UpdateVisibility(self.CanvasPanel_MatSelectPanel, false)
  local GemPackageInfo = GemData:GetAllGemPackageInfo()
  UpdateVisibility(self.CanvasPanel_Empty, nil == next(GemPackageInfo))
  UpdateVisibility(self.CanvasPanel_HasGem, nil ~= next(GemPackageInfo))
  UpdateVisibility(self.WBP_PuzzleFilterView, false)
end
function WBP_GemUpgradeView:InitMutationMatList()
  local Index = 1
  for k, ResourceId in pairs(self.MutationMatList) do
    local Item = GetOrCreateItem(self.WrapBox_MatList, Index, self.WBP_PuzzleRefactorMatItem:StaticClass())
    local Num = LogicOutsidePackback.GetResourceNumById(ResourceId)
    if Num > 0 then
      if Item.Show then
        Item:Show(ResourceId)
      end
      Index = Index + 1
    end
  end
  HideOtherItem(self.WrapBox_MatList, Index, true)
  UpdateVisibility(self.Overlay_HasMat, 1 ~= Index)
  UpdateVisibility(self.Overlay_EmptyMat, 1 == Index)
  EventSystem.Invoke(EventDef.Puzzle.OnPuzzleRefactorMaterialSelected, self.CurSelectMutationResourceId)
end
function WBP_GemUpgradeView:InitNum(...)
  local AllPackageInfo = GemData:GetAllGemPackageInfo()
  self.Txt_CurHaveNum:SetText(table.count(AllPackageInfo))
end
function WBP_GemUpgradeView:InitSortRuleComboBox(...)
  self.WBP_PuzzleSortRuleComboBox:Show(self, true)
end
function WBP_GemUpgradeView:RefreshGemItemList()
  self.RGTileViewGemList:RecyleAllData()
  local DataObjList = {}
  local GemPackageIdList = {}
  local FilterSelectStatus = self.ViewModel:GetGemFilterSelectStatus()
  local AllPackageInfo = GemData:GetAllGemPackageInfo()
  local FilterDiscardStatus = self.ViewModel:GetPuzzleFilterDiscardSelected()
  local FilterLockStatus = self.ViewModel:GetPuzzleFilterLockSelected()
  for GemId, SinglePackageInfo in pairs(AllPackageInfo) do
    if (not FilterDiscardStatus or SinglePackageInfo.state == EGemStatus.Discard) and (not FilterLockStatus or SinglePackageInfo.state == EGemStatus.Lock) then
      local ResourceId = GemData:GetGemResourceIdByUId(GemId)
      local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
      if next(FilterSelectStatus[EPuzzleFilterType.Quality]) == nil or table.Contain(FilterSelectStatus[EPuzzleFilterType.Quality], ResourceRowInfo.Rare) then
        local IsContainSubAttr = false
        if nil == next(FilterSelectStatus[EPuzzleFilterType.SubAttr]) then
          IsContainSubAttr = true
        else
          for index, SubAttrId in ipairs(FilterSelectStatus[EPuzzleFilterType.SubAttr]) do
            if table.Contain(SinglePackageInfo.mainAttrIDs, SubAttrId) then
              IsContainSubAttr = true
              break
            end
          end
        end
        if IsContainSubAttr then
          table.insert(GemPackageIdList, GemId)
        end
      end
    end
  end
  if next(GemPackageIdList) ~= nil then
    local SortFunction = self.ViewModel:GetSortRuleFunction()
    table.sort(GemPackageIdList, SortFunction)
    local IsNeedChangeSelectGemId = not self.ViewModel:GetCurSelectGemId() or not table.Contain(GemPackageIdList, self.ViewModel:GetCurSelectGemId())
    local FocusObj
    for i, GemId in ipairs(GemPackageIdList) do
      local DataObj = self.RGTileViewGemList:GetOrCreateDataObj()
      DataObj.GemId = GemId
      DataObj.CanDrag = false
      DataObj.CanShowToolTipWidget = false
      DataObj.ViewModel = self.ViewModel
      table.insert(DataObjList, DataObj)
      if IsNeedChangeSelectGemId then
        self.ViewModel:SetCurSelectGemId(GemId)
        IsNeedChangeSelectGemId = false
      end
      if GemId == self.ViewModel:GetCurSelectGemId() then
        FocusObj = DataObj
      end
    end
    self.RGTileViewGemList:SetRGListItems(DataObjList, false, true)
    if FocusObj then
      self.RGTileViewGemList:BP_ScrollItemIntoView(FocusObj)
    end
    EventSystem.Invoke(EventDef.Gem.OnGemItemSelected, self.ViewModel:GetCurSelectGemId())
  else
    self.RGTileViewGemList:SetRGListItems(DataObjList, false, true)
  end
  self:InitNum()
end
function WBP_GemUpgradeView:RefreshFilterIconStatus(...)
  local FilterSelectList = self.ViewModel:GetGemFilterSelectStatus()
  local IsSelect = false
  for k, SelectList in pairs(FilterSelectList) do
    if next(SelectList) ~= nil then
      IsSelect = true
      break
    end
  end
  local IsDiscardSelected = self.ViewModel:GetPuzzleFilterDiscardSelected()
  local IsLockSelected = self.ViewModel:GetPuzzleFilterLockSelected()
  if IsDiscardSelected or IsLockSelected then
    IsSelect = true
  end
  if IsSelect then
    self.RGStateController_Filter:ChangeStatus("HasFilter")
  else
    self.RGStateController_Filter:ChangeStatus("NoFilter")
  end
end
function WBP_GemUpgradeView:BindOnFilterButtonClicked()
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  else
    UpdateVisibility(self.WBP_PuzzleFilterView, true)
    self.WBP_PuzzleFilterView:Show(self.ViewModel, true)
  end
end
function WBP_GemUpgradeView:RefreshOperateInfo(...)
  local AllPackageInfo = GemData:GetAllGemPackageInfo()
  if next(AllPackageInfo) == nil then
    return
  end
  if self.SelectUpgradeType == EGemDevelopType.Upgrade then
    self:RefreshUpgradeInfo()
  elseif self.SelectUpgradeType == EGemDevelopType.Mutation then
    local AllChildren = self.ScrollList_Level:GetAllChildren()
    for k, SingleItem in pairs(AllChildren) do
      SingleItem:Hide()
    end
    self:RefreshMutationInfo()
  end
end
function WBP_GemUpgradeView:RefreshUpgradeInfo(...)
  local CurSelectedGemId = self.ViewModel:GetCurSelectGemId()
  if not CurSelectedGemId then
    return
  end
  if not self.CurSelectedLevel then
    return
  end
  local ResourceId = GemData:GetGemResourceIdByUId(CurSelectedGemId)
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
    Item:Show(self.ViewModel:GetCurSelectGemId(), Level, true)
    Index = Index + 1
  end
  HideOtherItem(self.ScrollList_Level, Index, true)
  local PackageInfo = GemData:GetGemPackageInfoByUId(CurSelectedGemId)
  if self.CurSelectedLevel == math.min(PackageInfo.level + 1, self.CurSelectedMaxLevel) then
    self:BindOnChangePuzzleUpgradeLevelSelected(self.CurSelectedLevel)
    return
  end
  local PackageInfo = GemData:GetGemPackageInfoByUId(self.ViewModel:GetCurSelectGemId())
  local Level = PackageInfo.level
  EventSystem.Invoke(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, math.min(Level + 1, self.CurSelectedMaxLevel))
end
function WBP_GemUpgradeView:RefreshMutationInfo()
  local CurSelectedGemId = self.ViewModel:GetCurSelectGemId()
  self.WBP_GemDevelopInfoItem:Show(CurSelectedGemId)
  self:RefreshRefactorButtonStatus()
end
function WBP_GemUpgradeView:BindOnUpgradeButtonClicked(...)
  local PackageInfo = GemData:GetGemPackageInfoByUId(self.ViewModel:GetCurSelectGemId())
  if PackageInfo.level >= self.CurSelectedMaxLevel then
    print("\229\183\178\231\187\143\229\136\176\230\187\161\231\186\167\228\186\134")
    return
  end
  if not self.HasEnoughResource then
    print("\232\181\132\230\186\144\228\184\141\229\164\159")
    ShowWaveWindow(self.NotEnoughResourceTipId)
    return
  end
  GemHandler:RequestUpgradeGemToServer(self.ViewModel:GetCurSelectGemId(), self.CurSelectedLevel)
end
function WBP_GemUpgradeView:BindOnMutationButtonClicked()
  if not self.CanClickRefactorButton then
    if 0 ~= self.RefactorButtonClickTipId then
      ShowWaveWindow(self.RefactorButtonClickTipId)
    end
    return
  end
  local IsSeniorMutation = self.CurSelectMutationResourceId == EPuzzleRefactorType.SeniorMutation or false
  GemHandler:RequestGemMutationToServer({
    self.ViewModel:GetCurSelectGemId()
  }, IsSeniorMutation)
end
function WBP_GemUpgradeView:BindOnJumpToModeSelectionButtonClicked()
  local PuzzleDevelopMain = UIMgr:GetLuaFromActiveView(ViewID.UI_PuzzleDevelopMain)
  if PuzzleDevelopMain then
    PuzzleDevelopMain:BindOnEscKeyPressed()
  end
  UIMgr:Hide(ViewID.UI_DevelopMain, true)
  UIMgr:Show(ViewID.UI_MainModeSelection, true)
end
function WBP_GemUpgradeView:BindOnSelectMatButtonClicked()
  UpdateVisibility(self.CanvasPanel_MatSelectPanel, not self.CanvasPanel_MatSelectPanel:IsVisible())
end
function WBP_GemUpgradeView:BindOnExpandLevelButtonClicked(...)
  UpdateVisibility(self.SizeBox_ExpandList, not self.SizeBox_ExpandList:IsVisible())
end
function WBP_GemUpgradeView:BindOnSelectMatButtonClicked()
  UpdateVisibility(self.CanvasPanel_MatSelectPanel, not self.CanvasPanel_MatSelectPanel:IsVisible())
end
function WBP_GemUpgradeView:BindOnMenuCheckStateChanged(SelectId)
  self.SelectUpgradeType = SelectId
  UpdateVisibility(self.Txt_EmptyUpgrade, self.SelectUpgradeType == EGemDevelopType.Upgrade)
  UpdateVisibility(self.Txt_EmptyMutation, self.SelectUpgradeType == EGemDevelopType.Mutation)
  UpdateVisibility(self.CanvasPanel_Strengthen, self.SelectUpgradeType == EGemDevelopType.Upgrade)
  UpdateVisibility(self.CanvasPanel_Mutation, self.SelectUpgradeType == EGemDevelopType.Mutation)
  self:RefreshOperateInfo()
end
function WBP_GemUpgradeView:BindOnSortRuleSelectionChanged(CurSelectedIndex)
  self.ViewModel:SetPuzzleSortRule(CurSelectedIndex)
  self:RefreshGemItemList()
end
function WBP_GemUpgradeView:BindOnUpdateGemItemHoverStatus(IsHover, GemId, IsPuzzleBoard)
  if IsHover then
    self.HoverGemId = GemId
  else
    self.HoverGemId = nil
  end
  if not IsPuzzleBoard then
    UpdateVisibility(self.PuzzleItemTipSlot, IsHover)
    if IsHover then
      local HoverTip = self.ViewModel:GetGemHoverWidget(GemId)
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
function WBP_GemUpgradeView:BindOnGemItemSelected(PuzzleId)
  local ResourceId = GemData:GetGemResourceIdByUId(PuzzleId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  SetImageBrushByPath(self.Img_GemIcon, RowInfo.Icon)
  self.CurSelectedLevel = 0
  self.CurSelectedGemRare = RowInfo.Rare
  self.CurSelectedMaxLevel = self.ViewModel:GetMaxLevelByQuality(RowInfo.Rare)
  self:RefreshOperateInfo()
end
function WBP_GemUpgradeView:BindOnChangePuzzleUpgradeLevelSelected(TargetLevel)
  UpdateVisibility(self.SizeBox_ExpandList, false)
  self.WBP_GemDevelopInfoItem:Show(self.ViewModel:GetCurSelectGemId(), TargetLevel)
  TargetLevel = math.min(TargetLevel, self.CurSelectedMaxLevel)
  if self.CurSelectedLevel == TargetLevel then
    self:RefreshUpgradeButtonStatus()
    return
  end
  self.CurSelectedLevel = TargetLevel
  self:RefreshUpgradeResourceInfo()
  local LevelFmt = NSLOCTEXT("GemUpgradeView", "CurSelectLevel", "{0}\231\186\167")
  local LevelTxt = UE.FTextFormat(LevelFmt(), TargetLevel)
  self.Txt_CurSelectLevel:SetText(LevelTxt)
  self:RefreshUpgradeButtonStatus()
end
function WBP_GemUpgradeView:RefreshUpgradeResourceInfo(...)
  local CurGemId = self.ViewModel:GetCurSelectGemId()
  local LevelInfo = self.ViewModel:GetLevelInfoByQuality(self.CurSelectedGemRare)
  local CostResourceInfo = {}
  local PackageInfo = GemData:GetGemPackageInfoByUId(CurGemId)
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
function WBP_GemUpgradeView:BindOnUpdateResourceInfo(...)
  self:RefreshUpgradeResourceInfo()
  self:RefreshUpgradeButtonStatus()
  self:InitMutationMatList()
  self:RefreshSelectRefactorResourceInfo()
end
function WBP_GemUpgradeView:RefreshUpgradeButtonStatus(...)
  local PackageInfo = GemData:GetGemPackageInfoByUId(self.ViewModel:GetCurSelectGemId())
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
function WBP_GemUpgradeView:BindOnUpdateGemPackageInfo(GemId)
  if not GemId or self.HoverGemId == GemId then
    local HoverWidget = self.ViewModel:GetGemHoverWidget(self.HoverGemId)
    HoverWidget:RefreshOperateVis()
  end
  if GemId == self.ViewModel:GetCurSelectGemId() then
    local PackageInfo = GemData:GetGemPackageInfoByUId(GemId)
    if PackageInfo.level >= self.CurSelectedLevel then
      EventSystem.Invoke(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, math.min(self.CurSelectedLevel + 1, self.CurSelectedMaxLevel))
    end
    if self.SelectUpgradeType == EGemDevelopType.Upgrade then
      self.WBP_GemDevelopInfoItem:Show(GemId, self.CurSelectedLevel)
    elseif self.SelectUpgradeType == EGemDevelopType.Mutation then
      self:RefreshRefactorButtonStatus()
      self.WBP_GemDevelopInfoItem:Show(GemId)
    end
  end
end
function WBP_GemUpgradeView:BindOnGemUpgradeSuccess(GemId)
  if GemId == self.ViewModel:GetCurSelectGemId() then
    self:PlayUpgradeSuccessAnim()
  end
end
function WBP_GemUpgradeView:BindOnPuzzleRefactorMaterialSelected(ResourceId)
  self.CurSelectMutationResourceId = ResourceId
  self:RefreshSelectRefactorResourceInfo()
  UpdateVisibility(self.CanvasPanel_MatSelectPanel, false)
end
function WBP_GemUpgradeView:RefreshSelectRefactorResourceInfo()
  local CurSelectResourceId = self.CurSelectMutationResourceId
  UpdateVisibility(self.Txt_SelectResourceTip, nil ~= CurSelectResourceId)
  if CurSelectResourceId then
    self.RGStateController_SelectMat:ChangeStatus("Select")
    local TargetText = self.SelectResourceTipText:Find(CurSelectResourceId)
    self.Txt_SelectResourceTip:SetText(TargetText)
    local GemId = self.ViewModel:GetCurSelectGemId()
    local ResourceId = GemData:GetGemResourceIdByUId(GemId)
    local Result, GemResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResGem, ResourceId)
    local TargetResourceList = GemResRowInfo[RefactorResourceVarList[CurSelectResourceId]]
    local CostNum = TargetResourceList and TargetResourceList[1] and TargetResourceList[1].value or 0
    self.WBP_ResourceItem_Mutation:Show(CurSelectResourceId, CostNum)
    self.WBP_ResourceItem_Mutation:UpdateNumTextStatus(CostNum)
    self.MainResourceCostInfo = TargetResourceList[1]
    self.MinorResourceCostInfo = TargetResourceList[2]
    local SecondCostNum = self.MinorResourceCostInfo and self.MinorResourceCostInfo.value or 0
    local CurrencyKey = self.MinorResourceCostInfo and self.MinorResourceCostInfo.key or self.DefaultSecondResourceId
    self.WBP_CurrencyResourceItem:Show(CurrencyKey, SecondCostNum)
    self.WBP_CurrencyResourceItem:UpdateNumTextStatus(SecondCostNum)
  else
    self.RGStateController_SelectMat:ChangeStatus("UnSelect")
    self.MainResourceCostInfo = nil
    self.MinorResourceCostInfo = nil
    self.WBP_CurrencyResourceItem:Show(self.DefaultSecondResourceId, 0)
    self.WBP_CurrencyResourceItem:UpdateNumTextStatus(0)
  end
  self:RefreshCostResourceStatus()
  self:RefreshRefactorButtonStatus()
end
function WBP_GemUpgradeView:RefreshRefactorButtonStatus(...)
  local CurSelectResourceId = self.CurSelectMutationResourceId
  local CurSelectedGemId = self.ViewModel:GetCurSelectGemId()
  local PackageInfo = GemData:GetGemPackageInfoByUId(CurSelectedGemId)
  self.CanClickRefactorButton = true
  self.RefactorButtonClickTipId = 0
  local ButtonStyle = self.NormalMutationStyle
  if not CurSelectResourceId then
    self.CanClickRefactorButton = false
    self.RefactorButtonClickTipId = self.NotSelectResourceTipId
  elseif not self.HasEnoughMutationResource then
    self.CanClickRefactorButton = false
    self.RefactorButtonClickTipId = self.NotEnoughResourceTipId
    ButtonStyle = self.NotEnoughResourceMutationStyle
  elseif CurSelectResourceId == EPuzzleRefactorType.Mutation and PackageInfo.mutation then
    self.CanClickRefactorButton = false
    self.RefactorButtonClickTipId = self.AlreadyMutationTipId
    ButtonStyle = self.AlreadyMutationStyle
  end
  self.Btn_Refactor:SetStyleByBottomStyleRowName(ButtonStyle)
  if CurSelectResourceId and CurSelectResourceId == EPuzzleRefactorType.Mutation then
    if PackageInfo.mutation then
      self.Btn_Refactor:SetContentText(self.AlreadyMutationText)
    else
      self.Btn_Refactor:SetContentText(self.NormalMutationText)
    end
  else
    self.Btn_Refactor:SetContentText(self.NormalMutationText)
  end
end
function WBP_GemUpgradeView:RefreshCostResourceStatus()
  self.HasEnoughMutationResource = true
  if self.MainResourceCostInfo then
    local CurHaveNum = LogicOutsidePackback.GetResourceNumById(self.MainResourceCostInfo.key)
    if CurHaveNum >= self.MainResourceCostInfo.value then
    else
      self.HasEnoughMutationResource = false
    end
  end
  if self.MinorResourceCostInfo then
    local CurHaveNum = LogicOutsidePackback.GetResourceNumById(self.MinorResourceCostInfo.key)
    if CurHaveNum >= self.MinorResourceCostInfo.value then
    else
      self.HasEnoughMutationResource = false
    end
  end
end
function WBP_GemUpgradeView:PlayUpgradeSuccessAnim(...)
  self.WBP_GemDevelopInfoItem:PlayUpgradeSuccessAnim()
end
function WBP_GemUpgradeView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  end
  UpdateVisibility(self.SizeBox_ExpandList, false)
  UpdateVisibility(self.CanvasPanel_MatSelectPanel, false)
  self.WBP_PuzzleSortRuleComboBox:HideExpandList()
  return UE.UWidgetBlueprintLibrary.Unhandled()
end
function WBP_GemUpgradeView:OnHide()
  self.ViewModel:OnViewClose()
  self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  local AllChildren = self.ScrollList_Level:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local AllChildren = self.WrapBox_MatList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  self:StopAllAnimations()
  self.RGTileViewGemList:SetRGListItems({}, false, true)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemItemSelected, self, self.BindOnGemItemSelected)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, self, self.BindOnChangePuzzleUpgradeLevelSelected)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateResourceInfo, self, self.BindOnUpdateResourceInfo)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemUpgradeSuccess, self, self.BindOnGemUpgradeSuccess)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleRefactorMaterialSelected, self, self.BindOnPuzzleRefactorMaterialSelected)
end
return WBP_GemUpgradeView
