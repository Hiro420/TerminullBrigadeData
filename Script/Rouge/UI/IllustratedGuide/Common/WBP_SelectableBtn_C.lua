local WBP_SelectableBtn_C = UnLua.Class()
function WBP_SelectableBtn_C:ChangeStyle(Style)
  if Style == BtbStyle.Normal then
    UpdateVisibility(self.Img_Normal, true)
    UpdateVisibility(self.Img_Select, false)
  elseif Style == BtbStyle.Cover then
    UpdateVisibility(self.Img_Cover, true)
  elseif Style == BtbStyle.Select then
    UpdateVisibility(self.Img_Select, true)
    UpdateVisibility(self.Img_Normal, false)
  end
end
function WBP_SelectableBtn_C:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Img_Cover, true)
end
function WBP_SelectableBtn_C:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Img_Cover, false)
end
return WBP_SelectableBtn_C
