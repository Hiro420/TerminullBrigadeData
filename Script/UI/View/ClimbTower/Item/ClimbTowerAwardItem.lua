local ClimbTowerAwardItem = UnLua.Class()
function ClimbTowerAwardItem:InitAwardItem(Item)
  self.WBP_Item:InitItem(Item.Id)
  UpdateVisibility(self.FirstPassPanel, Item.bFirstWinReward)
  if Item.bFirstWinReward then
    UpdateVisibility(self.RatioPanel, false)
  else
    UpdateVisibility(self.RatioPanel, Item.MarkStr ~= "")
  end
  UpdateVisibility(self.Completed, Item.bReceive)
  self.Txt_RatioNum:SetText(Item.MarkStr)
  UpdateVisibility(self.Txt_Num, Item.Num > 0)
  self.Txt_Num:SetText(Item.Num)
end
return ClimbTowerAwardItem
