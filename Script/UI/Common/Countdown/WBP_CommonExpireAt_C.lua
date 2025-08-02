local WBP_CommonExpireAt_C = UnLua.Class()

function WBP_CommonExpireAt_C:InitCommonExpireAt(ExpireAt)
  if nil == ExpireAt or "" == ExpireAt or "0" == ExpireAt then
    return
  end
  ExpireAt = GetClientTimestampByServerTimestamp(ExpireAt)
  local date = os.date("*t", ExpireAt)
  local str = string.format("%d-%02d-%02d %02d:%02d:%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
  self.Txt_ExpireAt:SetText(str)
  local currentTime = os.time()
  if tonumber(ExpireAt) - currentTime > 90000 then
    self.RGStateController_48:ChangeStatus(">25 hours", true)
  else
    self.RGStateController_48:ChangeStatus("<25 hours", false)
  end
end

return WBP_CommonExpireAt_C
