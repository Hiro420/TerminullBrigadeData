local WBP_PuzzleEquipInfoToggle = UnLua.Class()
function WBP_PuzzleEquipInfoToggle:Construct()
  SetImageBrushBySoftObject(self.Img_SelectBottom, self.SelectBottomImage)
  SetImageBrushBySoftObject(self.Img_UnSelectBottom, self.UnSelectBottomImage)
  SetImageBrushBySoftObject(self.Img_Hovered, self.HoveredImg)
  local Brush = self.Img_Hovered.Brush
  Brush.DrawAs = UE.ESlateBrushDrawType.Box
  local Margin = UE.FMargin()
  Margin.Bottom = 0.5
  Margin.Left = 0.5
  Margin.Right = 0.5
  Margin.Top = 0.5
  Brush.Margin = Margin
  self.Img_Hovered:SetBrush(Brush)
end
return WBP_PuzzleEquipInfoToggle
