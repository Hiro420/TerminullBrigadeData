local WBP_RGPickupItemWaveWindow_C = UnLua.Class()
function WBP_RGPickupItemWaveWindow_C:Construct()
end
function WBP_RGPickupItemWaveWindow_C:PlayFadeInWidgetAnim()
  self:PlayAnimationForward(self.StartAnim)
end
function WBP_RGPickupItemWaveWindow_C:Show(ItemData, Count)
  self.Index = 1
  if not self.Count or -1 == self.Count then
  else
    self:PlayAnimationForward(self.NumberIncreaseAnim)
  end
  local TargetCount = Count
  if self.Count then
    TargetCount = TargetCount + self.Count
  end
  self.Count = TargetCount
  if ItemData.ArticleType == UE.EArticleDataType.SkillResource then
    local ESkillCount = self:GetESkillCount() + Count
    local ESkillMaxCount = self:GetESkillMaxCount()
    if ESkillCount >= ESkillMaxCount then
      local Desc = UE.URGBlueprintLibrary.TextFromStringTable(1459)
      self.Txt_Num:SetText(Desc)
    else
      self.Txt_Num:SetText("+" .. TargetCount)
    end
  else
    self.Txt_Num:SetText("+" .. TargetCount)
  end
  self.Txt_Name:SetText(ItemData.Name)
  SetImageBrushBySoftObject(self.Img_Icon, ItemData.SpriteIcon, self.IconSize)
  SetImageBrushBySoftObject(self.Img_Icon_miaobian, ItemData.SpriteIcon, self.IconSize)
  self.MainPanel:SetRenderOpacity(1.0)
  self.RGStateController_Rare:ChangeStatus(tostring(ItemData.ItemRarity))
  self:BindToAnimationFinished(self.FadeOutAnim, {
    self,
    WBP_RGPickupItemWaveWindow_C.BindOnFadeOutAnimFinished
  })
end
function WBP_RGPickupItemWaveWindow_C:ChangeDisplayInfo(InName, InIcon)
  self.Txt_Name:SetText(InName)
  SetImageBrushBySoftObject(self.Img_Icon, InIcon, self.IconSize)
  SetImageBrushBySoftObject(self.Img_Icon_miaobian, InIcon, self.IconSize)
end
function WBP_RGPickupItemWaveWindow_C:PlayRemoveWidgetAnim()
  self:PlayAnimation(self.FadeOutAnim, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0)
end
function WBP_RGPickupItemWaveWindow_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Index = 1
  self.Count = -1
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
  end
  self:UnBindFromAnimationFinished(self.FadeOutAnim, {
    self,
    WBP_RGPickupItemWaveWindow_C.BindOnFadeOutAnimFinished
  })
  self:StopAnimation(self.FadeOutAnim)
end
function WBP_RGPickupItemWaveWindow_C:BindOnFadeOutAnimFinished()
  self:Hide()
  EventSystem.Invoke(EventDef.PickTipList.HidePickTipItem, self)
end
function WBP_RGPickupItemWaveWindow_C:GetESkillCount()
  return self:GetAttributeValue(self.ESkillCount)
end
function WBP_RGPickupItemWaveWindow_C:GetESkillMaxCount()
  return self:GetAttributeValue(self.ESkillMaxCount)
end
function WBP_RGPickupItemWaveWindow_C:GetAttributeValue(Attribute)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return 0
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if not ASC then
    return 0
  end
  local AttributeValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, Attribute, nil)
  return AttributeValue
end
return WBP_RGPickupItemWaveWindow_C
