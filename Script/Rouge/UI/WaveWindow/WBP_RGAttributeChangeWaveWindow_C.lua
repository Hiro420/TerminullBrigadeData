local WBP_RGAttributeChangeWaveWindow_C = UnLua.Class()
local MaxNum = 4
function WBP_RGAttributeChangeWaveWindow_C:JudgeCanShow()
  local character = self:GetOwningPlayerPawn()
  if not character or not character:IsValid() then
    return
  end
  local time = UE.UGameplayStatics.GetRealTimeSeconds(self)
  local ReasonTime = self:GetOwningPlayerPawn().OnPawnAcknowTime
  if time - ReasonTime <= 10 then
    print("[#LJS:\230\184\184\230\136\143\230\151\182\233\151\180\229\176\143\228\186\142\228\184\164\231\167\146\239\188\140\228\184\141\230\152\190\231\164\186\229\175\134\229\141\183\229\136\157\229\167\139\229\140\150\229\188\185\231\170\151]")
    self:SetVisibility(UE.ESlateVisibility.Hidden)
    EventSystem.Invoke(EventDef.PickTipList.HidePickTipItem, self)
    return
  end
end
function WBP_RGAttributeChangeWaveWindow_C:PlayFadeInWidgetAnim()
  self:PlayAnimationForward(self.StartAnim)
end
function WBP_RGAttributeChangeWaveWindow_C:SetWaveWindowParam(WaveWindowParamParam)
  self:JudgeCanShow()
  self.Overridden.SetWaveWindowParam(self, WaveWindowParamParam)
  local AttributeChangeTipsData = UE.FAttributeChangeTipsData()
  AttributeChangeTipsData.AttributeChangeTipsId = WaveWindowParamParam.IntParam0
  AttributeChangeTipsData.OldValue = WaveWindowParamParam.FloatParam0
  AttributeChangeTipsData.NewValue = WaveWindowParamParam.FloatParam1
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_RGAttributeChangeWaveWindow_C:SetWaveWindowParam not DTSubsystem")
    return nil
  end
  local Result, AttributeChangeTipsRow = DTSubsystem:GetAttributeChangeTipsTableRow(AttributeChangeTipsData.AttributeChangeTipsId, nil)
  if Result then
    local Desc = ""
    if AttributeChangeTipsRow.AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Default then
      Desc = string.format("%s %.2f%s \226\134\146 <%s>%.2f%s</>", AttributeChangeTipsRow.DisplayNameInUI, AttributeChangeTipsData.OldValue, AttributeChangeTipsRow.Unit, AttributeChangeTipsRow.RichTextFormat, AttributeChangeTipsData.NewValue, AttributeChangeTipsRow.Unit)
    elseif AttributeChangeTipsRow.AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Integer then
      Desc = string.format("%s %d%s \226\134\146 <%s>%d%s</>", AttributeChangeTipsRow.DisplayNameInUI, UE.UKismetMathLibrary.Round(AttributeChangeTipsData.OldValue), AttributeChangeTipsRow.Unit, AttributeChangeTipsRow.RichTextFormat, UE.UKismetMathLibrary.Round(AttributeChangeTipsData.NewValue), AttributeChangeTipsRow.Unit)
    elseif AttributeChangeTipsRow.AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Percent then
      Desc = string.format("%s %.2f%% \226\134\146 <%s>%.2f%%</>", AttributeChangeTipsRow.DisplayNameInUI, AttributeChangeTipsData.OldValue * 100, AttributeChangeTipsRow.RichTextFormat, AttributeChangeTipsData.NewValue * 100)
    elseif AttributeChangeTipsRow.AttributeDisplayType == UE.ERGAttributeDisplayType.DT_Reciprocal then
      Desc = string.format("%s %f%s \226\134\146 <%s>%f%s</>", AttributeChangeTipsRow.DisplayNameInUI, 1 / AttributeChangeTipsData.OldValue, AttributeChangeTipsRow.Unit, AttributeChangeTipsRow.RichTextFormat, 1 / AttributeChangeTipsData.NewValue, AttributeChangeTipsRow.Unit)
    elseif AttributeChangeTipsRow.AttributeDisplayType == UE.ERGAttributeDisplayType.DT_ReciprocalInteger then
      Desc = string.format("%s %d%s \226\134\146 <%s>%d%s</>", AttributeChangeTipsRow.DisplayNameInUI, UE.UKismetMathLibrary.Round(AttributeChangeTipsData.OldValue), AttributeChangeTipsRow.Unit, AttributeChangeTipsRow.RichTextFormat, UE.UKismetMathLibrary.Round(AttributeChangeTipsData.NewValue), AttributeChangeTipsRow.Unit)
    end
    self.RichTextInfo:SetText(Desc)
  end
end
function WBP_RGAttributeChangeWaveWindow_C:Destruct()
  self.Overridden.Destruct(self)
end
function WBP_RGAttributeChangeWaveWindow_C:PlayRemoveWidgetAnim()
  self:PlayAnimationForward(self.FadeOutAnim)
end
function WBP_RGAttributeChangeWaveWindow_C:OnAnimationFinished(Animation)
  if self.FadeOutAnim == Animation then
    EventSystem.Invoke(EventDef.PickTipList.HidePickTipItem, self)
  end
end
return WBP_RGAttributeChangeWaveWindow_C
