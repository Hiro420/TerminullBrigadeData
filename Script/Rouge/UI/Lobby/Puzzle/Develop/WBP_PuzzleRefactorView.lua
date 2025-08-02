local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_PuzzleRefactorView = Class(ViewBase)
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleHandler = require("Protocol.Puzzle.PuzzleHandler")
local RefactorResourceVarList = {
  [EPuzzleRefactorType.WashShape] = "WashShapeCost",
  [EPuzzleRefactorType.InscriptionRefresh] = "InscriptionRefreshCost",
  [EPuzzleRefactorType.WashSubAttrValue] = "WashSubAttrValueCost",
  [EPuzzleRefactorType.WashSlotNum] = "WashSlotNumCost",
  [EPuzzleRefactorType.WashRandomOneSubAttr] = "WashRandomOneSubAttrCost",
  [EPuzzleRefactorType.WashFirstOneSubAttr] = "WashFirstOneSubAttrCost",
  [EPuzzleRefactorType.WashLastOneSubAttr] = "WashLastOneSubAttrCost",
  [EPuzzleRefactorType.Mutation] = "MutationCost",
  [EPuzzleRefactorType.SeniorMutation] = "SeniorMutationCost"
}

function WBP_PuzzleRefactorView:BindClickHandler()
  self.CheckBox_DetailInfo.OnCheckStateChanged:Add(self, self.BindOnDetailListCheckStateChanged)
  self.Btn_Filter.OnClicked:Add(self, self.BindOnFilterButtonClicked)
  self.Btn_SelectMat.OnClicked:Add(self, self.BindOnSelectMatButtonClicked)
  self.Btn_Refactor.OnMainButtonClicked:Add(self, self.BindOnRefactorButtonClicked)
  self.Btn_JumpToModeSelection.OnMainButtonClicked:Add(self, self.BindOnJumpToModeSelectionButtonClicked)
end

function WBP_PuzzleRefactorView:UnBindClickHandler()
  self.CheckBox_DetailInfo.OnCheckStateChanged:Remove(self, self.BindOnDetailListCheckStateChanged)
  self.Btn_Filter.OnClicked:Remove(self, self.BindOnFilterButtonClicked)
  self.Btn_SelectMat.OnClicked:Remove(self, self.BindOnSelectMatButtonClicked)
  self.Btn_Refactor.OnMainButtonClicked:Remove(self, self.BindOnRefactorButtonClicked)
  self.Btn_JumpToModeSelection.OnMainButtonClicked:Remove(self, self.BindOnJumpToModeSelectionButtonClicked)
end

function WBP_PuzzleRefactorView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("PuzzleRefactorViewModel")
  self:BindClickHandler()
end

function WBP_PuzzleRefactorView:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_PuzzleRefactorView:OnShow(CurSelectedPuzzleId)
  self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  self.ViewModel:SetCurSelectPuzzleId(CurSelectedPuzzleId)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleItemSelected, self, self.BindOnPuzzleItemSelected)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateResourceInfo, self, self.BindOnUpdateResourceInfo)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleRefactorMaterialSelected, self, self.BindOnPuzzleRefactorMaterialSelected)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, self, self.BindOnUpdatePuzzleDetailInfo)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnWashPuzzleSlotAmountSuccess, self, self.BindOnWashPuzzleSlotAmountSuccess)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self.WBP_PuzzleDevelopInfoItem:RegisitPuzzleRefactorMarkArea()
  self:InitSortRuleComboBox()
  self:BindOnDetailListCheckStateChanged(false)
  self:InitRefactorMatList()
  self:BindOnPuzzleRefactorMaterialSelected(nil)
  self:RefreshFilterIconStatus()
  self.WBP_PuzzleRefactorMarkArea:RegisitMarkArea()
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  UpdateVisibility(self.CanvasPanel_Empty, next(AllPackageInfo) == nil)
  UpdateVisibility(self.CanvasPanel_HasPuzzle, next(AllPackageInfo) ~= nil)
  UpdateVisibility(self.WBP_PuzzleFilterView, false)
  UpdateVisibility(self.CanvasPanel_MatSelectPanel, false)
end

function WBP_PuzzleRefactorView:InitRefactorMatList()
  local Index = 1
  for k, ResourceId in pairs(self.RefactorResourceList) do
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
end

function WBP_PuzzleRefactorView:InitNum(...)
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  self.Txt_CurHaveNum:SetText(table.count(AllPackageInfo))
end

function WBP_PuzzleRefactorView:InitSortRuleComboBox(...)
  self.WBP_PuzzleSortRuleComboBox:Show(self)
end

function WBP_PuzzleRefactorView:RefreshPuzzleItemList()
  self.RGTileViewPuzzleList:RecyleAllData()
  local DataObjList = {}
  local PuzzlePackageIdList = {}
  local FilterSelectStatus = self.ViewModel:GetPuzzleFilterSelectStatus()
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  local FilterDiscardStatus = self.ViewModel:GetPuzzleFilterDiscardSelected()
  local FilterLockStatus = self.ViewModel:GetPuzzleFilterLockSelected()
  for PuzzleId, SinglePackageInfo in pairs(AllPackageInfo) do
    if (not FilterDiscardStatus or SinglePackageInfo.state == EPuzzleStatus.Discard) and (not FilterLockStatus or SinglePackageInfo.state == EPuzzleStatus.Lock) then
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

function WBP_PuzzleRefactorView:RefreshFilterIconStatus(...)
  local FilterSelectList = self.ViewModel:GetPuzzleFilterSelectStatus()
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

function WBP_PuzzleRefactorView:BindOnDetailListCheckStateChanged(IsChecked)
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

function WBP_PuzzleRefactorView:BindOnFilterButtonClicked()
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  else
    UpdateVisibility(self.WBP_PuzzleFilterView, true)
    self.WBP_PuzzleFilterView:Show(self.ViewModel)
  end
end

function WBP_PuzzleRefactorView:BindOnSelectMatButtonClicked()
  UpdateVisibility(self.CanvasPanel_MatSelectPanel, not self.CanvasPanel_MatSelectPanel:IsVisible())
end

function WBP_PuzzleRefactorView:BindOnRefactorButtonClicked()
  if not self.CanClickRefactorButton then
    if 0 ~= self.RefactorButtonClickTipId then
      ShowWaveWindow(self.RefactorButtonClickTipId)
    end
    return
  end
  local MarkAreaList = self.ViewModel:GetMarkAreaList()
  local CurSelectResourceId = self.ViewModel:GetCurSelectResourceId()
  local TargetAreaList = MarkAreaList[CurSelectResourceId]
  if TargetAreaList then
    for k, SingleItem in pairs(TargetAreaList) do
      SingleItem:PlayRefreshAnim()
    end
  end
  local CurSelectResourceId = self.ViewModel:GetCurSelectResourceId()
  local TargetPuzzleIdList = {
    self.ViewModel:GetCurSelectPuzzleId()
  }
  if CurSelectResourceId == EPuzzleRefactorType.InscriptionRefresh then
    PuzzleHandler:RequestWashPuzzleInscriptionToServer(TargetPuzzleIdList)
  elseif CurSelectResourceId == EPuzzleRefactorType.WashRandomOneSubAttr then
    local DetailInfo = PuzzleData:GetPuzzleDetailInfo(self.ViewModel:GetCurSelectPuzzleId())
    local SubAttrInitV2 = DetailInfo.SubAttrInitV2
    local HasGodAttr = false
    for i, SingleAttrInfo in ipairs(SubAttrInitV2) do
      if SingleAttrInfo.godAttr then
        HasGodAttr = true
        break
      end
    end
    if HasGodAttr and 0 ~= self.RefreshSubGodAttrTipId then
      ShowWaveWindowWithDelegate(self.RefreshSubGodAttrTipId, {}, {
        self,
        function()
          PuzzleHandler:RequestWashPuzzleSubAttrToServer(TargetPuzzleIdList)
        end
      })
    else
      PuzzleHandler:RequestWashPuzzleSubAttrToServer(TargetPuzzleIdList)
    end
  elseif CurSelectResourceId == EPuzzleRefactorType.WashSubAttrValue then
    PuzzleHandler:RequestWashPuzzleSubAttrValueToServer(TargetPuzzleIdList)
  elseif CurSelectResourceId == EPuzzleRefactorType.WashSlotNum then
    PuzzleHandler:RequestWashPuzzleSlotAmountToServer(TargetPuzzleIdList)
  elseif CurSelectResourceId == EPuzzleRefactorType.Mutation then
    if 0 ~= self.MutationTipId then
      ShowWaveWindowWithDelegate(self.MutationTipId, {}, {
        self,
        function()
          PuzzleHandler:RequestPuzzleMutationToServer(TargetPuzzleIdList, false)
        end
      })
    else
      PuzzleHandler:RequestPuzzleMutationToServer(TargetPuzzleIdList, false)
    end
  elseif CurSelectResourceId == EPuzzleRefactorType.SeniorMutation then
    PuzzleHandler:RequestPuzzleMutationToServer(TargetPuzzleIdList, true)
  elseif CurSelectResourceId == EPuzzleRefactorType.WashFirstOneSubAttr then
    local DetailInfo = PuzzleData:GetPuzzleDetailInfo(self.ViewModel:GetCurSelectPuzzleId())
    local SubAttrInitV2 = DetailInfo.SubAttrInitV2
    local FirstAttrInfo = SubAttrInitV2[1]
    local HasGodAttr = FirstAttrInfo and FirstAttrInfo.godAttr or false
    if HasGodAttr and 0 ~= self.RefreshSubGodAttrTipId then
      ShowWaveWindowWithDelegate(self.RefreshSubGodAttrTipId, {}, {
        self,
        function()
          PuzzleHandler:RequestWashPuzzleFirstSubAttrToServer(TargetPuzzleIdList)
        end
      })
    else
      PuzzleHandler:RequestWashPuzzleFirstSubAttrToServer(TargetPuzzleIdList)
    end
  elseif CurSelectResourceId == EPuzzleRefactorType.WashLastOneSubAttr then
    local DetailInfo = PuzzleData:GetPuzzleDetailInfo(self.ViewModel:GetCurSelectPuzzleId())
    local SubAttrInitV2 = DetailInfo.SubAttrInitV2
    local LastAttrInfo = SubAttrInitV2[#SubAttrInitV2]
    local HasGodAttr = LastAttrInfo and LastAttrInfo.godAttr or false
    if HasGodAttr and 0 ~= self.RefreshSubGodAttrTipId then
      ShowWaveWindowWithDelegate(self.RefreshSubGodAttrTipId, {}, {
        self,
        function()
          PuzzleHandler:RequestWashPuzzleLastSubAttrToServer(TargetPuzzleIdList)
        end
      })
    else
      PuzzleHandler:RequestWashPuzzleLastSubAttrToServer(TargetPuzzleIdList)
    end
  elseif CurSelectResourceId == EPuzzleRefactorType.WashShape then
    PuzzleHandler:RequestWashPuzzleShapeToServer(TargetPuzzleIdList)
  end
end

function WBP_PuzzleRefactorView:BindOnJumpToModeSelectionButtonClicked()
  local PuzzleDevelopMain = UIMgr:GetLuaFromActiveView(ViewID.UI_PuzzleDevelopMain)
  if PuzzleDevelopMain then
    PuzzleDevelopMain:BindOnEscKeyPressed()
  end
  UIMgr:Hide(ViewID.UI_DevelopMain, true)
  UIMgr:Show(ViewID.UI_MainModeSelection, true)
end

function WBP_PuzzleRefactorView:RefreshOperateInfo(...)
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  if next(AllPackageInfo) == nil then
    return
  end
  self.WBP_PuzzleDevelopInfoItem:Show(self.ViewModel:GetCurSelectPuzzleId())
  self:RefreshSelectRefactorResourceInfo()
end

function WBP_PuzzleRefactorView:BindOnSortRuleSelectionChanged(CurSelectedIndex)
  self.ViewModel:SetPuzzleSortRule(CurSelectedIndex)
  self:RefreshPuzzleItemList()
end

function WBP_PuzzleRefactorView:BindOnUpdatePuzzleItemHoverStatus(IsHover, PuzzleId, IsPuzzleBoard)
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

function WBP_PuzzleRefactorView:BindOnPuzzleItemSelected(PuzzleId)
  local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(PuzzleId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  self:RefreshPuzzleShape()
  self:RefreshOperateInfo()
  self:UpdateMarkAreaVis()
end

function WBP_PuzzleRefactorView:RefreshPuzzleShape()
  self:PlayAnimation(self.Anim_Refactoring_Shape)
  local Size = self.BoardItemSize
  local TemplateSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_SingleHexItem)
  local Index = 1
  local PuzzleId = self.ViewModel:GetCurSelectPuzzleId()
  local Result, ShapeRowInfo = PuzzleData:GetPuzzleShapeRowInfo(PuzzleId)
  if ShapeRowInfo.DevelopViewOffsetAndScale then
    if ShapeRowInfo.DevelopViewOffsetAndScale[1] then
      local OffsetAndScale = ShapeRowInfo.DevelopViewOffsetAndScale[1]
      self.CanvasPanel_Puzzle:SetRenderTranslation(UE.FVector2D(OffsetAndScale.x, OffsetAndScale.y))
      self.CanvasPanel_Puzzle:SetRenderScale(UE.FVector2D(OffsetAndScale.z, OffsetAndScale.z))
    else
      self.CanvasPanel_Puzzle:SetRenderTranslation(UE.FVector2D(0.0, 0.0))
      self.CanvasPanel_Puzzle:SetRenderScale(UE.FVector2D(1.0, 1.0))
    end
  end
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
end

function WBP_PuzzleRefactorView:BindOnUpdatePuzzlePackageInfo(PuzzleIdList)
  if not PuzzleIdList or table.Contain(PuzzleIdList, self.HoveredPuzzleId) then
    local HoverWidget = self.ViewModel:GetPuzzleHoverWidget(self.HoveredPuzzleId)
    HoverWidget:RefreshOperateVis()
  end
  if table.Contain(PuzzleIdList, self.ViewModel:GetCurSelectPuzzleId()) then
    self.WBP_PuzzleDevelopInfoItem:Show(self.ViewModel:GetCurSelectPuzzleId())
    self:RefreshPuzzleShape()
    self:RefreshRefactorButtonStatus()
  end
end

function WBP_PuzzleRefactorView:BindOnUpdatePuzzleDetailInfo(PuzzleIdList)
  if table.Contain(PuzzleIdList, self.ViewModel:GetCurSelectPuzzleId()) then
    self.WBP_PuzzleDevelopInfoItem:Show(self.ViewModel:GetCurSelectPuzzleId())
  end
end

function WBP_PuzzleRefactorView:BindOnWashPuzzleSlotAmountSuccess(PuzzleIdList)
  if not table.Contain(PuzzleIdList, self.ViewModel:GetCurSelectPuzzleId()) then
    return
  end
  self:RefreshPuzzleShape()
end

function WBP_PuzzleRefactorView:BindOnUpdateResourceInfo(...)
  self:InitRefactorMatList()
  self:RefreshSelectRefactorResourceInfo()
  local AllChildren = self.WrapBox_MatList:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshNum()
  end
end

function WBP_PuzzleRefactorView:BindOnPuzzleRefactorMaterialSelected(ResourceId)
  self.ViewModel:SetCurSelectResourceId(ResourceId)
  self:RefreshSelectRefactorResourceInfo()
  self:BindOnSelectMatButtonClicked()
  self:UpdateMarkAreaVis()
end

function WBP_PuzzleRefactorView:UpdateMarkAreaVis()
  local MarkAreaList = self.ViewModel:GetMarkAreaList()
  for SingleResourceId, ItemList in pairs(MarkAreaList) do
    for k, SingleItem in pairs(ItemList) do
      SingleItem:Hide()
    end
  end
  local CurSelectResourceId = self.ViewModel:GetCurSelectResourceId()
  local TargetAreaList = MarkAreaList[CurSelectResourceId]
  if TargetAreaList then
    for k, SingleItem in pairs(TargetAreaList) do
      SingleItem:Show()
    end
  end
end

function WBP_PuzzleRefactorView:RefreshSelectRefactorResourceInfo()
  local CurSelectResourceId = self.ViewModel:GetCurSelectResourceId()
  UpdateVisibility(self.Txt_SelectResourceTip, nil ~= CurSelectResourceId)
  if CurSelectResourceId then
    self.RGStateController_SelectMat:ChangeStatus("Select")
    local TargetText = self.SelectResourceTipText:Find(CurSelectResourceId)
    self.Txt_SelectResourceTip:SetText(TargetText)
    local PuzzleId = self.ViewModel:GetCurSelectPuzzleId()
    local PuzzleResourceId = PuzzleData:GetPuzzleResourceIdByUid(PuzzleId)
    local Result, PuzzleRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, PuzzleResourceId)
    local TargetResourceList = PuzzleRowInfo[RefactorResourceVarList[CurSelectResourceId]]
    local CostNum = TargetResourceList[1] and TargetResourceList[1].value or 0
    self.WBP_ResourceItem:Show(CurSelectResourceId, CostNum)
    self.WBP_ResourceItem:UpdateNumTextStatus(CostNum)
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

function WBP_PuzzleRefactorView:RefreshRefactorButtonStatus(...)
  local CurSelectResourceId = self.ViewModel:GetCurSelectResourceId()
  local CurSelectedPuzzleId = self.ViewModel:GetCurSelectPuzzleId()
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(CurSelectedPuzzleId)
  self.CanClickRefactorButton = true
  self.RefactorButtonClickTipId = 0
  if not CurSelectResourceId then
    self.CanClickRefactorButton = false
    self.RefactorButtonClickTipId = self.NotSelectResourceTipId
  elseif not self.HasEnoughResource then
    self.CanClickRefactorButton = false
    self.RefactorButtonClickTipId = self.NotEnoughResourceTipId
  elseif CurSelectResourceId == EPuzzleRefactorType.Mutation then
    if PuzzleData:IsPuzzleMutation(CurSelectedPuzzleId) then
      self.CanClickRefactorButton = false
      self.RefactorButtonClickTipId = self.MutationAlreadyTipId
    end
  elseif CurSelectResourceId == EPuzzleRefactorType.WashShape then
    if 0 ~= PackageInfo.equipHeroID then
      self.CanClickRefactorButton = false
      self.RefactorButtonClickTipId = self.RefreshShapeInEquipTipId
    else
      local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(CurSelectedPuzzleId)
      if GemSlotInfo then
        local IsEquipGem = false
        for SingleSlotIndex, SingleGemId in pairs(GemSlotInfo) do
          if "0" ~= SingleGemId then
            IsEquipGem = true
            break
          end
        end
        if IsEquipGem then
          self.CanClickRefactorButton = false
          self.RefactorButtonClickTipId = self.RefreshShapeInEquipGemTipId
        end
      end
    end
  elseif CurSelectResourceId == EPuzzleRefactorType.InscriptionRefresh then
    if PackageInfo.inscription <= 0 then
      self.CanClickRefactorButton = false
      self.RefactorButtonClickTipId = self.RefreshNotInscriptionTipId
    else
      local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(CurSelectedPuzzleId)
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
      if Result and RowInfo.Rare == TableEnums.ENUMResourceRare.EIR_Immortal then
        self.CanClickRefactorButton = false
        self.RefactorButtonClickTipId = self.RefreshImmortalInscriptionTipId
      end
    end
  end
  if self.CanClickRefactorButton then
    self.Btn_Refactor:SetStyleByBottomStyleRowName(self.NormalStyle)
  else
    self.Btn_Refactor:SetStyleByBottomStyleRowName(self.NotEnoughResourceStyle)
  end
  if CurSelectResourceId and (CurSelectResourceId == EPuzzleRefactorType.Mutation or CurSelectResourceId == EPuzzleRefactorType.SeniorMutation) then
    if PackageInfo.Mutation then
      if CurSelectResourceId == EPuzzleRefactorType.Mutation then
        self.Btn_Refactor:SetContentText(self.AlreadyMutationText)
      else
        self.Btn_Refactor:SetContentText(self.MutationText)
      end
    else
      self.Btn_Refactor:SetContentText(self.MutationText)
    end
  else
    self.Btn_Refactor:SetContentText(self.NormalText)
  end
end

function WBP_PuzzleRefactorView:RefreshCostResourceStatus()
  self.HasEnoughResource = true
  if self.MainResourceCostInfo then
    local CurHaveNum = LogicOutsidePackback.GetResourceNumById(self.MainResourceCostInfo.key)
    if CurHaveNum >= self.MainResourceCostInfo.value then
    else
      self.HasEnoughResource = false
    end
  end
  if self.MinorResourceCostInfo then
    local CurHaveNum = LogicOutsidePackback.GetResourceNumById(self.MinorResourceCostInfo.key)
    if CurHaveNum >= self.MinorResourceCostInfo.value then
    else
      self.HasEnoughResource = false
    end
  end
end

function WBP_PuzzleRefactorView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  end
  UpdateVisibility(self.SizeBox_ExpandList, false)
  UpdateVisibility(self.CanvasPanel_MatSelectPanel, false)
  self.WBP_PuzzleSortRuleComboBox:HideExpandList()
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function WBP_PuzzleRefactorView:OnHide()
  self.ViewModel:OnViewClose()
  self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  self:StopAllAnimations()
  local AllChildren = self.WrapBox_MatList:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  self.RGTileViewPuzzleList:SetRGListItems({}, false, true)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleItemSelected, self, self.BindOnPuzzleItemSelected)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateResourceInfo, self, self.BindOnUpdateResourceInfo)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleRefactorMaterialSelected, self, self.BindOnPuzzleRefactorMaterialSelected)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, self, self.BindOnUpdatePuzzleDetailInfo)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnWashPuzzleSlotAmountSuccess, self, self.BindOnWashPuzzleSlotAmountSuccess)
end

return WBP_PuzzleRefactorView
