local WBP_FunctionalButton_C = UnLua.Class()

function WBP_FunctionalButton_C:Construct()
  self.Btn_Main.OnClicked:Add(self, WBP_FunctionalButton_C.BindOnMainButtonClicked)
end

function WBP_FunctionalButton_C:BindOnMainButtonClicked()
  if self.MainButtonClicked then
    self.MainButtonClicked()
  end
end

function WBP_FunctionalButton_C:RefreshInfo(KeyName, KeyDesc)
  self.Txt_KeyName:SetText(KeyName)
  self.Txt_KeyDesc:SetText(KeyDesc)
end

function WBP_FunctionalButton_C:UpdateKeyDescription(Text)
  self.Txt_KeyDesc:SetText(Text)
end

return WBP_FunctionalButton_C
