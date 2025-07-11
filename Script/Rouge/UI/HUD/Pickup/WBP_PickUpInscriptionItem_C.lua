local WBP_PickUpInscriptionItem_C = UnLua.Class()
function WBP_PickUpInscriptionItem_C:InitInfo(InscriptionId, UpgradeLevel)
  self:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  local LogicCommandSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandSubsystem then
    return
  end
  local Desc = GetLuaInscriptionDesc(InscriptionId, 0, nil)
  self.Txt_InscriptionName:SetText(Desc)
  if 0 == UpgradeLevel then
    self.Txt_InscriptionName:SetDefaultColorAndOpacity(self.NormalTextColor)
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.Hidden)
    SetImageBrushBySoftObject(self.Img_CompareStatus, self.NormalSpriteIcon)
  elseif 1 == UpgradeLevel then
    self.Txt_InscriptionName:SetDefaultColorAndOpacity(self.HighTextColor)
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Img_Bottom:SetColorAndOpacity(self.HighLevelBottomColor)
    SetImageBrushBySoftObject(self.Img_CompareStatus, self.HighSpriteIcon)
  else
    self.Txt_InscriptionName:SetDefaultColorAndOpacity(self.LowTextColor)
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Img_Bottom:SetColorAndOpacity(self.LowLevelBottomColor)
    SetImageBrushBySoftObject(self.Img_CompareStatus, self.LowSpriteIcon)
  end
end
function WBP_PickUpInscriptionItem_C:SetInscriptionNameColor(SlateColor)
  self.Txt_InscriptionName:SetDefaultColorAndOpacity(SlateColor)
end
function WBP_PickUpInscriptionItem_C:SetSizeBoxWidth(Length)
  self.TextSizeBox:SetWidthOverride(Length)
end
function WBP_PickUpInscriptionItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_PickUpInscriptionItem_C
