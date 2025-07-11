local HeteromorphismItem = UnLua.Class()
function HeteromorphismItem:SetHeteromorphismInfo(Info)
  SetImageBrushByPath(self.Img_Icon, Info.Icon)
  self.RichText:SetText(Info.Name)
end
return HeteromorphismItem
