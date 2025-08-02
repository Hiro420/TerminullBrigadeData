local WBP_GRFetterIcon_C = UnLua.Class()

function WBP_GRFetterIcon_C:UpdateGRFetterIcon(IconPath, Level)
  SetImageBrushByPath(self.Image_FetterIcon, IconPath)
  self.TextBlock_Level:SetText(tostring(Level))
end

return WBP_GRFetterIcon_C
