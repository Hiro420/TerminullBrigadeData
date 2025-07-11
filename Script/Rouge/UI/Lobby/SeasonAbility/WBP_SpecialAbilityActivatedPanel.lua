local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_SpecialAbilityActivatedPanel = Class(ViewBase)
function WBP_SpecialAbilityActivatedPanel:BindClickHandler()
end
function WBP_SpecialAbilityActivatedPanel:UnBindClickHandler()
end
function WBP_SpecialAbilityActivatedPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_SpecialAbilityActivatedPanel:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_SpecialAbilityActivatedPanel:OnShow(SpecialAbilityId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  local TargetRowInfo
  local SpecialAbilityTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSpecialAbility)
  for index, SingleRowInfo in ipairs(SpecialAbilityTable) do
    if SingleRowInfo.SpecialAbilityID == SpecialAbilityId then
      TargetRowInfo = SingleRowInfo
      break
    end
  end
  local DA = GetLuaInscription(TargetRowInfo.Inscription)
  SetImageBrushByPath(self.Img_Icon, DA.Icon)
  local name = GetInscriptionName(TargetRowInfo.Inscription)
  local desc = GetLuaInscriptionDesc(TargetRowInfo.Inscription)
  self.Txt_Name:SetText(name)
  self.Txt_Desc:SetText(desc)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.HidePanel)
  self:SetEnhancedInputActionBlocking(true)
  self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end
function WBP_SpecialAbilityActivatedPanel:HidePanel(...)
  UIMgr:Hide(ViewID.UI_SpecialAbilityActivatedPanel)
end
function WBP_SpecialAbilityActivatedPanel:OnPreHide(...)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.HidePanel)
  self:SetEnhancedInputActionBlocking(false)
  self:StopAllAnimations()
end
function WBP_SpecialAbilityActivatedPanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end
function WBP_SpecialAbilityActivatedPanel:Destruct(...)
  self:OnPreHide()
end
return WBP_SpecialAbilityActivatedPanel
