local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityModule = require("Modules.SeasonAbility.SeasonAbilityModule")
local SeasonAbilityHandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")
local WBP_AutoExchangeAbilityPointPanel = Class(ViewBase)
function WBP_AutoExchangeAbilityPointPanel:BindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Add(self, self.BindOnCancelButtonClicked)
end
function WBP_AutoExchangeAbilityPointPanel:UnBindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Remove(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Remove(self, self.BindOnCancelButtonClicked)
end
function WBP_AutoExchangeAbilityPointPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_AutoExchangeAbilityPointPanel:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_AutoExchangeAbilityPointPanel:OnShow(HeroId, ExchangeNum)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.CurHeroId = HeroId
  self.NeedExchangeNum = ExchangeNum
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self:SetEnhancedInputActionBlocking(true)
  local CurExchangePointNum = SeasonAbilityData:GetTotalExchangeAbilityPointNumByHeroId(self.CurHeroId)
  local CurCostResourceNum = 0
  local CostResourceKey = 0
  for i = 1, self.NeedExchangeNum do
    local CurExchangePointRowInfo = SeasonAbilityData:GetExchangeAbilityPointTableRow(CurExchangePointNum + i)
    if CurExchangePointRowInfo then
      CostResourceKey = CurExchangePointRowInfo.ExchangeResource.key
      CurCostResourceNum = CurCostResourceNum + CurExchangePointRowInfo.ExchangeResource.value
    end
  end
  self.Txt_PointNum:SetText(self.NeedExchangeNum)
  self.WBP_CommonItem:InitCommonItem(CostResourceKey, CurCostResourceNum)
  self.WBP_CommonItem:UpdateNumPanelVis(true)
  self.CheckBox_IsAutoExchange:SetIsChecked(false)
end
function WBP_AutoExchangeAbilityPointPanel:BindOnConfirmButtonClicked(...)
  local UpgradeFunction = function(self)
    local PreAbilityList = SeasonAbilityData:GetPreAbilityLevelList()
    local CurEquipSchemeId = SeasonAbilityData:GetCurEquipSchemeId(self.CurHeroId)
    SeasonAbilityHandler:RequestUpgradeSeasonAbilityToServer(self.CurHeroId, CurEquipSchemeId, PreAbilityList)
  end
  SeasonAbilityHandler:RequestExchangeAbilityPointToServer(self.CurHeroId, self.NeedExchangeNum, {self, UpgradeFunction})
  UIMgr:Hide(ViewID.UI_AutoExchangeAbilityPointPanel)
end
function WBP_AutoExchangeAbilityPointPanel:BindOnCancelButtonClicked(...)
  UIMgr:Hide(ViewID.UI_AutoExchangeAbilityPointPanel)
end
function WBP_AutoExchangeAbilityPointPanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  SeasonAbilityModule:SetIsAutoExchangeAbilityPoint(self.CheckBox_IsAutoExchange:IsChecked())
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self:SetEnhancedInputActionBlocking(false)
end
return WBP_AutoExchangeAbilityPointPanel
