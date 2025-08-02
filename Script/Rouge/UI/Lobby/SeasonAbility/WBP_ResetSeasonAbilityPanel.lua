local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityHandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")
local WBP_ResetSeasonAbilityPanel = Class(ViewBase)

function WBP_ResetSeasonAbilityPanel:BindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Add(self, self.BindOnCancelButtonClicked)
end

function WBP_ResetSeasonAbilityPanel:UnBindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Remove(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Remove(self, self.BindOnCancelButtonClicked)
end

function WBP_ResetSeasonAbilityPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_ResetSeasonAbilityPanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_ResetSeasonAbilityPanel:OnShow(HeroId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.CurHeroId = HeroId
  local Result, HeroRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, self.CurHeroId)
  if Result then
    self.Txt_Desc:SetText(UE.FTextFormat(self.DescText, HeroRowInfo.Name))
  end
  local TotalExchangePointNum = SeasonAbilityData:GetTotalExchangeAbilityPointNumByHeroId(self.CurHeroId)
  self.Txt_PointNum:SetText(TotalExchangePointNum)
  local ResourceId = 0
  local ResourceNum = 0
  for i = 1, TotalExchangePointNum do
    local TargetRowInfo = SeasonAbilityData:GetExchangeAbilityPointTableRow(i)
    if TargetRowInfo then
      ResourceId = TargetRowInfo.ExchangeResource.key
      ResourceNum = ResourceNum + TargetRowInfo.ExchangeResource.value
    end
  end
  self.Txt_ReturnResourceNum:SetText(math.floor(ResourceNum / 2))
  local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if Result then
    SetImageBrushByPath(self.Img_ResourceIcon, ResourceRowInfo.Icon)
  end
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self:SetEnhancedInputActionBlocking(true)
end

function WBP_ResetSeasonAbilityPanel:BindOnConfirmButtonClicked(...)
  SeasonAbilityHandler:RequestResetSeasonAbilityToServer(self.CurHeroId)
  UIMgr:Hide(ViewID.UI_ResetSeasonAbilityPanel)
end

function WBP_ResetSeasonAbilityPanel:BindOnCancelButtonClicked(...)
  UIMgr:Hide(ViewID.UI_ResetSeasonAbilityPanel)
end

function WBP_ResetSeasonAbilityPanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self:SetEnhancedInputActionBlocking(false)
end

return WBP_ResetSeasonAbilityPanel
