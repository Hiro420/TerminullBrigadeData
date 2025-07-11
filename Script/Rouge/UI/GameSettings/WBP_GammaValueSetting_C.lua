local WBP_GammaValueSetting_C = UnLua.Class()
function WBP_GammaValueSetting_C:Construct()
  self.MainSlider.OnValueChanged:Add(self, self.BindOnSliderValueChanged)
  self.Btn_TipConfirm.OnClicked:Add(self, self.BindOnTipConfirmButtonClicked)
  self.Btn_TipCancel.OnClicked:Add(self, self.BindOnTipCancelButtonClicked)
end
function WBP_GammaValueSetting_C:Show(TagName)
  self.OldViewTarget = self:GetOwningPlayer():GetViewTarget()
  self.SettingTagName = TagName
  self:ChangeCamera(true)
  local CurValue = LogicGameSetting.GetGameSettingValue(self.SettingTagName)
  self:SetSliderValue(CurValue)
  self.SaveSettingsTip:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.AddListenerNew(EventDef.GameSettings.OnPreviousKeyPressed, self, self.BindOnPreviousKeyPressed)
  EventSystem.AddListenerNew(EventDef.GameSettings.OnNextKeyPressed, self, self.BindOnNextKeyPressed)
end
function WBP_GammaValueSetting_C:ChangeCamera(IsShowSettingCamera)
  local PC = self:GetOwningPlayer()
  if not PC then
    return
  end
  local GameSettingActor = UE.UGameplayStatics.GetActorOfClass(self, self.GammaValueActorClass)
  if IsShowSettingCamera then
    if GameSettingActor then
      GameSettingActor.CanTick = true
      PC:SetViewTargetWithBlend(GameSettingActor.ChildActor.ChildActor)
    end
  else
    if GameSettingActor then
      GameSettingActor.CanTick = false
    end
    PC:SetViewTargetWithBlend(self.OldViewTarget)
  end
end
function WBP_GammaValueSetting_C:SetSliderValue(Value)
  self.MainSlider:SetValue(Value)
  self:BindOnSliderValueChanged(Value)
end
function WBP_GammaValueSetting_C:BindOnSliderValueChanged(Value)
  LogicGameSetting.SetTempGameSettingsValue(self.SettingTagName, math.floor(Value))
  LogicGameSetting.SetGammaValue(math.floor(Value))
  self.Txt_Brightness_Num:SetText(math.floor(Value))
end
function WBP_GammaValueSetting_C:BindOnPreviousKeyPressed(...)
  self:SetSliderValue(math.clamp(self.MainSlider:GetValue() - 1, self.MainSlider.MinValue, self.MainSlider.MaxValue))
end
function WBP_GammaValueSetting_C:BindOnNextKeyPressed(...)
  self:SetSliderValue(math.clamp(self.MainSlider:GetValue() + 1, self.MainSlider.MinValue, self.MainSlider.MaxValue))
end
function WBP_GammaValueSetting_C:BindOnRestoreButtonClicked()
  local SettingRowInfo = LogicGameSetting.GetSettingsRowInfo(self.SettingTagName)
  if not SettingRowInfo then
    return
  end
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  GameUserSettings:SetGameSettingByTag(SettingRowInfo.Tag, SettingRowInfo.DefaultValue)
  self:SetSliderValue(SettingRowInfo.DefaultValue)
end
function WBP_GammaValueSetting_C:BindOnTipConfirmButtonClicked()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  local TempSettingValue = LogicGameSetting.GetTempGameSettingValue(self.SettingTagName)
  if not TempSettingValue then
    print("WBP_GammaValueSetting_C:BindOnTipConfirmButtonClicked Logic is Error, not found temp Setting value!")
  else
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(self.SettingTagName, nil)
    GameUserSettings:SetGameSettingByTag(Tag, TempSettingValue)
    LogicGameSetting.SetTempGameSettingsValue(self.SettingTagName, TempSettingValue)
  end
  self:ClosePanel()
end
function WBP_GammaValueSetting_C:BindOnTipCancelButtonClicked()
  LogicGameSetting.SetTempGameSettingsValue(self.SettingTagName, LogicGameSetting.GetGameSettingValue(self.SettingTagName))
  LogicGameSetting.SetGammaValue(LogicGameSetting.GetGameSettingValue(self.SettingTagName))
  self:ClosePanel()
end
function WBP_GammaValueSetting_C:ClosePanel()
  self:ShowMainSettingWidget(self.SettingTagName)
  self:ChangeCamera(false)
  self.OldViewTarget = nil
  EventSystem.RemoveListenerNew(EventDef.GameSettings.OnPreviousKeyPressed, self, self.BindOnPreviousKeyPressed)
  EventSystem.RemoveListenerNew(EventDef.GameSettings.OnNextKeyPressed, self, self.BindOnNextKeyPressed)
end
function WBP_GammaValueSetting_C:ShowExitConfirmTip()
  local TempSettingValue = LogicGameSetting.GetTempGameSettingValue(self.SettingTagName)
  if TempSettingValue then
    self.SaveSettingsTip:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_TipConfirm:SetKeyboardFocus()
  else
    self:ClosePanel()
  end
end
return WBP_GammaValueSetting_C
