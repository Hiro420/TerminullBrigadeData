local WBP_GemItemTip = UnLua.Class()
local GemData = require("Modules.Gem.GemData")
local GemHandler = require("Protocol.Gem.GemHandler")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleUpgrade = "ChipUpgrade"
local PuzzleLock = "ChipLock"
local PuzzleDiscard = "ChipDiscard"
function WBP_GemItemTip:Show(GemId, InPackageInfo)
  self.GemId = GemId
  local PackageInfo = InPackageInfo
  PackageInfo = PackageInfo or GemData:GetGemPackageInfoByUId(self.GemId)
  self.PackageInfo = PackageInfo
  if not PackageInfo then
    return
  end
  UpdateVisibility(self, true)
  local ResourceId = tonumber(PackageInfo.resourceID) or PackageInfo.resourceid
  local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  local Name = GemData:GetGemName(self.GemId, self.PackageInfo)
  self.Txt_Name:SetText(Name)
  local Level = PackageInfo.level or PackageInfo.Level
  self.Txt_Level:SetText(Level)
  local Result, GemResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResGem, ResourceId)
  if not Result then
    return
  end
  local Result, RarityRowInfo = GetRowData(DT.DT_ItemRarity, ResourceRowInfo.Rare)
  if Result then
    self.Img_BGRare:SetColorAndOpacity(RarityRowInfo.DisplayNameColor.SpecifiedColor)
  end
  local MainAttrValueList = {}
  for index, SingleAttrInfo in ipairs(GemResRowInfo.Attr) do
    MainAttrValueList[SingleAttrInfo.key] = SingleAttrInfo.value
  end
  local MainAttrGrowthValueList = {}
  local Result, CoreAttrLvUpRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGemLevelUpAttr, ResourceRowInfo.Rare)
  for i, SingleAttrInfo in ipairs(CoreAttrLvUpRowInfo.LevelUpAttr) do
    MainAttrGrowthValueList[SingleAttrInfo.key] = SingleAttrInfo.value
  end
  local MutationInfo, AttrId, CurMutationType, CurMutationValue
  if PackageInfo.mutation then
    MutationInfo = PackageInfo.mutationAttr[1]
    AttrId = MutationInfo and (MutationInfo.AttrID or MutationInfo.attrID)
    CurMutationType = MutationInfo and (MutationInfo.MutationType or MutationInfo.mutationType)
    CurMutationValue = MutationInfo and (MutationInfo.MutationValue or MutationInfo.mutationValue)
  end
  local Index = 1
  for i, SingleCoreAttributeId in ipairs(PackageInfo.mainAttrIDs) do
    local SingleCoreAttributeIdNumber = tonumber(SingleCoreAttributeId) or SingleCoreAttributeId
    local Item = GetOrCreateItem(self.VerticalBoxCoreAttr, Index, self.PuzzleCoreAttrListItemTemplate:StaticClass())
    local Value = MainAttrValueList[SingleCoreAttributeIdNumber] + MainAttrGrowthValueList[SingleCoreAttributeIdNumber] * PackageInfo.level or 0
    local MutationType
    if MutationInfo and AttrId == SingleCoreAttributeIdNumber and CurMutationType == EMutationType.NegaMutation then
      Value = Value * CurMutationValue
      MutationType = CurMutationType
    end
    Item:Show(SingleCoreAttributeIdNumber, Value, nil, MutationType)
    Index = Index + 1
  end
  HideOtherItem(self.VerticalBoxCoreAttr, Index, true)
  UpdateVisibility(self.MutationAttrItem, MutationInfo and CurMutationType == EMutationType.PosMutation)
  if MutationInfo and CurMutationType == EMutationType.PosMutation then
    self.MutationAttrItem:Show(AttrId, CurMutationValue, nil, false, CurMutationType)
  end
  self:RefreshOperateVis()
end
function WBP_GemItemTip:ShowWithoutOperator(PuzzleId, InPackageInfo)
  self:Show(PuzzleId, InPackageInfo)
  self:HideOperateTip()
end
function WBP_GemItemTip:ListenInputEvent(IsInMainView)
  self.IsInMainView = IsInMainView
  if not IsListeningForInputAction(self, PuzzleDiscard, UE.EInputEvent.IE_Pressed) then
    ListenForInputAction(PuzzleDiscard, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnDiscardKeyPressed
    })
  end
  if not IsListeningForInputAction(self, PuzzleLock, UE.EInputEvent.IE_Pressed) then
    ListenForInputAction(PuzzleLock, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnLockKeyPressed
    })
  end
  if self.IsInMainView and not IsListeningForInputAction(self, PuzzleUpgrade, UE.EInputEvent.IE_Pressed) then
    ListenForInputAction(PuzzleUpgrade, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnUpgradeKeyPressed
    })
  end
  if self.IsInMainView then
    self.WBP_InteractTipWidgetUnEquip:BindInteractAndClickEvent(self, self.BindOnUnEquipKeyPressed)
  end
  UpdateVisibility(self.Overlay_Upgrade, self.IsInMainView)
  UpdateVisibility(self.Overlay_EquipTip, self.IsInMainView)
end
function WBP_GemItemTip:BindOnDiscardKeyPressed(...)
  if not self.GemId then
    return
  end
  local PackageInfo = GemData:GetGemPackageInfoByUId(self.GemId)
  if PackageInfo.state == EGemStatus.Normal then
    GemHandler:RequestDiscardGemToServer(self.GemId)
  elseif PackageInfo.state == EGemStatus.Discard then
    GemHandler:RequestCancelLockOrDiscardGemToServer(self.GemId)
  end
end
function WBP_GemItemTip:BindOnLockKeyPressed(...)
  if not self.GemId then
    return
  end
  local PackageInfo = GemData:GetGemPackageInfoByUId(self.GemId)
  if PackageInfo.state == EGemStatus.Normal then
    GemHandler:RequestLockGemToServer(self.GemId)
  elseif PackageInfo.state == EGemStatus.Lock then
    GemHandler:RequestCancelLockOrDiscardGemToServer(self.GemId)
  end
end
function WBP_GemItemTip:BindOnUpgradeKeyPressed(...)
  UIMgr:Show(ViewID.UI_PuzzleDevelopMain, true, self.GemId, EPuzzleGemDevelopId.GemUpgrade)
end
function WBP_GemItemTip:BindOnUnEquipKeyPressed(...)
  if GemData:IsEquippedInPuzzle(self.GemId) then
    local EquipPuzzleId = GemData:GetGemEquippedPuzzleId(self.GemId)
    local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(EquipPuzzleId)
    local TargetSlotId
    for SlotId, GemId in pairs(GemSlotInfo) do
      if self.GemId == GemId then
        TargetSlotId = SlotId
        break
      end
    end
    if TargetSlotId then
      GemHandler:RequestUnEquipGemToServer(EquipPuzzleId, TargetSlotId)
    end
  end
end
function WBP_GemItemTip:RefreshOperateVis()
  UpdateVisibility(self.Overlay_OperateTip, true)
  local PackageInfo = self.PackageInfo
  PackageInfo = PackageInfo or GemData:GetGemPackageInfoByUId(self.GemId)
  local IsEquipped = GemData:IsEquippedInPuzzle(self.GemId)
  UpdateVisibility(self.WBP_InteractTipWidgetEquip, not IsEquipped)
  UpdateVisibility(self.WBP_InteractTipWidgetUnEquip, IsEquipped)
  UpdateVisibility(self.WBP_InteractTipWidgetLock, PackageInfo.state == EGemStatus.Normal)
  UpdateVisibility(self.WBP_InteractTipWidgetUnLock, PackageInfo.state == EGemStatus.Lock)
  UpdateVisibility(self.WBP_InteractTipWidgetDiscard, PackageInfo.state == EGemStatus.Normal)
  UpdateVisibility(self.WBP_InteractTipWidgetCancelDiscard, PackageInfo.state == EGemStatus.Discard)
end
function WBP_GemItemTip:HideOperateTip(...)
  UpdateVisibility(self.Overlay_OperateTip, false)
end
function WBP_GemItemTip:Hide()
  UpdateVisibility(self, false)
  if IsListeningForInputAction(self, PuzzleDiscard, UE.EInputEvent.IE_Pressed) then
    StopListeningForInputAction(self, PuzzleDiscard, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, PuzzleLock, UE.EInputEvent.IE_Pressed) then
    StopListeningForInputAction(self, PuzzleLock, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, PuzzleUpgrade, UE.EInputEvent.IE_Pressed) then
    StopListeningForInputAction(self, PuzzleUpgrade, UE.EInputEvent.IE_Pressed)
  end
  self.WBP_InteractTipWidgetUnEquip:UnBindInteractAndClickEvent(self, self.BindOnUnEquipKeyPressed)
end
function WBP_GemItemTip:Destruct(...)
  self:Hide()
end
return WBP_GemItemTip
