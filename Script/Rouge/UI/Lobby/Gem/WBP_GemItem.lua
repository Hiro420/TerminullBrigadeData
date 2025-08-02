local WBP_GemItem = UnLua.Class()
local GemData = require("Modules.Gem.GemData")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local GemHandler = require("Protocol.Gem.GemHandler")

function WBP_GemItem:Show(InGemId)
  self.DataObj = {GemId = InGemId}
  self.ResourceId = GemData:GetGemResourceIdByUId(InGemId)
  self.CanDrag = false
  self.CanShowToolTipWidget = true
  self:InitDisplayInfo()
  self:UpdatePuzzlePackageInfo()
  self:BindOnGemItemSelected()
  UpdateVisibility(self.CanvasPanel_Select, false)
end

function WBP_GemItem:OnListItemObjectSet(DataObj)
  self.DataObj = DataObj
  self.ResourceId = GemData:GetGemResourceIdByUId(self.DataObj.GemId)
  self.CanDrag = self.DataObj.CanDrag ~= nil and self.DataObj.CanDrag or false
  self.CanShowToolTipWidget = nil ~= self.DataObj.CanShowToolTipWidget and self.DataObj.CanShowToolTipWidget or false
  self:InitDisplayInfo()
  self:UpdateGemPackageInfo()
  UpdateVisibility(self.CanvasPanel_Del, self.DataObj.IsMultiSelect)
  self:BindOnGemItemSelected()
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemItemSelected, self, self.BindOnGemItemSelected)
end

function WBP_GemItem:PlayInAnimation(Index)
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

function WBP_GemItem:PlayDecomposeInAnimtion(Index)
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

function WBP_GemItem:InitDisplayInfo()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.ResourceId)
  if not Result then
    return
  end
  SetImageBrushByPath(self.Img_Icon, RowInfo.Icon)
  local Result, RarityRowInfo = GetRowData(DT.DT_ItemRarity, RowInfo.Rare)
  if Result then
    self.Img_Rare:SetColorAndOpacity(RarityRowInfo.DisplayNameColor.SpecifiedColor)
  end
end

function WBP_GemItem:UpdateGemPackageInfo()
  local PackageInfo = GemData:GetGemPackageInfoByUId(self.DataObj.GemId)
  self.Txt_Level:SetText(PackageInfo.level)
  UpdateVisibility(self.CanvasPanel_Lock, PackageInfo.state == EGemStatus.Lock)
  UpdateVisibility(self.CanvasPanel_Discard, PackageInfo.state == EGemStatus.Discard)
  local IsEquipped = GemData:IsEquippedInPuzzle(self.DataObj.GemId)
  UpdateVisibility(self.CanvasPanel_Equipped, IsEquipped)
  if IsEquipped then
    local EquipPuzzleId = GemData:GetGemEquippedPuzzleId(self.DataObj.GemId)
    local PuzzlePackageInfo = PuzzleData:GetPuzzlePackageInfo(EquipPuzzleId)
    UpdateVisibility(self.CanvasPanel_HeroEquipped, 0 ~= PuzzlePackageInfo.equipHeroID)
    UpdateVisibility(self.CanvasPanel_PuzzleEquipped, 0 == PuzzlePackageInfo.equipHeroID)
    if 0 ~= PuzzlePackageInfo.equipHeroID then
      local Result, HeroRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleHero, PuzzlePackageInfo.equipHeroID)
      if Result then
        SetImageBrushByPath(self.Img_EquippedHeroIcon, HeroRowInfo.HeroIcon)
      end
    end
  end
end

function WBP_GemItem:BindOnUpdateGemPackageInfo(GemId)
  if GemId and self.DataObj.GemId ~= GemId then
    return
  end
  self:UpdateGemPackageInfo()
end

function WBP_GemItem:BindOnUpdatePuzzlePackageInfo(PuzzleIdList)
  if not GemData:IsEquippedInPuzzle(self.DataObj.GemId) then
    return
  end
  local EquipPuzzleId = GemData:GetGemEquippedPuzzleId(self.DataObj.GemId)
  if PuzzleIdList and not table.Contain(PuzzleIdList, EquipPuzzleId) then
    return
  end
  self:UpdateGemPackageInfo()
end

function WBP_GemItem:BindOnGemItemSelected(GemId)
  local ViewModel = self.DataObj.ViewModel
  if not ViewModel then
    return
  end
  if self.DataObj.IsMultiSelect then
    UpdateVisibility(self.CanvasPanel_Select, table.Contain(ViewModel:GetCurSelectGemIdList(), self.DataObj.GemId))
  else
    UpdateVisibility(self.CanvasPanel_Select, ViewModel:GetCurSelectGemId() == self.DataObj.GemId)
  end
end

function WBP_GemItem:OnDragDetected(MyGeometry, PointerEvent)
  if not self.CanDrag then
    return nil
  end
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  local IsEquipped = GemData:IsEquippedInPuzzle(self.DataObj.GemId)
  if IsEquipped then
    local EquipPuzzleId = GemData:GetGemEquippedPuzzleId(self.DataObj.GemId)
    local PackageInfo = PuzzleData:GetPuzzlePackageInfo(EquipPuzzleId)
    if PackageInfo.equipHeroID == PuzzleViewModel:GetCurHeroId() then
      return nil
    end
  end
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  local DragOperation = PuzzleViewModel:GetGemDragOperation(self.DataObj.GemId)
  EventSystem.Invoke(EventDef.Gem.OnGemDrag, self.DataObj.GemId)
  return DragOperation
end

function WBP_GemItem:OnDragCancelled(MyGeometry, PointerEvent)
  print("GemDragCancelled")
  EventSystem.Invoke(EventDef.Gem.OnGemDragCancel)
end

function WBP_GemItem:OnMouseEnter()
  if self.CanShowToolTipWidget then
    return
  end
  UpdateVisibility(self.HoverPanel, true)
  EventSystem.Invoke(EventDef.Gem.OnUpdateGemItemHoverStatus, true, self.DataObj.GemId, false, self)
end

function WBP_GemItem:OnMouseLeave()
  if self.CanShowToolTipWidget then
    return
  end
  UpdateVisibility(self.HoverPanel, false)
  EventSystem.Invoke(EventDef.Gem.OnUpdateGemItemHoverStatus, false, self.DataObj and self.DataObj.GemId or nil, false, self)
end

function WBP_GemItem:GetToolTipWidget(...)
  if not self.CanShowToolTipWidget then
    return
  end
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  local Widget = PuzzleViewModel:GetGemHoverWidget(self.DataObj.GemId)
  Widget:HideOperateTip()
  return Widget
end

function WBP_GemItem:OnLeftMouseButtonDown(...)
  local ViewModel = self.DataObj.ViewModel
  if ViewModel then
    if ViewModel.CanSelectGem and not ViewModel:CanSelectGem(self.DataObj.GemId) then
      return
    end
    ViewModel:SetCurSelectGemId(self.DataObj.GemId)
  end
  EventSystem.Invoke(EventDef.Gem.OnGemItemSelected, self.DataObj.GemId)
end

function WBP_GemItem:OnRightMouseButtonDown(...)
  if not self.CanDrag then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local PuzzleView = UIMgr:GetLuaFromActiveView(ViewID.UI_Puzzle)
  if PuzzleView then
    PuzzleView:OnRightMouseButtonDown()
  end
end

function WBP_GemItem:OnMouseButtonUp(MyGeometry, MouseEvent)
  if not self.CanDrag then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local PuzzleView = UIMgr:GetLuaFromActiveView(ViewID.UI_Puzzle)
  if PuzzleView then
    PuzzleView:OnMouseButtonUp(MyGeometry, MouseEvent)
  end
end

function WBP_GemItem:BP_OnEntryReleased()
  self.DataObj = nil
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.InAnimTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.InAnimTimer)
  end
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePuzzlePackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemItemSelected, self, self.BindOnGemItemSelected)
end

function WBP_GemItem:Destruct(...)
  self:BP_OnEntryReleased()
end

return WBP_GemItem
