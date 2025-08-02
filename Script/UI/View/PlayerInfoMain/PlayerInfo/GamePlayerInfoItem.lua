local GamePlayerInfoItem = Class()

function GamePlayerInfoItem:InitGamePlayerInfoItem(BattleStatistic)
  UpdateVisibility(self, true)
  local dataPropertyName = tostring(self.DataPropertyName)
  if tostring(dataPropertyName) == "totalBattleDuration" then
    local value = tostring(math.ceil(tonumber(BattleStatistic[dataPropertyName]) / 3600)) .. "H"
    self.RGTextValue:SetText(value)
  elseif (tostring(dataPropertyName) == "totalHarm" or tostring(dataPropertyName) == "winHardest") and 0 == tonumber(BattleStatistic[dataPropertyName]) then
    self.RGTextValue:SetText("--")
  else
    self.RGTextValue:SetText(BattleStatistic[tostring(dataPropertyName)])
  end
end

function GamePlayerInfoItem:Hide()
  UpdateVisibility(self, false)
end

return GamePlayerInfoItem
