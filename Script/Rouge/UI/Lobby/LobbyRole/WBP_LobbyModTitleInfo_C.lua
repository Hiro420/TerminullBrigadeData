local WBP_LobbyModTitleInfo_C = UnLua.Class()
local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Yellow = UE.FLinearColor(0.381326, 0.116971, 0.015996, 1.0)
}

function WBP_LobbyModTitleInfo_C:InitModTitles(bIsLegend, ModInfo, ModNumber)
  self.ModType = ModInfo.ModType
  self.ChooseType = UE.ERGMODChooseType.Character
  local tempPaperSprite
  local SlateColor = UE.FSlateColor()
  SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  if bIsLegend then
    tempPaperSprite = self.ImageLine_Legend
    SlateColor.SpecifiedColor = CostTextColor.Yellow
  else
    tempPaperSprite = self.ImageLine_Normal
    SlateColor.SpecifiedColor = CostTextColor.White
  end
  local LineIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(tempPaperSprite)
  if LineIconObj then
    local LineBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(LineIconObj, 0, 0)
    self.Image_Title_Line:SetBrush(LineBrush)
  end
  self.TextBlock_Title:SetText(ModInfo.Name)
  self.TextBlock_Title:SetColorAndOpacity(SlateColor)
  self.TextBlock_TitleDes:SetText(ModInfo.Desc)
  local ModIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ModInfo.Icon)
  if ModIconObj then
    local ModBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(ModIconObj, 0, 0)
    self.Image_Title:SetBrush(ModBrush)
  end
end

return WBP_LobbyModTitleInfo_C
