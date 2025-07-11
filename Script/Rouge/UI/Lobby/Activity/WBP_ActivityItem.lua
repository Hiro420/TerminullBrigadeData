local PandoraModule = require("Modules.Pandora.PandoraModule")
local WBP_ActivityItem = UnLua.Class()
function WBP_ActivityItem:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
end
function WBP_ActivityItem:BindOnMainButtonClicked(...)
  if self.ActivityId and self.ActivityId == 10001 then
    FuncUtil.AddClickStatistics("ActivityRuleInfoMenu")
  end
  EventSystem.Invoke(EventDef.Activity.OnChangeActivityItemSelected, self.ActivityId, self.bByPandora)
end
function WBP_ActivityItem:Show(ActivityId)
  UpdateVisibility(self, true)
  self.ActivityId = ActivityId
  self.bByPandora = false
  local Result, ActivityRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBActivityGeneral, self.ActivityId)
  SetImageBrushByPath(self.Img_Icon, ActivityRowInfo.IconPath)
  self.Txt_Name:SetText(ActivityRowInfo.name)
  UpdateVisibility(self.Overlay_Selected, false)
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.ActivityId)
  EventSystem.AddListenerNew(EventDef.Activity.OnChangeActivityItemSelected, self, self.BindOnChangeActivityItemSelected)
end
function WBP_ActivityItem:ShowByPandora(MsgObj)
  UpdateVisibility(self, true)
  self.ActivityId = MsgObj.appId
  self.bByPandora = true
  self.Txt_Name:SetText(MsgObj.secondTabName)
  if PandoraModule.ActivityInfo and PandoraModule.ActivityInfo[MsgObj.appId] and MsgObj.secondTabIcon then
    local Patn = "/Game/Rouge/UI/Atlas_DT/Activity/ActivityCommon/Frames/%s.%s"
    SetImageBrushByPath(self.Img_Icon, string.format(Patn, MsgObj.secondTabIcon, MsgObj.secondTabIcon))
    UpdateVisibility(self.Img_Icon, true)
  else
    UpdateVisibility(self.Img_Icon, false)
  end
  UpdateVisibility(self.Overlay_Selected, false)
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.ActivityId)
  EventSystem.AddListenerNew(EventDef.Activity.OnChangeActivityItemSelected, self, self.BindOnChangeActivityItemSelected)
end
function WBP_ActivityItem:BindOnChangeActivityItemSelected(ActivityId)
  UpdateVisibility(self.Overlay_Selected, ActivityId == self.ActivityId)
  if ActivityId == self.ActivityId then
    self.ScaleBox_Icon:SetUserSpecifiedScale(1.0)
    self.Img_Icon:SetColorAndOpacity(self.SelectedIconColor)
    self.Txt_Name:SetColorAndOpacity(self.SelectedNameColor)
  else
    self.ScaleBox_Icon:SetUserSpecifiedScale(0.5)
    self.Img_Icon:SetColorAndOpacity(self.NormalIconColor)
    self.Txt_Name:SetColorAndOpacity(self.NormalNameColor)
  end
end
function WBP_ActivityItem:Hide(...)
  UpdateVisibility(self, false)
  EventSystem.RemoveListenerNew(EventDef.Activity.OnChangeActivityItemSelected, self, self.BindOnChangeActivityItemSelected)
end
function WBP_ActivityItem:Destruct(...)
  self:Hide()
end
return WBP_ActivityItem
