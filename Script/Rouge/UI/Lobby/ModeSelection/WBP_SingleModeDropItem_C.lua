local WBP_SingleModeDropItem_C = UnLua.Class()

function WBP_SingleModeDropItem_C:Show(ResourceId, DropRatio, Num)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.ResourceId = ResourceId
  self.WBP_Item:InitItem(ResourceId, Num)
  if not DropRatio then
    UpdateVisibility(self.RatioPanel, false)
  else
    UpdateVisibility(self.RatioPanel, true)
    self.Txt_RatioNum:SetText(DropRatio)
  end
end

function WBP_SingleModeDropItem_C:GetToolTipWidget()
  if not self.ItemToolTipWidget or not self.ItemToolTipWidget:IsValid() then
    self.ItemToolTipWidget = GetItemDetailWidget(self.ResourceId)
  end
  self.ItemToolTipWidget:InitCommonItemDetail(self.ResourceId)
  return self.ItemToolTipWidget
end

function WBP_SingleModeDropItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_SingleModeDropItem_C
