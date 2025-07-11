local WBP_RGPickupWaveWindow_C = UnLua.Class()
function WBP_RGPickupWaveWindow_C:RefreshInfo(Data, Level)
  self.Txt_Name:SetText(Data.Name)
  SetImageBrushBySoftObject(self.Img_Icon, Data.SpriteIcon, self.IconSize)
  if 0 == Level then
    self.Txt_Level:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Txt_Level:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Txt_Level:SetText("+" .. tostring(Level))
  end
  self:PlayAnimationForward(self.StartAnim)
end
return WBP_RGPickupWaveWindow_C
