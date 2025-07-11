function GetCountdownString(targetTimestamp)
  local currentTime = os.time()
  local timeDiff = targetTimestamp - currentTime
  if timeDiff <= 0 then
    return "\229\164\177\230\149\136"
  end
  local days = timeDiff / 86400
  local hours = timeDiff / 3600
  local minutes = timeDiff / 60
  local seconds = timeDiff
  if days >= 1 then
    return string.format("%d\229\164\169", math.floor(days))
  end
  if hours >= 1 then
    return string.format("%d\229\176\143\230\151\182", math.floor(hours))
  end
  if minutes >= 1 then
    return string.format("%d\229\136\134\233\146\159", math.floor(minutes))
  end
  return string.format("%d\231\167\146", seconds)
end
