local WBP_ScrollDescItem_C = UnLua.Class()

function WBP_ScrollDescItem_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_ScrollDescItem_C:InitScrollDescItem(Desc)
  UpdateVisibility(self, true)
  self.RichTextBlockDesc:SetText(Desc)
end

function WBP_ScrollDescItem_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_ScrollDescItem_C:Destruct()
end

return WBP_ScrollDescItem_C
