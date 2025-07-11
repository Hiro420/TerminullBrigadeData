local WBP_HeirloomCharacterActionItem = UnLua.Class()
function WBP_HeirloomCharacterActionItem:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
end
function WBP_HeirloomCharacterActionItem:Show(ActionRowName, Index)
  UpdateVisibility(self, true)
  self.ActionRowName = ActionRowName
  self.Index = Index
  local Result, RowInfo = GetRowData(DT.DT_CharacterAction, ActionRowName)
  self.Txt_ActionName:SetText(RowInfo.Name)
  self.Txt_ActionTitle:SetText(RowInfo.Title)
  EventSystem.AddListenerNew(EventDef.Heirloom.OnHeirloomHeroSkinActionItemSelected, self, self.BindOnHeirloomHeroSkinActionItemSelected)
end
function WBP_HeirloomCharacterActionItem:BindOnMainButtonClicked(...)
  EventSystem.Invoke(EventDef.Heirloom.OnHeirloomHeroSkinActionItemSelected, self.Index)
end
function WBP_HeirloomCharacterActionItem:BindOnHeirloomHeroSkinActionItemSelected(Index)
  if Index == self.Index then
    self.Txt_ActionName:SetColorAndOpacity(self.NameSelectedColor)
    self.Txt_ActionTitle:SetColorAndOpacity(self.TitleSelectedColor)
    UpdateVisibility(self.Img_Selected, true)
  else
    self.Txt_ActionName:SetColorAndOpacity(self.NameUnSelectedColor)
    self.Txt_ActionTitle:SetColorAndOpacity(self.TitleUnSelectedColor)
    UpdateVisibility(self.Img_Selected, false)
  end
end
function WBP_HeirloomCharacterActionItem:Hide(...)
  UpdateVisibility(self, false)
  self.ActionRowName = ""
  self.Index = -1
  EventSystem.RemoveListenerNew(EventDef.Heirloom.OnHeirloomHeroSkinActionItemSelected, self, self.BindOnHeirloomHeroSkinActionItemSelected)
end
function WBP_HeirloomCharacterActionItem:Destruct(...)
  self:Hide()
end
return WBP_HeirloomCharacterActionItem
