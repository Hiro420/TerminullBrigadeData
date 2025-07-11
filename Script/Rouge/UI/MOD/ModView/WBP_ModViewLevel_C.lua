local WBP_ModViewLevel_C = UnLua.Class()
local CostTextColor = {
  Gray = UE.FLinearColor(0.102242, 0.198069, 0.23074, 1.0),
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Black = UE.FLinearColor(0, 0, 0, 1.0),
  Yellow = UE.FLinearColor(1, 0.300544, 0.029557, 1.0)
}
function WBP_ModViewLevel_C:InitInfo(bIsLegend)
  local backColor = UE.FLinearColor()
  local activeColor = UE.FLinearColor()
  if bIsLegend then
    backColor = CostTextColor.Black
    activeColor = CostTextColor.Yellow
  else
    backColor = CostTextColor.Gray
    activeColor = CostTextColor.White
  end
  self.Image_Back:SetColorAndOpacity(backColor)
  self.Image_Activate:SetColorAndOpacity(activeColor)
end
function WBP_ModViewLevel_C:UpdateActiveInfo(Show)
  if Show then
    self.Image_Activate:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Activate:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
return WBP_ModViewLevel_C
