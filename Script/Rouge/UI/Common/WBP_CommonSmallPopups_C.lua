require("UI.Common.CommonPopupTypes")
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local WBP_CommonSmallPopups_C = UnLua.Class()
function WBP_CommonSmallPopups_C:Construct()
  self.WBP_CommonButton_05.OnMainButtonClicked:Add(self, self.OnComButtonClicked)
  self.WBP_CommonButton_06.OnMainButtonClicked:Add(self, self.HidePopups)
  self.WBP_InteractTipWidget_1.OnMainButtonClicked:Add(self, self.HidePopups)
end
function WBP_CommonSmallPopups_C:Destruct()
  self.WBP_CommonButton_05.OnMainButtonClicked:Remove(self, self.OnComButtonClicked)
  self.WBP_CommonButton_06.OnMainButtonClicked:Remove(self, self.HidePopups)
  self.WBP_InteractTipWidget_1.OnMainButtonClicked:Remove(self, self.HidePopups)
end
function WBP_CommonSmallPopups_C:OnShow()
  if not IsListeningForInputAction(self, "PauseGame") then
    ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
      self,
      self.HidePopups
    })
  end
end
function WBP_CommonSmallPopups_C:OnShowLink(PopupTypes, Title, Content, CurrencyId, Num, SkinID)
  if PopupTypes == ECommonSmallPopupTypes.UnlockSchemePanel then
    self:ShowUnlockSchemePanel(Title, Content, CurrencyId, Num, SkinID)
  elseif PopupTypes == ECommonSmallPopupTypes.ControllerConnectionLost then
    self:ShowControllerConnectionLost(Title, Content)
  end
end
function WBP_CommonSmallPopups_C:ShowControllerConnectionLost(Title, Content)
  self:ResetPopup()
  UpdateVisibility(self.ContentPanel_01, true)
  self.Text_Title_04:SetText(Title)
  self.Text_Conten_04:SetText(Content)
end
function WBP_CommonSmallPopups_C:ShowUnlockSchemePanel(Title, Content, CurrencyId, Num, SkinID)
  self.SkinID = SkinID
  self:ResetPopup()
  UpdateVisibility(self.UnlockSchemePanel, true)
  self.Text_Title_03:SetText(Title)
  self.Text_Conten_03:SetText(Content)
  local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, CurrencyId)
  if result then
    SetImageBrushByPath(self.Img_Currency, rowinfo.Icon)
  end
  self.Text_Quantity:SetText(Num)
end
function WBP_CommonSmallPopups_C:HidePopups()
  UIMgr:Hide(ViewID.UI_CommonSmallPopups)
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
end
function WBP_CommonSmallPopups_C:Destruct(...)
end
function WBP_CommonSmallPopups_C:OnComButtonClicked()
  UIMgr:Hide(ViewID.UI_CommonSmallPopups)
  SkinHandler.SendBuyHeroSkin(self.SkinID)
end
function WBP_CommonSmallPopups_C:ResetPopup()
  UpdateVisibility(self.TipsPanel, false)
  UpdateVisibility(self.InputFieldsPanel, false)
  UpdateVisibility(self.UnlockSchemePanel, false)
  UpdateVisibility(self.ContentPanel_01, false)
  UpdateVisibility(self.ContentPanel_02, false)
  UpdateVisibility(self.GetRewarded, false)
end
return WBP_CommonSmallPopups_C
