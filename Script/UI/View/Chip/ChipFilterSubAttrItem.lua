local ChipFilterSubAttrItem = UnLua.Class()
function ChipFilterSubAttrItem:Construct()
  self.BP_ButtonWithSoundSelect.OnClicked:Add(self, self.OnSelectClick)
end
function ChipFilterSubAttrItem:Destruct()
  self.BP_ButtonWithSoundSelect.OnClicked:Remove(self, self.OnSelectClick)
end
function ChipFilterSubAttrItem:InitChipFilterMainAttrItem(AttrId, Desc, bSelect, ParentView, idx)
  self.ParentView = ParentView
  self.bSelect = bSelect
  self.AttrId = AttrId
  UpdateVisibility(self, true)
  self.RGTextDesc:SetText(Desc)
  if bSelect then
    print("InitChipFilterSubAttrItem", idx, AttrId)
    self.RGTextIndex:SetText(idx)
    self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
  else
    self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
  end
end
function ChipFilterSubAttrItem:Hide()
  UpdateVisibility(self, false)
  self.ParentView = nil
  self.bSelect = false
  self.AttrId = nil
end
function ChipFilterSubAttrItem:OnSelectClick()
  if self.ParentView then
    local operatorSucc = self.ParentView:SelectSubAttrFilter(not self.bSelect, self.AttrId)
    if operatorSucc then
      self.bSelect = not self.bSelect
      if self.bSelect then
        local filterNum = self.ParentView:GetSubAttrFilterSelectIdx(self.AttrId)
        self.RGTextIndex:SetText(filterNum)
        self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
      else
        self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
      end
    end
  end
end
function ChipFilterSubAttrItem:OnMouseEnter()
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end
function ChipFilterSubAttrItem:OnMouseLeave()
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end
return ChipFilterSubAttrItem
