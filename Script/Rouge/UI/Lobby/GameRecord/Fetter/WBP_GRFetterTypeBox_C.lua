local WBP_GRFetterTypeBox_C = UnLua.Class()
function WBP_GRFetterTypeBox_C:UpdateSkillTag(SkillTagList)
  local TagItemList = self.SkillTagList:GetAllChildren()
  for i, SingleTagItem in iterator(TagItemList) do
    SingleTagItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local SkillTagInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBSkillTag)
  for i, SingleTagId in ipairs(SkillTagList) do
    local Item = self.SkillTagList:GetChildAt(i - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.TagItemTemplate:StaticClass())
      local Slot = self.SkillTagList:AddChild(Item)
      local Padding = UE.FMargin()
      Padding.Right = 5.0
      Slot:SetPadding(Padding)
    else
      Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    local TargetSkillTagInfo = SkillTagInfo[SingleTagId]
    if TargetSkillTagInfo then
      Item:RefreshInfo(TargetSkillTagInfo.Name)
    else
      Item:RefreshInfo("")
    end
  end
end
return WBP_GRFetterTypeBox_C
