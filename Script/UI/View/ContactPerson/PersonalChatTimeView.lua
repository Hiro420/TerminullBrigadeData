local PersonalChatTimeView = UnLua.Class()
function PersonalChatTimeView:Show(Time)
  local CurTime = GetCurrentTimestamp(false)
  local DateTime = UE.URGBlueprintLibrary.MakeDateTimeFromUnixTimestamp(Time)
  local CurDateTime = UE.URGBlueprintLibrary.MakeDateTimeFromUnixTimestamp(CurTime)
  local Minute = UE.UKismetMathLibrary.GetMinute(DateTime)
  local Day = UE.UKismetMathLibrary.GetDayOfYear(DateTime)
  local CurDay = UE.UKismetMathLibrary.GetDayOfYear(CurDateTime)
  if Minute < 10 then
    Minute = "0" .. tostring(Minute)
  end
  local Str = string.format("%d:%s", UE.UKismetMathLibrary.GetHour(DateTime), Minute)
  if Day ~= CurDay then
    Str = string.format("%d\229\185\180%d\230\156\136%d\230\151\165 %s", UE.UKismetMathLibrary.GetYear(DateTime), UE.UKismetMathLibrary.GetMonth(DateTime), UE.UKismetMathLibrary.GetDay(DateTime), Str)
  end
  self.Txt_Time:SetText(Str)
end
return PersonalChatTimeView
