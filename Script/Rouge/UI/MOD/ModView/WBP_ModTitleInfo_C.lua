local WBP_ModTitleInfo_C = UnLua.Class()
local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Yellow = UE.FLinearColor(0.381326, 0.116971, 0.015996, 1.0)
}
function WBP_ModTitleInfo_C:InitModTitles(bIsLegend, ModInfo)
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
  self.TextBlock_CurrentNumber:SetColorAndOpacity(SlateColor)
  self.TextBlock_Temp:SetColorAndOpacity(SlateColor)
  self.TextBlock_MaxNumber:SetColorAndOpacity(SlateColor)
  self:UpdateModTitles()
end
function WBP_ModTitleInfo_C:UpdateModTitles()
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local modComponent = pawn:GetComponentByClass(UE.UMODComponent.StaticClass())
    if modComponent then
      local nowNumber, MaxNumber
      MaxNumber, nowNumber = modComponent:GetTotalModNumByType(self.ModType, nowNumber, self.ChooseType)
      print("UpdateModTitles : " .. "self.ModType : " .. tostring(self.ModType) .. " / " .. "self.ChooseType : " .. tostring(self.ChooseType) .. " / " .. "nowNumber : " .. tostring(nowNumber) .. " / " .. "MaxNumber : " .. tostring(MaxNumber))
      self.TextBlock_CurrentNumber:SetText(tostring(nowNumber))
      self.TextBlock_MaxNumber:SetText(tostring(MaxNumber))
    else
      print("modComponent is null.")
    end
  else
    print("Pawn is null.")
  end
end
return WBP_ModTitleInfo_C
