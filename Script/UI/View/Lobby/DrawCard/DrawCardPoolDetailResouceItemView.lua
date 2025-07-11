local DrawCardPoolDetailResouceItemView = UnLua.Class()
function DrawCardPoolDetailResouceItemView:Construct()
  self.WBP_Item.OnClicked:Add(self, self.BindOnResouceItemClicked)
  EventSystem.AddListener(self, EventDef.DrawCard.OnChangeDrawCardAppearanceActor, self.BindOnChangeDrawCardAppearanceActor)
  EventSystem.AddListener(self, EventDef.Heirloom.OnHeirloomInfoChanged, self.BindOnHeirloomInfoChanged)
  self.ParentView = nil
  self.ResourceId = nil
end
function DrawCardPoolDetailResouceItemView:Destruct()
  self.WBP_Item.OnClicked:Remove(self, self.BindOnResouceItemClicked)
  EventSystem.RemoveListener(EventDef.DrawCard.OnChangeDrawCardAppearanceActor, self.BindOnChangeDrawCardAppearanceActor, self)
  EventSystem.RemoveListener(EventDef.Heirloom.OnHeirloomInfoChanged, self.BindOnHeirloomInfoChanged, self)
  self.ParentView = nil
  self.ResourceId = nil
end
function DrawCardPoolDetailResouceItemView:OnListItemObjectSet(ListItemObj)
  self:InitInfo(ListItemObj.ResourceId, ListItemObj.ParentView)
end
function DrawCardPoolDetailResouceItemView:InitInfo(ResourceId, ParentView)
  self.ParentView = ParentView
  self.ResourceId = ResourceId
  if not ResourceId then
    return
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local DrawCardViewModel = UIModelMgr:Get("DrawCardViewModel")
  local ResourceStatus = DrawCardViewModel:CheckResIsUnLock(ResourceId)
  self.WBP_Item:InitItem(ResourceId)
  self.WBP_Item:SetSel(ParentView.ResourceId == ResourceId)
  self.WBP_Item:SetOwn(ResourceStatus)
end
function DrawCardPoolDetailResouceItemView:BindOnResouceItemClicked()
  EventSystem.Invoke(EventDef.DrawCard.OnChangeDrawCardAppearanceActor, self.ResourceId)
end
function DrawCardPoolDetailResouceItemView:BindOnChangeDrawCardAppearanceActor(ResourceId)
  self.WBP_Item:SetSel(self.ResourceId == ResourceId)
end
function DrawCardPoolDetailResouceItemView:BindOnHeirloomInfoChanged()
  if not self.ResourceId then
    print("DrawCardPoolDetailResouceItemView:BindOnHeirloomInfoChanged self.ResourceId IsNil")
    return
  end
  local DrawCardViewModel = UIModelMgr:Get("DrawCardViewModel")
  local ResourceStatus = DrawCardViewModel:CheckResIsUnLock(self.ResourceId)
  self.WBP_Item:SetOwn(ResourceStatus)
end
function DrawCardPoolDetailResouceItemView:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return DrawCardPoolDetailResouceItemView
