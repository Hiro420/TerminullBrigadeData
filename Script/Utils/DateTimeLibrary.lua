local DateTimeLibrary = {}
function ConvertTimestampToServerTimeByServerTimeZone(Timestamp)
  local ServerTimeZone = DataMgr.GetServerTimeZone()
  local TimeOffsetSeconds = UE.URGBlueprintLibrary.GetTimeOffsetByTimeZoneId(ServerTimeZone)
  return Timestamp + TimeOffsetSeconds
end
function ConvertTimeStrToServerTimeByServerTimeZone(TimeStr)
  local Result, Date = UE.UKismetMathLibrary.DateTimeFromString(TimeStr, nil)
  local Timestamp = 0
  if Result then
    Timestamp = UE.URGBlueprintLibrary.GetTimestampFromDateTime(Date)
  end
  local ServerTimeZone = DataMgr.GetServerTimeZone()
  local TimeOffsetSeconds = UE.URGBlueprintLibrary.GetTimeOffsetByTimeZoneId(ServerTimeZone)
  local TargetTimestamp = Timestamp - TimeOffsetSeconds
  return TargetTimestamp
end
function ConvertTimeStrToServerTimeStrByServerTimeZone(TimeStr)
  local Timestamp = ConvertTimeStrToServerTimeByServerTimeZone(TimeStr)
  return TimestampToDateTimeText(Timestamp)
end
function GetLocalTimestampByServerTimeZone(...)
  local UTCTimestamp = GetCurrentTimestamp(true)
  local ClientTimeOffset = GetCurrentTimestamp(false) - GetCurrentTimestamp(true)
  local CurTimestamp = ConvertTimestampToServerTimeByServerTimeZone(UTCTimestamp - ClientTimeOffset)
  return CurTimestamp
end
function IsSameDay(Time1, Time2, hours)
  local Timestamp1 = ConvertTimestampToServerTimeByServerTimeZone(Time1) - hours * 3600
  local Timestamp2 = ConvertTimestampToServerTimeByServerTimeZone(Time2) - hours * 3600
  local DateTime1 = UE.URGBlueprintLibrary.MakeDateTimeFromUnixTimestamp(Timestamp1)
  local DateTime2 = UE.URGBlueprintLibrary.MakeDateTimeFromUnixTimestamp(Timestamp2)
  return UE.UKismetMathLibrary.GetDay(DateTime1) == UE.UKismetMathLibrary.GetDay(DateTime2) and UE.UKismetMathLibrary.GetMonth(DateTime1) == UE.UKismetMathLibrary.GetMonth(DateTime2) and UE.UKismetMathLibrary.GetYear(DateTime1) == UE.UKismetMathLibrary.GetYear(DateTime2)
end
return DateTimeLibrary
