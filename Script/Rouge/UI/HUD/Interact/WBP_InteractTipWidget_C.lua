local WBP_InteractTipWidget_C = UnLua.Class()
function WBP_InteractTipWidget_C:Construct()
  self:InitInfo()
  if self.CanInteract then
    self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
    self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
    self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Add(self, self.BindOnInputMethodChanged)
  end
end
function WBP_InteractTipWidget_C:Destruct()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.BindOnInputMethodChanged)
  end
end
function WBP_InteractTipWidget_C:BindOnInputMethodChanged(InputType)
  self:UpdateSelfVisible()
end
function WBP_InteractTipWidget_C:UpdateSelfVisible()
  if not self.bEnableAutoControlVisible then
    return
  end
  local IsVisible = self:CanTipWidgetShowByInputType()
  if not IsVisible then
    UpdateVisibility(self, false)
  elseif self.bOnlyForDisplay then
    self:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_InteractTipWidget_C:CanTipWidgetShowByInputType()
  if self.bOnlyUseOnGamePad then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
    if CommonInputSubsystem then
      local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
      if CurrentInputType == UE.ECommonInputType.Gamepad then
        return true
      else
        return false
      end
    end
  end
  return true
end
function WBP_InteractTipWidget_C:BindOnMainButtonClicked()
  self.OnMainButtonClicked:Broadcast()
end
function WBP_InteractTipWidget_C:BindOnMainButtonHovered()
  self.WBP_CustomKeyName:PlayHoverOrUnhoverAnim(true)
end
function WBP_InteractTipWidget_C:BindOnMainButtonUnhovered()
  self.WBP_CustomKeyName:PlayHoverOrUnhoverAnim(false)
end
function WBP_InteractTipWidget_C:BindInteractAndClickEvent(Obj, Callback, KeyName)
  self.OnMainButtonClicked:Add(Obj, Callback)
  local keyName = KeyName
  keyName = keyName or tostring(self.KeyRowName)
  if keyName and not IsListeningForInputAction(Obj, keyName, UE.EInputEvent.IE_Pressed) then
    ListenForInputAction(keyName, UE.EInputEvent.IE_Pressed, true, {Obj, Callback})
  end
end
function WBP_InteractTipWidget_C:UnBindInteractAndClickEvent(Obj, Callback, KeyName)
  self.OnMainButtonClicked:Remove(Obj, Callback)
  local keyName = KeyName
  keyName = keyName or tostring(self.KeyRowName)
  if keyName and IsListeningForInputAction(Obj, keyName, UE.EInputEvent.IE_Pressed) then
    StopListeningForInputAction(Obj, keyName, UE.EInputEvent.IE_Pressed)
  end
end
function WBP_InteractTipWidget_C:SetWidgetConfig(IsNeedProgress, KeyRowName, KeyDesc, IsNeedShowDescBottom, KeyImage)
  self.IsNeedProgress = IsNeedProgress
  self.KeyRowName = KeyRowName
  self.KeyDesc = KeyDesc
  self.KeyIcon = nil
  self.IsShowDescBottom = IsNeedShowDescBottom
  self.KeyImage = KeyImage
  UpdateVisibility(self, false)
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      UpdateVisibility(self, true)
      self:InitInfo()
    end
  }, 0.01, false)
  self:SetWidgetStyle()
end
function WBP_InteractTipWidget_C:InitInfo()
  self:UpdateSelfVisible()
  if self.IsNeedProgress then
    self:UpdateProgress(0.0)
    self.Img_Progress:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Progress:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.WBP_CustomKeyName:SetCustomKeyConfig(self.KeyRowName, self.KeyIcon)
  self.WBP_CustomKeyName:SetCustomKeyDisplayInfo(self.CustomKeyDisplayInfo)
  if UE.UKismetTextLibrary.TextIsEmpty(self.KeyDesc) then
    self:UpdateDescPanelVis(false)
  else
    self:UpdateDescPanelVis(true)
    if self.IsShowDescBottom then
      self.Img_DescBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Img_LeftDescBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Img_DescBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Img_LeftDescBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  if self.IsShowImage then
    SetImageBrushBySoftObject(self.Img_Key, self.KeyImage)
    self:ShowImage()
  else
    self.Txt_Desc:SetText(self.KeyDesc)
    self.Txt_LeftDesc:SetText(self.KeyDesc)
  end
end
function WBP_InteractTipWidget_C:UpdateDescPanelVis(IsShow)
  UpdateVisibility(self.DescPanel, not self.IsShowLeftDesc and IsShow)
  UpdateVisibility(self.LeftDescPanel, self.IsShowLeftDesc and IsShow)
end
function WBP_InteractTipWidget_C:UpdateProgress(ProgressParam)
  local Mat = self.Img_Progress:GetDynamicMaterial()
  if Mat then
    Mat:SetScalarParameterValue("Percent", ProgressParam)
  end
end
function WBP_InteractTipWidget_C:UpdateKeyDesc(Desc)
  self.KeyDesc = Desc
  self.Txt_Desc:SetText(self.KeyDesc)
  self.Txt_LeftDesc:SetText(self.KeyDesc)
end
function WBP_InteractTipWidget_C:UpdateKeyIamge(Image)
  self.KeyImage = Image
  SetImageBrushBySoftObject(self.Img_Key, Image)
end
function WBP_InteractTipWidget_C:ShowImage()
  self:UpdateDescPanelVis(false)
  UpdateVisibility(self.Img_Key, true)
end
function WBP_InteractTipWidget_C:PlayInAnimation()
  if self:IsAnimationPlaying(self.Ani_out) then
    self.IsInitiativeStop = true
    self:StopAnimation(self.Ani_out)
  end
  self:PlayAnimationForward(self.Ani_in)
end
function WBP_InteractTipWidget_C:PlayOutAnimation(AnimationFinishedEvent)
  self:PlayAnimationForward(self.Ani_out)
  self.OutAnimationFinishedEvent = AnimationFinishedEvent
end
function WBP_InteractTipWidget_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_Out then
    if self.IsInitiativeStop then
      self.IsInitiativeStop = false
    else
      self.OutAnimationFinishedEvent[2](self.OutAnimationFinishedEvent[1])
    end
  end
end
function WBP_InteractTipWidget_C:SetWidgetConfigFromCommonButton(KeyRowName, CanInteract, CustomKeyDisplayInfo, OnlyUseonGamePad, OnlyforDisplay, EnableAutoControlVisible)
  self.KeyRowName = KeyRowName
  self.CanInteract = CanInteract
  self.CustomKeyDisplayInfo = CustomKeyDisplayInfo
  self.bOnlyUseonGamePad = OnlyUseonGamePad
  self.bOnlyforDisplay = OnlyforDisplay
  self.bEnableAutoControlVisible = EnableAutoControlVisible
  UpdateVisibility(self, false)
  if self.KeyRowName and self.KeyRowName ~= "" and self.bEnableAutoControlVisible then
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        UpdateVisibility(self, true)
        self:InitInfo()
      end
    }, 0.01, false)
  end
end
return WBP_InteractTipWidget_C
