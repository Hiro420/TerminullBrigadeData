local CountdownData = require("UI.Common.Countdown.CountdownData")
local WBP_CommonCountdown_C = UnLua.Class()

function WBP_CommonCountdown_C:Construct()
  print("WBP_CommonCountdown_C:Construct()")
  if self.bUpdateCountdownText == nil then
    self.bUpdateCountdownText = true
  end
end

function WBP_CommonCountdown_C:Destruct()
  print("WBP_CommonCountdown_C:Destruct()")
end

function WBP_CommonCountdown_C:LuaTick(InDeltaTime)
  if self.bUpdateCountdownText then
    self:UpdateCountdownText()
  end
end

function WBP_CommonCountdown_C:SetItemId(ItemId)
  self.ItemId = ItemId
end

function WBP_CommonCountdown_C:SetTargetTimestamp(targetTimestamp)
  self.TargetTimestamp = tonumber(targetTimestamp)
  CountdownData:CacheCountdownData(self.ItemId, targetTimestamp)
  if not self.bUpdateCountdownText then
    self:UpdateCountdownText()
  end
end

function WBP_CommonCountdown_C:SetTargetTimestampById(Id, resourceID)
  local TextDay = NSLOCTEXT("WBP_CommonCountdown_C", "Day", "{0}\229\164\169")
  local TextLimitedTime = NSLOCTEXT("WBP_CommonCountdown_C", "LimitedTime", "\233\153\144\230\151\182")
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTimeLimitGift, Id)
  if result then
    for index, value in ipairs(row.giftPackage) do
      if value.resourceID == resourceID then
        if 1 == value.timeLimitType then
          self.Txt_Countdown:SetText(UE.FTextFormat(TextDay(), value.timeLimitParam))
          break
        end
        if 2 == value.timeLimitType then
          self.Txt_Countdown:SetText(TextLimitedTime())
        end
        break
      end
    end
  end
end

function WBP_CommonCountdown_C:UpdateCountdownText()
  if not self.TargetTimestamp then
    return
  end
  local timeString = GetCountdownString(self.TargetTimestamp)
  self.Txt_Countdown:SetText(timeString)
  if os.time() > self.TargetTimestamp then
    self.TargetTimestamp = nil
    return
  end
  local currentTime = os.time()
  if tonumber(self.TargetTimestamp) - currentTime < 90000 then
    self.RGStateController_color:ChangeStatus("<24")
  else
    self.RGStateController_color:ChangeStatus(">24")
  end
end

return WBP_CommonCountdown_C
