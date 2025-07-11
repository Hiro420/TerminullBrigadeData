local WBP_ScrollItemSlotLikeTipsView = UnLua.Class()
function WBP_ScrollItemSlotLikeTipsView:Construct()
  self.Overridden.Construct(self)
  self.LikeUserIdList = {}
end
function WBP_ScrollItemSlotLikeTipsView:LikeByUserId(UserId)
  self.Overridden.Construct(self)
  if table.Contain(self.LikeUserIdList, UserId) then
    print("WBP_ScrollItemSlotLikeTipsView:LikeByUser: Already liked.")
    return
  end
  table.insert(self.LikeUserIdList, UserId)
  self:UpdateUIByLike()
end
function WBP_ScrollItemSlotLikeTipsView:UnLikeByUserId(UserId)
  self.Overridden.Construct(self)
  if not table.Contain(self.LikeUserIdList, UserId) then
    print("WBP_ScrollItemSlotLikeTipsView:UnLikeByUser: Not liked.")
    return
  end
  for i, v in ipairs(self.LikeUserIdList) do
    if v == UserId then
      table.remove(self.LikeUserIdList, i)
      break
    end
  end
  self:UpdateUIByLike()
end
function WBP_ScrollItemSlotLikeTipsView:CheckLikeByUserId(UserId)
  self.Overridden.Construct(self)
  if table.Contain(self.LikeUserIdList, UserId) then
    return true
  end
  return false
end
function WBP_ScrollItemSlotLikeTipsView:UpdateUIByLike()
  if not self.LikeUserIdList or 0 == #self.LikeUserIdList then
    self.CanvasPanel_Like:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_Like:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if self.LikeUserIdList[1] then
      self.CanvasPanel_First:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Image_First:SetColorAndOpacity(UE.FLinearColor(1, 0, 1, 1))
      self.Image_FirstBottom:SetColorAndOpacity(UE.FLinearColor(1, 0, 1, 1))
      self.CanvasPanel_Second:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    if self.LikeUserIdList[2] then
      self.CanvasPanel_Second:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Image_Second:SetColorAndOpacity(UE.FLinearColor(1, 0, 0, 1))
    end
  end
end
function WBP_ScrollItemSlotLikeTipsView:Destruct()
  self.LikeUserIdList = nil
end
return WBP_ScrollItemSlotLikeTipsView
