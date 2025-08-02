local WBP_Virus_AianStateUMG_C = UnLua.Class()

function WBP_Virus_AianStateUMG_C:InitInfo(OwnerActor)
  self.OwningActor = OwnerActor
  if not self.OwningActor then
    return
  end
  self.CurrentColor = self.OwningActor.CurrentColor
  if self.CurrentColor == nil then
    return
  end
  self.StartColor = UE.FLinearColor(1.0, 0.012, 0.204, 1.0)
  self.EndColor = UE.FLinearColor(0.184, 0.224, 1.0, 1.0)
  self:OnVirusColorChange(self.CurrentColor)
end

function WBP_Virus_AianStateUMG_C:OnVirusColorChange(ColorProgress)
  local bIncrease = ColorProgress - self.CurrentColor > 0
  self.CurrentColor = ColorProgress
  self.arrow:SetValue(ColorProgress)
  self.URGImage_Progress_red:SetClippingValue(1 - ColorProgress)
  self.URGImage_Progress_blue:SetClippingValue(ColorProgress)
  self.Slider_Progress:SetValue(1 - ColorProgress)
  self.Slider_Progress_2:SetValue(ColorProgress)
  local FinalColor = LerpColor(self.StartColor, self.EndColor, ColorProgress)
  self.image_Progress_di:SetColorAndOpacity(FinalColor)
  local bFull = math.abs(ColorProgress - 1) < 0.001
  local bEmpty = math.abs(ColorProgress - 0) < 0.001
  if bIncrease then
    if bFull then
      UpdateVisibility(self.CanvasPanel_Red_turns_blue, false)
      UpdateVisibility(self.CanvasPanel_Blue_turns_red, true)
      self:PlayAnimation(self.Ani_Red_turns_blue)
    else
      UpdateVisibility(self.CanvasPanel_Red_turns_blue, true)
      UpdateVisibility(self.CanvasPanel_Blue_turns_red, false)
    end
  elseif bEmpty then
    UpdateVisibility(self.CanvasPanel_Red_turns_blue, true)
    UpdateVisibility(self.CanvasPanel_Blue_turns_red, false)
    self:PlayAnimation(self.Ani_blue_turns_red)
  else
    UpdateVisibility(self.CanvasPanel_Red_turns_blue, false)
    UpdateVisibility(self.CanvasPanel_Blue_turns_red, true)
  end
end

function WBP_Virus_AianStateUMG_C:ShowPanel()
  UpdateVisibility(self.CanvasPanel_Root, true)
end

function WBP_Virus_AianStateUMG_C:HidePanel()
  UpdateVisibility(self.CanvasPanel_Root, false)
end

return WBP_Virus_AianStateUMG_C
