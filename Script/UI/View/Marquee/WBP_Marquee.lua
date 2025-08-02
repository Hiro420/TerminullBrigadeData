local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local BattlePassHandler = require("Protocol.BattlePass.BattlePassHandler")
local PandoraData = require("Modules.Pandora.PandoraData")
local WBP_Marquee = Class(ViewBase)

function WBP_Marquee:OnShow()
end

function WBP_Marquee:OnRollback()
end

function WBP_Marquee:OnHide()
end

function WBP_Marquee:OnDisplay()
end

function WBP_Marquee:OnUnDisplay()
end

function WBP_Marquee:OnFocusInput()
end

function WBP_Marquee:OnUnFocusInput()
end

function WBP_Marquee:InitMarquee()
  UpdateVisibility(self, true)
  self.RichTxt_Marquee:SetText(UE.URGMarqueeSubsystem.Get(GameInstance).CurrentMarqueeData.Content)
end

return WBP_Marquee
