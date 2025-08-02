local WBP_ModLevel_C = UnLua.Class()

function WBP_ModLevel_C:UpdateActiveInfo(Show)
  if Show then
    self.Image_ModLevel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_ModLevel:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

return WBP_ModLevel_C
