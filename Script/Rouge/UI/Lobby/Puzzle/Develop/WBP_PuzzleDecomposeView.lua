local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_PuzzleDecomposeView = Class(ViewBase)
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleHandler = require("Protocol.Puzzle.PuzzleHandler")
local GemData = require("Modules.Gem.GemData")
local EDecomposeButtonStatus = {
  Empty = 0,
  Lock = 1,
  Normal = 2
}

function WBP_PuzzleDecomposeView:BindClickHandler()
  self.Btn_Filter.OnClicked:Add(self, self.BindOnFilterButtonClicked)
  self.Btn_Decompose.OnMainButtonClicked:Add(self, self.BindOnDecomposeButtonClicked)
  self.CheckBox_PickAll.OnCheckStateChanged:Add(self, self.BindOnPickAllCheckStateChanged)
end

function WBP_PuzzleDecomposeView:UnBindClickHandler()
  self.Btn_Filter.OnClicked:Remove(self, self.BindOnFilterButtonClicked)
  self.Btn_Decompose.OnMainButtonClicked:Remove(self, self.BindOnDecomposeButtonClicked)
  self.CheckBox_PickAll.OnCheckStateChanged:Remove(self, self.BindOnPickAllCheckStateChanged)
end

function WBP_PuzzleDecomposeView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("PuzzleDecomposeViewModel")
  self:BindClickHandler()
end

function WBP_PuzzleDecomposeView:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_PuzzleDecomposeView:OnShow(...)
  self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleItemSelected, self, self.BindOnPuzzleItemSelected)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnDecomposePuzzleSuccess, self, self.BindOnDecomposePuzzleSuccess)
  self.CheckBox_PickAll:SetIsChecked(false)
  self:InitSortRuleComboBox()
  self:BindOnPuzzleItemSelected()
  self:RefreshFilterIconStatus()
  UpdateVisibility(self.WBP_PuzzleFilterView, false)
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  self.Txt_MaxHaveNum:SetText(ConstTable.MatrixPuzzleMaxDecomposeNum)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self.RGTileViewPuzzleList:SetRenderOpacity(0.0)
  self.ItemInAnimTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.RGTileViewPuzzleList:SetRenderOpacity(1.0)
      local AllDisplayedEntryWidget = self.RGTileViewPuzzleList:GetDisplayedEntryWidgets()
      local Index = 0
      for k, SingleItem in pairs(AllDisplayedEntryWidget) do
        SingleItem:PlayDecomposeInAnimtion(Index)
        Index = Index + 1
      end
    end
  }, 0.02, false)
end

function WBP_PuzzleDecomposeView:InitSortRuleComboBox(...)
  self.WBP_PuzzleSortRuleComboBox:Show(self)
end

function WBP_PuzzleDecomposeView:RefreshPuzzleItemList(...)
  self.RGTileViewPuzzleList:RecyleAllData()
  local DataObjList = {}
  local PuzzlePackageIdList = {}
  local FilterSelectStatus = self.ViewModel:GetPuzzleFilterSelectStatus()
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  local IsFilterDiscardSelected = self.ViewModel:GetPuzzleFilterDiscardSelected()
  local IsFilterLockSelected = self.ViewModel:GetPuzzleFilterLockSelected()
  for PuzzleId, SinglePackageInfo in pairs(AllPackageInfo) do
    if (not IsFilterDiscardSelected or SinglePackageInfo.state == EPuzzleStatus.Discard) and (not IsFilterLockSelected or SinglePackageInfo.state == EPuzzleStatus.Lock) then
      local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(PuzzleId)
      local IsEquipGem = false
      for SlotIndex, GemId in pairs(GemSlotInfo) do
        if GemData:IsEquippedInPuzzle(GemId) then
          IsEquipGem = true
          break
        end
      end
      if 0 == SinglePackageInfo.equipHeroID and not IsEquipGem then
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
  end
  UpdateVisibility(self.RGTileViewPuzzleList, next(PuzzlePackageIdList) ~= nil)
  UpdateVisibility(self.Overlay_ListEmpty, next(PuzzlePackageIdList) == nil)
  UpdateVisibility(self.CanvasPanel_EmptyPuzzleList, next(PuzzlePackageIdList) == nil)
  if next(PuzzlePackageIdList) ~= nil then
    local SortFunction = function(A, B)
      local APackageInfo = PuzzleData:GetPuzzlePackageInfo(A)
      local BPackageInfo = PuzzleData:GetPuzzlePackageInfo(B)
      if APackageInfo.state ~= BPackageInfo.state and (APackageInfo.state == EPuzzleStatus.Discard or BPackageInfo.state == EPuzzleStatus.Discard) then
        return APackageInfo.state == EPuzzleStatus.Discard and BPackageInfo.state ~= EPuzzleStatus.Discard
      end
      local Func = self.ViewModel:GetSortRuleFunction()
      return Func(A, B)
    end
    table.sort(PuzzlePackageIdList, SortFunction)
    for i, PuzzleId in ipairs(PuzzlePackageIdList) do
      local DataObj = self.RGTileViewPuzzleList:GetOrCreateDataObj()
      DataObj.PuzzleId = PuzzleId
      DataObj.CanDrag = false
      DataObj.CanShowToolTipWidget = false
      DataObj.ViewModel = self.ViewModel
      DataObj.IsMultiSelect = true
      DataObj.ParentListView = self.RGTileViewPuzzleList
      table.insert(DataObjList, DataObj)
    end
    self.RGTileViewPuzzleList:SetRGListItems(DataObjList, false, true)
  end
end

function WBP_PuzzleDecomposeView:RefreshFilterIconStatus(...)
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

function WBP_PuzzleDecomposeView:BindOnSortRuleSelectionChanged(CurSelectedIndex)
  self.ViewModel:SetPuzzleSortRule(CurSelectedIndex)
  self:RefreshPuzzleItemList()
end

function WBP_PuzzleDecomposeView:BindOnFilterButtonClicked()
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  else
    UpdateVisibility(self.WBP_PuzzleFilterView, true)
    self.WBP_PuzzleFilterView:Show(self.ViewModel)
  end
end

function WBP_PuzzleDecomposeView:BindOnDecomposeButtonClicked(...)
  if self.ButtonStatus == EDecomposeButtonStatus.Empty then
    return
  elseif self.ButtonStatus == EDecomposeButtonStatus.Lock then
    print("\230\156\137\233\148\129\229\174\154\231\154\132\230\168\161\231\187\132")
    return
  else
    local PuzzleIdList = self.ViewModel:GetCurSelectPuzzleIdList()
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    local WaveWindow = RGWaveWindowManager:ShowWaveWindowWithDelegate(300004, {}, nil, {
      self,
      function()
        PuzzleHandler:RequestDecomposePuzzleToServer(PuzzleIdList)
        self.ViewModel:RemoveAllCurSelectPuzzleIdList()
        self.CheckBox_PickAll:SetIsChecked(false)
      end
    })
    WaveWindow:Show(PuzzleIdList, true)
  end
end

function WBP_PuzzleDecomposeView:BindOnPickAllCheckStateChanged(IsChecked)
  if IsChecked then
    local CurSelectIdList = self.ViewModel:GetCurSelectPuzzleIdList()
    local MaxSelectNum = self.ViewModel:GetMaxCanSelectNum()
    local CanSelectNum = MaxSelectNum - table.count(CurSelectIdList)
    if CanSelectNum <= 0 then
      return
    end
    local AllItems = self.RGTileViewPuzzleList:GetListItems()
    local AddNum = 0
    for i, SingleItem in pairs(AllItems) do
      if CanSelectNum < AddNum + 1 then
        break
      end
      local PackageInfo = PuzzleData:GetPuzzlePackageInfo(SingleItem.PuzzleId)
      if PackageInfo.state ~= EPuzzleStatus.Lock and not table.Contain(CurSelectIdList, SingleItem.PuzzleId) then
        self.ViewModel:SetCurSelectPuzzleId(SingleItem.PuzzleId)
        AddNum = AddNum + 1
      end
    end
    EventSystem.Invoke(EventDef.Puzzle.OnPuzzleItemSelected)
  else
    self.ViewModel:RemoveAllCurSelectPuzzleIdList()
  end
end

function WBP_PuzzleDecomposeView:BindOnUpdatePuzzlePackageInfo(PuzzleIdList)
  self:RefreshDecomposeButtonStatus()
  if not PuzzleIdList or table.Contain(PuzzleIdList, self.HoveredPuzzleId) then
    local HoverWidget = self.ViewModel:GetPuzzleHoverWidget(self.HoveredPuzzleId)
    HoverWidget:RefreshOperateVis()
  end
  local CurSelectIdList = self.ViewModel:GetCurSelectPuzzleIdList()
  if next(CurSelectIdList) ~= nil then
    local TargetPuzzleId = CurSelectIdList[#CurSelectIdList]
    if table.Contain(PuzzleIdList, TargetPuzzleId) then
      self.WBP_PuzzleDevelopInfoItem:Show(TargetPuzzleId)
    end
  end
end

function WBP_PuzzleDecomposeView:BindOnUpdatePuzzleItemHoverStatus(IsHover, PuzzleId, IsPuzzleBoard)
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

function WBP_PuzzleDecomposeView:BindOnDecomposePuzzleSuccess(PuzzleIdList)
  self:RefreshPuzzleItemList()
  self:RefreshPuzzleDevelopInfoItem()
  self:RefreshDecomposeButtonStatus()
  self:RefreshDecomposeResourceInfo()
end

function WBP_PuzzleDecomposeView:BindOnPuzzleItemSelected(PuzzleId)
  local CurSelectedNum = table.count(self.ViewModel:GetCurSelectPuzzleIdList())
  if self.CurSelectedNum and CurSelectedNum < self.CurSelectedNum then
    self.CheckBox_PickAll:SetIsChecked(false)
  end
  self.CurSelectedNum = CurSelectedNum
  self:RefreshPuzzleDevelopInfoItem()
  self:RefreshDecomposeButtonStatus()
  self:RefreshDecomposeResourceInfo()
end

function WBP_PuzzleDecomposeView:RefreshPuzzleDevelopInfoItem()
  local CurSelectIdList = self.ViewModel:GetCurSelectPuzzleIdList()
  UpdateVisibility(self.WBP_PuzzleDevelopInfoItem, next(CurSelectIdList) ~= nil)
  UpdateVisibility(self.Overlay_Empty, next(CurSelectIdList) == nil)
  if next(CurSelectIdList) ~= nil then
    local TargetPuzzleId = CurSelectIdList[#CurSelectIdList]
    self.WBP_PuzzleDevelopInfoItem:Show(TargetPuzzleId)
  end
end

function WBP_PuzzleDecomposeView:RefreshDecomposeButtonStatus(...)
  local CurSelectIdList = self.ViewModel:GetCurSelectPuzzleIdList()
  local IsEmpty = next(CurSelectIdList) == nil
  if IsEmpty then
    self.ButtonStatus = EDecomposeButtonStatus.Empty
    self.Btn_Decompose:SetStyleByBottomStyleRowName("Upgrade_C")
    return
  end
  for i, SingleId in ipairs(CurSelectIdList) do
    local PackageInfo = PuzzleData:GetPuzzlePackageInfo(SingleId)
    if PackageInfo.state == EPuzzleStatus.Lock then
      self.ButtonStatus = EDecomposeButtonStatus.Lock
      self.Btn_Decompose:SetStyleByBottomStyleRowName("Upgrade_C")
      return
    end
  end
  self.ButtonStatus = EDecomposeButtonStatus.Normal
  self.Btn_Decompose:SetStyleByBottomStyleRowName("Upgrade")
end

function WBP_PuzzleDecomposeView:RefreshDecomposeResourceInfo(...)
  local ResourceList = {}
  local PuzzleIdList = self.ViewModel:GetCurSelectPuzzleIdList()
  self.Txt_CurHaveNum:SetText(table.count(PuzzleIdList))
  for index, PuzzleId in ipairs(PuzzleIdList) do
    local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(PuzzleId)
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
    local PuzzleDevelopViewModel = UIModelMgr:Get("PuzzleDevelopViewModel")
    local LevelInfo = PuzzleDevelopViewModel:GetLevelInfoByQuality(RowInfo.Rare)
    local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
    if LevelInfo then
      for i = 0, PackageInfo.level do
        local ResetResourceInfo = LevelInfo[i].ResetGetResource
        for i, SingleResourceInfo in ipairs(ResetResourceInfo) do
          if not ResourceList[SingleResourceInfo.key] then
            ResourceList[SingleResourceInfo.key] = 0
          end
          ResourceList[SingleResourceInfo.key] = ResourceList[SingleResourceInfo.key] + SingleResourceInfo.value
        end
      end
    end
    local Result, ResPuzzleRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
    for i, SingleResourceInfo in ipairs(ResPuzzleRowInfo.decomposeResource) do
      if not ResourceList[SingleResourceInfo.key] then
        ResourceList[SingleResourceInfo.key] = 0
      end
      ResourceList[SingleResourceInfo.key] = ResourceList[SingleResourceInfo.key] + SingleResourceInfo.value
    end
  end
  local ResourceIdList = {}
  for ResourceId, Value in pairs(ResourceList) do
    table.insert(ResourceIdList, ResourceId)
  end
  table.sort(ResourceIdList, function(A, B)
    return A < B
  end)
  local Index = 1
  for i, ResourceId in ipairs(ResourceIdList) do
    local Item = GetOrCreateItem(self.Horizontal_ResourceList, Index, self.WBP_ResourceItem:StaticClass())
    Item:Show(ResourceId, ResourceList[ResourceId])
    Index = Index + 1
  end
  HideOtherItem(self.Horizontal_ResourceList, Index, true)
  UpdateVisibility(self.Horizontal_DecomposeResourceList, next(ResourceList) ~= nil)
end

function WBP_PuzzleDecomposeView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  end
  self.WBP_PuzzleSortRuleComboBox:HideExpandList()
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function WBP_PuzzleDecomposeView:OnHide()
  self.ViewModel:OnViewClose()
  self.WBP_PuzzleFilterView:Hide()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ItemInAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ItemInAnimTimer)
  end
  self:StopAllAnimations()
  self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleItemSelected, self, self.BindOnPuzzleItemSelected)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnDecomposePuzzleSuccess, self, self.BindOnDecomposePuzzleSuccess)
end

function WBP_PuzzleDecomposeView:Destruct(...)
  self:OnHide()
end

return WBP_PuzzleDecomposeView
