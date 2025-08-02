local WBP_GRFetterBox_C = UnLua.Class()

function WBP_GRFetterBox_C:Construct()
  self.wbp_GRFetterItemClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/GameRecord/Fetter/WBP_GRFetterItem.WBP_GRFetterItem_C")
end

function WBP_GRFetterBox_C:UpdateGRFetterBox(CurrentFetterData)
  if not CurrentFetterData then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local number = table.count(CurrentFetterData)
  if number <= 0 then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local padding = UE.FMargin()
  padding.Top = 5
  UpdateWidgetContainerByClass(self.VerticalBox_GRFetterBox, number, self.wbp_GRFetterItemClass, padding, self, self:GetOwningPlayer())
  local widgetArray = self.VerticalBox_GRFetterBox:GetAllChildren()
  for key, value in pairs(CurrentFetterData) do
    if widgetArray:IsValidIndex(key) then
      widgetArray:Get(key):UpdateGRFetterItem(value)
    end
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

return WBP_GRFetterBox_C
