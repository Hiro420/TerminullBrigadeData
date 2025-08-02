local WBP_MarkUIInteractTip_Upgrade_C = UnLua.Class()

function WBP_MarkUIInteractTip_Upgrade_C:Construct()
  self:RefreshWidget()
end

function WBP_MarkUIInteractTip_Upgrade_C:SetWidgetConfig(IsNeedProgress, KeyRowName, KeyDesc, IsNeedShowDescBottom)
  self.IsNeedProgress = IsNeedProgress
  self.KeyRowName = KeyRowName
  self.KeyDesc = KeyDesc
  self.KeyIcon = nil
  self.IsShowDescBottom = IsNeedShowDescBottom
  self:RefreshWidget()
end

function WBP_MarkUIInteractTip_Upgrade_C:SetInteractActor(TargetActor)
  self.TargetActor = TargetActor
  self:RefreshWidget()
end

function WBP_MarkUIInteractTip_Upgrade_C:RefreshWidget()
  local Pawn = self:GetOwningPlayerPawn()
  local GenericModifyComponent = Pawn:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  local TransferText = ""
  local Interact_SpecificComp, Interact_UpgradeRarityModify
  if UE.RGUtil.IsUObjectValid(self.TargetActor) then
    local InteractComponent = self.TargetActor:GetComponentByClass(UE.URGInteractComponent_UpgradeModify:StaticClass())
    Interact_SpecificComp = self.TargetActor:GetComponentByClass(UE.URGInteractComponent_SpecificModify:StaticClass())
    Interact_UpgradeRarityModify = self.TargetActor:GetComponentByClass(UE.URGInteractComponent_UpgradeRarityModify:StaticClass())
    if InteractComponent then
      local configId = InteractComponent.ItemIfAllModifyReachMaxLevel.ConfigId
      local stack = InteractComponent.ItemIfAllModifyReachMaxLevel.Stack
      TransferText = UE.FTextFormat(self.TransferInteractTip, stack)
    elseif Interact_SpecificComp then
      local CompensateItemId, stack = Interact_SpecificComp:GetAbandonRefundItems()
      TransferText = UE.FTextFormat(self.TransferInteractTip, stack)
    elseif Interact_UpgradeRarityModify then
      local stack = Interact_UpgradeRarityModify.CompensateItem.Stack
      TransferText = UE.FTextFormat(self.TransferInteractTip, stack)
    end
    self:InitInfo()
    local curSpecificModify = LogicGenericModify:GetFirstSpecificModify()
    if 41 == LogicTeam.GetWorldId() then
      self.Btn_Main_1:SetVisibility(UE.ESlateVisibility.Collapsed)
    elseif Interact_SpecificComp and curSpecificModify then
      self.Txt_Desc_1:SetText(tostring(TransferText))
      self.Btn_Main_1:SetVisibility(UE.ESlateVisibility.Visible)
    elseif GenericModifyComponent and GenericModifyComponent:HasCandidateModifies() and InteractComponent then
      UpdateVisibility(self.Btn_Main_1, false)
    elseif GenericModifyComponent and Interact_UpgradeRarityModify then
      if not GenericModifyComponent:HasCandidateRarityUpModifies() then
        self.Txt_Desc:SetText(tostring(TransferText))
      end
      UpdateVisibility(self.Btn_Main_1, false)
    else
      self.Txt_Desc:SetText(tostring(TransferText))
      self.Btn_Main_1:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function WBP_MarkUIInteractTip_Upgrade_C:InitInfo()
  if self.IsNeedProgress then
    self:UpdateProgress(0.0)
    self.Img_Progress:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_Progress_1:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Progress:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_Progress_1:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.WBP_CustomKeyName:SetCustomKeyConfig(self.KeyRowName, self.KeyIcon)
  self.Txt_Desc:SetText(self.KeyDesc)
  if UE.UKismetTextLibrary.TextIsEmpty(self.KeyDesc) then
    self.DescPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.DescPanel_1:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.DescPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.DescPanel_1:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if self.IsShowDescBottom then
      self.Img_DescBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Img_DescBottom_1:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Img_DescBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Img_DescBottom_1:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function WBP_MarkUIInteractTip_Upgrade_C:PlayInAnimation()
  if self:IsAnimationPlaying(self.Ani_out) then
    self.IsInitiativeStop = true
    self:StopAnimation(self.Ani_out)
  end
  self:PlayAnimationForward(self.Ani_in)
end

function WBP_MarkUIInteractTip_Upgrade_C:PlayOutAnimation(AnimationFinishedEvent)
  self:PlayAnimationForward(self.Ani_out)
  self.OutAnimationFinishedEvent = AnimationFinishedEvent
  StopListeningForInputAction(self, "RefreshNPC", UE.EInputEvent.IE_Pressed)
end

function WBP_MarkUIInteractTip_Upgrade_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_Out then
    if self.IsInitiativeStop then
      self.IsInitiativeStop = false
    else
      self.OutAnimationFinishedEvent[2](self.OutAnimationFinishedEvent[1])
    end
  end
end

return WBP_MarkUIInteractTip_Upgrade_C
