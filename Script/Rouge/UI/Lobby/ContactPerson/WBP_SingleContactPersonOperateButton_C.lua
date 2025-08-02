local WBP_SingleContactPersonOperateButton_C = UnLua.Class()

function WBP_SingleContactPersonOperateButton_C:Construct()
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end

function WBP_SingleContactPersonOperateButton_C:BindOnMainButtonHovered()
  UpdateVisibility(self.HoveredPanel, true)
end

function WBP_SingleContactPersonOperateButton_C:BindOnMainButtonUnhovered()
  UpdateVisibility(self.HoveredPanel, false)
end

return WBP_SingleContactPersonOperateButton_C
