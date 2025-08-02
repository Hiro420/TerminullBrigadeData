local WBP_SingleGridBar_C = UnLua.Class()
local PositionParam = "position"

function WBP_SingleGridBar_C:InitInfo(MinNum, MaxNum, ReduceAnimName, SizeX, Parent)
  self.MinNum = MinNum
  self.MaxNum = MaxNum
  self.SizeX = SizeX
  self.Parent = Parent
  self.HasSpecialAttribute = self.Parent and self.Parent.HasSpecialAttribute or false
  UpdateVisibility(self.Img_SpecialFill, self.HasSpecialAttribute)
  if self.ListWidget and self.IsExecuteVirtualLogic then
    self.ListWidget.UpdateVirtualImg:Add(self, WBP_SingleGridBar_C.BindOnUpdateVirtualImg)
  end
  if self.IsExecuteVirtualLogic then
    self.VirtualBar:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.VirtualBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.ReduceFXWidget:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:InitInfoImp()
  if not UE.UKismetStringLibrary.IsEmpty(ReduceAnimName) then
    self.ReduceAnimName = ReduceAnimName
  end
  self.UIQuality = BattleUIScalability:GetGridBarScalability()
end

function WBP_SingleGridBar_C:PlayVirtualWhiteFXAnim(IsRecover, LeftValue, RightValue, AnimColor)
  self.Img_VirtualWhite_Anim:SetColorAndOpacity(AnimColor)
  if self.UIQuality ~= UIQuality.LOW then
    self:StopAllAnimations()
  end
  local LeftPercent = math.clamp((LeftValue - self.MinNum) / (self:GetMaxNum() - self.MinNum), 0.0, 1.0)
  local RightPercent = math.clamp((RightValue - self.MinNum) / (self:GetMaxNum() - self.MinNum), 0.0, 1.0)
  self.Img_VirtualWhite_Anim:SetClippingValue(RightPercent)
  self.Img_VirtualWhite_Anim:SetLeftClippingValue(LeftPercent)
  if self.UIQuality ~= UIQuality.LOW then
    if IsRecover then
      self:PlayAnimation(self.ShieldFlareGreen)
    else
      self:PlayAnimation(self.ShieldFlareRed)
    end
  end
end

function WBP_SingleGridBar_C:BindOnUpdateVirtualImg(CurValue)
  self:UpdateVirtualImg(CurValue)
end

function WBP_SingleGridBar_C:InitInfoImp()
  self.TargetHp = -1
  self.OldValue = -1
  UpdateVisibility(self.URGImageBloodEffect, false)
end

function WBP_SingleGridBar_C:JudgeCanPlayReduceAnim(OldFXPercent, TargetFXPercent)
  if self.CanPlayReduceAnim then
    return self.CanPlayReduceAnim(OldFXPercent, TargetFXPercent)
  end
  if 0.0 == OldFXPercent or 0.0 == TargetFXPercent then
    return false
  end
  if not TargetFXPercent or not OldFXPercent then
    return false
  end
  return TargetFXPercent < OldFXPercent
end

function WBP_SingleGridBar_C:SetReduceAnimName(InAnimName)
  self.ReduceAnimName = InAnimName
end

function WBP_SingleGridBar_C:PlayReduceAnim(OldPercent, TargetPercent)
  if UE.UKismetStringLibrary.IsEmpty(self.ReduceAnimName) then
    self.ReduceFXWidget:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ReduceFXWidget)
  if not Slot then
    return
  end
  local Position = Slot:GetPosition()
  Position.X = self.SizeX * (1 - TargetPercent) * -1
  Slot:SetPosition(Position)
  self.ReduceFXWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.ReduceFXWidget:PlayReduceAnim(self.ReduceAnimName)
end

function WBP_SingleGridBar_C:ShowOrHideVirtualWhiteBar(IsShow)
  if not self.IsShowVirtualWhite then
    UpdateVisibility(self.Img_VirtualWhite, false)
    return
  end
  UpdateVisibility(self.Img_VirtualWhite, IsShow)
end

function WBP_SingleGridBar_C:UpdateVirtualWhiteBarValue(VirtualWhiteBarValue)
  if not self.IsShowVirtualWhite then
    return
  end
  self:UpdatePanelSize(self.Img_VirtualWhite, VirtualWhiteBarValue)
end

function WBP_SingleGridBar_C:SetIsShowVirtualWhite(InIsShowVirtualWhite)
  self.IsShowVirtualWhite = InIsShowVirtualWhite
end

function WBP_SingleGridBar_C:SetGetSpecialMaxAttributeValue(Func)
  self.OnGetSpecialMaxAttributeValue = Func
end

function WBP_SingleGridBar_C:UpdateVirtualImg(CurValue)
  self:UpdatePanelSize(self.VirtualBar, CurValue)
end

function WBP_SingleGridBar_C:UpdateBarStyle(FillObj, BottomObj, VirtualObj, SpecialObj)
  local Brush = UE.FSlateBrush()
  local Margin = UE.FMargin()
  Margin.Bottom = 0.5
  Margin.Left = 0.5
  Margin.Right = 0.5
  Margin.Top = 0.5
  Brush.Margin = Margin
  Brush.DrawAs = UE.ESlateBrushDrawType.Box
  Brush.ResourceObject = FillObj
  self.FillImg:SetBrush(Brush)
  Brush.ResourceObject = BottomObj
  self.BackGroundImg:SetBrush(Brush)
  Brush.ResourceObject = VirtualObj
  self.VirtualBar:SetBrush(Brush)
  self.Img_VirtualWhite:SetBrush(Brush)
  Brush.ResourceObject = SpecialObj
  self.Img_SpecialFill:SetBrush(Brush)
end

function WBP_SingleGridBar_C:UpdateBarColor(FillColor, VirtualColor, BottomColor, SpecialFillColor)
  self.FillImg:SetColorAndOpacity(FillColor)
  self.VirtualBar:SetColorAndOpacity(VirtualColor)
  self.BackGroundImg:SetColorAndOpacity(BottomColor)
  self.Img_SpecialFill:SetColorAndOpacity(SpecialFillColor)
end

function WBP_SingleGridBar_C:UpdateReduceFXWidgetColor(InColor)
  self.ReduceFXWidget:UpdateFXImgColor(InColor)
end

function WBP_SingleGridBar_C:UpdateVirtualWhiteColor(VirtualWhiteColor)
  self.Img_VirtualWhite:SetColorAndOpacity(VirtualWhiteColor)
end

function WBP_SingleGridBar_C:Show()
  self:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
end

function WBP_SingleGridBar_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_SingleGridBar_C
