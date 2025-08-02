local WBP_TabSecond_C = UnLua.Class()

function WBP_TabSecond_C:BindOnClicked(Obj, Callback)
  self.Button_Clicked.OnClicked:Clear()
  self.Button_Clicked.OnClicked:Add(Obj, Callback)
end

function WBP_TabSecond_C:SetSelect(bSel)
  UpdateVisibility(self.HorizontalBox_1, bSel)
  UpdateVisibility(self.CanvasPanel_403, bSel)
  UpdateVisibility(self.HorizontalBox_0, not bSel)
  if bSel then
    self:PlayAnimation(self.Ani_Clicked)
  end
end

return WBP_TabSecond_C
