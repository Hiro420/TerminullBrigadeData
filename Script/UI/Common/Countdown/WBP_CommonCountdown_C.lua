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
