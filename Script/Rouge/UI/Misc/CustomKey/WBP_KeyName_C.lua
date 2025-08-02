local WBP_KeyName_C = UnLua.Class()

function WBP_KeyName_C:Construct()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Add(self, self.BindOnInputMethodChanged)
  end
end

function WBP_KeyName_C:SetCustomKeyConfig(KeyRowName, KeyNameStyle)
  self.KeyRowName = KeyRowName
  self.KeyNameStyle = KeyNameStyle
  self:InitInfo()
end

function WBP_KeyName_C:SetBottomOpacity(Opacity)
  self.Img_Bottom:SetRenderOpacity(Opacity)
end

function WBP_KeyName_C:SetTextOpacity(Opacity)
  self.Txt_KeyName:SetRenderOpacity(Opacity)
  self.Img_KeyIcon:SetRenderOpacity(Opacity)
end

function WBP_KeyName_C:SetTextColorAndOpacity(ColorAndOpacity)
  self.Txt_KeyName:SetColorAndOpacity(ColorAndOpacity)
end

function WBP_KeyName_C:SetIconColorAndOpacity(ColorAndOpacity)
  self.Img_KeyIcon:SetColorAndOpacity(ColorAndOpacity)
end

function WBP_KeyName_C:Show()
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_KeyName_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self.IsBind then
    EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, self.BindOnKeyChanged, self)
    self.IsBind = false
  end
end

function WBP_KeyName_C:PlayHoverOrUnhoverAnim(IsHover)
  if IsHover then
    self:PlayAnimationForward(self.Ani_hover_in)
  else
    self:PlayAnimationForward(self.Ani_hover_out)
  end
end

function WBP_KeyName_C:InitInfo()
  self:StopAllAnimations()
  local IsCustomKey, RowInfo = GetRowData(DT.DT_CustomKey, self.KeyRowName)
  if IsCustomKey and not self.IsBind then
    EventSystem.AddListener(self, EventDef.GameSettings.OnKeyChanged, self.BindOnKeyChanged)
    self.IsBind = true
  end
  self:ChangeCustomKeyAppearance(self.KeyRowName)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(self.KeyNameStyle.BottomIcon) then
    SetImageBrushBySoftObject(self.Img_Bottom, self.KeyNameStyle.BottomIcon, self.KeyNameStyle.BottomIconSize)
    local Brush = self.Img_Bottom.Brush
    Brush.DrawAs = UE.ESlateBrushDrawType.Box
    local Margin = UE.FMargin()
    Margin.Bottom = 0.5
    Margin.Left = 0.5
    Margin.Right = 0.5
    Margin.Top = 0.5
    Brush.Margin = Margin
    self.Img_Bottom:SetBrush(Brush)
  end
  if self.KeyNameStyle.TextColorAndOpacity then
    self.Txt_KeyName:SetColorAndOpacity(self.KeyNameStyle.TextColorAndOpacity)
  end
  self.Img_Bottom:SetColorAndOpacity(self.KeyNameStyle.BottomColorAndOpacity)
end

function WBP_KeyName_C:BindOnInputMethodChanged(InputType)
  self:ChangeCustomKeyAppearance(self.KeyRowName)
end

function WBP_KeyName_C:ChangeCustomKeyAppearance(KeyName)
  local KeyDisplayInfo, IsIcon = LogicGameSetting.GetCurSelectedKeyNameByKeyRowName(KeyName, self.KeyNameStyle.KeyIconUseType)
  if IsIcon then
    self.KeyNamePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_KeyIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    SetImageBrushBySoftObject(self.Img_KeyIcon, KeyDisplayInfo, self.KeyNameStyle.IconSize)
  else
    self.KeyNamePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_KeyIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_KeyName:SetText(KeyDisplayInfo)
  end
end

function WBP_KeyName_C:BindOnKeyChanged(ChangedKeyList)
  if not table.Contain(ChangedKeyList, self.KeyRowName) then
    return
  end
  self:ChangeCustomKeyAppearance(self.KeyRowName)
end

function WBP_KeyName_C:Destruct()
  EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, self.BindOnKeyChanged, self)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.BindOnInputMethodChanged)
  end
end

return WBP_KeyName_C
