local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SeasonAbilityHandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")
local WBP_ChangeSchemeNamePanel = Class(ViewBase)

function WBP_ChangeSchemeNamePanel:BindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Add(self, self.BindOnCancelButtonClicked)
  self.Edit_SchemeName.OnTextChanged:Add(self, self.BindOnSchemeNameTextChanged)
end

function WBP_ChangeSchemeNamePanel:UnBindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Remove(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Remove(self, self.BindOnCancelButtonClicked)
  self.Edit_SchemeName.OnTextChanged:Remove(self, self.BindOnSchemeNameTextChanged)
end

function WBP_ChangeSchemeNamePanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_ChangeSchemeNamePanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_ChangeSchemeNamePanel:OnShow(HeroId, SchemeId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.CurHeroId = HeroId
  self.SchemeId = SchemeId
  self:SetEnhancedInputActionBlocking(true)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
end

function WBP_ChangeSchemeNamePanel:BindOnConfirmButtonClicked(...)
  local Text = tostring(self.Edit_SchemeName:GetText())
  if UE.UKismetStringLibrary.IsEmpty(Text) then
    UIMgr:Hide(ViewID.UI_ChangeSchemeNamePanel)
    return
  end
  SeasonAbilityHandler:RequestRenameSchemeToServer(self.CurHeroId, self.SchemeId, Text)
  UIMgr:Hide(ViewID.UI_ChangeSchemeNamePanel)
end

function WBP_ChangeSchemeNamePanel:BindOnCancelButtonClicked(...)
  UIMgr:Hide(ViewID.UI_ChangeSchemeNamePanel)
end

function WBP_ChangeSchemeNamePanel:BindOnSchemeNameTextChanged(Text)
  local TargetStr = UE.UKismetStringLibrary.Left(Text, 6)
  self.Edit_SchemeName:SetText(TargetStr)
end

function WBP_ChangeSchemeNamePanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.CurHeroId = -1
  self.SchemeId = -1
  self:SetEnhancedInputActionBlocking(false)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
end

return WBP_ChangeSchemeNamePanel
