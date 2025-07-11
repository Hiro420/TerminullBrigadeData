local WBP_CommonButton = UnLua.Class()
function WBP_CommonButton:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end
function WBP_CommonButton:BindOnMainButtonClicked(...)
  self.OnMainButtonClicked:Broadcast()
end
function WBP_CommonButton:BindOnMainButtonHovered(...)
  self.OnMainButtonHovered:Broadcast()
end
function WBP_CommonButton:BindOnMainButtonUnhovered(...)
  self.OnMainButtonUnhovered:Broadcast()
end
function WBP_CommonButton:SetCanChangeHoverContentColor(InCanChangeHoverContentColor)
  self.CanChangeHoverContentColor = InCanChangeHoverContentColor
end
function WBP_CommonButton:Destruct(...)
  self.Btn_Main.OnClicked:Remove(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Remove(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Remove(self, self.BindOnMainButtonUnhovered)
end
return WBP_CommonButton
