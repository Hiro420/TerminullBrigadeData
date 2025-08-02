local WBP_InteractNormalWidget_C = UnLua.Class()

function WBP_InteractNormalWidget_C:Construct()
end

function WBP_InteractNormalWidget_C:Destruct()
end

function WBP_InteractNormalWidget_C:UpdateInteractInfo(InteractTipRow)
  self.Txt_InteractTip:SetText(InteractTipRow.Info)
end

function WBP_InteractNormalWidget_C:HideWidget()
  UpdateVisibility(self, false)
end

return WBP_InteractNormalWidget_C
