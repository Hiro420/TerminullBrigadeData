local WBP_JapanFundsPolicy_C = UnLua.Class()

function WBP_JapanFundsPolicy_C:Construct()
  self.Btn_Confirm.OnClicked:Add(self, self.ClosePanel)
  self.ExitGameKey.OnMainButtonClicked:Add(self, self.ClosePanel)
  self:PlayAnimation(self.StartAnim)
end

function WBP_JapanFundsPolicy_C:Destruct()
  self.Btn_Confirm.OnClicked:Remove(self, self.ClosePanel)
  self.ExitGameKey.OnMainButtonClicked:Remove(self, self.ClosePanel)
end

function WBP_JapanFundsPolicy_C:ClosePanel()
  RGUIMgr:CloseUI(UIConfig.WBP_JapanFundsPolicy_C.UIName)
end

return WBP_JapanFundsPolicy_C
