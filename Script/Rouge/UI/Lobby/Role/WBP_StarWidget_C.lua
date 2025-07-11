local WBP_StarWidget_C = UnLua.Class()
function WBP_StarWidget_C:RefreshInfo(StarNum, MaxStar)
  local AllChildren = self.AttributeList:GetAllChildren()
  for Index, SingleItem in pairs(AllChildren) do
    SingleItem:SetStatus(Index <= StarNum)
    if Index <= MaxStar then
      SingleItem:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end
return WBP_StarWidget_C
