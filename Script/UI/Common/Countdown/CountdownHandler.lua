local DayFmt = NSLOCTEXT("GetCountdownString", "CountdownHandler_DayFmt", "%d\229\164\169")
local Expire = NSLOCTEXT("GetCountdownString", "CountdownHandler_Expire", "\229\164\177\230\149\136")
local HourFmt = NSLOCTEXT("GetCountdownString", "CountdownHandler_HourFmt", "%d\229\176\143\230\151\182")
local MinuteFmt = NSLOCTEXT("GetCountdownString", "CountdownHandler_MinuteFmt", "%d\229\136\134\233\146\159")
local SecondFmt = NSLOCTEXT("GetCountdownString", "CountdownHandler_SecondFmt", "%d\231\167\146")

function GetCountdownString(targetTimestamp)
  local currentTime = os.time()
  local timeDiff = targetTimestamp - currentTime
  if timeDiff <= 0 then
    return tostring(Expire())
  end
  local days = timeDiff / 86400
  local hours = timeDiff / 3600
  local minutes = timeDiff / 60
  local seconds = timeDiff
  if days >= 1 then
    return string.format(tostring(DayFmt()), math.floor(days))
  end
  if hours >= 1 then
    return string.format(tostring(HourFmt()), math.floor(hours))
  end
  if minutes >= 1 then
    return string.format(tostring(MinuteFmt()), math.floor(minutes))
  end
  return string.format(tostring(SecondFmt()), math.floor(seconds))
end
