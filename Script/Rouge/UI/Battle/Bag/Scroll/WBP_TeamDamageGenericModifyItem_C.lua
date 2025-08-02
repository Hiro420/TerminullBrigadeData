local WBP_TeamDamageGenericModifyItem_C = UnLua.Class()

function WBP_TeamDamageGenericModifyItem_C:Construct()
  self.Overridden.Construct(self)
  EventSystem.AddListenerNew(EventDef.TeamDamage.OnUpdateHoverStatus, self, self.BindOnUpdateHoverStatus)
end

function WBP_TeamDamageGenericModifyItem_C:OnListItemObjectSet(ListItemObj)
  self.Index = ListItemObj.Index
  self.UserId = ListItemObj.UserId
  self.WBP_BagRoleGenericItem:InitBagRoleGenericItem(ListItemObj.ModifyData, UE.ERGGenericModifySlot.None, ListItemObj.UpdateGenericModifyTips, ListItemObj.ParentView, nil, self)
  self:SetNavigationRuleCustom(UE.EUINavigation.Left, {
    ListItemObj.ParentView,
    ListItemObj.ParentView.BindOnNavigation
  })
  self:SetNavigationRuleCustom(UE.EUINavigation.Right, {
    ListItemObj.ParentView,
    ListItemObj.ParentView.BindOnNavigation
  })
  self:SetNavigationRuleCustom(UE.EUINavigation.Up, {
    ListItemObj.ParentView,
    ListItemObj.ParentView.BindOnNavigation
  })
  self:SetNavigationRuleCustom(UE.EUINavigation.Down, {
    ListItemObj.ParentView,
    ListItemObj.ParentView.BindOnNavigation
  })
end

function WBP_TeamDamageGenericModifyItem_C:Destruct()
  EventSystem.RemoveListenerNew(EventDef.TeamDamage.OnUpdateHoverStatus, self, self.BindOnUpdateHoverStatus)
end

function WBP_TeamDamageGenericModifyItem_C:OnAddedToFocusPath(...)
  self.WBP_BagRoleGenericItem:OnMouseEnter()
end

function WBP_TeamDamageGenericModifyItem_C:OnRemovedFromFocusPath(...)
  self.WBP_BagRoleGenericItem:OnMouseLeave()
end

function WBP_TeamDamageGenericModifyItem_C:BindOnUpdateHoverStatus(UserId, AttributeModifyIndex, GenericModifyIndex)
  if tonumber(self.UserId) == tonumber(UserId) and self.Index == GenericModifyIndex then
    self:SetKeyboardFocus()
  end
end

return WBP_TeamDamageGenericModifyItem_C
