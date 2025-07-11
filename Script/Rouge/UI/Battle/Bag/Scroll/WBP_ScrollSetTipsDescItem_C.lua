local WBP_ScrollSetTipsDescItem_C = UnLua.Class()
function WBP_ScrollSetTipsDescItem_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_ScrollSetTipsDescItem_C:InitScrollSetTipsDescItem(bActivate, Desc, Lv)
  UpdateVisibility(self, true)
  UpdateVisibility(self.URGImageActived, bActivate)
  UpdateVisibility(self.URGImageInActived, not bActivate)
  local FinalDesc = Desc
  if Logic_Scroll.NumToZh[Lv] then
    FinalDesc = UE.FTextFormat(Logic_Scroll.NumToZh[Lv](), Desc)
  end
  self.RichTextBlockDesc:SetText(FinalDesc)
  if bActivate then
    self.RichTextBlockDesc:SetDefaultColorAndOpacity(self.ActivatedColor)
    self.RichTextBlockDesc:SetIsEnabled(true)
  else
    self.RichTextBlockDesc:SetDefaultColorAndOpacity(self.InActivatedColor)
    self.RichTextBlockDesc:SetIsEnabled(false)
  end
end
function WBP_ScrollSetTipsDescItem_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_ScrollSetTipsDescItem_C:Destruct()
end
return WBP_ScrollSetTipsDescItem_C
