local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityHandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")
local WBP_UnlockSchemePanel = Class(ViewBase)
function WBP_UnlockSchemePanel:BindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Add(self, self.BindOnCancelButtonClicked)
end
function WBP_UnlockSchemePanel:UnBindClickHandler()
  self.Btn_Confirm.OnMainButtonClicked:Remove(self, self.BindOnConfirmButtonClicked)
  self.Btn_Cancel.OnMainButtonClicked:Remove(self, self.BindOnCancelButtonClicked)
end
function WBP_UnlockSchemePanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_UnlockSchemePanel:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_UnlockSchemePanel:OnShow(HeroId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self:SetEnhancedInputActionBlocking(true)
  self.CurHeroId = HeroId
  local TotalUnlockLevel = SeasonAbilityData:GetUnlockedSchemeNum()
  local TargetUnlockLevel = TotalUnlockLevel + 1
  local SchemeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSeasonAbilityPresentScheme)
  self.SchemeRowInfo = nil
  for index, SingleSchemeRowInfo in ipairs(SchemeTable) do
    if SingleSchemeRowInfo.PresentSchemeID == TargetUnlockLevel then
      self.SchemeRowInfo = SingleSchemeRowInfo
      break
    end
  end
  self.Txt_SchemeName:SetText(self.SchemeRowInfo.Name)
  local UnlockResourceInfo = self.SchemeRowInfo.UnlockConsumerResource[1]
  if UnlockResourceInfo then
    UpdateVisibility(self.Img_CostIcon, true)
    UpdateVisibility(self.Txt_CostNum, true)
    local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, UnlockResourceInfo.key)
    if Result then
      SetImageBrushByPath(self.Img_CostIcon, ResourceRowInfo.Icon)
    end
    self.Txt_CostNum:SetText(UnlockResourceInfo.value)
  else
    UpdateVisibility(self.Img_CostIcon, false)
    UpdateVisibility(self.Txt_CostNum, false)
  end
end
function WBP_UnlockSchemePanel:BindOnConfirmButtonClicked(...)
  local UnlockResourceInfo = self.SchemeRowInfo.UnlockConsumerResource[1]
  local CurHaveResourceNum = LogicOutsidePackback.GetResourceNumById(UnlockResourceInfo.key)
  if CurHaveResourceNum < UnlockResourceInfo.value then
    ShowWaveWindow(self.NotEnoughResourceTip)
    UIMgr:Hide(ViewID.UI_UnlockSchemePanel)
    return
  end
  SeasonAbilityHandler:RequestUnlockSchemeToServer(self.CurHeroId)
  UIMgr:Hide(ViewID.UI_UnlockSchemePanel)
end
function WBP_UnlockSchemePanel:BindOnCancelButtonClicked(...)
  UIMgr:Hide(ViewID.UI_UnlockSchemePanel)
end
function WBP_UnlockSchemePanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnCancelButtonClicked)
  self:SetEnhancedInputActionBlocking(false)
  self.SchemeRowInfo = nil
end
return WBP_UnlockSchemePanel
