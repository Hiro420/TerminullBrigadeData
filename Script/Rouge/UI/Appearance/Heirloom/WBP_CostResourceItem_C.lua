local WBP_CostResourceItem_C = UnLua.Class()
function WBP_CostResourceItem_C:SetCompareInfo(CostId, CostNum)
  local ResourceInfo = LogicOutsidePackback.GetResourceInfoById(CostId)
  if ResourceInfo then
    SetImageBrushByPath(self.Img_Icon, ResourceInfo.Icon, self.IconSize)
  end
  local CurResourceNum = LogicOutsidePackback.GetResourceNumById(CostId)
  self.Txt_Cost:SetText(string.format("%d/%d", CurResourceNum, CostNum))
  if CostNum > CurResourceNum then
    self.Txt_Cost:SetColorAndOpacity(self.NotEnoughColor)
  else
    self.Txt_Cost:SetColorAndOpacity(self.EnoughColor)
  end
end
return WBP_CostResourceItem_C
