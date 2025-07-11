local WBP_JapanCommercialPolicy_C = UnLua.Class()
function WBP_JapanCommercialPolicy_C:Construct()
  self.Btn_Confirm.OnClicked:Add(self, self.ClosePanel)
  self.ExitGameKey.OnMainButtonClicked:Add(self, self.ClosePanel)
  self:PlayAnimation(self.StartAnim)
end
function WBP_JapanCommercialPolicy_C:Destruct()
  self.Btn_Confirm.OnClicked:Remove(self, self.ClosePanel)
  self.ExitGameKey.OnMainButtonClicked:Remove(self, self.ClosePanel)
end
function WBP_JapanCommercialPolicy_C:ClosePanel()
  RGUIMgr:CloseUI(UIConfig.WBP_JapanCommercialPolicy_C.UIName)
end
return WBP_JapanCommercialPolicy_C
