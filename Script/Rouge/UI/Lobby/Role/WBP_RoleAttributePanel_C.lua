local WBP_RoleAttributePanel_C = UnLua.Class()

function WBP_RoleAttributePanel_C:Construct()
  self.Txt_Name:SetText(tostring(self.Name))
  local OverlaySlot = UE.UWidgetLayoutLibrary.SlotAsOverlaySlot(self.Txt_Name)
  if self.IsRight then
    OverlaySlot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Right)
  else
    OverlaySlot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Left)
  end
end

function WBP_RoleAttributePanel_C:RefreshInfo(Num)
  local AllChildren = self.AttributeList:GetAllChildren()
  for Index, SingleItem in pairs(AllChildren) do
    SingleItem:SetStatus(Index <= Num)
  end
end

return WBP_RoleAttributePanel_C
