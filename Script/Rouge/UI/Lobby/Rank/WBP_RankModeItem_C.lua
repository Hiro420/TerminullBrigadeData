local WBP_RankModeItem_C = UnLua.Class()

function WBP_RankModeItem_C:Construct()
  self.Button_Mode.OnClicked:Add(self, WBP_RankModeItem_C.OnClicked_Button)
end

function WBP_RankModeItem_C:Destruct()
  self.Button_Mode.OnClicked:Remove(self, WBP_RankModeItem_C.OnClicked_Button)
end

function WBP_RankModeItem_C:UpdateRankModeItem(Index)
  print("WBP_RankModeItem_C", Index)
  self.Index = Index
  if self.SelectIndex == nil then
    self.SelectIndex = 1
  end
  self.SelectIndex = self.TextBlock_Mode:SetText(EnumRankModeString[Index])
  if Index == self.SelectIndex then
    self:UpdateButtonStatus(true)
  else
  end
end

function WBP_RankModeItem_C:UpdateButtonStatus(Selected)
  local SlateColor = UE.FSlateColor()
  SlateColor.SpecifiedColor = UE.FLinearColor(0.701102, 0.165132, 0.015209, 1)
  SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  if Selected then
    SlateColor.SpecifiedColor = UE.FLinearColor(0.701102, 0.165132, 0.015209, 1)
    self.TextBlock_Mode:SetColorAndOpacity(SlateColor)
    self.Image_Mode:SetColorAndOpacity(UE.FLinearColor(0.701102, 0.165132, 0.015209, 1))
    self.Image_Mode:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    SlateColor.SpecifiedColor = UE.FLinearColor(0.733333, 0.733333, 0.733333, 1)
    self.TextBlock_Mode:SetColorAndOpacity(SlateColor)
    self.Image_Mode:SetColorAndOpacity(UE.FLinearColor(1, 1, 1, 1))
    self.Image_Mode:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function WBP_RankModeItem_C:OnClicked_Button()
  EventSystem.Invoke(EventDef.Rank.OnModeChange, self.Index)
  self:UpdateButtonStatus(true)
end

return WBP_RankModeItem_C
