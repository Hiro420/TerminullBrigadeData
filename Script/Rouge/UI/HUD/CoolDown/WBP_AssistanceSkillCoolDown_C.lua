local WBP_AssistanceSkillCoolDown_C = UnLua.Class()

function WBP_AssistanceSkillCoolDown_C:Construct()
  ListenObjectMessage(nil, GMP.MSG_OnAbilityTagUpdate, self, self.BindOnAbilityTagUpdate)
  self:ListenInputEvent(true)
end

function WBP_AssistanceSkillCoolDown_C:InitInfo(GenericModifyId)
  self.ModifyId = GenericModifyId
  self.Img_SkillIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:ChangeProhibitVis(false)
  if self:IsValidSkill() then
    self.Img_Bottom:SetBrush(self.CommonBottomIcon)
    self.Img_SkillIcon:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Txt_KeyName:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    UpdateVisibility(self, true)
  else
    SetImageBrushBySoftObject(self.Img_Bottom, self.EmptySlotBottomIcon)
    self.Txt_KeyName:SetVisibility(UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self, false)
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local LogicCommandSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandSubsystem then
    return
  end
  local Result, RowInfo = DTSubsystem:GetGenericModifyDataByName(tostring(self.ModifyId), nil)
  if not Result then
    print("WBP_AssistanceSkillCoolDown_C:InitInfo Invalid Modify", self.ModifyId)
    return
  end
  local InscriptionDA = GetLuaInscription(RowInfo.Inscription)
  if not InscriptionDA then
    print("WBP_AssistanceSkillCoolDown_C:InitInfo Invalid Inscription", RowInfo.Inscription)
    return
  end
  SetImageBrushByPath(self.Img_SkillIcon, InscriptionDA.Icon)
  SetImageBrushByPath(self.Img_DisableSkillIcon, InscriptionDA.Icon)
  local BResult, GroupRowInfo = DTSubsystem:GetGenericModifyGroupDataByName(RowInfo.GroupId)
  if not BResult then
    return
  end
  self.TargetBottomColor = GroupRowInfo.ChoosePanelColor.SpecifiedColor
  self.Img_CoolDown:SetColorAndOpacity(self.TargetBottomColor)
  self.Img_CoolDownFrame:SetColorAndOpacity(self.TargetBottomColor)
end

function WBP_AssistanceSkillCoolDown_C:BindOnAbilityTagUpdate(Tag, bTagExist, TargetActor)
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

function WBP_AssistanceSkillCoolDown_C:ChangeProhibitVis(bTagExist)
  if bTagExist then
    self.Img_DisableSkillIcon:SetVisibility(UE.ESlateVisibility.Visible)
    self.Img_DisableBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_SkillIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Img_DisableSkillIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_DisableBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_SkillIcon:SetVisibility(UE.ESlateVisibility.Visible)
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_AssistanceSkillCoolDown_C:UpdateOperateOpacity()
  if self.IsInUnNormalState or self.IsCooling then
    self.Img_OperateBottom:SetOpacity(self.NotCountOperateBottomOpacity)
    self.Txt_KeyName:SetOpacity(self.NotCountOperateTextOpacity)
  else
    self.Img_OperateBottom:SetOpacity(self.NormalOperateBottomOpacity)
    self.Txt_KeyName:SetOpacity(self.NormalOperateTextOpacity)
  end
end

function WBP_AssistanceSkillCoolDown_C:SetCoolingStatus(State)
  if self.CurState and self.CurState == State then
    return
  end
  self.CurState = State
  if State == UE.ERGAbilityStateType.None then
    self.Img_Bottom:SetBrush(self.NormalBottom)
    self.Img_SkillIcon:SetColorAndOpacity(self.NormalIconColor)
    self.Img_OperateBottom:SetOpacity(self.NormalOperateBottomOpacity)
    self.Txt_KeyName:SetOpacity(self.NormalOperateTextOpacity)
    self.CoolDownPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    if self.IsNeedPlayCompleteAnim then
      self.FX_UltimateSkillComplete:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.FX_UltimateSkillComplete:PlayAnimationForward(self.FX_UltimateSkillComplete.UltimateComplete_Blue)
      self.IsNeedPlayCompleteAnim = false
    end
  elseif State == UE.ERGAbilityStateType.Activated then
    self.Img_Bottom:SetBrush(self.ActivedBottom)
    self.Img_SkillIcon:SetColorAndOpacity(self.ActivedIconColor)
    self.Img_OperateBottom:SetOpacity(self.NormalOperateBottomOpacity)
    self.Txt_KeyName:SetOpacity(self.NormalOperateTextOpacity)
    self.CoolDownPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:PlayAniInAnimation()
  elseif State == UE.ERGAbilityStateType.InCoolDown then
    self.Img_Bottom:SetBrush(self.CoolDownBottom)
    self.Img_SkillIcon:SetColorAndOpacity(self.CoolDownIconColor)
    self.Img_OperateBottom:SetOpacity(self.NotCountOperateBottomOpacity)
    self.Txt_KeyName:SetOpacity(self.NotCountOperateTextOpacity)
    self:PlayAniInAnimation()
    self.IsNeedPlayCompleteAnim = true
    self.FX_UltimateSkillComplete:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CoolDownPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  self:PlayAniOutAnimation()
  self:UpdateOperateOpacity()
end

function WBP_AssistanceSkillCoolDown_C:PlayAniInAnimation()
  if self.IsInPressState then
    return
  end
  self:PlayAnimationForward(self.Ani_In)
  self.IsInPressState = true
end

function WBP_AssistanceSkillCoolDown_C:PlayAniOutAnimation()
  if not self.IsInPressState then
    return
  end
  if self.CurState == UE.ERGAbilityStateType.Activated or self.CurState == UE.ERGAbilityStateType.InCoolDown then
    return
  end
  self:PlayAnimationForward(self.Ani_Out)
  self.IsInPressState = false
end

function WBP_AssistanceSkillCoolDown_C:Destruct()
  UnListenObjectMessage(GMP.MSG_OnAbilityTagUpdate, self)
  self:ListenInputEvent(false)
end

return WBP_AssistanceSkillCoolDown_C
