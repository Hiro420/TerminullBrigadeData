local WBP_GRSingleModType_C = UnLua.Class()
local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Yellow = UE.FLinearColor(0.304987, 0.116971, 0.025187, 1.0),
  Black = UE.FLinearColor(0, 0, 0, 1.0)
}
function WBP_GRSingleModType_C:UpdateSingleModType(ModIdList, ModName, ModIcon)
  local padding = UE.FMargin()
  if self.IsLegend then
    padding.Right = 40
  else
    padding.Right = 10
  end
  self.TextBlock_Name:SetText(ModName)
  local ModIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ModIcon)
  if ModIconObj then
    local ModBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(ModIconObj, 0, 0)
    self.Image_ModType:SetBrush(ModBrush)
  end
  self.WBP_ModInfoBox:UpdateModInfoBox(ModIdList, self.IsLegend, padding)
end
return WBP_GRSingleModType_C
