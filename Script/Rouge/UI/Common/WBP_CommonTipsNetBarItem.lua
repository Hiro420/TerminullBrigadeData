local WBP_CommonTipsNetBarItem = UnLua.Class()

function WBP_CommonTipsNetBarItem:UpdatePanel(ConfigData)
  if self.Image_Icon then
    SetImageBrushByPath(self.Image_Icon, ConfigData.Icon, self.Image_Icon.Brush.ImageSize)
  end
  if self.Txt_Name then
    self.Txt_Name:SetText(ConfigData.Name)
  end
  if self.Txt_Count then
    self.Txt_Count:SetText(ConfigData.RewardDes)
  end
  if self.Txt_Des then
    self.Txt_Des:SetText(ConfigData.Des)
  end
end

return WBP_CommonTipsNetBarItem
