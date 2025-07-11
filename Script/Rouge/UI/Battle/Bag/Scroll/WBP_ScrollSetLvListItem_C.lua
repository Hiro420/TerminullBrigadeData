local WBP_ScrollSetLvListItem_C = UnLua.Class()
function WBP_ScrollSetLvListItem_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_ScrollSetLvListItem_C:InitSetLvListItem(CurLevel, selfLevel, bHaveNext, PreSetLv)
  UpdateVisibility(self, true)
  local Cls = self.WBP_ScrollSetLvItem:GetClass()
  local Index = 1
  for i = PreSetLv + 1, selfLevel do
    local Item = GetOrCreateItem(self.HorizontalBoxList, Index, Cls)
    Item:InitSetLvItem(CurLevel, i, false)
    Index = Index + 1
  end
  if bHaveNext then
    local Item = GetOrCreateItem(self.HorizontalBoxList, Index, Cls)
    Item:InitSetLvItem(CurLevel, selfLevel, true)
    Index = Index + 1
  end
  HideOtherItem(self.HorizontalBoxList, Index)
end
function WBP_ScrollSetLvListItem_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_ScrollSetLvListItem_C:Destruct()
end
return WBP_ScrollSetLvListItem_C
