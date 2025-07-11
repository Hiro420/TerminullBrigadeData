local WBP_RGPickupScrollWaveWindow_C = UnLua.Class()
function WBP_RGPickupScrollWaveWindow_C:JudgeCanShow()
  local time = UE.UGameplayStatics.GetRealTimeSeconds(self)
  local ReasonTime = self:GetOwningPlayerPawn().OnPawnAcknowTime
  if time - ReasonTime <= 10 then
    print("[#LJS:\230\184\184\230\136\143\230\151\182\233\151\180\229\176\143\228\186\142\228\184\164\231\167\146\239\188\140\228\184\141\230\152\190\231\164\186\229\175\134\229\141\183\229\136\157\229\167\139\229\140\150\229\188\185\231\170\151]")
    self:SetVisibility(UE.ESlateVisibility.Hidden)
    EventSystem.Invoke(EventDef.PickTipList.HidePickTipItem, self)
    return
  end
end
function WBP_RGPickupScrollWaveWindow_C:Show(ScrollId)
  self:JudgeCanShow()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_RGPickupScrollWaveWindow_C:Show not DTSubsystem")
    return nil
  end
  local TargetColor
  local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(ScrollId, nil)
  if ResultModify then
    local Size = {X = 70, Y = 70}
    SetImageBrushBySoftObject(self.Img_Icon, AttributeModifyRow.SpriteIcon, Size)
    self.Txt_Name:SetText(AttributeModifyRow.Name)
    local ResultItemRarity, ItemRarityRow = DTSubsystem:GetItemRarityTableRow(AttributeModifyRow.Rarity, nil)
    if ResultItemRarity then
      TargetColor = ItemRarityRow.PickupItemColor
    end
  end
  TargetColor = TargetColor or self.DefaultBottomPanelColor
  self.Img_BottomPanel:SetColorAndOpacity(TargetColor)
  self.Img_QualityDecoration:SetColorAndOpacity(TargetColor)
end
function WBP_RGPickupScrollWaveWindow_C:PlayFadeInWidgetAnim()
  self:PlayAnimationForward(self.StartAnim)
end
function WBP_RGPickupScrollWaveWindow_C:PlayRemoveWidgetAnim()
  self:PlayAnimation(self.FadeOutAnim)
end
function WBP_RGPickupScrollWaveWindow_C:OnAnimationFinished(Animation)
  if self.FadeOutAnim == Animation then
    EventSystem.Invoke(EventDef.PickTipList.HidePickTipItem, self)
  end
end
function WBP_RGPickupScrollWaveWindow_C:Destruct()
  self.Overridden.Destruct(self)
end
function WBP_RGPickupScrollWaveWindow_C:Hide()
end
return WBP_RGPickupScrollWaveWindow_C
