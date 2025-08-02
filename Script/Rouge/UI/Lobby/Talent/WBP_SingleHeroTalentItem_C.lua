local WBP_SingleHeroTalentItem_C = UnLua.Class()

function WBP_SingleHeroTalentItem_C:Show(TalentId, Level, CurLevel, CanUpgrade)
  self:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  self.Txt_Level:SetText(Level)
  local SlateColor = UE.FSlateColor()
  SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  if Level <= CurLevel then
    self.Img_Lock:SetVisibility(UE.ESlateVisibility.Hidden)
    self.StatusPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
  else
    SlateColor.SpecifiedColor = UE.FLinearColor(0.215861, 0.215861, 0.215861, 1.0)
    if Level == CurLevel + 1 and CanUpgrade then
      self.StatusPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      self.Img_Lock:SetVisibility(UE.ESlateVisibility.Hidden)
    else
      self.Img_Lock:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      self.StatusPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  self.Txt_Desc:SetColorAndOpacity(SlateColor)
  self.Txt_ModName:SetColorAndOpacity(SlateColor)
  self.Img_LevelBottom:SetColorAndOpacity(SlateColor.SpecifiedColor)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  local TargetTalentInfo = TalentInfo[Level]
  if 1 == Level then
    self.Txt_Status:SetText("\229\143\175\232\167\163\233\148\129")
  else
    self.Txt_Status:SetText("\229\143\175\229\141\135\231\186\167")
  end
  if not TalentInfo then
    return
  end
  self.Txt_Desc:SetText(TargetTalentInfo.Desc)
  local LogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if LogicCommandDataSubsystem then
    local ModData = GetLuaInscription(TargetTalentInfo.ModId)
    if ModData then
      self.Img_ModIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Txt_ModName:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      local name = GetInscriptionName(TargetTalentInfo.ModId)
      self.Txt_ModName:SetText(name)
      SetImageBrushByPath(self.Img_ModIcon, ModData.Icon)
    else
      self.Img_ModIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Txt_ModName:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function WBP_SingleHeroTalentItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_SingleHeroTalentItem_C
