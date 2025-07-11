local SkinToggle = UnLua.Class()
function SkinToggle:Construct()
end
function SkinToggle:InitSkinToggle(CurProgress, MaxProgress)
  UpdateVisibility(self, true, true)
  local progressStr = string.format("%d/%d", CurProgress, MaxProgress)
  self.RGTextUnSelectProgress:SetText(progressStr)
  self.RGTextSelectProgress:SetText(progressStr)
end
function SkinToggle:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Hover, true)
end
function SkinToggle:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Hover, false)
end
function SkinToggle:Hide()
  UpdateVisibility(self, false)
end
function SkinToggle:SetSkinToggleForStore(ImgPath, name)
  SetImageBrushByPath(self.icon_01, ImgPath)
  SetImageBrushByPath(self.icon_02, ImgPath)
  self.RGTextUnSelectName:SetText(name)
  self.RGTextSelectName:SetText(name)
  UpdateVisibility(self.RGTextUnSelectProgress, false)
  UpdateVisibility(self.RGTextSelectProgress, false)
end
return SkinToggle
