local WBP_RecruitComboItem_C = UnLua.Class()
function WBP_RecruitComboItem_C:Show(InText)
  self.Txt_OptionName:SetText(InText)
  self.Option = tostring(InText)
end
function WBP_RecruitComboItem_C:SetLock()
  UpdateVisibility(self.Panel_Lock, true)
end
return WBP_RecruitComboItem_C
