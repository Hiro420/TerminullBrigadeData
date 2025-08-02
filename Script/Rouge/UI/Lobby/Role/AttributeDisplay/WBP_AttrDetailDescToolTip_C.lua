local WBP_AttrDetailDescToolTip_C = UnLua.Class()

function WBP_AttrDetailDescToolTip_C:RefreshInfo(RowData)
  self.Txt_Name:SetText(RowData.DisplayNameInUI)
  self.Txt_Desc:SetText(RowData.DetailDesc)
end

return WBP_AttrDetailDescToolTip_C
