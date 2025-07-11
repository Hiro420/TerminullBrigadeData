local WBP_Selector_C = UnLua.Class()
function WBP_Selector_C:InitSelector(Length, SelIndex, OnChangeFunC)
  self.MaxLeng = Length
  self.Index = SelIndex
  self.OnChangeFunC = OnChangeFunC
  self.HorizontalBox:ClearChildren()
  for i = 1, Length do
    local ItemWidget = GetOrCreateItem(self.HorizontalBox, i, self.WBP_Selector_Item:GetClass())
    ItemWidget.Index = i
    ItemWidget.Btn.OnClicked:Clear()
    ItemWidget.Btn.OnClicked:Add(self, function()
      self:SetSelectByIndex(ItemWidget.Index)
    end)
    self:SelectedItemWidget(ItemWidget, ItemWidget.Index == SelIndex)
    ItemWidget.Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Center)
    ItemWidget.Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Center)
  end
  HideOtherItem(self.HorizontalBox, Length)
end
function WBP_Selector_C:SelectedItemWidget(ItemWidget, bSel)
  if self.LastWidget and false ~= bSel then
    UpdateVisibility(self.LastWidget.Image_Sel, false)
  end
  if ItemWidget then
    UpdateVisibility(ItemWidget.Image_Sel, bSel)
    if bSel then
      self.LastWidget = ItemWidget
    end
  end
end
function WBP_Selector_C:CheckIndex()
  if self.Index <= 0 then
    self.Index = self.MaxLeng
  end
  if self.Index > self.MaxLeng then
    self.Index = 1
  end
end
function WBP_Selector_C:SetSelectByIndex(Index)
  self.Index = Index
  self:CheckIndex()
  local TargetItem = self.HorizontalBox:GetChildAt(self.Index - 1)
  if TargetItem then
    self:SelectedItemWidget(TargetItem, true)
    if self.OnChangeFunC then
      self.OnChangeFunC(self.Index)
    end
  end
end
return WBP_Selector_C
