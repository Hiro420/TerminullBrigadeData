local WBP_ModInfoItem_C = UnLua.Class()
function WBP_ModInfoItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self.Image_ModHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_ModInfoItem_C:OnMouseLeave(MouseEvent)
  self.Image_ModHover:SetVisibility(UE.ESlateVisibility.Hidden)
end
local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Yellow = UE.FLinearColor(0.304987, 0.116971, 0.025187, 1.0),
  Black = UE.FLinearColor(0, 0, 0, 1.0)
}
function WBP_ModInfoItem_C:UpdateInitModInfoItem(ModIdList, bIsLegend)
  local maxLevel = #ModIdList
  if maxLevel <= 0 then
    return
  end
  self.ModId = 0
  for key, value in pairs(ModIdList) do
    if 1 == key then
      self.ModId = value
    end
  end
  self.ModIdList = ModIdList
  local outSaveData = GetLuaInscription(self.ModId)
  if outSaveData then
    SetImageBrushByPath(self.Image_Mod, outSaveData.Icon)
  else
    print("OutSaveData is null.")
  end
  self:UpdateModInfoItemColor(bIsLegend)
  self:UpdateModInfoItemOpacity(0.3)
  self.TextBlock_CurrentLevel:SetText("0")
  self.TextBlock_MaxLevel:SetText(tostring(maxLevel))
  self.CurrentLevel = 0
end
function WBP_ModInfoItem_C:UpdateModInfoItem(CurrentLevel)
  self.CurrentLevel = CurrentLevel
  self:UpdateModInfoItemOpacity(1)
  self.TextBlock_CurrentLevel:SetText(tostring(CurrentLevel))
end
function WBP_ModInfoItem_C:UpdateModInfoItemOpacity(Opacity)
  self.Image_Mod:SetOpacity(Opacity)
  self.TextBlock_CurrentLevel:SetOpacity(Opacity)
  self.TextBlock_Line:SetOpacity(Opacity)
  self.TextBlock_MaxLevel:SetOpacity(Opacity)
end
function WBP_ModInfoItem_C:UpdateModInfoItemColor(IsLegend)
  local SlateColor = UE.FSlateColor()
  SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  SlateColor.SpecifiedColor = UE.FLinearColor()
  if IsLegend then
    self.Image_ModBack:SetColorAndOpacity(CostTextColor.Yellow)
    SlateColor.SpecifiedColor = CostTextColor.Yellow
  else
    self.Image_ModBack:SetColorAndOpacity(CostTextColor.Black)
    SlateColor.SpecifiedColor = CostTextColor.White
  end
  self.TextBlock_CurrentLevel:SetColorAndOpacity(SlateColor)
  self.TextBlock_Line:SetColorAndOpacity(SlateColor)
  self.TextBlock_MaxLevel:SetColorAndOpacity(SlateColor)
end
function WBP_ModInfoItem_C:GetToolTipWidget()
  if self.ModID > 0 then
    local widgetClass = UE.UClass.Load("/Game/Rouge/UI/MOD/ModView/WBP_ModViewTip.WBP_ModViewTip_C")
    local toolTipWidget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
    if toolTipWidget then
      local OutSaveData = GetLuaInscription(self.ModID)
      if OutSaveData then
        toolTipWidget:InitModTipInfo(OutSaveData, self.CurrentLevel, self.ModIdList)
        return toolTipWidget
      end
    end
  else
    return nil
  end
end
return WBP_ModInfoItem_C
