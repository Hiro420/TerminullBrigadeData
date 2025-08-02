local WBP_SingleRoleIcon_C = UnLua.Class()

function WBP_SingleRoleIcon_C:ShowPlayerIcon(Show)
  if Show then
    self.Image_Icon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Icon:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

return WBP_SingleRoleIcon_C
