local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleHandler = require("Protocol.Puzzle.PuzzleHandler")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local GemData = require("Modules.Gem.GemData")
local GemHandler = require("Protocol.Gem.GemHandler")
local WBP_PuzzleView = Class(ViewBase)
local OverWorldGridMaxNumTip = 300001
local PuzzleEquippedTip = 300002
local EInfoToggle = {Attr = 1, Inscription = 2}
local EListType = {Puzzle = 1, Gem = 2}

function WBP_PuzzleView:BindClickHandler()
  self.CheckBox_DetailInfo.OnCheckStateChanged:Add(self, self.BindOnDetailListCheckStateChanged)
  self.RGTileViewPuzzleList.BP_OnItemSelectionChanged:Add(self, self.BindOnItemSelectionChanged)
  self.Btn_Filter.OnClicked:Add(self, self.BindOnFilterButtonClicked)
  self.InfoToggleGroup.OnCheckStateChanged:Add(self, self.BindOnInfoToggleGroupCheckStateChanged)
  self.Btn_ExpandInfo.OnClicked:Add(self, self.BindOnExpandInfoButtonClicked)
  self.Btn_Obtain.OnMainButtonClicked:Add(self, self.BindOnObtainButtonClicked)
  self.Btn_GemObtain.OnMainButtonClicked:Add(self, self.BindOnObtainButtonClicked)
  self.WBP_CommonButton_Upgrade.OnMainButtonClicked:Add(self, self.BindOnUpgradeButtonClicked)
  self.WBP_CommonButton_Decompose.OnMainButtonClicked:Add(self, self.BindOnDecomposeButtonClicked)
  self.RGViewListToggle.OnCheckStateChanged:Add(self, self.BindOnRGViewListToggleStateChanged)
end

function WBP_PuzzleView:UnBindClickHandler()
  self.CheckBox_DetailInfo.OnCheckStateChanged:Remove(self, self.BindOnDetailListCheckStateChanged)
  self.RGTileViewPuzzleList.BP_OnItemSelectionChanged:Remove(self, self.BindOnItemSelectionChanged)
  self.Btn_Filter.OnClicked:Remove(self, self.BindOnFilterButtonClicked)
  self.InfoToggleGroup.OnCheckStateChanged:Remove(self, self.BindOnInfoToggleGroupCheckStateChanged)
  self.Btn_ExpandInfo.OnClicked:Remove(self, self.BindOnExpandInfoButtonClicked)
  self.Btn_Obtain.OnMainButtonClicked:Remove(self, self.BindOnObtainButtonClicked)
  self.Btn_GemObtain.OnMainButtonClicked:Remove(self, self.BindOnObtainButtonClicked)
  self.WBP_CommonButton_Upgrade.OnMainButtonClicked:Remove(self, self.BindOnUpgradeButtonClicked)
  self.WBP_CommonButton_Decompose.OnMainButtonClicked:Remove(self, self.BindOnDecomposeButtonClicked)
  self.RGViewListToggle.OnCheckStateChanged:Remove(self, self.BindOnRGViewListToggleStateChanged)
end

function WBP_PuzzleView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("PuzzleViewModel")
  self:BindClickHandler()
end

function WBP_PuzzleView:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_PuzzleView:OnShow(CurHeroId)
  self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  LogicRole.ShowOrHideRoleMainHero(false)
  ChangeLobbyCamera(GameInstance, "Role")
  self:InitWorldList()
  self:UpdateCurHeroInfo(CurHeroId)
  self:InitSortRuleComboBox()
  self:BindOnDetailListCheckStateChanged(false)
  self:SetIsExpandInfo(true)
  self:RefreshGemItemList()
  self.InfoToggleGroup:SelectId(EInfoToggle.Attr)
  self.RGViewListToggle:SelectId(EListType.Puzzle)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self.ItemInAnimTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      local AllDisplayedEntryWidget = self.RGTileViewPuzzleList:GetDisplayedEntryWidgets()
      local Index = 0
      for k, SingleItem in pairs(AllDisplayedEntryWidget) do
        SingleItem:PlayInAnimation(Index)
        Index = Index + 1
      end
    end
  }, 0.02, false)
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  self.Txt_MaxNum:SetText(ConstTable.MartrixPuzzleMaxPackageNum)
  self:RefreshButtonNumInfo()
  PuzzleHandler:RequestGetPuzzleSlotUnlockInfo()
  UpdateVisibility(self.WBP_PuzzleFilterView, false)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleboardDrop, self, self.BindOnPuzzleboardDrop)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleboardDragEnter, self, self.BindOnPuzzleboardDragEnter)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleboardDragCancelled, self, self.BindOnPuzzleboardDragCancelled)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnRotatePuzzleDragCoordinate, self, self.BindOnRotatePuzzleDragCoordinate)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnEquipPuzzleSuccess, self, self.BindOnEquipPuzzleSuccess)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUnEquipPuzzleSuccess, self, self.BindOnUnEquipPuzzleSuccess)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemItemSelected, self, self.BindOnGemItemSelected)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemEquipSuccess, self, self.BindOnGemEquipSuccess)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemUnEquipSuccess, self, self.BindOnGemUnEquipSuccess)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemDecomposeSuccess, self, self.BindOnGemDecomposeSuccess)
end

function WBP_PuzzleView:OnRollback()
  LogicRole.ShowOrHideRoleMainHero(false)
  ChangeLobbyCamera(GameInstance, "Role")
  if self.ViewListToggleState == EListType.Puzzle then
    self:RefreshPuzzleItemList()
  else
    self:RefreshGemItemList()
  end
  self:RefreshButtonNumInfo()
  self:RefreshEquipAttrAndInscriptionInfo()
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
end

function WBP_PuzzleView:OnHideByOther(...)
  self.WBP_PuzzleFilterView:Hide()
  self:BindOnUpdatePuzzleItemHoverStatus(false)
  self:BindOnUpdateGemItemHoverStatus(false)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  self.RGTileViewPuzzleList:SetRGListItems({}, false, true)
  self.RGTileViewGemList:SetRGListItems({}, false, true)
end

function WBP_PuzzleView:UpdateViewByHeroId(HeroId)
  self:UpdateCurHeroInfo(HeroId)
  if self.HoveredPuzzleId then
    local HoverWidget = self.ViewModel:GetPuzzleHoverWidget(self.HoveredPuzzleId)
    HoverWidget:RefreshOperateVis()
  end
  self:PlayAnimation(self.Ani_switch)
end

function WBP_PuzzleView:GetCurHeroId(...)
  return self.CurHeroId
end

function WBP_PuzzleView:RefreshButtonNumInfo(...)
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  self.ViewListToggle_Puzzle:SetCurHaveNum(table.count(AllPackageInfo))
  local AllGemPackageInfo = GemData:GetAllGemPackageInfo()
  self.ViewListToggle_Gem:SetCurHaveNum(table.count(AllGemPackageInfo))
end

function WBP_PuzzleView:UpdateCurHeroInfo(InHeroId)
  self.CurHeroId = InHeroId
  self.ViewModel:SetCurHeroId(self:GetCurHeroId())
  self:InitPuzzleboard()
  self:RefreshEquipAttrAndInscriptionInfo()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleHero, self:GetCurHeroId())
  if Result then
    local NameIcon = GetAssetByPath(RowInfo.NameIcon, true)
    if NameIcon then
      local NameDynamicMaterial = self.Img_Name:GetDynamicMaterial()
      if NameDynamicMaterial then
        NameDynamicMaterial:SetTextureParameterValue("litu", NameIcon)
      end
      local NameBottomDynamicMaterial = self.Img_NameBottom:GetDynamicMaterial()
      if NameBottomDynamicMaterial then
        NameBottomDynamicMaterial:SetTextureParameterValue("litu", NameIcon)
      end
    end
    local BottomIcon = GetAssetByPath(RowInfo.FXBottomIcon, true)
    if BottomIcon then
      local NotFullBottomDynamicMat = self.Img_NotFullBottom:GetDynamicMaterial()
      if NotFullBottomDynamicMat then
        NotFullBottomDynamicMat:SetTextureParameterValue("renwu", BottomIcon)
      end
      local FullBottomDynamicMat = self.Img_FullBottom:GetDynamicMaterial()
      if FullBottomDynamicMat then
        FullBottomDynamicMat:SetTextureParameterValue("Texture (T2d)", BottomIcon)
      end
    end
  end
  print("ywtao,PuzzleInfo:" .. PuzzleData:GetHeroPuzzleInfoByHeroId(InHeroId))
end

function WBP_PuzzleView:InitPuzzleboard(...)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleHero, self:GetCurHeroId())
  if Result then
    SetImageBrushByPath(self.Img_Bottom, RowInfo.BottomIcon)
  end
  local Size = self.BoardItemSize
  local TemplateSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.PuzzleboardItemTemplate)
  local Index = 1
  self.CurBoardSlotList = {}
  local BoardCoordinate = PuzzleData:GetPuzzleboardCoordinateByHeroId(self:GetCurHeroId())
  if not BoardCoordinate then
    return
  end
  for CoordinateX, SingleCoordinateInfo in pairs(BoardCoordinate) do
    for CoordinateY, SlotId in pairs(SingleCoordinateInfo) do
      local Item = GetOrCreateItem(self.Canvaspanel_Puzzleboard, Index, self.PuzzleboardItemTemplate:StaticClass())
      local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
      if Slot then
        Slot:SetAnchors(TemplateSlot:GetAnchors())
        Slot:SetAlignment(TemplateSlot:GetAlignment())
        local PosX = 1.5 * Size.X * CoordinateX
        local PosY = Size.Y * (0 - (-CoordinateX - CoordinateY) + CoordinateY)
        Slot:SetPosition(UE.FVector2D(PosX, PosY))
        Slot:SetAutoSize(true)
      end
      Item:Show(CoordinateX, CoordinateY, SlotId, true)
      table.insert(self.CurBoardSlotList, SlotId)
      Index = Index + 1
    end
  end
  HideOtherItem(self.Canvaspanel_Puzzleboard, Index, true)
  self:UpdatePuzzleBoardEquipStatus()
end

function WBP_PuzzleView:UpdatePuzzleBoardEquipStatus()
  local EquipNum = 0
  for i, SingleSlotId in ipairs(self.CurBoardSlotList) do
    if PuzzleData:IsSlotEquipped(SingleSlotId) then
      EquipNum = EquipNum + 1
    end
  end
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  local MaxboardNum = ConstTable.MatrixPuzzleMaxGridNum
  self.IsFullEquip = EquipNum == MaxboardNum
  UpdateVisibility(self.Overlay_NotFull, not self.IsFullEquip)
  UpdateVisibility(self.Overlay_Full, self.IsFullEquip)
end

function WBP_PuzzleView:InitSortRuleComboBox(...)
  self.WBP_PuzzleSortRuleComboBox:Show(self)
  self.GemSortRuleComboBox:Show(self, true)
end

function WBP_PuzzleView:RefreshPuzzleItemList()
  self.RGTileViewPuzzleList:RecyleAllData()
  local DataObjList = {}
  local PuzzlePackageIdList = {}
  local FilterSelectStatus = self.ViewModel:GetPuzzleFilterSelectStatus()
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  self.Txt_CurNum:SetText(table.count(AllPackageInfo))
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
  UpdateVisibility(self.CanvasPanel_EmptyPuzzleList, next(PuzzlePackageIdList) == nil)
  if next(PuzzlePackageIdList) ~= nil then
    local SortFunction = self.ViewModel:GetSortRuleFunction(self.ViewModel:GetPuzzleSortRule(false))
    table.sort(PuzzlePackageIdList, SortFunction)
    for i, PuzzleId in ipairs(PuzzlePackageIdList) do
      local DataObj = self.RGTileViewPuzzleList:GetOrCreateDataObj()
      DataObj.PuzzleId = PuzzleId
      DataObj.CanDrag = true
      DataObj.CanShowToolTipWidget = false
      DataObj.ViewModel = self.ViewModel
      table.insert(DataObjList, DataObj)
    end
    self.RGTileViewPuzzleList:SetRGListItems(DataObjList, false, true)
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        local AllDisplayedEntryWidgets = self.RGTileViewPuzzleList:GetDisplayedEntryWidgets()
        for i, SingleItem in iterator(AllDisplayedEntryWidgets) do
          if 1 == i then
            BeginnerGuideData:UpdateWidget("FirstPuzzleItem", SingleItem)
          end
        end
      end
    }, 0.5, false)
  end
end

function WBP_PuzzleView:RefreshGemItemList(...)
  self.RGTileViewGemList:RecyleAllData()
  local DataObjList = {}
  local GemIdList = {}
  local FilterSelectStatus = self.ViewModel:GetGemFilterSelectStatus()
  local AllPackageInfo = GemData:GetAllGemPackageInfo()
  self.Txt_CurNum:SetText(table.count(AllPackageInfo))
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
          table.insert(GemIdList, GemId)
        end
      end
    end
  end
  UpdateVisibility(self.RGTileViewGemList, next(GemIdList) ~= nil)
  UpdateVisibility(self.CanvasPanel_EmptyGemList, next(GemIdList) == nil)
  if next(GemIdList) ~= nil then
    local SortFunction = self.ViewModel:GetSortRuleFunction(self.ViewModel:GetPuzzleSortRule(true), true)
    table.sort(GemIdList, SortFunction)
    for i, GemId in ipairs(GemIdList) do
      local DataObj = self.RGTileViewGemList:GetOrCreateDataObj()
      DataObj.GemId = GemId
      DataObj.CanDrag = true
      DataObj.CanShowToolTipWidget = false
      DataObj.ViewModel = self.ViewModel
      table.insert(DataObjList, DataObj)
    end
  end
  self.RGTileViewGemList:SetRGListItems(DataObjList, false, true)
end

function WBP_PuzzleView:RefreshFilterIconStatus(...)
  local FilterSelectList
  if self.ViewListToggleState == EListType.Puzzle then
    FilterSelectList = self.ViewModel:GetPuzzleFilterSelectStatus()
  else
    FilterSelectList = self.ViewModel:GetGemFilterSelectStatus()
  end
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

function WBP_PuzzleView:RefreshEquipAttrAndInscriptionInfo(...)
  local EquipPuzzleIdList = PuzzleData:GetEquipPuzzleIdListByHeroId(self:GetCurHeroId())
  self.WorldUseNumList = {}
  self.CurEquipInscriptionList = {}
  if next(EquipPuzzleIdList) == nil then
    UpdateVisibility(self.Scroll_AttrList, false)
    UpdateVisibility(self.Overlay_AttrEmpty, true)
    UpdateVisibility(self.Scroll_InscriptionList, false)
    UpdateVisibility(self.Overlay_InscriptionEmpty, true)
  else
    local AttrList = {}
    local InscriptionIdList = {}
    for i, PuzzleId in ipairs(EquipPuzzleIdList) do
      local DetailInfo = PuzzleData:GetPuzzleDetailInfo(PuzzleId)
      local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
      if PackageInfo and DetailInfo then
        local Result, PuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, PuzzleData:GetPuzzleResourceIdByUid(PuzzleId))
        if 0 ~= PackageInfo.inscription then
          table.insert(InscriptionIdList, PackageInfo.inscription)
          table.insert(self.CurEquipInscriptionList, PackageInfo.inscription)
        end
        if not self.WorldUseNumList[PuzzleResRowInfo.worldID] then
          self.WorldUseNumList[PuzzleResRowInfo.worldID] = PuzzleResRowInfo.gridNum
        else
          self.WorldUseNumList[PuzzleResRowInfo.worldID] = self.WorldUseNumList[PuzzleResRowInfo.worldID] + PuzzleResRowInfo.gridNum
        end
        for i, SingleCoreAttributeInfo in ipairs(PuzzleResRowInfo.MainAttr) do
          if not AttrList[tostring(SingleCoreAttributeInfo.key)] then
            AttrList[tostring(SingleCoreAttributeInfo.key)] = SingleCoreAttributeInfo.value
          else
            AttrList[tostring(SingleCoreAttributeInfo.key)] = AttrList[tostring(SingleCoreAttributeInfo.key)] + SingleCoreAttributeInfo.value
          end
        end
        for AttrId, AttrValue in pairs(DetailInfo.MainAttrGrowth) do
          if not AttrList[AttrId] then
            AttrList[AttrId] = AttrValue
          else
            AttrList[AttrId] = AttrList[AttrId] + AttrValue
          end
        end
        for AttrId, AttrValue in pairs(DetailInfo.SubAttrGrowth) do
          if not AttrList[AttrId] then
            AttrList[AttrId] = AttrValue
          else
            AttrList[AttrId] = AttrList[AttrId] + AttrValue
          end
        end
        for i, AttrInfo in pairs(DetailInfo.SubAttrInitV2) do
          local AttrId = AttrInfo.attrID
          local AttrValue = AttrInfo.value
          if AttrInfo.mutationType ~= EMutationType.NegaMutation then
            if not AttrList[AttrId] then
              AttrList[AttrId] = AttrValue
            else
              AttrList[AttrId] = AttrList[AttrId] + AttrValue
            end
          end
        end
        local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(PuzzleId)
        for SlotIndex, GemId in pairs(GemSlotInfo) do
          if GemData:IsEquippedInPuzzle(GemId) then
            local MainAttrValueList = GemData:GetMainAttrValueList(GemId)
            local GemPackageInfo = GemData:GetGemPackageInfoByUId(GemId)
            local MutationInfo = GemPackageInfo.mutation and GemPackageInfo.mutationAttr[1]
            for AttrId, AttrValue in pairs(MainAttrValueList) do
              if MutationInfo and MutationInfo.MutationType == EMutationType.NegaMutation then
                AttrValue = AttrValue * MutationInfo.MutationValue
              end
              if not AttrList[tostring(AttrId)] then
                AttrList[tostring(AttrId)] = AttrValue
              else
                AttrList[tostring(AttrId)] = AttrList[tostring(AttrId)] + AttrValue
              end
            end
            if MutationInfo and MutationInfo.MutationType == EMutationType.PosMutation then
              if not AttrList[tostring(MutationInfo.AttrID)] then
                AttrList[tostring(MutationInfo.AttrID)] = MutationInfo.MutationValue
              else
                AttrList[tostring(MutationInfo.AttrID)] = AttrList[tostring(MutationInfo.AttrID)] + MutationInfo.MutationValue
              end
            end
          end
        end
      end
    end
    local HasAttr = next(AttrList) ~= nil
    local HasInscription = next(InscriptionIdList) ~= nil
    UpdateVisibility(self.Scroll_AttrList, HasAttr, true)
    UpdateVisibility(self.Overlay_AttrEmpty, not HasAttr)
    UpdateVisibility(self.Scroll_InscriptionList, HasInscription)
    UpdateVisibility(self.Overlay_InscriptionEmpty, not HasInscription)
    if HasAttr then
      local MainAttrIdList = {}
      local SubAttrIdList = {}
      for AttrIdStr, AttrValue in pairs(AttrList) do
        local Result, ARowInfo = GetRowData(DT.DT_AttributeModifyOp, AttrIdStr)
        if ARowInfo.AttributeType == UE.EAttributeType.SubAttr then
          table.insert(SubAttrIdList, AttrIdStr)
        elseif ARowInfo.AttributeType ~= UE.EAttributeType.None then
          table.insert(MainAttrIdList, AttrIdStr)
        end
      end
      table.sort(MainAttrIdList, function(A, B)
        local Result, ARowInfo = GetRowData(DT.DT_AttributeModifyOp, A)
        local Result, BRowInfo = GetRowData(DT.DT_AttributeModifyOp, B)
        if ARowInfo.Priority == BRowInfo.Priority then
          return ARowInfo.ID < BRowInfo.ID
        end
        return ARowInfo.Priority > BRowInfo.Priority
      end)
      table.sort(SubAttrIdList, function(A, B)
        local Result, ARowInfo = GetRowData(DT.DT_AttributeModifyOp, A)
        local Result, BRowInfo = GetRowData(DT.DT_AttributeModifyOp, B)
        if ARowInfo.Priority == BRowInfo.Priority then
          return ARowInfo.ID < BRowInfo.ID
        end
        return ARowInfo.Priority > BRowInfo.Priority
      end)
      UpdateVisibility(self.Vertical_MainAttributePanel, next(MainAttrIdList) ~= nil)
      UpdateVisibility(self.Vertical_SubAttributePanel, next(SubAttrIdList) ~= nil)
      local Index = 1
      for i, SingleAttrIdStr in ipairs(MainAttrIdList) do
        local Item = GetOrCreateItem(self.Vertical_MainAttribute, Index, self.AttrItemTemplate:StaticClass())
        Item:Show(SingleAttrIdStr, AttrList[SingleAttrIdStr])
        Index = Index + 1
      end
      HideOtherItem(self.Vertical_MainAttribute, Index, true)
      Index = 1
      for i, SingleAttrIdStr in ipairs(SubAttrIdList) do
        local Item = GetOrCreateItem(self.Vertical_SubAttribute, Index, self.AttrItemTemplate:StaticClass())
        Item:Show(SingleAttrIdStr, AttrList[SingleAttrIdStr])
        Index = Index + 1
      end
      HideOtherItem(self.Vertical_SubAttribute, Index, true)
    end
    if HasInscription then
      local InscriptionMutexList = {}
      local Index = 1
      for i, InscriptionId in ipairs(InscriptionIdList) do
        local Item = GetOrCreateItem(self.Scroll_InscriptionList, Index, self.InscriptionItemTemplate:StaticClass())
        local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBInscriptionMutex, InscriptionId)
        local IsActive = nil == InscriptionMutexList[InscriptionId]
        Item:Show(InscriptionId, IsActive)
        if Result then
          for i, SingleInscriptionId in ipairs(RowInfo.InscriptionIDs) do
            InscriptionMutexList[SingleInscriptionId] = 1
          end
        end
        Index = Index + 1
      end
      HideOtherItem(self.Scroll_InscriptionList, Index, true)
    end
  end
  local AllChildren = self.WrapBox_World:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshUseNum(self.WorldUseNumList)
  end
end

function WBP_PuzzleView:InitWorldList(...)
  local WorldTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPuzzleWorld)
  local WorldList = {}
  for WorldId, SingleWorldRowInfo in pairs(WorldTable) do
    if SingleWorldRowInfo.IsOpen then
      table.insert(WorldList, WorldId)
    end
  end
  table.sort(WorldList, function(A, B)
    return A < B
  end)
  local Index = 1
  for i, SingleWorldId in ipairs(WorldList) do
    local Item = GetOrCreateItem(self.WrapBox_World, Index, self.WBP_PuzzleWorldItem:StaticClass())
    Item:Show(SingleWorldId)
    Index = Index + 1
  end
  HideOtherItem(self.WrapBox_World, Index, true)
end

function WBP_PuzzleView:BindOnPuzzleboardDrop(ChessboardCoordinate, ItemCoordinate, PuzzleId)
  self.IsDragEnter = false
  local CurHeroId = self:GetCurHeroId()
  local CanDrop = true
  local NeedRequestServer = false
  local PendingDragSlotList = PuzzleData:GetPendingDragSlotList()
  local Index = 1
  for k, SingleCoordinate in pairs(ItemCoordinate) do
    local TargetSingleCoordinateX = ChessboardCoordinate.key + SingleCoordinate.key
    local TargetSingleCoordinateY = ChessboardCoordinate.value + SingleCoordinate.value
    local SlotId = PuzzleData:GetPuzzleSlotIdByCoordinate(CurHeroId, {key = TargetSingleCoordinateX, value = TargetSingleCoordinateY})
    if not SlotId then
      CanDrop = false
      break
    else
      local Status = PuzzleData:GetSlotStatus(SlotId)
      if nil == Status or type(Status) ~= "number" or Status == EPuzzleSlotStatus.Lock or Status == EPuzzleSlotStatus.PendingCanNotEquip then
        CanDrop = false
        break
      end
      if not PendingDragSlotList or PendingDragSlotList[Index] ~= SlotId then
        NeedRequestServer = true
      end
    end
    Index = Index + 1
  end
  if CanDrop then
    if nil ~= next(PendingDragSlotList) then
      PuzzleData:SetPendingDragSlotList({})
    end
    local SlotIdList = {}
    for k, SingleCoordinate in pairs(ItemCoordinate) do
      local TargetSingleCoordinateX = ChessboardCoordinate.key + SingleCoordinate.key
      local TargetSingleCoordinateY = ChessboardCoordinate.value + SingleCoordinate.value
      local SlotId = PuzzleData:GetPuzzleSlotIdByCoordinate(CurHeroId, {key = TargetSingleCoordinateX, value = TargetSingleCoordinateY})
      if 0 == SingleCoordinate.key and 0 == SingleCoordinate.value then
        table.insert(SlotIdList, 1, SlotId)
      else
        table.insert(SlotIdList, SlotId)
      end
    end
    if NeedRequestServer then
      local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, PuzzleData:GetPuzzleResourceIdByUid(PuzzleId))
      local TargetWorldUseNum = self.WorldUseNumList[RowInfo.worldID]
      local EquipSlotList = PuzzleData:GetSlotListByPuzzleId(PuzzleId)
      local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
      if (not EquipSlotList or PackageInfo.equipHeroID ~= self:GetCurHeroId()) and TargetWorldUseNum and TargetWorldUseNum + RowInfo.gridNum > ConstTable.MatrixPuzzleWroldGridLimitNum then
        ShowWaveWindow(OverWorldGridMaxNumTip)
        NeedRequestServer = false
        local AllChildren = self.WrapBox_World:GetAllChildren()
        for k, SingleItem in pairs(AllChildren) do
          SingleItem:RefreshUseNum(self.WorldUseNumList)
        end
      else
        local EquipFunc = function(PuzzleId, CurHeroId, SlotIdList)
          local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
          local IsMutexInscription = false
          local EquipSlotList = PuzzleData:GetSlotListByPuzzleId(PuzzleId)
          if (not EquipSlotList or next(EquipSlotList) == nil) and 0 ~= PackageInfo.inscription then
            for index, SingleInscriptionId in ipairs(self.CurEquipInscriptionList) do
              local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBInscriptionMutex, SingleInscriptionId)
              if Result and table.Contain(RowInfo.InscriptionIDs, PackageInfo.inscription) then
                IsMutexInscription = true
              end
            end
          end
          if IsMutexInscription then
            ShowWaveWindowWithDelegate(1187, {}, function()
              PuzzleHandler:RequestEquipPuzzleToServer(PuzzleId, CurHeroId, SlotIdList)
            end)
            NeedRequestServer = false
            local AllChildren = self.WrapBox_World:GetAllChildren()
            for k, SingleItem in pairs(AllChildren) do
              SingleItem:RefreshUseNum(self.WorldUseNumList)
            end
          else
            PuzzleHandler:RequestEquipPuzzleToServer(PuzzleId, CurHeroId, SlotIdList)
          end
        end
        if PackageInfo.equipHeroID > 0 and PackageInfo.equipHeroID ~= self:GetCurHeroId() then
          print("\230\152\175\229\144\166\232\166\129\230\155\180\230\141\162\232\139\177\233\155\132")
          local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, PackageInfo.equipHeroID)
          local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
          local WaveWindow = RGWaveWindowManager:ShowWaveWindowWithDelegate(PuzzleEquippedTip, {
            RowInfo.Name
          }, nil, {
            self,
            function()
              EquipFunc(PuzzleId, CurHeroId, SlotIdList)
            end
          })
          WaveWindow:Show(PuzzleId)
          NeedRequestServer = false
          local AllChildren = self.WrapBox_World:GetAllChildren()
          for k, SingleItem in pairs(AllChildren) do
            SingleItem:RefreshUseNum(self.WorldUseNumList)
          end
        else
          EquipFunc(PuzzleId, CurHeroId, SlotIdList)
        end
      end
    end
    PuzzleData:SetPendingEquipSlot({})
    PuzzleData:SetPendingCanNotEquipSlot({})
    if not NeedRequestServer then
      EventSystem.Invoke(EventDef.Puzzle.RefreshPuzzleboardItemStatus)
    end
  else
    local NeedBroadcast = false
    if next(PuzzleData:GetPendingDragSlotList()) ~= nil then
      PuzzleData:SetPendingDragSlotList({})
      NeedBroadcast = true
    end
    if nil ~= next(PuzzleData.PendingCanNotEquipSlotList) then
      PuzzleData:SetPendingCanNotEquipSlot({})
      NeedBroadcast = true
    end
    if NeedBroadcast then
      EventSystem.Invoke(EventDef.Puzzle.RefreshPuzzleboardItemStatus)
    end
    local AllChildren = self.WrapBox_World:GetAllChildren()
    for k, SingleItem in pairs(AllChildren) do
      SingleItem:RefreshUseNum(self.WorldUseNumList)
    end
  end
end

function WBP_PuzzleView:BindOnPuzzleboardDragEnter(IsEnter, ChessboardCoordinate, ItemCoordinate)
  self.IsDragEnter = IsEnter
  self.DragCenterChessboardCoordinate = ChessboardCoordinate
  local CurHeroId = self:GetCurHeroId()
  if IsEnter then
    local CanDrop = true
    PuzzleData:SetPendingCanNotEquipSlot({})
    for k, SingleCoordinate in pairs(ItemCoordinate) do
      local TargetSingleCoordinateX = ChessboardCoordinate.key + SingleCoordinate.key
      local TargetSingleCoordinateY = ChessboardCoordinate.value + SingleCoordinate.value
      local SlotId = PuzzleData:GetPuzzleSlotIdByCoordinate(CurHeroId, {key = TargetSingleCoordinateX, value = TargetSingleCoordinateY})
      if not SlotId then
        CanDrop = false
        break
      else
        local Status = PuzzleData:GetSlotStatus(SlotId)
        if nil == Status or type(Status) ~= "number" or Status == EPuzzleSlotStatus.Lock or Status == EPuzzleSlotStatus.PendingCanNotEquip then
          CanDrop = false
          break
        end
      end
    end
    local EquipSlotList = {}
    for k, SingleCoordinate in pairs(ItemCoordinate) do
      local TargetSingleCoordinateX = ChessboardCoordinate.key + SingleCoordinate.key
      local TargetSingleCoordinateY = ChessboardCoordinate.value + SingleCoordinate.value
      local SlotId = PuzzleData:GetPuzzleSlotIdByCoordinate(CurHeroId, {key = TargetSingleCoordinateX, value = TargetSingleCoordinateY})
      table.insert(EquipSlotList, SlotId)
    end
    if CanDrop then
      PuzzleData:SetPendingEquipSlot(EquipSlotList)
      PuzzleData:SetPendingCanNotEquipSlot({})
      EventSystem.Invoke(EventDef.Puzzle.RefreshPuzzleboardItemStatus)
    else
      PuzzleData:SetPendingEquipSlot({})
      PuzzleData:SetPendingCanNotEquipSlot(EquipSlotList)
      EventSystem.Invoke(EventDef.Puzzle.RefreshPuzzleboardItemStatus)
    end
  else
    PuzzleData:SetPendingEquipSlot({})
    PuzzleData:SetPendingCanNotEquipSlot({})
    EventSystem.Invoke(EventDef.Puzzle.RefreshPuzzleboardItemStatus)
  end
end

function WBP_PuzzleView:BindOnPuzzleboardDragCancelled(PuzzleId, IsNeedUnEquip)
  print("WBP_PuzzleView:BindOnPuzzleboardDragCancelled")
  self.IsDragEnter = false
  local NeedBroadcast = false
  if next(PuzzleData:GetPendingDragSlotList()) ~= nil then
    PuzzleData:SetPendingDragSlotList({})
    NeedBroadcast = true
  end
  if nil ~= next(PuzzleData.PendingCanNotEquipSlotList) then
    PuzzleData:SetPendingCanNotEquipSlot({})
    NeedBroadcast = true
  end
  if NeedBroadcast then
    EventSystem.Invoke(EventDef.Puzzle.RefreshPuzzleboardItemStatus)
  end
  if IsNeedUnEquip then
    PuzzleHandler:RequestUnEquipPuzzleToServer(PuzzleId, self:GetCurHeroId())
  end
end

function WBP_PuzzleView:BindOnRotatePuzzleDragCoordinate(RotateCoordinate)
  if self.IsDragEnter then
    EventSystem.Invoke(EventDef.Puzzle.OnPuzzleboardDragEnter, true, self.DragCenterChessboardCoordinate, RotateCoordinate)
  end
end

function WBP_PuzzleView:BindOnItemSelectionChanged(Item, IsSelected)
end

function WBP_PuzzleView:BindOnFilterButtonClicked()
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  else
    UpdateVisibility(self.WBP_PuzzleFilterView, true)
    local IsGem = self.ViewListToggleState == EListType.Gem
    self.WBP_PuzzleFilterView:Show(self.ViewModel, IsGem)
  end
end

function WBP_PuzzleView:BindOnInfoToggleGroupCheckStateChanged(SelectIndex)
  UpdateVisibility(self.Overlay_AttrInfo, SelectIndex == EInfoToggle.Attr)
  UpdateVisibility(self.Overlay_InscriptionInfo, SelectIndex == EInfoToggle.Inscription)
end

function WBP_PuzzleView:BindOnExpandInfoButtonClicked(...)
  self:SetIsExpandInfo(not self.IsExpandInfo)
end

function WBP_PuzzleView:BindOnObtainButtonClicked(...)
  UIMgr:Hide(ViewID.UI_DevelopMain, true)
  UIMgr:Show(ViewID.UI_MainModeSelection, true)
end

function WBP_PuzzleView:SetIsExpandInfo(IsExpand)
  self.IsExpandInfo = IsExpand
  UpdateVisibility(self.CanvasPanel_Info, self.IsExpandInfo)
end

function WBP_PuzzleView:BindOnUpdatePuzzleItemHoverStatus(IsHover, PuzzleId, IsPuzzleBoard, Position, HoverItem)
  if IsHover then
    self.HoveredPuzzleId = PuzzleId
  else
    self.HoveredPuzzleId = nil
  end
  if not IsPuzzleBoard then
    UpdateVisibility(self.PuzzleItemTipSlot, IsHover)
    if IsHover then
      self.PuzzleItemTipWidget = self.ViewModel:GetPuzzleHoverWidget(PuzzleId, HoverItem)
      self.PuzzleItemTipWidget:ListenInputEvent(true)
    elseif self.PuzzleItemTipWidget then
      self.PuzzleItemTipWidget:Hide()
    end
  end
end

function WBP_PuzzleView:BindOnUpdateGemItemHoverStatus(IsHover, GemId, IsPuzzleBoard, HoveredItem)
  if IsHover then
    self.HoverGemId = GemId
  else
    self.HoverGemId = nil
  end
  if not IsPuzzleBoard then
    if IsHover then
      self.GemItemTipWidget = self.ViewModel:GetGemHoverWidget(self.HoverGemId, HoveredItem)
      self.GemItemTipWidget:Show(GemId)
      self.GemItemTipWidget:ListenInputEvent(true)
    elseif self.GemItemTipWidget and self.GemItemTipWidget:IsValid() then
      self.GemItemTipWidget:Hide()
    end
  end
end

function WBP_PuzzleView:BindOnUpdatePuzzlePackageInfo(PuzzleIdList)
  if self.HoveredPuzzleId and (not PuzzleIdList or table.Contain(PuzzleIdList, self.HoveredPuzzleId)) then
    local HoverWidget = self.ViewModel:GetPuzzleHoverWidget(self.HoveredPuzzleId)
    HoverWidget:RefreshOperateVis()
  end
  if not PuzzleIdList then
    self:RefreshButtonNumInfo()
    self:RefreshPuzzleItemList()
    self:RefreshEquipAttrAndInscriptionInfo()
    self:UpdatePuzzleBoardEquipStatus()
  end
end

function WBP_PuzzleView:BindOnUpdateGemPackageInfo(GemId)
  if self.HoverGemId and (not GemId or self.HoverGemId == GemId) then
    local HoverWidget = self.ViewModel:GetGemHoverWidget(self.HoverGemId)
    HoverWidget:RefreshOperateVis()
  end
  if not GemId then
    self:RefreshButtonNumInfo()
    self:RefreshGemItemList()
    self:RefreshEquipAttrAndInscriptionInfo()
    self:UpdatePuzzleBoardEquipStatus()
  end
end

function WBP_PuzzleView:BindOnGemDecomposeSuccess(...)
  self:RefreshGemItemList()
end

function WBP_PuzzleView:BindOnEquipPuzzleSuccess(PuzzleId)
  self:RefreshEquipAttrAndInscriptionInfo()
  local LastIsFullEquipBoard = self.IsFullEquip
  self:UpdatePuzzleBoardEquipStatus()
  if not LastIsFullEquipBoard and self.IsFullEquip then
    self:PlayAnimation(self.Ani_full)
  end
end

function WBP_PuzzleView:BindOnGemEquipSuccess(...)
  self:RefreshEquipAttrAndInscriptionInfo()
end

function WBP_PuzzleView:BindOnGemUnEquipSuccess(...)
  self:RefreshEquipAttrAndInscriptionInfo()
end

function WBP_PuzzleView:BindOnUnEquipPuzzleSuccess(PuzzleId)
  self:RefreshEquipAttrAndInscriptionInfo()
  local LastIsFullEquipBoard = self.IsFullEquip
  self:UpdatePuzzleBoardEquipStatus()
  if LastIsFullEquipBoard and not self.IsFullEquip then
    self:PlayAnimation(self.Ani_NotFull)
  end
end

function WBP_PuzzleView:OnRightMouseButtonDown(...)
  if not self.HoverGemId and self.HoveredPuzzleId then
    local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.HoveredPuzzleId)
    if 0 ~= PackageInfo.equipHeroID and PackageInfo.equipHeroID == self:GetCurHeroId() then
      PuzzleHandler:RequestUnEquipPuzzleToServer(self.HoveredPuzzleId, PackageInfo.equipHeroID)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, false)
      PlaySound2DByName(self.UnEquipPuzzleSoundName, "WBP_PuzzleView:OnRightMouseButtonDown")
    end
  end
  if self.HoverGemId then
    local PackageInfo = GemData:GetGemPackageInfoByUId(self.HoverGemId)
    if GemData:IsEquippedInPuzzle(self.HoverGemId) then
      local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(PackageInfo.pzUniqueID)
      local TargetSlotId
      for SlotId, GemId in pairs(GemSlotInfo) do
        if GemId == self.HoverGemId then
          TargetSlotId = tonumber(SlotId)
        end
      end
      if TargetSlotId then
        GemHandler:RequestUnEquipGemToServer(PackageInfo.pzUniqueID, TargetSlotId)
        EventSystem.Invoke(EventDef.Gem.OnUpdateGemItemHoverStatus, false)
      end
    end
  end
end

function WBP_PuzzleView:BindOnDetailListCheckStateChanged(IsChecked)
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

function WBP_PuzzleView:BindOnSortRuleSelectionChanged(Id, IsGem)
  self.ViewModel:SetPuzzleSortRule(Id, IsGem)
  if self.ViewListToggleState == EListType.Puzzle then
    if not IsGem then
      self:RefreshPuzzleItemList()
    end
  elseif IsGem then
    self:RefreshGemItemList()
  end
end

function WBP_PuzzleView:BindOnUpgradeButtonClicked(...)
  if self.ViewListToggleState == EListType.Puzzle then
    UIMgr:Show(ViewID.UI_PuzzleDevelopMain, true, nil)
  else
    UIMgr:Show(ViewID.UI_PuzzleDevelopMain, true, nil, EPuzzleGemDevelopId.GemUpgrade)
  end
end

function WBP_PuzzleView:BindOnDecomposeButtonClicked(...)
  if self.ViewListToggleState == EListType.Puzzle then
    UIMgr:Show(ViewID.UI_PuzzleDevelopMain, true, nil, EPuzzleGemDevelopId.PuzzleDecompose)
  else
    UIMgr:Show(ViewID.UI_PuzzleDevelopMain, true, nil, EPuzzleGemDevelopId.GemDecompose)
  end
end

function WBP_PuzzleView:BindOnRGViewListToggleStateChanged(State)
  self.ViewListToggleState = State
  UpdateVisibility(self.Overlay_PuzzleList, State == EListType.Puzzle)
  UpdateVisibility(self.Overlay_GemList, State == EListType.Gem)
  UpdateVisibility(self.ScaleBox_DetailInfo, State == EListType.Puzzle)
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  end
  self.ViewModel:SetPuzzleFilterDiscardSelected(false)
  self.ViewModel:SetPuzzleFilterLockSelected(false)
  UpdateVisibility(self.WBP_PuzzleSortRuleComboBox, State == EListType.Puzzle)
  UpdateVisibility(self.GemSortRuleComboBox, State == EListType.Gem)
  self.WBP_PuzzleSortRuleComboBox:HideExpandList()
  self.GemSortRuleComboBox:HideExpandList()
  if State == EListType.Gem then
    self:RefreshGemItemList()
    self.WBP_CommonButton_Upgrade:SetContentText(self.GemUpgradeText)
    self.WBP_CommonButton_Decompose:SetContentText(self.GemDecomposeText)
  else
    self:RefreshPuzzleItemList()
    self.WBP_CommonButton_Upgrade:SetContentText(self.PuzzleUpgradeText)
    self.WBP_CommonButton_Decompose:SetContentText(self.PuzzleDecomposeText)
  end
  self:RefreshFilterIconStatus()
end

function WBP_PuzzleView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.WBP_PuzzleFilterView:IsVisible() then
    self.WBP_PuzzleFilterView:Hide()
  end
  self.WBP_PuzzleSortRuleComboBox:HideExpandList()
  self.GemSortRuleComboBox:HideExpandList()
  if UE.UKismetInputLibrary.PointerEvent_IsMouseButtonDown(MouseEvent, self.RightMouseButtonKey) then
    self:OnRightMouseButtonDown()
    return UE.UWidgetBlueprintLibrary.Handled()
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function WBP_PuzzleView:OnMouseButtonUp(MyGeometry, MouseEvent)
  if not UE.UWidgetBlueprintLibrary.IsDragDropping() then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local Operation = UE.UWidgetBlueprintLibrary.GetDragDroppingContent()
  if not Operation or Operation.IsGem then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local CurKey = UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(self:GetOwningPlayer(), UE.UCommonInputSubsystem:StaticClass())
  local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
  local RotateKey = LogicGameSetting.GetCurPlayerMappableKey("PuzzleRotate", CurrentInputType)
  if UE.UKismetInputLibrary.EqualEqual_KeyKey(CurKey, RotateKey) then
    self.ViewModel.DragVisualWidget:BindOnPuzzleRotateKeyPressed(true)
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function WBP_PuzzleView:OnKeyDown(MyGeometry, InKeyEvent)
  if not UE.UWidgetBlueprintLibrary.IsDragDropping() then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local CurKey = UE.UKismetInputLibrary.GetKey(InKeyEvent)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(self:GetOwningPlayer(), UE.UCommonInputSubsystem:StaticClass())
  local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
  local RotateKey = LogicGameSetting.GetCurPlayerMappableKey("PuzzleRotate_Gamepad", CurrentInputType)
  if UE.URGBlueprintLibrary.EqualKey(CurKey, RotateKey) then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  UE.UWidgetBlueprintLibrary.CancelDragDrop()
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function WBP_PuzzleView:OnPreHide(...)
  LogicRole.ShowOrHideRoleMainHero(false)
  UE.UWidgetBlueprintLibrary.CancelDragDrop()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ItemInAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ItemInAnimTimer)
  end
  local AllChildren = self.WrapBox_World:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local AllPuzzleBoard = self.Canvaspanel_Puzzleboard:GetAllChildren()
  for k, SingleItem in pairs(AllPuzzleBoard) do
    SingleItem:Hide()
  end
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleboardDrop, self, self.BindOnPuzzleboardDrop)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleboardDragEnter, self, self.BindOnPuzzleboardDragEnter)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleboardDragCancelled, self, self.BindOnPuzzleboardDragCancelled)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnRotatePuzzleDragCoordinate, self, self.BindOnRotatePuzzleDragCoordinate)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnEquipPuzzleSuccess, self, self.BindOnEquipPuzzleSuccess)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUnEquipPuzzleSuccess, self, self.BindOnUnEquipPuzzleSuccess)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemItemSelected, self, self.BindOnGemItemSelected)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemEquipSuccess, self, self.BindOnGemEquipSuccess)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemUnEquipSuccess, self, self.BindOnGemUnEquipSuccess)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemDecomposeSuccess, self, self.BindOnGemDecomposeSuccess)
  self.ViewModel:OnViewClose()
  self.RGTileViewPuzzleList.BP_OnItemSelectionChanged:Remove(self, self.BindOnItemSelectionChanged)
  if self.PuzzleItemTipWidget then
    self.PuzzleItemTipWidget:Hide()
  end
  self.RGTileViewPuzzleList:SetRGListItems({}, false, true)
  self.RGTileViewGemList:SetRGListItems({}, false, true)
end

function WBP_PuzzleView:OnHide()
  self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  self:StopAllAnimations()
end

function WBP_PuzzleView:Destruct()
  self:OnPreHide()
end

return WBP_PuzzleView
