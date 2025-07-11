local WBP_GameSettingsTitleButton_C = UnLua.Class()
function WBP_GameSettingsTitleButton_C:Construct()
  self.Btn_Main.OnClicked:Add(self, WBP_GameSettingsTitleButton_C.BindOnMainButtonClicked)
end
function WBP_GameSettingsTitleButton_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.GameSettings.OnTitleButtonClicked, self.TagName)
end
function WBP_GameSettingsTitleButton_C:Show(TagName)
  self.TagName = TagName
  local LabelRowInfo = LogicGameSetting.GetLabelRowInfo(self.TagName)
  if not LabelRowInfo then
    return
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Name:SetText(LabelRowInfo.Name)
  EventSystem.AddListener(self, EventDef.GameSettings.OnTitleButtonClicked, WBP_GameSettingsTitleButton_C.BindOnTitleButtonClicked)
end
function WBP_GameSettingsTitleButton_C:BindOnTitleButtonClicked(TagName, IsNeedFocus)
  if TagName == self.TagName then
    self.SelectedPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.UnSelectedPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_Name:SetColorAndOpacity(self.SelectedTextColor)
    self:PlayAnimation(self.AnI_click, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
    if IsNeedFocus and not self.IsFocus then
      self:SetKeyboardFocus()
    end
  else
    self.SelectedPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.UnSelectedPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_Name:SetColorAndOpacity(self.UnSelectedTextColor)
  end
end
function WBP_GameSettingsTitleButton_C:OnAddedToFocusPath(...)
  self.IsFocus = true
  EventSystem.Invoke(EventDef.GameSettings.OnTitleButtonClicked, self.TagName, true)
end
function WBP_GameSettingsTitleButton_C:OnRemovedFromFocusPath(...)
  self.IsFocus = false
end
function WBP_GameSettingsTitleButton_C:RemoveEventListener()
  EventSystem.RemoveListener(EventDef.GameSettings.OnTitleButtonClicked, WBP_GameSettingsTitleButton_C.BindOnTitleButtonClicked, self)
end
function WBP_GameSettingsTitleButton_C:Hide()
  self.TagName = nil
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:RemoveEventListener()
end
function WBP_GameSettingsTitleButton_C:Destruct()
  self:RemoveEventListener()
end
return WBP_GameSettingsTitleButton_C
