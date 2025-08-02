local WBP_PuzzleDevelopInfoItem = UnLua.Class()
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local GemData = require("Modules.Gem.GemData")
local PuzzleInfoConfig = require("GameConfig.Puzzle.PuzzleInfoConfig")

function WBP_PuzzleDevelopInfoItem:Show(PuzzleId, TargetLevel)
  UpdateVisibility(self, true)
  local LastPuzzleId = self.PuzzleId
  self.PuzzleId = PuzzleId
  self.TargetLevel = TargetLevel
  UpdateVisibility(self.Horizontal_CompareLevel, nil ~= TargetLevel)
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
  if not PackageInfo then
    return
  end
  local ResourceId = tonumber(PackageInfo.resourceID)
  local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  local Name = PuzzleData:GetPuzzleName(PuzzleId, PackageInfo)
  if self.PuzzleId == LastPuzzleId and not self.LastIsMutation and PackageInfo.Mutation then
    self:PlayAnimation(self.Anim_Mutation_Name_IN)
  end
  self.LastIsMutation = PackageInfo.Mutation
  self.Txt_Name:SetText(Name)
  self.Txt_CurLevel:SetText(PackageInfo.level)
  if self.TargetLevel then
    self.Txt_TargetLevel:SetText(self.TargetLevel)
  end
  if self.TargetLevel then
    if PackageInfo.level > self.TargetLevel then
      self.RGStateController_Color:ChangeStatus("Reset")
    elseif PackageInfo.level < self.TargetLevel then
      self.RGStateController_Color:ChangeStatus("Upgrade")
    else
      self.RGStateController_Color:ChangeStatus("Normal")
    end
  end
  local IsNeedCompareAttr = 0 == self.TargetLevel and PackageInfo.level ~= self.TargetLevel
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
  local Result, CoreAttrLvUpRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleMainAttrLvUp, ResourceRowInfo.Rare)
  local MainAttrGrowthValueList = {}
  for i, SingleAttrInfo in ipairs(CoreAttrLvUpRowInfo.LevelUPMainAttrGrowth) do
    MainAttrGrowthValueList[SingleAttrInfo.x] = SingleAttrInfo.y
  end
  local PuzzleDetailInfo = PuzzleData:GetPuzzleDetailInfo(PuzzleId)
  local Index = 1
  for i, SingleCoreAttributeInfo in ipairs(PuzzleResRowInfo.MainAttr) do
    local Item = GetOrCreateItem(self.VerticalBoxCoreAttr, Index, self.PuzzleCoreAttrListItemTemplate:StaticClass())
    local AttrGrowthValue = PuzzleDetailInfo.MainAttrGrowth[tostring(SingleCoreAttributeInfo.key)] or 0
    local CompareValue
    if TargetLevel then
      if TargetLevel < PackageInfo.level then
        CompareValue = SingleCoreAttributeInfo.value
      elseif TargetLevel > PackageInfo.level then
        local GrowthValue = MainAttrGrowthValueList[SingleCoreAttributeInfo.key] and MainAttrGrowthValueList[SingleCoreAttributeInfo.key] * (self.TargetLevel - PackageInfo.level) or 0
        CompareValue = SingleCoreAttributeInfo.value + AttrGrowthValue + GrowthValue
      end
      if CompareValue and CompareValue == SingleCoreAttributeInfo.value + AttrGrowthValue then
        CompareValue = nil
      end
    end
    Item.BottomColor = self.PuzzleCoreAttrListItemTemplate.BottomColor
    Item:Show(SingleCoreAttributeInfo.key, SingleCoreAttributeInfo.value + AttrGrowthValue, CompareValue)
    if TargetLevel and PackageInfo.level > self.TargetLevel then
      Item:ChangeArrowColor(self.ReduceArrowColor)
    else
      Item:ChangeArrowColor(self.AddArrowColor)
    end
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
  local IsShowMutationItem = false
  local Index = 1
  local SubAttrList = {}
  local FirstSubAttrItem, LastSubAttrItem
  for i, AttrInfo in pairs(PuzzleDetailInfo.SubAttrInitV2) do
    local SubAttrId = AttrInfo.attrID
    local SubAttrValue = AttrInfo.value
    local IsGodAttr = PuzzleData:IsGodSubAttr(self.PuzzleId, nil, SubAttrId)
    local RangeValue = IsGodAttr and SubGodAttrRangeList[SubAttrId] or SubAttrRangeList[SubAttrId]
    if AttrInfo.mutationType ~= EMutationType.PosMutation then
      local Item = GetOrCreateItem(self.VerticalBoxRandomAttrList, Index, self.PuzzleSubAttrListItemTemplate:StaticClass())
      local AttrGrowthValue = PuzzleDetailInfo.SubAttrGrowth[tostring(SubAttrId)] or 0
      local CompareValue
      if IsNeedCompareAttr then
        CompareValue = SubAttrValue
      end
      if LastPuzzleId == self.PuzzleId then
        Item:PlayRefactorAnim(SubAttrId, SubAttrValue + AttrGrowthValue)
        Item:PlayMutationAnim(AttrInfo.mutationType)
      end
      Item:Show(SubAttrId, SubAttrValue + AttrGrowthValue, CompareValue, IsGodAttr, AttrInfo.mutationType, RangeValue)
      if 1 == Index then
        FirstSubAttrItem = Item
      end
      LastSubAttrItem = Item
      table.insert(SubAttrList, SubAttrId)
      Index = Index + 1
    else
      if LastPuzzleId == self.PuzzleId then
        self.PuzzleMutationSubAttrListItem:PlayMutationAnim(AttrInfo.mutationType)
      end
      self.PuzzleMutationSubAttrListItem:Show(SubAttrId, SubAttrValue, nil, false, AttrInfo.mutationType, RangeValue)
      IsShowMutationItem = true
    end
  end
  if not IsShowMutationItem then
    self.PuzzleMutationSubAttrListItem:Hide()
  end
  for SubAttrId, SubAttrValue in pairs(PuzzleDetailInfo.SubAttrGrowth) do
    if not table.Contain(SubAttrList, SubAttrId) then
      local Item = GetOrCreateItem(self.VerticalBoxRandomAttrList, Index, self.PuzzleSubAttrListItemTemplate:StaticClass())
      local CompareValue
      if IsNeedCompareAttr then
        CompareValue = 0
      end
      local IsGodAttr = PuzzleData:IsGodSubAttr(self.PuzzleId, nil, SubAttrId)
      local RangeValue = IsGodAttr and SubGodAttrRangeList[SubAttrId] or SubAttrRangeList[SubAttrId]
      Item:Show(SubAttrId, SubAttrValue, CompareValue, IsGodAttr, EMutationType.Normal, RangeValue)
      table.insert(SubAttrList, SubAttrId)
      LastSubAttrItem = Item
      Index = Index + 1
    end
  end
  HideOtherItem(self.VerticalBoxRandomAttrList, Index, true)
  if self.IsNeedRegisitMarkArea then
    local PuzzleRefactorViewModel = UIModelMgr:Get("PuzzleRefactorViewModel")
    PuzzleRefactorViewModel:UnRegisitMarkArea(EPuzzleRefactorType.WashFirstOneSubAttr)
    PuzzleRefactorViewModel:UnRegisitMarkArea(EPuzzleRefactorType.WashLastOneSubAttr)
    local PuzzleRefactorViewModel = UIModelMgr:Get("PuzzleRefactorViewModel")
    local ResourceId = PuzzleRefactorViewModel:GetCurSelectResourceId()
    if FirstSubAttrItem then
      FirstSubAttrItem:RegisitMarkArea({
        EPuzzleRefactorType.WashFirstOneSubAttr
      })
      if ResourceId == EPuzzleRefactorType.WashFirstOneSubAttr then
        FirstSubAttrItem:ShowPuzzleRefactorMarkArea()
      end
    end
    if LastSubAttrItem then
      LastSubAttrItem:RegisitMarkArea({
        EPuzzleRefactorType.WashLastOneSubAttr
      })
      if ResourceId == EPuzzleRefactorType.WashLastOneSubAttr then
        LastSubAttrItem:ShowPuzzleRefactorMarkArea()
      end
    end
  end
  Index = 1
  local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(self.PuzzleId)
  UpdateVisibility(self.CanvasPanel_Gem, nil ~= next(GemSlotInfo))
  UpdateVisibility(self.URGImage_Line_1, nil ~= next(GemSlotInfo))
  if nil ~= next(GemSlotInfo) then
    local SlotIndexList = {}
    for SlotIndex, GemId in pairs(GemSlotInfo) do
      table.insert(SlotIndexList, SlotIndex)
    end
    table.sort(SlotIndexList, function(a, b)
      return "0" ~= GemSlotInfo[a] and "0" == GemSlotInfo[b]
    end)
    local SlotInAnimDelayTime = 0
    local CurPlaySlotInAnimIndex = LastPuzzleId == self.PuzzleId and self.LastGemSlotInfoCount + 1 or 0
    for SlotIndex, SlotIndex in ipairs(SlotIndexList) do
      local GemId = GemSlotInfo[SlotIndex]
      local Item
      local IsEmptyGem = "0" == GemId
      local AttrId, AttrValue = nil, 0
      if not IsEmptyGem then
        local GemPackageInfo = GemData:GetGemPackageInfoByUId(GemId)
        for i, SingleAttrId in ipairs(GemPackageInfo.mainAttrIDs) do
          AttrId = SingleAttrId
          local GemResourceId = GemData:GetGemResourceIdByUId(GemId)
          local Result, GemResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResGem, GemResourceId)
          if not Result then
            return
          end
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
          local MutationType, MutationInfo
          if GemPackageInfo.mutation then
            MutationInfo = GemPackageInfo.mutationAttr[1]
            MutationType = MutationInfo and MutationInfo.MutationType
          end
          if MutationInfo and MutationInfo.AttrID == SingleAttrId and MutationInfo.MutationType == EMutationType.NegaMutation then
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
        if CurPlaySlotInAnimIndex == Index then
          Item:PlaySlotInAnim(SlotInAnimDelayTime)
          SlotInAnimDelayTime = SlotInAnimDelayTime + self.SlotInAnimInterval
          CurPlaySlotInAnimIndex = CurPlaySlotInAnimIndex + 1
        end
        Index = Index + 1
      end
    end
    HideOtherItem(self.VerticalBox_GemAttr, Index)
  end
  self.LastGemSlotInfoCount = table.count(GemSlotInfo)
  UpdateVisibility(self.CanvasPanel_SpecialAttr, PackageInfo.inscription > 0)
  if PackageInfo.inscription > 0 then
    local Desc = GetLuaInscriptionDesc(PackageInfo.inscription)
    if LastPuzzleId == self.PuzzleId and self.LastInscription ~= PackageInfo.inscription then
      self:PlayAnimation(self.Anim_Refactoring_Entry)
    end
    self.RGRichTextBlockSpecialDesc:SetText(Desc)
    self.Txt_InscriptionName:SetText(PuzzleData:GetPuzzleInscriptionName(PackageInfo.inscription))
  end
  self.LastInscription = PackageInfo.inscription
  UpdateVisibility(self.CanvasPanel_Lock, PackageInfo.state == EPuzzleStatus.Lock)
  UpdateVisibility(self.CanvasPanel_Discard, PackageInfo.state == EPuzzleStatus.Discard)
end

function WBP_PuzzleDevelopInfoItem:RegisitPuzzleRefactorMarkArea()
  self.IsNeedRegisitMarkArea = true
  self.WBP_PuzzleRefactorMarkArea_AllSubAttr:RegisitMarkArea()
  self.WBP_PuzzleRefactorMarkArea_AllSubAttr_Gem:RegisitMarkArea()
  self.WBP_PuzzleRefactorMarkArea_Inscription:RegisitMarkArea()
end

function WBP_PuzzleDevelopInfoItem:PlaySwitchAnim(...)
  local AllChildren = self.VerticalBoxCoreAttr:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:PlaySwitchAnim()
  end
  local AllSubAttrChildren = self.VerticalBoxRandomAttrList:GetAllChildren()
  for key, SingleItem in pairs(AllSubAttrChildren) do
    SingleItem:PlaySwitchAnim()
  end
end

function WBP_PuzzleDevelopInfoItem:PlayUpgradeSuccessAnim(...)
  self:PlayAnimation(self.Ani_upgrade_succeed)
  self.IsPlayUpgradeSuccessAnim = true
  self.MaxCoreAttrNum = self.VerticalBoxCoreAttr:GetChildrenCount()
  self.MaxSubAttrNum = self.VerticalBoxRandomAttrList:GetChildrenCount()
  self.CurPlayCoreAttrIndex = 0
  self.CurPlaySubAttrIndex = 0
  self.DeltaSeconds = 0
end

function WBP_PuzzleDevelopInfoItem:Hide()
  self.LastGemSlotInfoCount = 0
  self.PuzzleId = nil
end

function WBP_PuzzleDevelopInfoItem:Destruct()
  self:Hide()
end

return WBP_PuzzleDevelopInfoItem
