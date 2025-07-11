local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_ActivityRuleDesc = Class(ViewBase)
function WBP_ActivityRuleDesc:BindClickHandler()
end
function WBP_ActivityRuleDesc:UnBindClickHandler()
end
function WBP_ActivityRuleDesc:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_ActivityRuleDesc:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_ActivityRuleDesc:OnShow(ActivityId)
  self.ActivityId = ActivityId
  local Result, ActivityRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBActivityGeneral, self.ActivityId)
  if Result then
    self.RGRichTextBlock_Rule:SetText(ActivityRowInfo.ruleDesc)
  end
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.ListenForEscKeyPressed)
end
function WBP_ActivityRuleDesc:ListenForEscKeyPressed(...)
  UIMgr:Hide(ViewID.UI_ActivityRuleDesc)
end
function WBP_ActivityRuleDesc:OnHide()
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.ListenForEscKeyPressed)
end
function WBP_ActivityRuleDesc:Destruct(...)
  self:OnHide()
end
return WBP_ActivityRuleDesc
