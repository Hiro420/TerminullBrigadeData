local WBP_RoleSkillTip_C = UnLua.Class()
function WBP_RoleSkillTip_C:Construct()
end
function WBP_RoleSkillTip_C:RefreshInfo(SkillGroupId, CurHeroId, GenricModifyDataList)
  self.CurHeroId = CurHeroId
  local SkillGroupInfo = LogicRole.GetSkillTableRow(SkillGroupId)
  if not SkillGroupInfo then
    print("not found skill group info,SkillGroupId:", SkillGroupId)
    return
  end
  local CurLevel = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  local TargetSkillInfo = SkillGroupInfo[CurLevel]
  if not TargetSkillInfo then
    TargetSkillInfo = SkillGroupInfo[1]
    if not TargetSkillInfo then
      return
    end
  end
  self.SkillLevelPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Line:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Txt_SkillLevel:SetText(tostring(CurLevel))
  self.Txt_SkillName:SetText(TargetSkillInfo.Name)
  local FinalText = TargetSkillInfo.Desc
  local DescParams = {}
  for i, SingleParam in ipairs(TargetSkillInfo.DescParams) do
    table.insert(DescParams, "<RoleUpgradeAttribute>" .. SingleParam .. "</>")
  end
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if WaveWindowManager then
    FinalText = WaveWindowManager:FormatTextByOrder(FinalText, DescParams)
  end
  self.Txt_SkillDesc:SetText(FinalText)
  self:UpdateSkillTag(TargetSkillInfo.SkillTags)
  local SoftObjReference = MakeStringToSoftObjectReference(TargetSkillInfo.IconPath)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjReference) then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjReference):Cast(UE.UPaperSprite)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_Icon:SetBrush(Brush)
    end
  end
  if GenricModifyDataList and #GenricModifyDataList > 0 then
    UpdateVisibility(self.RGRichTextBlockGeneric, true)
    local str = "\229\183\178\232\142\183\229\190\151[%s]%s\230\149\136\230\158\156"
    for i, v in ipairs(GenricModifyDataList) do
      if i == #GenricModifyDataList then
        str = string.format(str, v.Name, "")
      else
        str = string.format(str, v.Name, "[%s]%s")
      end
      self.RGRichTextBlockGeneric:SetText(str)
    end
  else
    UpdateVisibility(self.RGRichTextBlockGeneric, false)
  end
end
function WBP_RoleSkillTip_C:GetDefaultFontStyle()
  return self.TxtTemplate.DefaultTextStyleOverride
end
function WBP_RoleSkillTip_C:UpdateSkillLevelInfo(SkillGroupInfo)
  local AllLevelItems = self.SkillLevelPanel:GetAllChildren()
  for i, SingleItem in iterator(AllLevelItems) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local HeroStar = 1
  if DataMgr then
    HeroStar = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  end
  local Index = 1
  for Level, SingleSkillLevelInfo in pairs(SkillGroupInfo) do
    if 1 ~= SingleSkillLevelInfo.Star and HeroStar >= SingleSkillLevelInfo.Star then
      local Item = self.SkillLevelPanel:GetChildAt(Index - 1)
      if not Item then
        Item = self:SpawnSkillLevelInfoItem()
      else
        Item:SetVisibility(UE.ESlateVisibility.Visible)
      end
      Item:SetText("LV:" .. SingleSkillLevelInfo.Star .. "  " .. SingleSkillLevelInfo.SimpleDesc)
      local SlateColor = UE.FSlateColor()
      SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
      if SingleSkillLevelInfo.Star == HeroStar then
        SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
        Item:SetDefaultColorAndOpacity(SlateColor)
      elseif HeroStar < SingleSkillLevelInfo.Star then
        SlateColor.SpecifiedColor = UE.FLinearColor(0.323143, 0.323143, 0.323143, 1.0)
        Item:SetDefaultColorAndOpacity(SlateColor)
      else
        SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
        Item:SetDefaultColorAndOpacity(SlateColor)
      end
    end
    Index = Index + 1
  end
end
function WBP_RoleSkillTip_C:UpdateSkillTag(SkillTagList)
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
function WBP_RoleSkillTip_C:HideChangeFetterPanel()
  self.ChangeFetterPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_RoleSkillTip_C
