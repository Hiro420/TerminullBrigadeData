local WBP_ComboItem_C = UnLua.Class()

function WBP_ComboItem_C:Show(InText, CurSelectedOption)
  self.Txt_OptionName:SetText(InText)
  self.Option = tostring(InText)
end

function WBP_ComboItem_C:RefreshSelectedStatus(SelectedOption)
  if self.Option == SelectedOption then
    self.Txt_OptionName:SetColorAndOpacity(self.SelectedColor)
  else
    self.Txt_OptionName:SetColorAndOpacity(self.UnSelectedColor)
  end
end

function WBP_ComboItem_C:RefreshEnableStatus(IsEnabled)
  if IsEnabled then
    self.RGStateController_disableColor:ChangeStatus("Normal")
  else
    self.RGStateController_disableColor:ChangeStatus("Disable")
  end
end

return WBP_ComboItem_C
