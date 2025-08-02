local WBP_SingleAttributeItem_C = UnLua.Class()

function WBP_SingleAttributeItem_C:SetStatus(IsShow)
  if IsShow then
    self.Img_Fill:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Fill:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

return WBP_SingleAttributeItem_C
