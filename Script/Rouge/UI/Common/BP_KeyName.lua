local BP_KeyName = UnLua.Class()

function BP_KeyName:Bp_Init()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Add(self, self.BindOnInputMethodChanged)
  end
end

function BP_KeyName:Bp_UnInit()
  self.Overridden.Bp_UnInit(self)
  EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, self.BindOnKeyChanged, self)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.BindOnInputMethodChanged)
  end
end

function BP_KeyName:Bp_SetCustomKeyConfig(RichTxtKeyName)
  self.RichTxtKeyName = RichTxtKeyName
  self:UpdateRowName()
  self:InitInfo()
end

function BP_KeyName:UpdateRowName()
  local result, row = GetRowData(DT.DT_RichTxtKeyName, self.RichTxtKeyName)
  if result then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
    if CommonInputSubsystem then
      local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
      if CurrentInputType == UE.ECommonInputType.Gamepad then
        self.KeyRowName = row.PadKeyRowName
      else
        self.KeyRowName = row.KMKeyRowName
      end
      self.KeyNameStyle = row.KeyNameStyle
    end
  end
end

function BP_KeyName:SetBottomOpacity(Opacity)
end

function BP_KeyName:SetTextOpacity(Opacity)
end

function BP_KeyName:SetTextColorAndOpacity(ColorAndOpacity)
  self:SetKeyTxtColorAndOpacity(ColorAndOpacity)
end

function BP_KeyName:SetIconColorAndOpacity(ColorAndOpacity)
  self.Img_KeyIcon:SetColorAndOpacity(ColorAndOpacity)
end

function BP_KeyName:Show()
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function BP_KeyName:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self.IsBind then
    EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, self.BindOnKeyChanged, self)
    self.IsBind = false
  end
end

function BP_KeyName:InitInfo()
  local IsCustomKey, RowInfo = GetRowData(DT.DT_CustomKey, self.KeyRowName)
  if IsCustomKey and not self.IsBind then
    EventSystem.AddListener(self, EventDef.GameSettings.OnKeyChanged, self.BindOnKeyChanged)
    self.IsBind = true
  end
  self:ChangeCustomKeyAppearance(self.KeyRowName)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(self.KeyNameStyle.BottomIcon) then
    local Brush = MakeBrushBySoftObj(self.KeyNameStyle.BottomIcon, self.KeyNameStyle.BottomIconSize)
    Brush.DrawAs = UE.ESlateBrushDrawType.Box
    local Margin = UE.FMargin()
    Margin.Bottom = 0.5
    Margin.Left = 0.5
    Margin.Right = 0.5
    Margin.Top = 0.5
    Brush.Margin = Margin
    self:SetBottomIcon(Brush)
  end
  if self.KeyNameStyle.TextColorAndOpacity then
    self:SetKeyTxtColorAndOpacity(self.KeyNameStyle.TextColorAndOpacity.SpecifiedColor)
  end
  self:SetBottomColorAndOpacity(self.KeyNameStyle.BottomColorAndOpacity)
end

function BP_KeyName:BindOnInputMethodChanged(InputType)
  self:UpdateRowName()
  self:ChangeCustomKeyAppearance(self.KeyRowName)
end

function BP_KeyName:ChangeCustomKeyAppearance(KeyName)
  if "None" == KeyName then
    self:SetKeyNamePanelVis(UE.ESlateVisibility.Collapsed)
    self:SetKeyIconVis(UE.ESlateVisibility.Collapsed)
    self:SetSpacerVis(UE.ESlateVisibility.Collapsed)
    self:SetImgAddVis(UE.ESlateVisibility.Collapsed)
    return
  end
  local result, row = GetRowData(DT.DT_RichTxtKeyName, self.RichTxtKeyName)
  if result then
    if row.bShowImageAdd then
      self:SetSpacerVis(UE.ESlateVisibility.SelfHitTestInvisible)
      self:SetImgAddVis(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetSpacerVis(UE.ESlateVisibility.Collapsed)
      self:SetImgAddVis(UE.ESlateVisibility.Collapsed)
    end
  end
  local KeyDisplayInfo, IsIcon = LogicGameSetting.GetCurSelectedKeyNameByKeyRowName(KeyName, self.KeyNameStyle.KeyIconUseType)
  if IsIcon then
    self:SetKeyNamePanelVis(UE.ESlateVisibility.Collapsed)
    self:SetKeyIconVis(UE.ESlateVisibility.SelfHitTestInvisible)
    local Brush = MakeBrushBySoftObj(KeyDisplayInfo, self.KeyNameStyle.IconSize)
    self:SetIcon(Brush)
  else
    self:SetKeyNamePanelVis(UE.ESlateVisibility.SelfHitTestInvisible)
    self:SetKeyIconVis(UE.ESlateVisibility.Collapsed)
    self:SetKeyName(KeyDisplayInfo)
  end
end

function BP_KeyName:BindOnKeyChanged(ChangedKeyList)
  if not table.Contain(ChangedKeyList, self.KeyRowName) then
    return
  end
  self:ChangeCustomKeyAppearance(self.KeyRowName)
end

return BP_KeyName
