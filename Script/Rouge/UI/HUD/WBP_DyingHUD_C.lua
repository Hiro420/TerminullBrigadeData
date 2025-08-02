local WBP_DyingHUD_C = UnLua.Class()

function WBP_DyingHUD_C:Construct()
  self.WBP_DyingMaterial.OnRescueRatioChangeEvent:Add(self, WBP_DyingHUD_C.OnRescueStateChange)
  self.WBP_DyingMaterial.Target = self:GetOwningPlayerPawn()
  local Character = self:GetOwningPlayerPawn()
  if Character then
    local InteractRescue = Character:GetComponentByClass(UE.URGInteractComponent_Rescue.StaticClass())
    if InteractRescue then
      InteractRescue.OnRescueFailed:Add(self, self.OnRescueCancel)
    end
  end
end

function WBP_DyingHUD_C:Destruct()
  self.WBP_DyingMaterial.OnRescueRatioChangeEvent:Remove(self, WBP_DyingHUD_C.OnRescueStateChange)
  local Character = self:GetOwningPlayerPawn()
  if Character then
    local InteractRescue = Character:GetComponentByClass(UE.URGInteractComponent_Rescue.StaticClass())
    if InteractRescue then
      InteractRescue.OnRescueFailed:Remove(self, self.OnRescueCancel)
    end
  end
end

function WBP_DyingHUD_C:OnRescueStateChange(Rescue, Ratio)
  self:ShowDyingInfo(not Rescue)
  self.Ratio = Ratio
  self:SetRescueTime()
end

function WBP_DyingHUD_C:OnRescueCancel()
  ShowWaveWindow(1098)
end

function WBP_DyingHUD_C:SetRescueTime()
  local time = UE.UKismetMathLibrary.FCeil(self.RescueTotalTime - self.Ratio * self.RescueTotalTime)
  local DyingCountDownFmt = NSLOCTEXT("DyingHUD", "DyingCountDown", "{0}\231\167\146")
  self.TextBlock_Time:SetText(UE.FTextFormat(DyingCountDownFmt, time))
end

function WBP_DyingHUD_C:OnCharacterDying(Character)
  self:ShowDyingInfo(true)
  if Character and Character:IsValid() then
    self.DyingCount = Character:GetDyingCount()
    local DyingFmt = NSLOCTEXT("DyingHUD", "DyingCount", "\231\172\172{0}\230\172\161")
    self.TextBlock_DyingCount:SetText(UE.FTextFormat(DyingFmt, self.DyingCount))
    local settings = UE.URGCharacterSettings.GetSettings()
    if settings and settings:IsValid() then
      self.RescueTotalTime = settings:GetRescueTotalTime(self.DyingCount)
    end
  end
end

function WBP_DyingHUD_C:ShowDyingInfo(Dying)
  if self.Dying ~= Dying then
    if Dying then
      self:StopAnimation(self.ani_Overlay_Dying_out)
      self:StopAnimation(self.ani_Overlay_Rescue_in)
      self:PlayAnimation(self.ani_Overlay_Rescue_out)
      self:PlayAnimation(self.ani_Overlay_Dying_in)
      UpdateVisibility(self.Overlay_Dying, true)
    else
      self:StopAnimation(self.ani_Overlay_Rescue_out)
      self:StopAnimation(self.ani_Overlay_Dying_in)
      self:PlayAnimation(self.ani_Overlay_Dying_out)
      self:PlayAnimation(self.ani_Overlay_Rescue_in)
      UpdateVisibility(self.Overlay_Rescue, true)
    end
  end
  self.Dying = Dying
end

function WBP_DyingHUD_C:ShowDying()
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:OnCharacterDying(self:GetOwningPlayerPawn())
  self:ShowRevivalInfo()
end

function WBP_DyingHUD_C:HideDying()
  UpdateVisibility(self.Overlay_Dying, false)
  UpdateVisibility(self.Overlay_Rescue, false)
  UpdateVisibility(self, false)
  self.WBP_DyingRevival:UnBindKey()
end

function WBP_DyingHUD_C:ShowRevivalInfo()
  UpdateVisibility(self.WBP_DyingRevival, true)
  self.WBP_DyingRevival:ShowRevivalInfo()
end

return WBP_DyingHUD_C
