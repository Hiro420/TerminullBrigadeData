local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_GemDecomposeView = Class(ViewBase)
local GemData = require("Modules.Gem.GemData")
local GemHandler = require("Protocol.Gem.GemHandler")
local EDecomposeButtonStatus = {
  Empty = 0,
  Lock = 1,
  Normal = 2
}
local DecomposeWaveId = 300007

function WBP_GemDecomposeView:BindClickHandler()
  self.Btn_Filter.OnClicked:Add(self, self.BindOnFilterButtonClicked)
  self.Btn_Decompose.OnMainButtonClicked:Add(self, self.BindOnDecomposeButtonClicked)
  self.CheckBox_PickAll.OnCheckStateChanged:Add(self, self.BindOnPickAllCheckStateChanged)
end

function WBP_GemDecomposeView:UnBindClickHandler()
  self.Btn_Filter.OnClicked:Remove(self, self.BindOnFilterButtonClicked)
  self.Btn_Decompose.OnMainButtonClicked:Remove(self, self.BindOnDecomposeButtonClicked)
  self.CheckBox_PickAll.OnCheckStateChanged:Remove(self, self.BindOnPickAllCheckStateChanged)
end

function WBP_GemDecomposeView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("GemDecomposeViewModel")
  self:BindClickHandler()
end

function WBP_GemDecomposeView:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_GemDecomposeView:OnShow(...)
  self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemItemSelected, self, self.BindOnGemItemSelected)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemDecomposeSuccess, self, self.BindOnDecomposeGemSuccess)
  self.CheckBox_PickAll:SetIsChecked(false)
  self:InitSortRuleComboBox()
  self:BindOnGemItemSelected()
  self:RefreshFilterIconStatus()
  UpdateVisibility(self.WBP_PuzzleFilterView, false)
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  self.Txt_MaxHaveNum:SetText(ConstTable.MatrixPuzzleMaxDecomposeNum)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self.RGTileViewGemList:SetRenderOpacity(0.0)
  self.ItemInAnimTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.RGTileViewGemList:SetRenderOpacity(1.0)
      local AllDisplayedEntryWidget = self.RGTileViewGemList:GetDisplayedEntryWidgets()
      local Index = 0
      for k, SingleItem in pairs(AllDisplayedEntryWidget) do
        SingleItem:PlayDecomposeInAnimtion(Index)
        Index = Index + 1
      end
    end
  }, 0.02, false)
end

function WBP_GemDecomposeView:InitSortRuleComboBox(...)
  self.WBP_PuzzleSortRuleComboBox:Show(self, true)
end

function WBP_GemDecomposeView:RefreshGemItemList(...)
  self.RGTileViewGemList:RecyleAllData()
  local DataObjList = {}
  local GemPackageIdList = {}
  local FilterSelectStatus = self.ViewModel:GetGemFilterSelectStatus()
  local AllPackageInfo = GemData:GetAllGemPackageInfo()
  local IsFilterDiscardSelected = self.ViewModel:GetPuzzleFilterDiscardSelected()
  local IsFilterLockSelected = self.ViewModel:GetPuzzleFilterLockSelected()
  for GemId, SinglePackageInfo in pairs(AllPackageInfo) do
    if (not IsFilterDiscardSelected or SinglePackageInfo.state == EGemStatus.Discard) and (not IsFilterLockSelected or SinglePackageInfo.state == EGemStatus.Lock) and not GemData:IsEquippedInPuzzle(GemId) then
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
  UpdateVisibility(self.RGTileViewGemList, next(GemPackageIdList) ~= nil)
  UpdateVisibility(self.Overlay_ListEmpty, next(GemPackageIdList) == nil)
  if next(GemPackageIdList) ~= nil then
    local SortFunction = function(A, B)
      local APackageInfo = GemData:GetGemPackageInfoByUId(A)
      local BPackageInfo = GemData:GetGemPackageInfoByUId(B)
      if APackageInfo.state ~= BPackageInfo.state and (APackageInfo.state == EGemStatus.Discard or BPackageInfo.state == EGemStatus.Discard) then
        return APackageInfo.state == EGemStatus.Discard and BPackageInfo.state ~= EGemStatus.Discard
      end
      local Func = self.ViewModel:GetSortRuleFunction()
      return Func(A, B)
    end
    table.sort(GemPackageIdList, SortFunction)
    for i, GemId in ipairs(GemPackageIdList) do
      local DataObj = self.RGTileViewGemList:GetOrCreateDataObj()
      DataObj.GemId = GemId
      DataObj.CanDrag = false
      DataObj.CanShowToolTipWidget = false
      DataObj.ViewModel = self.ViewModel
      DataObj.IsMultiSelect = true
      DataObj.ParentListView = self.RGTileViewGemList
      table.insert(DataObjList, DataObj)
    end
  end
  self.RGTileViewGemList:SetRGListItems(DataObjList, false, true)
end

function WBP_GemDecomposeView:RefreshFilterIconStatus(...)
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

function WBP_GemDecomposeView:BindOnSortRuleSelectionChanged(CurSelectedIndex)
  self.ViewModel:SetPuzzleSortRule(CurSelectedIndex)
  self:RefreshGemItemList()
end

function WBP_GemDecomposeView:BindOnFilterButtonClicked()
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  else
    UpdateVisibility(self.WBP_PuzzleFilterView, true)
    self.WBP_PuzzleFilterView:Show(self.ViewModel, true)
  end
end

function WBP_GemDecomposeView:BindOnDecomposeButtonClicked(...)
  if self.ButtonStatus == EDecomposeButtonStatus.Empty then
    return
  elseif self.ButtonStatus == EDecomposeButtonStatus.Lock then
    print("\230\156\137\233\148\129\229\174\154\231\154\132\230\168\161\231\187\132")
    return
  else
    local GemIdList = self.ViewModel:GetCurSelectGemIdList()
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    local WaveWindow = RGWaveWindowManager:ShowWaveWindowWithDelegate(DecomposeWaveId, {}, nil, {
      self,
      function()
        GemHandler:RequestDecomposeGemsToServer(GemIdList)
        self.ViewModel:RemoveAllCurSelectGemIdList()
        self.CheckBox_PickAll:SetIsChecked(false)
      end
    })
    WaveWindow:Show(GemIdList)
  end
end

function WBP_GemDecomposeView:BindOnPickAllCheckStateChanged(IsChecked)
  if IsChecked then
    local CurSelectIdList = self.ViewModel:GetCurSelectGemIdList()
    local MaxSelectNum = self.ViewModel:GetMaxCanSelectNum()
    local CanSelectNum = MaxSelectNum - table.count(CurSelectIdList)
    if CanSelectNum <= 0 then
      return
    end
    local AllItems = self.RGTileViewGemList:GetListItems()
    local AddNum = 0
    for i, SingleItem in pairs(AllItems) do
      if CanSelectNum < AddNum + 1 then
        break
      end
      local PackageInfo = GemData:GetGemPackageInfoByUId(SingleItem.GemId)
      if PackageInfo.state ~= EGemStatus.Lock and not table.Contain(CurSelectIdList, SingleItem.GemId) then
        self.ViewModel:SetCurSelectGemId(SingleItem.GemId)
        AddNum = AddNum + 1
      end
    end
    EventSystem.Invoke(EventDef.Gem.OnGemItemSelected)
  else
    self.ViewModel:RemoveAllCurSelectGemIdList()
  end
end

function WBP_GemDecomposeView:BindOnUpdateGemPackageInfo(GemId)
  self:RefreshDecomposeButtonStatus()
  if not GemId or self.HoveredGemId == GemId then
    local HoverWidget = self.ViewModel:GetGemHoverWidget(self.HoveredGemId)
    HoverWidget:RefreshOperateVis()
  end
  local CurSelectIdList = self.ViewModel:GetCurSelectGemIdList()
  if next(CurSelectIdList) ~= nil then
    local TargetGemId = CurSelectIdList[#CurSelectIdList]
    if TargetGemId == GemId then
      self.WBP_GemDevelopInfoItem:Show(TargetGemId)
    end
  end
end

function WBP_GemDecomposeView:BindOnUpdateGemItemHoverStatus(IsHover, GemId, IsPuzzleBoard)
  if IsHover then
    self.HoveredGemId = GemId
  else
    self.HoveredGemId = nil
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

function WBP_GemDecomposeView:BindOnDecomposeGemSuccess(GemIdList)
  self:RefreshGemItemList()
  self:RefreshGemDevelopInfoItem()
  self:RefreshDecomposeButtonStatus()
  self:RefreshDecomposeResourceInfo()
end

function WBP_GemDecomposeView:BindOnGemItemSelected(GemId)
  local CurSelectedNum = table.count(self.ViewModel:GetCurSelectGemIdList())
  if self.CurSelectedNum and CurSelectedNum < self.CurSelectedNum then
    self.CheckBox_PickAll:SetIsChecked(false)
  end
  self.CurSelectedNum = CurSelectedNum
  self:RefreshGemDevelopInfoItem()
  self:RefreshDecomposeButtonStatus()
  self:RefreshDecomposeResourceInfo()
end

function WBP_GemDecomposeView:RefreshGemDevelopInfoItem()
  local CurSelectIdList = self.ViewModel:GetCurSelectGemIdList()
  UpdateVisibility(self.WBP_GemDevelopInfoItem, next(CurSelectIdList) ~= nil)
  UpdateVisibility(self.Overlay_Empty, next(CurSelectIdList) == nil)
  if next(CurSelectIdList) ~= nil then
    local TargetGemId = CurSelectIdList[#CurSelectIdList]
    self.WBP_GemDevelopInfoItem:Show(TargetGemId)
  end
end

function WBP_GemDecomposeView:RefreshDecomposeButtonStatus(...)
  local CurSelectIdList = self.ViewModel:GetCurSelectGemIdList()
  local IsEmpty = next(CurSelectIdList) == nil
  if IsEmpty then
    self.ButtonStatus = EDecomposeButtonStatus.Empty
    self.Btn_Decompose:SetStyleByBottomStyleRowName("Upgrade_C")
    return
  end
  for i, SingleId in ipairs(CurSelectIdList) do
    local PackageInfo = GemData:GetGemPackageInfoByUId(SingleId)
    if PackageInfo.state == EGemStatus.Lock then
      self.ButtonStatus = EDecomposeButtonStatus.Lock
      self.Btn_Decompose:SetStyleByBottomStyleRowName("Upgrade_C")
      return
    end
  end
  self.ButtonStatus = EDecomposeButtonStatus.Normal
  self.Btn_Decompose:SetStyleByBottomStyleRowName("Upgrade")
end

function WBP_GemDecomposeView:RefreshDecomposeResourceInfo(...)
  local ResourceList = {}
  local GemIdList = self.ViewModel:GetCurSelectGemIdList()
  self.Txt_CurHaveNum:SetText(table.count(GemIdList))
  for index, GemId in ipairs(GemIdList) do
    local ResourceId = GemData:GetGemResourceIdByUId(GemId)
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
    local GemUpgradeViewModel = UIModelMgr:Get("GemUpgradeViewModel")
    local LevelInfo = GemUpgradeViewModel:GetLevelInfoByQuality(RowInfo.Rare)
    local PackageInfo = GemData:GetGemPackageInfoByUId(GemId)
    for i = 0, PackageInfo.level do
      local DecomposeResourceInfo = LevelInfo[i].DecomposeGetResource
      for i, SingleResourceInfo in ipairs(DecomposeResourceInfo) do
        if not ResourceList[SingleResourceInfo.key] then
          ResourceList[SingleResourceInfo.key] = 0
        end
        ResourceList[SingleResourceInfo.key] = ResourceList[SingleResourceInfo.key] + SingleResourceInfo.value
      end
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

function WBP_GemDecomposeView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  end
  self.WBP_PuzzleSortRuleComboBox:HideExpandList()
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function WBP_GemDecomposeView:OnHide()
  self.ViewModel:OnViewClose()
  self.WBP_PuzzleFilterView:Hide()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ItemInAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ItemInAnimTimer)
  end
  self:StopAllAnimations()
  self.RGTileViewGemList:SetRGListItems({}, false, true)
  self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemItemSelected, self, self.BindOnGemItemSelected)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemDecomposeSuccess, self, self.BindOnDecomposeGemSuccess)
end

function WBP_GemDecomposeView:Destruct(...)
  self:OnHide()
end

return WBP_GemDecomposeView
