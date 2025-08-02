local WBP_AttributeUpgradeItem_C = UnLua.Class()

function WBP_AttributeUpgradeItem_C:Show(AttributeName, CurAttributeValue, TargetAttributeValue)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local Result, RowInfo = DTSubsystem:GetAttributeInfoById(tonumber(AttributeName), nil)
    if Result then
      self.Txt_AttributeName:SetText(RowInfo.Name)
    end
  end
  self.Txt_CurAttributeValue:SetText(CurAttributeValue)
  self.Txt_TargetAttributeValue:SetText(TargetAttributeValue)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_AttributeUpgradeItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_AttributeUpgradeItem_C
