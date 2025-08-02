local WBP_SkillUpgradeItem_C = UnLua.Class()

function WBP_SkillUpgradeItem_C:RefreshInfo(CurHeroStar, TargetHeroStar, SkillGroupId)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local SkillGroupInfo = LogicRole.GetSkillTableRow(SkillGroupId)
  self.Txt_CurSkillLevel:SetText(CurHeroStar)
  self.Txt_TargetSkillLevel:SetText(TargetHeroStar)
  local CurStarSkillInfo = SkillGroupInfo[CurHeroStar]
  local TargetStarSkillInfo = SkillGroupInfo[TargetHeroStar]
  if not CurStarSkillInfo or not TargetStarSkillInfo then
    print("SkillUpgradeItem not enough skill info, please check SkillGroupId:", SkillGroupId)
    return
  end
  local SoftObjRef = MakeStringToSoftObjectReference(CurStarSkillInfo.IconPath)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjRef) then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjRef):Cast(UE.UPaperSprite)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_Icon:SetBrush(Brush)
    end
  end
  local DescParams = {}
  local TargetDescText = TargetStarSkillInfo.Desc
  for i, SingleParam in ipairs(TargetStarSkillInfo.DescParams) do
    local CurStarParam = CurStarSkillInfo.DescParams[i]
    if CurStarParam then
      local ParamDiff = SingleParam - CurStarParam
      local ParamText = tostring(ParamDiff)
      if ParamDiff > 0 then
        ParamText = "+" .. tostring(ParamDiff)
      end
      table.insert(DescParams, "<RoleUpgradeAttribute>" .. CurStarParam .. "(" .. ParamText .. ")" .. "</>")
    else
      table.insert(DescParams, "<RoleUpgradeAttribute>" .. SingleParam .. "</>")
    end
  end
  self.Txt_SkillName:SetText(TargetStarSkillInfo.Name)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager)
  TargetDescText = WaveWindowManager:FormatTextByOrder(TargetDescText, DescParams)
  self.Txt_Desc:SetText(TargetDescText)
end

return WBP_SkillUpgradeItem_C
