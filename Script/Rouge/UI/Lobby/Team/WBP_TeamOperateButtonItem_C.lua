local WBP_TeamOperateButtonItem_C = UnLua.Class()
function WBP_TeamOperateButtonItem_C:Construct()
  SetImageBrushBySoftObject(self.Img_Icon, self.IconSoftObject, self.IconSize)
  self.Txt_Name:SetText(self.Name)
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end
function WBP_TeamOperateButtonItem_C:BindOnMainButtonClicked()
  if self.OnMainButtonClickedFuncList then
    self.OnMainButtonClickedFuncList[2](self.OnMainButtonClickedFuncList[1])
  end
end
function WBP_TeamOperateButtonItem_C:BindOnMainButtonHovered()
  if self.OnMainButtonHoveredFuncList then
    self.OnMainButtonHoveredFuncList[2](self.OnMainButtonHoveredFuncList[1])
  end
  self.Txt_Name:SetColorAndOpacity(self.HoveredColor)
  self.Img_Icon:SetColorAndOpacity(self.HoveredColor.SpecifiedColor)
end
function WBP_TeamOperateButtonItem_C:BindOnMainButtonUnhovered()
  if self.OnMainButtonUnhoveredFuncList then
    self.OnMainButtonUnhoveredFuncList[2](self.OnMainButtonUnhoveredFuncList[1])
  end
  self.Txt_Name:SetColorAndOpacity(self.UnHoveredColor)
  self.Img_Icon:SetColorAndOpacity(self.UnHoveredColor.SpecifiedColor)
end
function WBP_TeamOperateButtonItem_C:SetTxtName(NameParam)
  self.Name = NameParam
  self.Txt_Name:SetText(NameParam)
end
return WBP_TeamOperateButtonItem_C
