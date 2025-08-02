local WBP_MonthCardTipItem = UnLua.Class()
local MonthCardData = require("Modules.MonthCard.MonthCardData")
local PrivilegeData = require("Modules.Privilege.PrivilegeData")

function WBP_MonthCardTipItem:Show(MonthCardId, RemainTime, IsPrivilegeItem)
  UpdateVisibility(self, true)
  local ResourceId = MonthCardData:GetMonthCardResourceId(tonumber(MonthCardId))
  if IsPrivilegeItem then
    ResourceId = PrivilegeData:GetResIdByPrivilegeId(MonthCardId)
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  self.Txt_Name:SetText(RowInfo.Name)
  SetImageBrushByPath(self.Img_Icon, RowInfo.Icon, self.IconSize)
  local Day = math.floor(RemainTime / 86400)
  local Hour = math.floor(RemainTime % 86400 / 3600)
  local Minute = math.floor(RemainTime % 3600 / 60)
  self.RGStateController_TimeLimit:ChangeStatus("Normal")
  local RemainTimeStr
  if Day > 999 then
    RemainTimeStr = NSLOCTEXT("MonthCardItem", "OverDayStr", "999+\229\164\169")
  elseif Day >= 1 then
    RemainTimeStr = UE.FTextFormat(NSLOCTEXT("MonthCardItem", "DayStr", "{0}\229\164\169"), Day)
  elseif Hour >= 1 then
    RemainTimeStr = UE.FTextFormat(NSLOCTEXT("MonthCardItem", "HourStr", "{0}\229\176\143\230\151\182"), Hour)
  else
    RemainTimeStr = UE.FTextFormat(NSLOCTEXT("MonthCardItem", "MinuteStr", "{0}\229\136\134\233\146\159"), Minute)
    self.RGStateController_TimeLimit:ChangeStatus("LessThan")
  end
  self.Txt_RemainTime:SetText(RemainTimeStr)
end

function WBP_MonthCardTipItem:Hide(...)
  UpdateVisibility(self, false)
end

return WBP_MonthCardTipItem
