local WBP_AttrItem_C = UnLua.Class()
local TipsClassPath = "/Game/Rouge/UI/Lobby/Role/AttrbuteDisplay/WBP_AttrDetailDescToolTip.WBP_AttrDetailDescToolTip_C"
local FormatValue = function(value, AttributeDisplayType)
  if AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Default then
    return string.format("%.1f", value)
  elseif AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Integer then
    return string.format("%d", UE.UKismetMathLibrary.Round(value))
  elseif AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Percent then
    return string.format("%.1f%% ", value * 100)
  elseif AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Reciprocal then
    return string.format("%f", 1 / value)
  elseif AttributeDisplayType == UE.ERGAttributeDisplayType.DT_ReciprocalInteger then
    return string.format("%d", UE.UKismetMathLibrary.Round(1 / value))
  elseif AttributeDisplayType == UE.ERGAttributeDisplayType.DT_FloorInteger then
    return string.format("%d", math.floor(value))
  end
  return "0"
end

function WBP_AttrItem_C:Construct()
  if IsValidObj(self.Btn_Desc) then
    self.Btn_Desc.OnHovered:Add(self, self.OnBtnDescHovered)
    self.Btn_Desc.OnUnhovered:Add(self, self.OnBtnDescUnhovered)
  end
end

function WBP_AttrItem_C:InitAttrItem(AttrDisplayData, AttrTagName, bIsAbridge)
  UpdateVisibility(self, true, true)
  self.RowData = AttrDisplayData
  if not bIsAbridge and not self.RowData.SpriteIcon:IsNull() then
    UpdateVisibility(self.Icon_01, true)
    SetImageBrushBySoftObject(self.Icon_01, self.RowData.SpriteIcon)
  else
    UpdateVisibility(self.Icon_01, false)
  end
  self.RGTextName:SetText(AttrDisplayData.DisplayNameInUI)
  self:ChangeDetailDescVis(AttrDisplayData.IsShowDetailDesc)
  local Character = self:GetOwningPlayerPawn()
  if Character then
    local resultHeroBasic, rowHeroBasic = GetRowData(DT.DT_HeroBasicAttribute, tostring(AttrTagName))
    if resultHeroBasic and rowHeroBasic.bIsAttrOpMode then
      local attrTb = {FullAttrName = AttrTagName, Value = 0}
      for i, v in pairs(rowHeroBasic.AttrOpCfgAry) do
        local valueOp = 0
        if v.bIsOpAttr then
          local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
          valueOp = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, v.Attribute, nil)
        else
          valueOp = v.Value
        end
        if v.ModifierOp == UE.EGameplayModOp.Additive then
          attrTb.Value = attrTb.Value + valueOp
        elseif v.ModifierOp == UE.EGameplayModOp.Multiplicitive then
          attrTb.Value = attrTb.Value * valueOp
        elseif v.ModifierOp == UE.EGameplayModOp.Division then
          attrTb.Value = attrTb.Value / valueOp
        elseif v.ModifierOp == UE.EGameplayModOp.Override then
          attrTb.Value = valueOp
        end
      end
      self.RGRichTextBlockAttr:SetText(FormatValue(attrTb.Value, AttrDisplayData.AttributeDisplayType))
    elseif "BasicAttributeSet.SkillDamageIncrease" == AttrTagName then
      local SkillDamageAddRatioValue = UE.URGDamageStatics.GetCharacterSkillDamageAddRatio(Character) - 1
      self.RGRichTextBlockAttr:SetText(FormatValue(SkillDamageAddRatioValue, AttrDisplayData.AttributeDisplayType))
    elseif "BasicAttributeSet.SingleShotDamage" == AttrTagName then
      local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
      local attrName = "BasicAttributeSet.BaseAttack"
      local AttrTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(attrName)
      local baseAttackValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, AttrTag, nil)
      local baseAtkAddName = "BasicAttributeSet.BaseAttackAdd"
      local baseAtkAddTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(baseAtkAddName)
      local baseAtkAddValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, baseAtkAddTag, nil)
      local baseAtkRatioName = "BasicAttributeSet.BaseAttackRatio"
      local baseAtkRatioTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(baseAtkRatioName)
      local baseAtkRatioValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, baseAtkRatioTag, nil)
      local baseAtkFixedAddName = "BasicAttributeSet.BaseAttackFixedAdd"
      local baseAtkFixedAddTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(baseAtkFixedAddName)
      local baseAtkFixedAddValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, baseAtkFixedAddTag, nil)
      local atkValue = (baseAttackValue + baseAtkAddValue) * baseAtkRatioValue + baseAtkFixedAddValue
      local baseWeaponAttackName = "BasicAttributeSet.BaseWeaponAttack"
      local baseWeaponAttackAttrTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(baseWeaponAttackName)
      local baseWeaponAttackValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, baseWeaponAttackAttrTag, nil)
      local weaponDmgRatioName = "DamageRatioAttributeSet.WeaponDamageRatio"
      local weaponDmgRatioNameTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByNameFromUClass(weaponDmgRatioName, UE.UDamageRatioAttributeSet:StaticClass())
      local weaponDmgRatioNameValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, weaponDmgRatioNameTag, nil)
      local weaponDmgAddName = "EquipAttributeSet.WeaponDamageAdd"
      local weaponDmgAddTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(weaponDmgAddName)
      local weaponDmgAddValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, weaponDmgAddTag, nil)
      local weaponDmgRatioAddName = "EquipAttributeSet.WeaponDamageRatioAdd"
      local weaponDmgRatioAddTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(weaponDmgRatioAddName)
      local weaponDmgRatioAddValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, weaponDmgRatioAddTag, nil)
      local heroId = -1
      if DataMgr.GetMyHeroInfo() then
        heroId = DataMgr.GetMyHeroInfo().equipHero
      end
      local comprehensiveAttackRatio = 1
      if -1 ~= heroId then
        comprehensiveAttackRatio = LogicRole.GetAttrInitValue("ComprehensiveAttackRatio", heroId)
      end
      local weaponDmgAddName_A = "EquipAttributeSet.WeaponDamageAdd_A"
      local weaponDmgAddTag_A = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(weaponDmgAddName_A)
      local weaponDmgAddValue_A = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, weaponDmgAddTag_A, nil)
      local weaponDmgAddName_B = "EquipAttributeSet.WeaponDamageAdd_B"
      local weaponDmgAddTag_B = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(weaponDmgAddName_B)
      local weaponDmgAddValue_B = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, weaponDmgAddTag_B, nil)
      local weaponDmgAddName_C = "EquipAttributeSet.WeaponDamageAdd_C"
      local weaponDmgAddTag_C = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(weaponDmgAddName_C)
      local weaponDmgAddValue_C = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, weaponDmgAddTag_C, nil)
      local weaponDmgReduceName_A = "EquipAttributeSet.WeaponDamageReduce_A"
      local weaponDmgReduceTag_A = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(weaponDmgReduceName_A)
      local weaponDmgReduceValue_A = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, weaponDmgReduceTag_A, nil)
      local weaponDmgReduceName_B = "EquipAttributeSet.WeaponDamageReduce_B"
      local weaponDmgReduceTag_B = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(weaponDmgReduceName_B)
      local weaponDmgReduceValue_B = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, weaponDmgReduceTag_B, nil)
      local weaponDamageRatioReduceName = "EquipAttributeSet.WeaponDamageRatioReduce"
      local weaponDamageRatioReduceTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(weaponDamageRatioReduceName)
      local weaponDamageRatioReduceValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, weaponDamageRatioReduceTag, nil)
      local bulletDmgRatio = (1 + weaponDmgRatioAddValue + weaponDmgAddValue_A) * (1 + weaponDmgAddValue_B) * (1 + weaponDmgAddValue_C) / ((1 + weaponDamageRatioReduceValue + weaponDmgReduceValue_A) * (1 + weaponDmgReduceValue_B))
      local SingleShotDamageValue = ((atkValue + baseWeaponAttackValue) * comprehensiveAttackRatio * weaponDmgRatioNameValue + weaponDmgAddValue) * bulletDmgRatio
      self.RGRichTextBlockAttr:SetText(FormatValue(SingleShotDamageValue, AttrDisplayData.AttributeDisplayType))
      print("AttrItem SingleShotDamageValue", SingleShotDamageValue, atkValue, baseWeaponAttackValue, weaponDmgRatioNameValue, weaponDmgAddValue, bulletDmgRatio)
    elseif "SkillAttributeSet.SkillQEnergyRecover" == AttrTagName then
      local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
      local attrGrowSpeedName = "SkillAttributeSet.SkillQ_EnergyRecover_SelfGrowSpeed"
      local attrGrowSpeedTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(attrGrowSpeedName)
      local growSpeedValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, attrGrowSpeedTag, nil)
      local skillQEnergyRecoverValue = 100 / growSpeedValue
      self.RGRichTextBlockAttr:SetText(FormatValue(skillQEnergyRecoverValue, AttrDisplayData.AttributeDisplayType))
    elseif "SkillAttributeSet.SkillE_RecoveryCountTimes" == AttrTagName then
      local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
      local skillE_RecoveryCountTimes = "SkillAttributeSet.SkillE_RecoveryCountTimes"
      local skillE_RecoveryCountTimesTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(skillE_RecoveryCountTimes)
      local skillE_RecoveryCountTimesValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, skillE_RecoveryCountTimesTag, nil)
      local value = 1 / skillE_RecoveryCountTimesValue * LogicRole.GetSkillEInterval()
      self.RGRichTextBlockAttr:SetText(FormatValue(value, AttrDisplayData.AttributeDisplayType))
    elseif "BasicAttributeSet.DamageReduce" == AttrTagName then
      local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
      local damageReduceName = "BasicAttributeSet.DamageReduce"
      local damageReduceTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(damageReduceName)
      local damageReduceValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, damageReduceTag, nil)
      local value = damageReduceValue - 1
      self.RGRichTextBlockAttr:SetText(FormatValue(value, AttrDisplayData.AttributeDisplayType))
    else
      local AttrTag = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(AttrTagName)
      local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
      local AttrValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, AttrTag, nil)
      if UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttrDisplayData.ExtraAttrTag, self.NoneGameplayTag) then
        self.RGRichTextBlockAttr:SetText(FormatValue(AttrValue, AttrDisplayData.AttributeDisplayType))
      else
        local ExtraValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, AttrDisplayData.ExtraAttrTag, nil)
        self.RGRichTextBlockAttr:SetText(string.format("%s / %s", FormatValue(ExtraValue, AttrDisplayData.AttributeDisplayType), FormatValue(AttrValue, AttrDisplayData.AttributeDisplayType)))
      end
    end
  end
  if self.RowData.DisplayUnitInUI and self.Txt_Unit then
    self.Txt_Unit:SetText(self.RowData.DisplayUnitInUI)
    UpdateVisibility(self.Txt_Unit, true)
  else
    UpdateVisibility(self.Txt_Unit, false)
  end
end

function WBP_AttrItem_C:InitAttrItemByValue(AttrDisplayData, Value, bIsAbridge)
  UpdateVisibility(self, true, true)
  self.RowData = AttrDisplayData
  if not bIsAbridge and not self.RowData.SpriteIcon:IsNull() then
    UpdateVisibility(self.Icon_01, true)
    SetImageBrushBySoftObject(self.Icon_01, self.RowData.SpriteIcon)
  else
    UpdateVisibility(self.Icon_01, false)
  end
  self.RGTextName:SetText(AttrDisplayData.DisplayNameInUI)
  self:ChangeDetailDescVis(AttrDisplayData.IsShowDetailDesc)
  self.RGRichTextBlockAttr:SetText(string.format("%s", FormatValue(Value, AttrDisplayData.AttributeDisplayType)))
  self.Txt_Unit:SetText(AttrDisplayData.DisplayUnitInUI)
  UpdateVisibility(self.Txt_Unit, true)
end

function WBP_AttrItem_C:InitAttrItemByWeapon(AttrDisplayData, Value, DisplayUnitInUI)
  UpdateVisibility(self, true, true)
  self.RowData = AttrDisplayData
  if not self.RowData.SpriteIcon:IsNull() then
    UpdateVisibility(self.Icon_01, true)
    SetImageBrushBySoftObject(self.Icon_01, self.RowData.SpriteIcon)
  end
  self.RGTextName:SetText(AttrDisplayData.DisplayNameInUI)
  self:ChangeDetailDescVis(AttrDisplayData.IsShowDetailDesc)
  self.RGRichTextBlockAttr:SetText(Value)
  if self.Txt_Unit and DisplayUnitInUI then
    self.Txt_Unit:SetText(DisplayUnitInUI)
  end
  UpdateVisibility(self.Txt_Unit, true)
end

function WBP_AttrItem_C:InitAttrItemBgByIndex(Index)
  local bgAlpha = 0 == Index % 2 and 0.04 or 0.08
  self.Bg_AttrItem:SetRenderOpacity(bgAlpha)
end

function WBP_AttrItem_C:InitLobbyAttrItem(RowData, Value)
  UpdateVisibility(self, true, true)
  self.RowData = RowData
  if not self.RowData.SpriteIcon:IsNull() then
    UpdateVisibility(self.Icon_01, true)
    SetImageBrushBySoftObject(self.Icon_01, self.RowData.SpriteIcon)
  else
    UpdateVisibility(self.Icon_01, false)
  end
  self.RGTextName:SetText(RowData.DisplayNameInUI)
  self.RGRichTextBlockAttr:SetText(FormatValue(Value, RowData.AttributeDisplayType))
  self:ChangeDetailDescVis(RowData.IsShowDetailDesc)
  if self.Txt_Unit and RowData.DisplayUnitInUI then
    self.Txt_Unit:SetText(RowData.DisplayUnitInUI)
  end
  UpdateVisibility(self.Txt_Unit, true)
end

function WBP_AttrItem_C:ChangeDetailDescVis(IsShow)
  UpdateVisibility(self.Img_DetailDesc, IsShow, true)
  UpdateVisibility(self.Btn_Desc, IsShow, true)
end

function WBP_AttrItem_C:GetDetailDescToolTipWidget()
end

function WBP_AttrItem_C:PlayShowAni(Index)
  local delayTime = Index * 0.02
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.aniTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.aniTimer)
    self.aniTimer = nil
  end
  self.aniTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      self:PlayAnimation(self.Ani_in)
    end
  }, delayTime, false)
end

function WBP_AttrItem_C:OnBtnDescHovered()
  self.DetailDescToolTipWidget = ShowCommonTips(nil, self.Btn_Desc, nil, TipsClassPath)
  self.DetailDescToolTipWidget:RefreshInfo(self.RowData)
end

function WBP_AttrItem_C:OnBtnDescUnhovered()
  UpdateVisibility(self.DetailDescToolTipWidget, false)
end

function WBP_AttrItem_C:Hide()
  UpdateVisibility(self, false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.aniTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.aniTimer)
    self.aniTimer = nil
  end
end

function WBP_AttrItem_C:Destruct()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.aniTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.aniTimer)
    self.aniTimer = nil
  end
  if IsValidObj(self.Btn_Desc) then
    self.Btn_Desc.OnHovered:Remove(self, self.OnBtnDescHovered)
    self.Btn_Desc.OnUnhovered:Remove(self, self.OnBtnDescUnhovered)
  end
end

return WBP_AttrItem_C
