local WBP_ActivityTitle = UnLua.Class()
function WBP_ActivityTitle:Construct()
  self.Btn_RuleDesc.OnClicked:Add(self, self.BindOnRuleDescButtonClicked)
end
function WBP_ActivityTitle:Show(ActivityId)
  self.ActivityId = ActivityId
  UpdateVisibility(self, true)
  local Result, ActivityRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBActivityGeneral, self.ActivityId)
  if not Result then
    print("WBP_ActivityTitle:Show not found activity row info! Please check TBActivityGeneral!")
    return
  end
  self.Txt_Name:SetText(ActivityRowInfo.name)
  self.Txt_Time:SetText(ActivityRowInfo.openTime)
  self.Txt_Desc:SetText(ActivityRowInfo.desc)
end
function WBP_ActivityTitle:Hide(...)
  UpdateVisibility(self, false)
end
function WBP_ActivityTitle:BindOnRuleDescButtonClicked(...)
  UIMgr:Show(ViewID.UI_ActivityRuleDesc, false, self.ActivityId)
end
return WBP_ActivityTitle
