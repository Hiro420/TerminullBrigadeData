local WBP_GPInscriptionItem_C = UnLua.Class()
function WBP_GPInscriptionItem_C:Construct()
  self:UpdateInscriptionDesOpacity(true)
end
function WBP_GPInscriptionItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  EventSystem.Invoke(EventDef.GamePokey.OnInscriptionHovered, self.InscriptionId)
end
function WBP_GPInscriptionItem_C:OnMouseLeave(MouseEvent)
  EventSystem.Invoke(EventDef.GamePokey.OnInscriptionUnHovered)
end
function WBP_GPInscriptionItem_C:UpdateInscriptionDes(InscriptionId)
  self.InscriptionId = InscriptionId
  local LogicCommandSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandSubsystem then
    return
  end
  local Desc = GetLuaInscriptionDesc(InscriptionId, 0, nil)
  self.Txt_InscriptionName:SetText(Desc)
end
local CostTextColor = {
  HighLight = UE.FLinearColor(0.590619, 0.590619, 0.590619, 1.0),
  LowLight = UE.FLinearColor(0.590619, 0.590619, 0.590619, 0.5)
}
function WBP_GPInscriptionItem_C:UpdateInscriptionDesOpacity(HighLight)
  local SlateColor = UE.FSlateColor()
  SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  if HighLight then
    SlateColor.SpecifiedColor = CostTextColor.HighLight
  else
    SlateColor.SpecifiedColor = CostTextColor.LowLight
  end
  self.Txt_InscriptionName:SetDefaultColorAndOpacity(SlateColor)
end
function WBP_GPInscriptionItem_C:SetTextWidthOverride(Width)
  self.TextSizeBox:SetWidthOverride(Width)
end
return WBP_GPInscriptionItem_C
