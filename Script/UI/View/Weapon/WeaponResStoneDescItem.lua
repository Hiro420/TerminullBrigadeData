local WeaponResStoneDescItem = UnLua.Class()
function WeaponResStoneDescItem:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.WeaponInfo = nil
end
return WeaponResStoneDescItem
