local WBP_ScrollSetTag_C = UnLua.Class()

function WBP_ScrollSetTag_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_ScrollSetTag_C:InitSetTag(AttributeModifySetRow)
  SetImageBrushBySoftObject(self.URGImageIcon, AttributeModifySetRow.SetIcon, {X = 13, Y = 13})
  self.RGTextSetName:SetText(AttributeModifySetRow.SetName)
end

function WBP_ScrollSetTag_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_ScrollSetTag_C:Destruct()
end

return WBP_ScrollSetTag_C
