local WBP_RGBeginnerOperateTip_DashPart2_C = UnLua.Class()
function WBP_RGBeginnerOperateTip_DashPart2_C:Show()
  self.AltDescItem:UpdateText(self.AltDescItem.DescText, self.AltDescItem.KeyInfoList)
  self.AltDescItem:SetFlagSelectedPanelVis(false)
  self.AltDescItem:ShowFlagPanel()
  self.CDescItem:UpdateText(self.CDescItem.DescText, self.CDescItem.KeyInfoList)
  self.CDescItem:SetFlagSelectedPanelVis(false)
  self.CDescItem:ShowFlagPanel()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    ListenObjectMessage(Character, GMP.MSG_CharacterSkill_ExcuteHeroSkill, self, self.BindOnCharacterExecuteHeroSkill)
  end
end
function WBP_RGBeginnerOperateTip_DashPart2_C:BindOnCharacterExecuteHeroSkill(Type, AbilityPredictionKey)
  if Type == UE.ESkillType.MoveSkill then
    self.CDescItem:SetFlagSelectedPanelVis(true)
  elseif Type == UE.ESkillType.EvadeSkill then
    self.AltDescItem:SetFlagSelectedPanelVis(true)
  end
end
function WBP_RGBeginnerOperateTip_DashPart2_C:Destruct()
  UnListenObjectMessage(GMP.MSG_CharacterSkill_ExcuteHeroSkill, self)
end
return WBP_RGBeginnerOperateTip_DashPart2_C
