local WBP_IllustratedGuide_C = UnLua.Class()
function WBP_IllustratedGuide_C:Construct()
  self:BlueprintBeginPlay()
end
function WBP_IllustratedGuide_C:AddBtnEvent()
  self.Btn_GenericModify.Btn.OnClicked:Add(self, function()
    self:BindSelectGenericModifyTab()
  end)
end
function WBP_IllustratedGuide_C:BlueprintBeginPlay()
  self:AddBtnEvent()
  self:BindSelectGenericModifyTab()
end
function WBP_IllustratedGuide_C:BindSelectGenericModifyTab()
  self.Btn_GenericModify:ChangeStyle(BtbStyle.Select)
  self.ContentSwitcher:SetActiveWidgetIndex(0)
  self.WBP_IGuide_GenericModify:InitGenericModify()
end
return WBP_IllustratedGuide_C
