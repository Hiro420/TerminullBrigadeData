local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityHandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")
local WBP_ExchangeAbilityPointPanel = Class(ViewBase)

function WBP_ExchangeAbilityPointPanel:BindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Add(self, self.BindOnCancelButtonClicked)
  self.Btn_Subtract.OnClicked:Add(self, self.BindOnSubtractButtonClicked)
  self.Btn_Add.OnClicked:Add(self, self.BindOnAddButtonClicked)
  self.Btn_Max.OnClicked:Add(self, self.BindOnMaxButtonClicked)
end

function WBP_ExchangeAbilityPointPanel:UnBindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Remove(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Remove(self, self.BindOnCancelButtonClicked)
  self.Btn_Subtract.OnClicked:Remove(self, self.BindOnSubtractButtonClicked)
  self.Btn_Add.OnClicked:Remove(self, self.BindOnAddButtonClicked)
  self.Btn_Max.OnClicked:Remove(self, self.BindOnMaxButtonClicked)
end

function WBP_ExchangeAbilityPointPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_ExchangeAbilityPointPanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_ExchangeAbilityPointPanel:OnShow(HeroId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.CurHeroId = HeroId
  local CurExchangePointNum = SeasonAbilityData:GetTotalExchangeAbilityPointNumByHeroId(self.CurHeroId)
  local MaxPointNum = SeasonAbilityData:GetMaxExchangeAbilityPointNum()
  local CanExchangePointNumByNum = MaxPointNum - CurExchangePointNum
  local MaxCanExchangePointNum = 0
  self.ExchangePointCostList = {}
  local CurCostResourceNum = 0
  local CostResourceKey = 0
  for i = 1, CanExchangePointNumByNum do
    local CurExchangePointRowInfo = SeasonAbilityData.ExchangeAbilityPointTable[CurExchangePointNum + i]
    if CurExchangePointRowInfo then
      CostResourceKey = CurExchangePointRowInfo.ExchangeResource.key
      local CurHaveResourceNum = LogicOutsidePackback.GetResourceNumById(CurExchangePointRowInfo.ExchangeResource.key)
      if CurHaveResourceNum - CurCostResourceNum >= CurExchangePointRowInfo.ExchangeResource.value then
        MaxCanExchangePointNum = MaxCanExchangePointNum + 1
        self.ExchangePointCostList[i] = CurExchangePointRowInfo.ExchangeResource.value
        CurCostResourceNum = CurCostResourceNum + CurExchangePointRowInfo.ExchangeResource.value
      else
        break
      end
    end
  end
  self.WBP_Item:InitItem(CostResourceKey, 0)
  self:SetExchangeNumInfo(0)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self:SetEnhancedInputActionBlocking(true)
end

function WBP_ExchangeAbilityPointPanel:BindOnConfirmButtonClicked(...)
  if self.CurExchangeNum > 0 then
    SeasonAbilityHandler:RequestExchangeAbilityPointToServer(self.CurHeroId, self.CurExchangeNum)
    EventSystem.Invoke(EventDef.SeasonAbility.OnAddAbilityPoint, self.CurExchangeNum)
  end
  UIMgr:Hide(ViewID.UI_ExchangeAbilityPointPanel)
end

function WBP_ExchangeAbilityPointPanel:BindOnCancelButtonClicked(...)
  UIMgr:Hide(ViewID.UI_ExchangeAbilityPointPanel)
end

function WBP_ExchangeAbilityPointPanel:SetExchangeNumInfo(InExchangeNum)
  local MaxExchangeNum = table.count(self.ExchangePointCostList)
  self.CurExchangeNum = math.clamp(InExchangeNum, 0, MaxExchangeNum)
  self.Txt_PointNum:SetText(self.CurExchangeNum)
  self.Txt_Num:SetText(self.CurExchangeNum)
  local CurCostResourceNum = 0
  for i = 1, self.CurExchangeNum do
    CurCostResourceNum = CurCostResourceNum + self.ExchangePointCostList[i]
  end
  self.WBP_Item:InitItem(0, CurCostResourceNum)
end

function WBP_ExchangeAbilityPointPanel:BindOnSubtractButtonClicked(...)
  self:SetExchangeNumInfo(self.CurExchangeNum - 1)
end

function WBP_ExchangeAbilityPointPanel:BindOnAddButtonClicked(...)
  self:SetExchangeNumInfo(self.CurExchangeNum + 1)
end

function WBP_ExchangeAbilityPointPanel:BindOnMaxButtonClicked(...)
  local MaxExchangeNum = table.count(self.ExchangePointCostList)
  self:SetExchangeNumInfo(MaxExchangeNum)
end

function WBP_ExchangeAbilityPointPanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self:SetEnhancedInputActionBlocking(false)
end

return WBP_ExchangeAbilityPointPanel
