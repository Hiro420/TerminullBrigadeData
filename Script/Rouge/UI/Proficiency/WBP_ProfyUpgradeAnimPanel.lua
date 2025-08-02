local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local WBP_ProfyUpgradeAnimPanel = Class(ViewBase)
local HeroIsLockedWaveId = 1141

function WBP_ProfyUpgradeAnimPanel:BindClickHandler()
end

function WBP_ProfyUpgradeAnimPanel:UnBindClickHandler()
  self.Btn_Main.OnMainButtonClicked:Remove(self, self.BindOnMainButtonClicked)
end

function WBP_ProfyUpgradeAnimPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_ProfyUpgradeAnimPanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_ProfyUpgradeAnimPanel:OnShow(HeroId)
  self.CurHeroId = HeroId
  local MaxUnlockLevel = ProficiencyData:GetMaxUnlockProfyLevel(HeroId)
  local MaxLevel = ProficiencyData:GetMaxProfyLevel(HeroId)
  self.Txt_ProfyLevel:SetText(MaxUnlockLevel)
  UpdateVisibility(self.Txt_AllRewardUnlockTip, MaxUnlockLevel >= MaxLevel)
  if MaxUnlockLevel >= MaxLevel then
    local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
    self.Txt_AllRewardUnlockTip:SetText(UE.FTextFormat(self.AllRewardUnlockTipText, RowInfo.Name))
  end
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  self:SetEnhancedInputActionBlocking(true)
  self.Btn_Main.OnMainButtonClicked:Add(self, self.BindOnMainButtonClicked)
end

function WBP_ProfyUpgradeAnimPanel:BindOnMainButtonClicked()
  local IsSystemLock = false
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.HERO_MASTERY) then
    IsSystemLock = true
  end
  if not IsSystemLock then
    if not DataMgr.IsOwnHero(self.CurHeroId) then
      ShowWaveWindow(HeroIsLockedWaveId, {})
    else
      UIMgr:Show(ViewID.UI_DevelopMain, true, 3, self.CurHeroId)
    end
  end
  UIMgr:Hide(ViewID.UI_ProfyUpgradeAnimPanel, false)
end

function WBP_ProfyUpgradeAnimPanel:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_ProfyUpgradeAnimPanel, false)
end

function WBP_ProfyUpgradeAnimPanel:OnPreHide()
  self:UnBindClickHandler()
end

function WBP_ProfyUpgradeAnimPanel:OnHide()
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  self:SetEnhancedInputActionBlocking(false)
end

return WBP_ProfyUpgradeAnimPanel
