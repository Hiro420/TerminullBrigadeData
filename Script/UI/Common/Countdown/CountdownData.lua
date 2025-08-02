local CountdownData = {}

function CountdownData:CacheCountdownData(ItemId, TargetTimestamp)
  if not ItemId or not TargetTimestamp then
    return
  end
  self[ItemId] = TargetTimestamp
  if not self[ItemId] then
    self[ItemId] = TargetTimestamp
  elseif self[ItemId] ~= TargetTimestamp and (0 == TargetTimestamp or TargetTimestamp > self[ItemId]) then
    self[ItemId] = TargetTimestamp
    EventSystem:Invoke(EventDef.Lobby.UpdateLimitedResource, ItemId, TargetTimestamp)
  end
end

return CountdownData
