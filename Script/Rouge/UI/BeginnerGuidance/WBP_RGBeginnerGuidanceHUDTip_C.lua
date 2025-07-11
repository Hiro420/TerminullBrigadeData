local WBP_RGBeginnerGuidanceHUDTip_C = UnLua.Class()
function WBP_RGBeginnerGuidanceHUDTip_C:Construct()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  LogicBeginnerGuidance.RegisterHUDTip(self.BeginnerGuidanceRowId, self)
end
function WBP_RGBeginnerGuidanceHUDTip_C:Show()
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if not self.OperateTipWidget or not self.OperateTipWidget:IsValid() then
    local ClassPath = MakeStringToSoftObjectReference("/Game/Rouge/UI/BeginnerGuidance/WBP_RGBeginnerGuidanceOperateTip.WBP_RGBeginnerGuidanceOperateTip_C")
    local Class = GetAssetBySoftObjectPtr(ClassPath, true)
    self.OperateTipWidget = UE.UWidgetBlueprintLibrary.Create(self, Class)
    self.FrameSlot:AddChild(self.OperateTipWidget)
  end
  self.OperateTipWidget:RefreshInfo(self.BeginnerGuidanceRowId)
end
function WBP_RGBeginnerGuidanceHUDTip_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_RGBeginnerGuidanceHUDTip_C:Destruct()
  LogicBeginnerGuidance.UnRegisterHUDTip(self.BeginnerGuidanceRowId, self)
end
return WBP_RGBeginnerGuidanceHUDTip_C
