local WBP_RGComMsgPopup_Type1_C = UnLua.Class()
local ESlateVisibility = UE.ESlateVisibility

function WBP_RGComMsgPopup_Type1_C:SetWaveWindowParam(WaveWindowParamParam)
  self.Overridden.SetWaveWindowParam(self, WaveWindowParamParam)
  local PopupType = WaveWindowParamParam.IntParam0
  self:SetPopupType(PopupType)
  self:SetPopupData(WaveWindowParamParam)
end

function WBP_RGComMsgPopup_Type1_C:SetPopupType(PopupType)
  local SelfHitTestInvisible = ESlateVisibility.SelfHitTestInvisible
  local Collapsed = ESlateVisibility.Collapsed
  local Visible = ESlateVisibility.Visible
  local TypeEnum = UE.EComMsgPopupStateType
  self.Txt_Info:SetVisibility(PopupType == TypeEnum.Default and SelfHitTestInvisible or Collapsed)
  self.ScaleBox_EditableText:SetVisibility(PopupType == TypeEnum.EditText and SelfHitTestInvisible or Collapsed)
  self.RGEditableTextNickName:SetVisibility(PopupType == TypeEnum.EditText and Visible or Collapsed)
  self.WBP_AwardItem:SetVisibility(PopupType == TypeEnum.AwardPopup and SelfHitTestInvisible or Collapsed)
  local bIsShowCheckBox = PopupType == TypeEnum.MoreTextWithCheck or PopupType == TypeEnum.AwardPopup
  self.CheckBox_Prohibt:SetVisibility(bIsShowCheckBox and Visible or Collapsed)
  local bIsShowMoreText = PopupType ~= TypeEnum.Default and PopupType ~= TypeEnum.EditText
  self.Txt_MoreInfo:SetVisibility(bIsShowMoreText and SelfHitTestInvisible or Collapsed)
end

function WBP_RGComMsgPopup_Type1_C:SetPopupData(WaveWindowParamParam)
  local PopupType = WaveWindowParamParam.IntParam0
  local MoreInfo = WaveWindowParamParam.StringParam0
  if PopupType == UE.EComMsgPopupStateType.Default or PopupType == UE.EComMsgPopupStateType.EditText then
    return
  elseif PopupType == UE.EComMsgPopupStateType.MoreText or PopupType == UE.EComMsgPopupStateType.MoreTextWithCheck then
    self.Txt_MoreInfo:SetText(MoreInfo)
  elseif PopupType == UE.EComMsgPopupStateType.AwardPopup then
    self.Txt_MoreInfo:SetText(MoreInfo)
    self.WBP_AwardItem:Show(5018)
  end
end

function WBP_RGComMsgPopup_Type1_C:GetNickName()
  return tostring(self.RGEditableTextNickName:GetText())
end

function WBP_RGComMsgPopup_Type1_C:GetIsChecked()
  return self.CheckBox_Prohibt:IsChecked()
end

return WBP_RGComMsgPopup_Type1_C
