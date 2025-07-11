local WBP_Shop_Equipment_Props_C = UnLua.Class()
function WBP_Shop_Equipment_Props_C:Construct()
  self:UpdateScrollList()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    Character.AttributeModifyComponent.OnAddModify:Add(self, self.UpdateScrollList)
    Character.AttributeModifyComponent.OnRemoveModify:Add(self, self.UpdateScrollList)
  end
end
function WBP_Shop_Equipment_Props_C:UpdateScrollList()
  self:UpdateScrollTips(false)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    local ScrollItemCls = UE.UClass.Load("/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollItemSlot.WBP_ScrollItemSlot_C")
    self.ScrollMap = {}
    local Index = 1
    for i, v in iterator(Character.AttributeModifyComponent.ActivatedModifies) do
      local ScrollItem
      if i > 4 then
        ScrollItem = GetOrCreateItem(self.WrapBoxScroll_1, Index - 4, ScrollItemCls)
      else
        ScrollItem = GetOrCreateItem(self.WrapBoxScroll, Index, ScrollItemCls)
      end
      if ScrollItem then
        UpdateVisibility(ScrollItem, true)
        ScrollItem:UpdateScrollData(v, self.UpdateScrollTips, self, Index)
        UpdateVisibility(ScrollItem.WBP_DragDropItem, false, false)
        if self.CurSelectIndex == Index then
          self:UpdateScrollTips(true, v, self.CurSelectIndex)
        end
        if self.ScrollMap[v] then
          table.insert(self.ScrollMap[v], ScrollItem)
        else
          self.ScrollMap[v] = {ScrollItem}
        end
        Index = Index + 1
        UpdateVisibility(ScrollItem.WBP_ScrollItem, true, false)
      end
    end
    if Index > 4 then
      HideOtherItem(self.WrapBoxScroll_1, Index - 4, true)
    else
      HideOtherItem(self.WrapBoxScroll, Index, true)
      HideOtherItem(self.WrapBoxScroll_1, 1, true)
    end
  end
end
function WBP_Shop_Equipment_Props_C:UpdateScrollTips(bIsShow, ModifyId, Item)
  if bIsShow then
    self.WBP_ScrollPickUpTipsView:Show(false)
    if Item then
      ShowCommonTips(nil, Item, self.WBP_ScrollPickUpTipsView)
    end
  else
    self.WBP_ScrollPickUpTipsView:Hide()
    return
  end
  if self.WBP_ScrollPickUpTipsView.Slot then
    local X = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self).X + 300
    local Position = self.WBP_ScrollPickUpTipsView.Slot:GetPosition()
    Position.X = X
    self.WBP_ScrollPickUpTipsView.Slot:SetPosition(Position)
  end
  self.WBP_ScrollPickUpTipsView:InitScrollTipsView(ModifyId, EScrollTipsOpenType.EFromShop)
end
return WBP_Shop_Equipment_Props_C
