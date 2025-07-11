local WBP_WeaponSkillCoolDown_C = UnLua.Class()
function WBP_WeaponSkillCoolDown_C:Construct()
  ListenObjectMessage(nil, GMP.MSG_OnAbilityTagUpdate, self, self.BindOnAbilityTagUpdate)
  self:ChangeProhibitVis(false)
end
function WBP_WeaponSkillCoolDown_C:InitInfo(WeaponId)
  local Result, RowInfo = GetRowData(DT.DT_Weapon, tostring(WeaponId))
  if not Result then
    return
  end
  self.AbilityClass = RowInfo.AbilityConfig.RMBAbilityClass
  if UE.UKismetSystemLibrary.IsValidClass(self.AbilityClass) then
    self.StatusWidgetSwitcher:SetActiveWidget(self.ValidSkillPanel)
    self:SetCoolDownTagContainer()
    local BResult, SkillRowInfo = GetRowData(DT.DT_Skill, self:GetAbilityId())
    if not BResult then
      return
    end
    self.HasPersistentState = SkillRowInfo.HasPersistentState
    SetImageBrushBySoftObject(self.Img_SkillIcon, SkillRowInfo.Icon)
    SetImageBrushBySoftObject(self.Img_DisableSkillIcon, SkillRowInfo.Icon)
  else
    self.StatusWidgetSwitcher:SetActiveWidget(self.InValidSkillPanel)
    SetImageBrushBySoftObject(self.Img_UnSkillDefaultIcon, RowInfo.UnSkillDefaultIcon)
  end
end
function WBP_WeaponSkillCoolDown_C:BindOnAbilityTagUpdate(Tag, bTagExist, TargetActor)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if TargetActor ~= Character then
    return
  end
  local CharacterSettings = UE.URGCharacterSettings.GetSettings()
  if not CharacterSettings then
    return
  end
  if CharacterSettings.AbnormalStateTags:Contains(Tag) then
    self:ChangeProhibitVis(bTagExist)
    self.IsInUnNormalState = bTagExist
    self:UpdateOperateOpacity()
  end
end
function WBP_WeaponSkillCoolDown_C:ChangeProhibitVis(bTagExist)
  if bTagExist then
    self.Img_DisableSkillIcon:SetVisibility(UE.ESlateVisibility.Visible)
    self.Img_DisableBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_SkillIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_UnSkillDefaultIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_InvalidBottom:SetVisibility(UE.ESlateVisibility.Hidden)
  else
    self.Img_DisableSkillIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_DisableBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_SkillIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_UnSkillDefaultIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_InvalidBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_WeaponSkillCoolDown_C:UpdateOperateOpacity()
  if self.IsInUnNormalState or self.CurState == UE.ERGAbilityStateType.InCoolDown then
    self.Img_OperateIcon:SetOpacity(self.NotCountOperateIconOpacity)
    self.Img_InValidOperateIcon:SetOpacity(self.NotCountOperateIconOpacity)
  else
    self.Img_OperateIcon:SetOpacity(self.NormalOperateIconOpacity)
    self.Img_InValidOperateIcon:SetOpacity(self.NormalOperateIconOpacity)
  end
end
function WBP_WeaponSkillCoolDown_C:Destruct()
  UnListenObjectMessage(GMP.MSG_OnAbilityTagUpdate, self)
end
return WBP_WeaponSkillCoolDown_C
