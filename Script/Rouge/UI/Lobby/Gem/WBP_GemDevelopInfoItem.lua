local WBP_GemDevelopInfoItem = UnLua.Class()
local GemData = require("Modules.Gem.GemData")
function WBP_GemDevelopInfoItem:Show(GemId, TargetLevel)
  UpdateVisibility(self, true)
  local LastGemId = self.GemId
  self.GemId = GemId
  self.TargetLevel = TargetLevel
  UpdateVisibility(self.Horizontal_CompareLevel, nil ~= TargetLevel)
  local PackageInfo = GemData:GetGemPackageInfoByUId(self.GemId)
  if not PackageInfo then
    return
  end
  local ResourceId = GemData:GetGemResourceIdByUId(self.GemId)
  local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  if self.GemId == LastGemId and not self.LastIsMutation and PackageInfo.mutation then
    self:PlayAnimation(self.Anim_Mutation_Name_IN)
  end
  self.LastIsMutation = PackageInfo.mutation
  local Name = GemData:GetGemName(self.GemId)
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
  local Result, GemResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResGem, ResourceId)
  local MainAttrValueList = {}
  for index, SingleAttrInfo in ipairs(GemResRowInfo.Attr) do
    MainAttrValueList[SingleAttrInfo.key] = SingleAttrInfo.value
  end
  local MainAttrGrowthValueList = {}
  local Result, CoreAttrLvUpRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGemLevelUpAttr, ResourceRowInfo.Rare)
  for i, SingleAttrInfo in ipairs(CoreAttrLvUpRowInfo.LevelUpAttr) do
    MainAttrGrowthValueList[SingleAttrInfo.key] = SingleAttrInfo.value
  end
  local MutationInfo
  if PackageInfo.mutation then
    MutationInfo = PackageInfo.mutationAttr[1]
  end
  local Index = 1
  for i, SingleCoreAttributeId in ipairs(PackageInfo.mainAttrIDs) do
    local Item = GetOrCreateItem(self.VerticalBoxCoreAttr, Index, self.PuzzleCoreAttrListItemTemplate:StaticClass())
    local CurValue = MainAttrValueList[SingleCoreAttributeId] + MainAttrGrowthValueList[SingleCoreAttributeId] * PackageInfo.level
    local CompareValue
    if TargetLevel then
      CompareValue = MainAttrValueList[SingleCoreAttributeId] + MainAttrGrowthValueList[SingleCoreAttributeId] * TargetLevel
      if CompareValue and CompareValue == CurValue then
        CompareValue = nil
      end
    end
    Item.BottomColor = self.PuzzleCoreAttrListItemTemplate.BottomColor
    local MutationType
    if MutationInfo and MutationInfo.AttrID == SingleCoreAttributeId and MutationInfo.MutationType == EMutationType.NegaMutation then
      CurValue = CurValue * MutationInfo.MutationValue
      CompareValue = CompareValue and CompareValue * MutationInfo.MutationValue
      MutationType = MutationInfo.MutationType
    end
    if LastGemId == self.GemId then
      Item:PlayMutationAnim(MutationType)
    end
    Item:Show(SingleCoreAttributeId, CurValue, CompareValue, MutationType)
    if TargetLevel and PackageInfo.level > self.TargetLevel then
      Item:ChangeArrowColor(self.ReduceArrowColor)
    else
      Item:ChangeArrowColor(self.AddArrowColor)
    end
    Index = Index + 1
  end
  HideOtherItem(self.VerticalBoxCoreAttr, Index, true)
  UpdateVisibility(self.CanvasPanel_Lock, PackageInfo.state == EGemStatus.Lock)
  UpdateVisibility(self.CanvasPanel_Discard, PackageInfo.state == EGemStatus.Discard)
  self.MutationAttrItem:Hide()
  if MutationInfo and MutationInfo.MutationType == EMutationType.PosMutation then
    if LastGemId == self.GemId then
      self.MutationAttrItem:PlayMutationAnim(MutationInfo.MutationType)
    end
    self.MutationAttrItem:Show(MutationInfo.AttrID, MutationInfo.MutationValue, nil, false, MutationInfo.MutationType)
  end
end
function WBP_GemDevelopInfoItem:PlayUpgradeSuccessAnim(...)
  self:PlayAnimation(self.Ani_upgrade_succeed)
  local AllChildren = self.VerticalBoxCoreAttr:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:PlayUpgradeSuccessAnim()
  end
end
function WBP_GemDevelopInfoItem:Destruct()
  self:StopAllAnimations()
  local AllChildren = self.VerticalBoxCoreAttr:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
end
return WBP_GemDevelopInfoItem
