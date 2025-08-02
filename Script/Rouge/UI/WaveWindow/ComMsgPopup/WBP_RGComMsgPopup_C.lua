local WBP_RGComMsgPopup_C = UnLua.Class()
local ESlateVisibility = UE.ESlateVisibility

function WBP_RGComMsgPopup_C:SetWaveWindowParam(WaveWindowParamParam)
  self.Overridden.SetWaveWindowParam(self, WaveWindowParamParam)
  local PopupType = WaveWindowParamParam.IntParam0
  self:SetPopupType(PopupType)
  self:SetPopupData(WaveWindowParamParam)
end

function WBP_RGComMsgPopup_C:SetPopupData(WaveWindowParamParam)
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

function WBP_RGComMsgPopup_C:GetNickName()
  return tostring(self.RGEditableTextNickName:GetText())
end

function WBP_RGComMsgPopup_C:GetIsChecked()
  return self.CheckBox_Prohibt:IsChecked()
end

return WBP_RGComMsgPopup_C
