local BattlePassGroupItem = UnLua.Class()

function BattlePassGroupItem:InitGroupItem(Name, ID)
  self.Txt_GroupName:SetText(Name)
  self.TaskGroupID = ID
  self.WBP_RedDotView:ChangeRedDotIdByTag(ID)
end

function BattlePassGroupItem:OnToggleStateChanged(bSel, Index)
  if bSel then
    self.RGStateControllerSelect:ChangeStatus("Select", true)
  else
    self.RGStateControllerSelect:ChangeStatus("UnSelect", true)
  end
end

function BattlePassGroupItem:OnMouseEnter(MyGeometry, MouseEvent)
  self:PlayAnimation(self.Ani_hover_in)
end

function BattlePassGroupItem:OnMouseLeave(MyGeometry, MouseEvent)
  self:PlayAnimation(self.Ani_hover_out)
end

return BattlePassGroupItem
