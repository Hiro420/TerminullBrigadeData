local WBP_MessageBox_C = UnLua.Class()

function WBP_MessageBox_C:Construct()
  self.ConfirmButton.OnClicked:Add(self, WBP_MessageBox_C.OnClicked_ConfirmButton)
  self.CancelButton.OnClicked:Add(self, WBP_MessageBox_C.OnClicked_CancelButton)
end

function WBP_MessageBox_C:Show(Message_Text)
  self:UpdateMessage(Message_Text)
  self:SetVisibility(UE.ESlateVisibility.Visible)
end

function WBP_MessageBox_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_MessageBox_C:OnClicked_ConfirmButton()
  self.OnConfirm:Broadcast()
  self:Hide()
end

function WBP_MessageBox_C:OnClicked_CancelButton()
  self.OnCancel:Broadcast()
  self:Hide()
end

return WBP_MessageBox_C
