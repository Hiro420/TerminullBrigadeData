local WBP_LoadingPanelItem = UnLua.Class()
function WBP_LoadingPanelItem:Show(Status, IconObj)
  UpdateVisibility(self.CanvasPanel_NoPass, 1 == Status)
  UpdateVisibility(self.CanvasPanel_Current, 2 == Status)
  UpdateVisibility(self.CanvasPanel_Pass, 3 == Status)
  if 1 == Status then
    SetImageBrushBySoftObject(self.Img_IconBG, IconObj)
  elseif 2 == Status then
    SetImageBrushBySoftObject(self.Img_Current, IconObj)
  elseif 3 == Status then
    SetImageBrushBySoftObject(self.Img_Icon, IconObj)
  end
end
return WBP_LoadingPanelItem
