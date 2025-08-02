local ListContainer = {}
local ListContainer_mt = {__index = ListContainer}

function ListContainer.New(WidgetClass, MaxNum)
  local self = setmetatable({}, ListContainer_mt)
  self:Init(WidgetClass, MaxNum)
  return self
end

function ListContainer:Init(WidgetClass, MaxNum)
  self.ChildClass = WidgetClass
  self.ClassRef = UnLua.Ref(self.ChildClass)
  self.MaxNum = MaxNum
  self.AllWidgets = {}
  self.AllUseWidgets = {}
  self.RefList = {}
end

function ListContainer:GetOrCreateItem()
  for i, SingleWidget in ipairs(self.AllWidgets) do
    if not table.Contain(self.AllUseWidgets, SingleWidget) then
      return SingleWidget
    end
  end
  return self:CreateItem()
end

function ListContainer:CreateItem()
  if not self.ChildClass then
    print("ListContainer WidgetClass is nil")
    return nil
  end
  if not self.MaxNum or table.count(self.AllWidgets) < self.MaxNum then
    local Widget = UE.UWidgetBlueprintLibrary.Create(GameInstance, self.ChildClass)
    table.insert(self.AllWidgets, Widget)
    table.insert(self.RefList, UnLua.Ref(Widget))
    Widget:SetVisibility(UE.ESlateVisibility.Collapsed)
    Widget.ListContainer = self
    return Widget
  end
  return self.AllUseWidgets[1]
end

function ListContainer:ShowItem(Item, ...)
  if not table.Contain(self.AllUseWidgets, Item) then
    table.insert(self.AllUseWidgets, Item)
  end
  if Item.Show then
    Item:Show(...)
  end
end

function ListContainer:HideItem(Item)
  if Item.Hide then
    Item:Hide()
  end
  table.RemoveItem(self.AllUseWidgets, Item)
end

function ListContainer:ClearAllUseWidgets()
  for i, SingleWidget in ipairs(self.AllUseWidgets) do
    if SingleWidget and SingleWidget:IsValid() and SingleWidget.Hide then
      SingleWidget:Hide()
    end
  end
  self.AllUseWidgets = {}
end

function ListContainer:GetAllUseWidgetsCount()
  return table.count(self.AllUseWidgets)
end

function ListContainer:GetAllWidgetsCount()
  return table.count(self.AllWidgets)
end

function ListContainer:ClearAllWidgets()
  self:ClearAllUseWidgets()
  for i, SingleWidget in ipairs(self.AllWidgets) do
    if SingleWidget:IsValid() then
      UnLua.Unref(SingleWidget)
      SingleWidget:RemoveFromParent()
    end
  end
  self.AllWidgets = {}
  self.RefList = {}
  UnLua.Unref(self.ChildClass)
  self.ClassRef = nil
end

function ListContainer:GetAllUseWidgetsList()
  return self.AllUseWidgets
end

return ListContainer
