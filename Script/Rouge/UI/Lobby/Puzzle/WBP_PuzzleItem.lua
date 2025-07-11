local WBP_PuzzleItem = UnLua.Class()
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleInfoConfig = require("GameConfig.Puzzle.PuzzleInfoConfig")
function WBP_PuzzleItem:Show(InPuzzleId)
  self.DataObj = {PuzzleId = InPuzzleId}
  self.ResourceId = PuzzleData:GetPuzzleResourceIdByUid(self.DataObj.PuzzleId)
  self.CanDrag = false
  self.CanShowToolTipWidget = true
  self:InitDisplayInfo()
  self:UpdatePuzzlePackageInfo()
  self:BindOnUpdatePuzzleListStyle()
  self:BindOnPuzzleItemSelected()
  self:UpdatePuzzleDetailInfo()
  UpdateVisibility(self.CanvasPanel_Select, false)
end
function WBP_PuzzleItem:OnListItemObjectSet(DataObj)
  self.DataObj = DataObj
  self.ResourceId = PuzzleData:GetPuzzleResourceIdByUid(self.DataObj.PuzzleId)
  self.CanDrag = self.DataObj.CanDrag ~= nil and self.DataObj.CanDrag or false
  self.CanShowToolTipWidget = nil ~= self.DataObj.CanShowToolTipWidget and self.DataObj.CanShowToolTipWidget or false
  self:InitDisplayInfo()
  self:UpdatePuzzlePackageInfo()
  self:BindOnUpdatePuzzleListStyle()
  UpdateVisibility(self.CanvasPanel_Del, self.DataObj.IsMultiSelect)
  self:BindOnPuzzleItemSelected()
  self:UpdatePuzzleDetailInfo()
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.AddListenerNew(EventDef.Puzzle.UpdatePuzzleListStyle, self, self.BindOnUpdatePuzzleListStyle)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleItemSelected, self, self.BindOnPuzzleItemSelected)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, self, self.BindOnUpdatePuzzleDetailInfo)
end
function WBP_PuzzleItem:PlayInAnimation(Index)
  local DelayTime = Index * self.InAnimInterval
  if DelayTime <= 0 then
    self:PlayAnimation(self.Ani_in)
  else
    UpdateVisibility(self, false)
    self.InAnimTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        UpdateVisibility(self, true)
        self:PlayAnimation(self.Ani_in)
      end
    }, DelayTime, false)
  end
end
function WBP_PuzzleItem:PlayDecomposeInAnimtion(Index)
  local Column = math.floor(Index / self.DecomposeColumnNum)
  local Row = Index % self.DecomposeColumnNum
  local DelayTime = Row * self.InAnimInterval + Column * self.InAnimInterval
  if DelayTime <= 0 then
    self:PlayAnimation(self.Ani_decompose_in)
  else
    UpdateVisibility(self, false)
    self.InAnimTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        UpdateVisibility(self, true)
        self:PlayAnimation(self.Ani_decompose_in)
      end
    }, DelayTime, false)
  end
end
function WBP_PuzzleItem:InitDisplayInfo()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.ResourceId)
  if not Result then
    return
  end
  local Result, RarityRowInfo = GetRowData(DT.DT_ItemRarity, RowInfo.Rare)
  if Result then
    self.Img_Rare:SetColorAndOpacity(RarityRowInfo.DisplayNameColor.SpecifiedColor)
  end
  UpdateVisibility(self.CanvasPanel_RedQuality, RowInfo.Rare == TableEnums.ENUMResourceRare.EIR_Immortal)
  local Result, PuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, self.ResourceId)
  local IsShowGradeIcon = PuzzleResRowInfo.Grade > 0 and PuzzleInfoConfig.IsShowGradeIcon
  local IsShowGradeText = PuzzleResRowInfo.Grade > 0 and not PuzzleInfoConfig.IsShowGradeIcon
  UpdateVisibility(self.Img_Grade, IsShowGradeIcon)
  if IsShowGradeIcon then
    local Result, GradeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleGrade, PuzzleResRowInfo.Grade)
    if Result then
      SetImageBrushByPath(self.Img_Grade, GradeRowInfo.Icon, self.GradeIconSize)
    end
  end
  UpdateVisibility(self.Txt_Grade, IsShowGradeText)
  if IsShowGradeText then
    local Result, GradeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleGrade, PuzzleResRowInfo.Grade)
    if Result then
      self.Txt_Grade:SetText(GradeRowInfo.Name)
    end
  end
end
function WBP_PuzzleItem:UpdatePuzzlePackageInfo()
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.DataObj.PuzzleId)
  UpdateVisibility(self.CanvasPanel_Lock, PackageInfo.state == EPuzzleStatus.Lock)
  UpdateVisibility(self.CanvasPanel_Discard, PackageInfo.state == EPuzzleStatus.Discard)
  UpdateVisibility(self.CanvasPanel_Equipped, 0 ~= PackageInfo.equipHeroID)
  if 0 ~= PackageInfo.equipHeroID then
    local Result, HeroRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleHero, PackageInfo.equipHeroID)
    if Result then
      SetImageBrushByPath(self.Img_EquippedHeroIcon, HeroRowInfo.HeroIcon)
    end
  end
  local Result, ShapeRowInfo = PuzzleData:GetPuzzleShapeRowInfo(self.DataObj.PuzzleId)
  if Result then
    SetImageBrushByPath(self.Img_Icon, ShapeRowInfo.Icon, self.IconSize)
  end
end
function WBP_PuzzleItem:UpdatePuzzleDetailInfo(...)
  local IsShowGoldenQuality = false
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.ResourceId)
  if Result and RowInfo.Rare ~= TableEnums.ENUMResourceRare.EIR_Immortal then
    local DetailInfo = PuzzleData:GetPuzzleDetailInfo(self.DataObj.PuzzleId)
    local SubAttrInitV2 = DetailInfo.SubAttrInitV2
    for i, SingleAttrInfo in ipairs(SubAttrInitV2) do
      if SingleAttrInfo.godAttr then
        IsShowGoldenQuality = true
        break
      end
    end
  end
  UpdateVisibility(self.CanvasPanel_GoldenQuality, IsShowGoldenQuality)
  local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(self.DataObj.PuzzleId)
  UpdateVisibility(self.Horizontal_GemIcon, next(GemSlotInfo) ~= nil)
  if next(GemSlotInfo) ~= nil then
    local SlotIndexList = {}
    for SlotIndex, EquipGemId in pairs(GemSlotInfo) do
      table.insert(SlotIndexList, SlotIndex)
    end
    table.sort(SlotIndexList, function(a, b)
      return "0" ~= GemSlotInfo[a] and "0" == GemSlotInfo[b]
    end)
    local Index = 1
    for i, SingleSlotIndex in ipairs(SlotIndexList) do
      local GemId = GemSlotInfo[SingleSlotIndex]
      local Item = GetOrCreateItem(self.Horizontal_GemIcon, Index, self.WBP_GemIconInPuzzle:StaticClass())
      Item:Show(GemId)
      Index = Index + 1
    end
    HideOtherItem(self.Horizontal_GemIcon, Index)
  end
end
function WBP_PuzzleItem:BindOnUpdatePuzzlePackageInfo(PuzzleIdList)
  if PuzzleIdList and not table.Contain(PuzzleIdList, self.DataObj.PuzzleId) then
    return
  end
  self:UpdatePuzzlePackageInfo()
end
function WBP_PuzzleItem:BindOnUpdatePuzzleDetailInfo(PuzzleIdList)
  if PuzzleIdList and not table.Contain(PuzzleIdList, self.DataObj.PuzzleId) then
    return
  end
  self:UpdatePuzzleDetailInfo()
end
function WBP_PuzzleItem:BindOnPuzzleItemSelected(PuzzleId)
  local ViewModel = self.DataObj.ViewModel
  if not ViewModel then
    return
  end
  if self.DataObj.IsMultiSelect then
    UpdateVisibility(self.CanvasPanel_Select, table.Contain(ViewModel:GetCurSelectPuzzleIdList(), self.DataObj.PuzzleId))
  else
    UpdateVisibility(self.CanvasPanel_Select, ViewModel:GetCurSelectPuzzleId() == self.DataObj.PuzzleId)
  end
end
function WBP_PuzzleItem:BindOnUpdatePuzzleListStyle()
  local PuzzleViewModel = self.DataObj.ViewModel
  local IsShowDetail = PuzzleViewModel and PuzzleViewModel.GetIsShowPuzzleDetailList and PuzzleViewModel:GetIsShowPuzzleDetailList() or false
  UpdateVisibility(self.Overlay_Attribute, IsShowDetail)
  if IsShowDetail then
    local DetailInfo = PuzzleData:GetPuzzleDetailInfo(self.DataObj.PuzzleId)
    local AttrIdList = {}
    local Index = 1
    local FilterSelectList = self.DataObj.ViewModel:GetPuzzleFilterSelectStatus()
    local AttrFilter = FilterSelectList[EPuzzleFilterType.SubAttr]
    for i, AttrInfo in pairs(DetailInfo.SubAttrInitV2) do
      local AttrId = AttrInfo.attrID
      local Value = AttrInfo.value
      local Item = GetOrCreateItem(self.Vertical_SubAttr, Index, self.WBP_PuzzleItemAttrItem:StaticClass())
      local AttrGrowthValue = DetailInfo.SubAttrGrowth[tostring(AttrId)] or 0
      Item:Show(AttrId, Value + AttrGrowthValue, table.Contain(AttrFilter, tonumber(AttrId)))
      table.insert(AttrIdList, AttrId)
      Index = Index + 1
    end
    for AttrId, Value in pairs(DetailInfo.SubAttrGrowth) do
      if not table.Contain(AttrIdList, AttrId) then
        local Item = GetOrCreateItem(self.Vertical_SubAttr, Index, self.WBP_PuzzleItemAttrItem:StaticClass())
        Item:Show(AttrId, Value)
        table.insert(AttrIdList, AttrId, table.count(AttrFilter, tonumber(AttrId)))
        Index = Index + 1
      end
    end
    HideOtherItem(self.Vertical_SubAttr, Index, true)
    local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.DataObj.PuzzleId)
    UpdateVisibility(self.Overlay_Inscription, PackageInfo.inscription > 0)
    if PackageInfo.inscription > 0 then
      self.Txt_SpecialAttr:SetText(GetInscriptionName(PackageInfo.inscription))
    end
  end
end
function WBP_PuzzleItem:OnDragDetected(MyGeometry, PointerEvent)
  if not self.CanDrag then
    return nil
  end
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.DataObj.PuzzleId)
  if PackageInfo.equipHeroID == PuzzleViewModel:GetCurHeroId() then
    return nil
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, self.ResourceId)
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  local Result, ShapeRowInfo = PuzzleData:GetPuzzleShapeRowInfo(self.DataObj.PuzzleId)
  local DragOperation = PuzzleViewModel:GetPuzzleDragOperation(ShapeRowInfo.initPositions, self.DataObj.PuzzleId)
  EventSystem.Invoke(EventDef.Puzzle.OnPuzzleDrag, self.DataObj.PuzzleId)
  return DragOperation
end
function WBP_PuzzleItem:OnDragCancelled(MyGeometry, PointerEvent)
  print("DragCancelled")
  EventSystem.Invoke(EventDef.Puzzle.OnPuzzleboardDragCancelled, self.DataObj.PuzzleId)
end
function WBP_PuzzleItem:OnMouseEnter()
  if self.CanShowToolTipWidget then
    return
  end
  UpdateVisibility(self.HoverPanel, true)
  self:PlayAnimation(self.Ani_hover_in)
  PlaySound2DByName(self.HoverSoundName, "WBP_PuzzleItem:OnMouseEnter")
  local MyGeometry = self.CanvasPanel_Simple:GetCachedGeometry()
  local LocalPosition = UE.USlateBlueprintLibrary.GetLocalTopLeft(MyGeometry)
  local PixelPos, ViewportPos = UE.USlateBlueprintLibrary.LocalToViewport(self, MyGeometry, LocalPosition, nil, nil)
  EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, true, self.DataObj.PuzzleId, false, ViewportPos, self)
end
function WBP_PuzzleItem:OnMouseLeave()
  if self.CanShowToolTipWidget then
    return
  end
  UpdateVisibility(self.HoverPanel, false, false, true)
  self:PlayAnimation(self.Ani_hover_out)
  EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, false)
end
function WBP_PuzzleItem:GetToolTipWidget(...)
  if not self.CanShowToolTipWidget then
    return
  end
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  local Widget = PuzzleViewModel:GetPuzzleHoverWidget(self.DataObj.PuzzleId)
  Widget:HideOperateTip()
  return Widget
end
function WBP_PuzzleItem:OnLeftMouseButtonDown(...)
  local PuzzleViewModel = self.DataObj.ViewModel
  if PuzzleViewModel then
    if PuzzleViewModel.CanSelectPuzzle and not PuzzleViewModel:CanSelectPuzzle(self.DataObj.PuzzleId) then
      return
    end
    PuzzleViewModel:SetCurSelectPuzzleId(self.DataObj.PuzzleId)
  end
  local PuzzleView = UIMgr:GetLuaFromActiveView(ViewID.UI_Puzzle)
  if PuzzleView then
    PuzzleView:SetFocus()
  end
  PlaySound2DByName(self.SelectSoundName, "WBP_PuzzleItem:OnLeftMouseButtonDown")
  EventSystem.Invoke(EventDef.Puzzle.OnPuzzleItemSelected, self.DataObj.PuzzleId)
end
function WBP_PuzzleItem:OnRightMouseButtonDown(...)
  if not self.CanDrag then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local PuzzleView = UIMgr:GetLuaFromActiveView(ViewID.UI_Puzzle)
  if PuzzleView then
    PuzzleView:OnRightMouseButtonDown()
  end
end
function WBP_PuzzleItem:OnMouseButtonUp(MyGeometry, MouseEvent)
  if not self.CanDrag then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local PuzzleView = UIMgr:GetLuaFromActiveView(ViewID.UI_Puzzle)
  if PuzzleView then
    PuzzleView:OnMouseButtonUp(MyGeometry, MouseEvent)
    PuzzleView:SetFocus()
  end
end
function WBP_PuzzleItem:BP_OnEntryReleased()
  self.DataObj = nil
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.InAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.InAnimTimer)
  end
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.UpdatePuzzleListStyle, self, self.BindOnUpdatePuzzleListStyle)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleItemSelected, self, self.BindOnPuzzleItemSelected)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, self, self.BindOnUpdatePuzzleDetailInfo)
end
function WBP_PuzzleItem:Destruct(...)
  self:BP_OnEntryReleased()
end
return WBP_PuzzleItem
