local WBP_GameSettingsItemIndex = UnLua.Class()

function WBP_GameSettingsItemIndex:Show(...)
  UpdateVisibility(self, true)
  self:ChangeSelectedStatus(false)
end

function WBP_GameSettingsItemIndex:ChangeSelectedStatus(IsSelected)
  if IsSelected then
    self.Img_Fill:SetColorAndOpacity(self.SelectedColor)
  else
    self.Img_Fill:SetColorAndOpacity(self.UnSelectedColor)
  end
end

return WBP_GameSettingsItemIndex
