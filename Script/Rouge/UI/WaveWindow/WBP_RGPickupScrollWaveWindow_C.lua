local WBP_RGPickupScrollWaveWindow_C = UnLua.Class()

function WBP_RGPickupScrollWaveWindow_C:JudgeCanShow()
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
