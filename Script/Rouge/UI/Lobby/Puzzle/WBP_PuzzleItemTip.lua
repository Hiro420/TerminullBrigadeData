local WBP_PuzzleItemTip = UnLua.Class()
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleHandler = require("Protocol.Puzzle.PuzzleHandler")
local GemData = require("Modules.Gem.GemData")
local table = require("table")
local PuzzleInfoConfig = require("GameConfig.Puzzle.PuzzleInfoConfig")
local PuzzleUpgrade = "ChipUpgrade"
local PuzzleLock = "ChipLock"
local PuzzleDiscard = "ChipDiscard"

function WBP_PuzzleItemTip:Show(PuzzleId, InPackageInfo, InDetailInfo, InGemPackageInfoList)
  self.PuzzleId = PuzzleId
  local PackageInfo = InPackageInfo
  PackageInfo = PackageInfo or PuzzleData:GetPuzzlePackageInfo(PuzzleId)
  self.PackageInfo = PackageInfo
  local PuzzleDetailInfo = InDetailInfo
  PuzzleDetailInfo = PuzzleDetailInfo or PuzzleData:GetPuzzleDetailInfo(PuzzleId)
  if not PackageInfo or not PuzzleDetailInfo then
    return
  end
  UpdateVisibility(self, true)
  local ResourceId = tonumber(PackageInfo.resourceID) or PackageInfo.resourceid
  local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  local Name = PuzzleData:GetPuzzleName(PuzzleId, PackageInfo, PuzzleDetailInfo)
  self.Txt_Name:SetText(Name)
  self.Txt_Name:ResetMarqueeOffset()
  local Result, PuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
  if not Result then
    return
  end
  local Result, WorldModeInfo = GetRowData(DT.DT_GameMode, PuzzleResRowInfo.worldID)
  if not Result then
    return
  end
  self.Txt_WorldName:SetText(WorldModeInfo.Name)
  local IsShowGradeIcon = PuzzleResRowInfo.Grade > 0 and PuzzleInfoConfig.IsShowGradeIcon
  local IsShowGradeText = PuzzleResRowInfo.Grade > 0 and not PuzzleInfoConfig.IsShowGradeIcon
  UpdateVisibility(self.Img_Grade, IsShowGradeIcon)
  if IsShowGradeIcon then
    local Result, GradeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleGrade, PuzzleResRowInfo.Grade)
    if Result then
      SetImageBrushByPath(self.Img_Grade, GradeRowInfo.TipIcon, self.GradeIconSize)
    end
  end
  UpdateVisibility(self.Txt_Grade, IsShowGradeText)
  if IsShowGradeText then
    local Result, GradeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleGrade, PuzzleResRowInfo.Grade)
    if Result then
      self.Txt_Grade:SetText(GradeRowInfo.Name)
    end
  end
  local Result, RarityRowInfo = GetRowData(DT.DT_ItemRarity, ResourceRowInfo.Rare)
  if Result then
    self.Img_BGRare:SetColorAndOpacity(RarityRowInfo.DisplayNameColor.SpecifiedColor)
  end
  local Index = 1
  for i, SingleCoreAttributeInfo in ipairs(PuzzleResRowInfo.MainAttr) do
    local Item = GetOrCreateItem(self.VerticalBoxCoreAttr, Index, self.PuzzleCoreAttrListItemTemplate:StaticClass())
    local MainGrowth = PuzzleDetailInfo.MainAttrGrowth or PuzzleDetailInfo.mainattrgrowth
    local AttrGrowthValue = MainGrowth[tostring(SingleCoreAttributeInfo.key)] or 0
    Item:Show(SingleCoreAttributeInfo.key, SingleCoreAttributeInfo.value + AttrGrowthValue)
    Index = Index + 1
  end
  HideOtherItem(self.VerticalBoxCoreAttr, Index, true)
  local SubAttrPoolResult, SubAttrPoolRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleSubAttrInit, PuzzleResRowInfo.SubAttrPoolID)
  local SubAttrRangeList = {}
  local SubGodAttrRangeList = {}
  if SubAttrPoolResult then
    for i, SingleSubAttrInfo in ipairs(SubAttrPoolRowInfo.Attr) do
      local TempTable = {
        MinValue = SingleSubAttrInfo.y,
        MaxValue = SingleSubAttrInfo.z
      }
      SubAttrRangeList[SingleSubAttrInfo.x] = TempTable
    end
    for i, SingleSubAttrInfo in ipairs(SubAttrPoolRowInfo.GodAttr) do
      local TempTable = {
        MinValue = SingleSubAttrInfo.y,
        MaxValue = SingleSubAttrInfo.z
      }
      SubGodAttrRangeList[SingleSubAttrInfo.x] = TempTable
    end
  end
  self.PuzzleMutationSubAttrItem:Hide()
  local Index = 1
  local SubAttrList = {}
  local SubGrowth = PuzzleDetailInfo.SubAttrGrowth or PuzzleDetailInfo.subattrgrowth
  local SubInit = PuzzleDetailInfo.SubAttrInitV2 or PuzzleDetailInfo.subattrinit
  local HasPosMutationAttr = false
  for i, SubAttrInfo in ipairs(SubInit) do
    local SubAttrId = SubAttrInfo.attrID or SubAttrInfo.attrid or SubAttrInfo.AttrID
    local SubAttrValue = SubAttrInfo.value or SubAttrInfo.Value
    local MutationType = SubAttrInfo.mutationType or SubAttrInfo.MutationType
    local IsGodAttr = PuzzleData:IsGodSubAttr(self.PuzzleId, PuzzleDetailInfo, SubAttrId)
    local RangeValue = IsGodAttr and SubGodAttrRangeList[SubAttrId] or SubAttrRangeList[SubAttrId]
    if MutationType ~= EMutationType.PosMutation then
      local Item = GetOrCreateItem(self.VerticalBoxRandomAttrList, Index, self.PuzzleSubAttrListItemTemplate:StaticClass())
      local AttrGrowthValue = SubGrowth[tostring(SubAttrId)] or 0
      Item:Show(SubAttrId, SubAttrValue + AttrGrowthValue, nil, IsGodAttr, MutationType, RangeValue)
      table.insert(SubAttrList, SubAttrId)
      Index = Index + 1
    else
      self.PuzzleMutationSubAttrItem:Show(SubAttrId, SubAttrValue, nil, false, MutationType, RangeValue)
      HasPosMutationAttr = true
    end
  end
  for SubAttrId, SubAttrValue in pairs(SubGrowth) do
    if not table.Contain(SubAttrList, SubAttrId) then
      local Item = GetOrCreateItem(self.VerticalBoxRandomAttrList, Index, self.PuzzleSubAttrListItemTemplate:StaticClass())
      local IsGodAttr = PuzzleData:IsGodSubAttr(self.PuzzleId, PuzzleDetailInfo, SubAttrId)
      local RangeValue = IsGodAttr and SubGodAttrRangeList[SubAttrId] or SubAttrRangeList[SubAttrId]
      Item:Show(SubAttrId, SubAttrValue, nil, IsGodAttr, EMutationType.Normal, RangeValue)
      table.insert(SubAttrList, SubAttrId)
      Index = Index + 1
    end
  end
  HideOtherItem(self.VerticalBoxRandomAttrList, Index, true)
  Index = 1
  local GemSlotInfo = PuzzleDetailInfo.GemSlotInfo or PuzzleDetailInfo.gemslotinfo or {}
  UpdateVisibility(self.CanvasPanel_Gem, next(GemSlotInfo) ~= nil)
  UpdateVisibility(self.URGImage_Line_2, next(GemSlotInfo) ~= nil or HasPosMutationAttr)
  if next(GemSlotInfo) ~= nil then
    local SlotIndexList = {}
    for SlotIndex, GemId in pairs(GemSlotInfo) do
      table.insert(SlotIndexList, SlotIndex)
    end
    table.sort(SlotIndexList, function(a, b)
      return "0" ~= GemSlotInfo[a] and "0" == GemSlotInfo[b]
    end)
    for SlotIndex, SlotIndex in ipairs(SlotIndexList) do
      local GemId = GemSlotInfo[SlotIndex]
      local Item
      local IsEmptyGem = "0" == GemId
      local AttrId, AttrValue = nil, 0
      if not IsEmptyGem then
        local GemPackageInfo = InGemPackageInfoList and InGemPackageInfoList[GemId]
        GemPackageInfo = GemPackageInfo or GemData:GetGemPackageInfoByUId(GemId)
        local MutationInfo
        if GemPackageInfo.mutation then
          MutationInfo = GemPackageInfo.mutationAttr[1]
        end
        local GemResourceId = GemData:GetGemResourceIdByUId(GemId, GemPackageInfo)
        local Result, GemResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResGem, GemResourceId)
        if not Result then
          return
        end
        for i, SingleAttrId in ipairs(GemPackageInfo.mainAttrIDs) do
          AttrId = SingleAttrId
          local Result, GemResGeneralRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, GemResourceId)
          local Result, CoreAttrLvUpRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGemLevelUpAttr, GemResGeneralRowInfo.Rare)
          local MainAttrGrowthValueList = {}
          for i, SingleAttrInfo in ipairs(CoreAttrLvUpRowInfo.LevelUpAttr) do
            MainAttrGrowthValueList[SingleAttrInfo.key] = SingleAttrInfo.value
          end
          for index, SingleAttrInfo in ipairs(GemResRowInfo.Attr) do
            if SingleAttrInfo.key == AttrId then
              AttrValue = SingleAttrInfo.value + MainAttrGrowthValueList[AttrId] * GemPackageInfo.level
              break
            end
          end
          local MutationType = MutationInfo and MutationInfo.MutationType
          if MutationInfo and MutationInfo.AttrID == AttrId and MutationInfo.MutationType == EMutationType.NegaMutation then
            AttrValue = AttrValue * MutationInfo.MutationValue
          end
          Item = GetOrCreateItem(self.VerticalBox_GemAttr, Index, self.WBP_GemAttrItem:StaticClass())
          Item:Show(IsEmptyGem, AttrId, AttrValue, MutationType)
          if MutationType and MutationType == EMutationType.PosMutation then
            Item:ShowMutationAttr(MutationInfo.AttrID, MutationInfo.MutationValue)
          end
          Index = Index + 1
        end
      else
        Item = GetOrCreateItem(self.VerticalBox_GemAttr, Index, self.WBP_GemAttrItem:StaticClass())
        Item:Show(IsEmptyGem, AttrId, AttrValue)
        Index = Index + 1
      end
    end
    HideOtherItem(self.VerticalBox_GemAttr, Index)
  end
  self:RefreshOperateVis()
  local Inscription = PackageInfo.inscription or PackageInfo.Inscription
  UpdateVisibility(self.CanvasPanel_SpecialAttr, Inscription > 0)
  if Inscription > 0 then
    self.RGRichTextBlockSpecialDesc:SetText(GetLuaInscriptionDesc(Inscription))
    self.Txt_InscriptionName:SetText(PuzzleData:GetPuzzleInscriptionName(Inscription))
  end
end

function WBP_PuzzleItemTip:ShowWithoutOperator(PuzzleId, InPackageInfo, InDetailInfo)
  self:Show(PuzzleId, InPackageInfo, InDetailInfo)
  self:HideOperateTip()
end

function WBP_PuzzleItemTip:ListenInputEvent(IsInMainView)
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

function WBP_PuzzleItemTip:BindOnDiscardKeyPressed(...)
  if not self.PuzzleId then
    return
  end
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.PuzzleId)
  if PackageInfo.state == EPuzzleStatus.Normal then
    PuzzleHandler:RequestDiscardPuzzleToServer(self.PuzzleId)
  elseif PackageInfo.state == EPuzzleStatus.Discard then
    PuzzleHandler:RequestCancelLockOrDiscardPuzzle(self.PuzzleId)
  end
end

function WBP_PuzzleItemTip:BindOnLockKeyPressed(...)
  if not self.PuzzleId then
    return
  end
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(self.PuzzleId)
  if PackageInfo.state == EPuzzleStatus.Normal then
    PuzzleHandler:RequestLockPuzzleToServer(self.PuzzleId)
  elseif PackageInfo.state == EPuzzleStatus.Lock then
    PuzzleHandler:RequestCancelLockOrDiscardPuzzle(self.PuzzleId)
  end
end

function WBP_PuzzleItemTip:BindOnUpgradeKeyPressed(...)
  UIMgr:Show(ViewID.UI_PuzzleDevelopMain, true, self.PuzzleId)
end

function WBP_PuzzleItemTip:BindOnUnEquipKeyPressed(...)
  local PuzzleView = UIMgr:GetLuaFromActiveView(ViewID.UI_Puzzle)
  if PuzzleView then
    PuzzleView:OnRightMouseButtonDown()
  end
end

function WBP_PuzzleItemTip:RefreshOperateVis()
  UpdateVisibility(self.Overlay_OperateTip, true)
  local PackageInfo = self.PackageInfo
  PackageInfo = PackageInfo or PuzzleData:GetPuzzlePackageInfo(self.PuzzleId)
  UpdateVisibility(self.WBP_InteractTipWidgetEquip, 0 == PackageInfo.equipHeroID)
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  UpdateVisibility(self.WBP_InteractTipWidgetUnEquip, 0 ~= PackageInfo.equipHeroID and PackageInfo.equipHeroID == PuzzleViewModel:GetCurHeroId())
  UpdateVisibility(self.WBP_InteractTipWidgetLock, PackageInfo.state == EPuzzleStatus.Normal)
  UpdateVisibility(self.WBP_InteractTipWidgetUnLock, PackageInfo.state == EPuzzleStatus.Lock)
  UpdateVisibility(self.WBP_InteractTipWidgetDiscard, PackageInfo.state == EPuzzleStatus.Normal)
  UpdateVisibility(self.WBP_InteractTipWidgetCancelDiscard, PackageInfo.state == EPuzzleStatus.Discard)
end

function WBP_PuzzleItemTip:HideOperateTip(...)
  UpdateVisibility(self.Overlay_OperateTip, false)
end

function WBP_PuzzleItemTip:Hide()
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

function WBP_PuzzleItemTip:Destruct(...)
  self:Hide()
end

return WBP_PuzzleItemTip
