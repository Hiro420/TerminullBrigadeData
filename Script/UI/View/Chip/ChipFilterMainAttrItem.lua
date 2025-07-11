local ChipFilterMainAttrItem = UnLua.Class()
function ChipFilterMainAttrItem:Construct()
  self.BP_ButtonWithSoundSelect.OnClicked:Add(self, self.OnSelectClick)
end
function ChipFilterMainAttrItem:Destruct()
  self.BP_ButtonWithSoundSelect.OnClicked:Remove(self, self.OnSelectClick)
end
function ChipFilterMainAttrItem:InitChipFilterMainAttrItem(AttrId, Desc, bSelect, ParentView, idx)
  self.ParentView = ParentView
  self.bSelect = bSelect
  self.AttrId = AttrId
  UpdateVisibility(self, true)
  self.RGTextDesc:SetText(Desc)
  if bSelect then
    print("InitChipFilterMainAttrItem", idx, AttrId)
    self.RGTextIndex:SetText(idx)
    self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
  else
    self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
  end
end
function ChipFilterMainAttrItem:Hide()
  UpdateVisibility(self, false)
  self.ParentView = nil
  self.bSelect = false
  self.AttrId = nil
end
function ChipFilterMainAttrItem:OnSelectClick()
  if self.ParentView then
    local operatorSucc = self.ParentView:SelectMainAttrFilter(not self.bSelect, self.AttrId)
    if operatorSucc then
      self.bSelect = not self.bSelect
      if self.bSelect then
        local filterNum = self.ParentView:GetMainAttrFilterSelectIdx(self.AttrId)
        self.RGTextIndex:SetText(filterNum)
        self.RGStateControllerSelect:ChangeStatus(ESelect.Select)
      else
        self.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
      end
    end
  end
end
function ChipFilterMainAttrItem:OnMouseEnter()
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end
function ChipFilterMainAttrItem:OnMouseLeave()
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end
return ChipFilterMainAttrItem
